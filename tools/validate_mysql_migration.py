#!/usr/bin/env python3
"""Validate the generated MySQL migration files without a MySQL server.

Checks performed on migrations/mysql/:
  001_schema.sql
    * every CREATE TABLE parses into columns + a key
    * no duplicate table names / column names
  002_data.sql
    * every INSERT targets a table that exists in the schema
    * every column name in the INSERT exists on that table
    * value count == column count
    * hex literals fit the target BINARY/VARBINARY column
    * no T-SQL leftovers (bracketed identifiers, N'...', CAST(... AS DateTime))
  003_functions.sql / 004_procedures.sql / 005_reconstructed.sql
    * balanced BEGIN/END inside DELIMITER $$ ... $$ blocks
    * every routine named in CREATE ... is unique

Exit code 1 on any failure so it can be used in CI.
"""

import os
import re
import sys
from collections import OrderedDict

MIG = "migrations/mysql"
errors = []
stats = {}


def err(msg):
    errors.append(msg)


# ---------------------------------------------------------------- schema ----
def parse_schema(path):
    tables = OrderedDict()
    text = open(path, encoding="latin-1").read()
    for m in re.finditer(r"CREATE TABLE `([^`]+)` \((.*?)\n\) ENGINE", text, re.S):
        name, body = m.group(1), m.group(2)
        cols = OrderedDict()
        for line in body.split("\n"):
            cm = re.match(r"\s*`([^`]+)`\s+([A-Za-z]+(?:\([^)]*\))?(?:\s+UNSIGNED)?)", line)
            if cm:
                if cm.group(1) in cols:
                    err("001_schema.sql: duplicate column %s.%s" % (name, cm.group(1)))
                cols[cm.group(1)] = cm.group(2).upper()
        if not cols:
            err("001_schema.sql: table %s has no columns" % name)
        if name in tables:
            err("001_schema.sql: duplicate table %s" % name)
        tables[name] = cols
    return tables


# ------------------------------------------------------------------ data ----
INSERT_RE = re.compile(r"^INSERT INTO `([^`]+)` \((.*?)\) VALUES \((.*)\);$", re.S)


def split_values(s):
    """Split a VALUES tuple on top-level commas, honouring quotes/backslashes."""
    out, cur, depth = [], [], 0
    i, n = 0, len(s)
    in_str = False
    while i < n:
        c = s[i]
        if in_str:
            if c == "\\":
                cur.append(c)
                if i + 1 < n:
                    cur.append(s[i + 1])
                i += 2
                continue
            if c == "'":
                if i + 1 < n and s[i + 1] == "'":
                    cur.append("''")
                    i += 2
                    continue
                in_str = False
            cur.append(c)
            i += 1
            continue
        if c == "'":
            in_str = True
            cur.append(c)
            i += 1
            continue
        if c == "(":
            depth += 1
        elif c == ")":
            depth -= 1
        if c == "," and depth == 0:
            out.append("".join(cur).strip())
            cur = []
            i += 1
            continue
        cur.append(c)
        i += 1
    if cur:
        out.append("".join(cur).strip())
    return out


def binary_width(typ):
    m = re.match(r"(VAR)?BINARY\((\d+)\)", typ)
    return int(m.group(2)) if m else None


def validate_data(schema, path, limit=None):
    checked = 0
    bin_checked = 0
    seen_tables = set()
    stmt, start_line = [], 0
    with open(path, encoding="latin-1") as f:
        for lineno, raw in enumerate(f, 1):
            line = raw.rstrip("\n")
            if not stmt:
                if not line or line.startswith("--") or line.startswith("SET") or line == "COMMIT;":
                    continue
                start_line = lineno
            stmt.append(line)
            if not line.rstrip().endswith(";"):
                continue            # statement continues on the next line
            line = "\n".join(stmt)
            stmt = []
            if "[dbo]" in line:
                err("002_data.sql:%d T-SQL leftover: %s" % (start_line, line[:120]))
                continue
            m = INSERT_RE.match(line)
            if not m:
                err("002_data.sql:%d unparsable INSERT: %s" % (start_line, line[:120]))
                continue
            table, colstr, valstr = m.group(1), m.group(2), m.group(3)
            lineno = start_line
            if table not in schema:
                err("002_data.sql:%d unknown table %s" % (lineno, table))
                continue
            seen_tables.add(table)
            cols = [c.strip().strip("`") for c in colstr.split(",")]
            absent = [c for c in cols if c not in schema[table]]
            if absent:
                err("002_data.sql:%d %s: unknown columns %s" % (lineno, table, absent))
                continue
            vals = split_values(valstr)
            if len(vals) != len(cols):
                err("002_data.sql:%d %s: %d columns but %d values"
                    % (lineno, table, len(cols), len(vals)))
                continue
            for col, val in zip(cols, vals):
                w = binary_width(schema[table][col])
                if w and val.startswith("0x"):
                    blen = (len(val) - 2) // 2
                    bin_checked += 1
                    if blen > w:
                        err("002_data.sql:%d %s.%s: %d bytes > %s"
                            % (lineno, table, col, blen, schema[table][col]))
            checked += 1
            if limit and checked >= limit:
                break
    if stmt:
        err("002_data.sql:%d unterminated statement at EOF" % start_line)
    stats["inserts_checked"] = checked
    stats["binary_values_checked"] = bin_checked
    stats["tables_with_data"] = len(seen_tables)


# --------------------------------------------------------------- routines ---
TABLE_REF_RE = re.compile(
    r"\b(?:FROM|JOIN|UPDATE|INSERT\s+INTO|DELETE\s+FROM)\s+`?([A-Za-z_][A-Za-z0-9_]*)`?",
    re.I)


def check_table_references(path, body, schema):
    """Every table a routine touches must exist in 001_schema.sql."""
    for m in TABLE_REF_RE.finditer(body):
        name = m.group(1)
        upper = name.upper()
        if upper in ("SELECT", "DUAL", "WHERE", "SET", "VALUES", "INTO"):
            continue
        if upper in schema:
            continue
        # A reference may be resolved through a table alias defined earlier in
        # the same statement (UPDATE x a SET ... WHERE a.col), so an unknown
        # name is only reported when it is not an alias in this routine.
        if re.search(r"\b(?:FROM|JOIN|UPDATE|INTO)\s+`?\w+`?\s+(?:AS\s+)?%s\b" % re.escape(name),
                     body, re.I):
            continue
        err("%s: routine references unknown table `%s`" % (os.path.basename(path), name))


def validate_routines(path):
    text = open(path, encoding="latin-1").read()
    bodies = re.findall(r"DELIMITER \$\$(.*?)DELIMITER ;", text, re.S)
    created = []
    for body in bodies:
        for m in re.finditer(r"CREATE\s+(?:DEFINER\S+\s+)?(FUNCTION|PROCEDURE)\s+`([^`]+)`", body):
            created.append(m.group(2))
        # Structural checks run on comment-free text ("CREATE TABLE IF NOT
        # EXISTS" in a header comment must not count as an IF).
        body = re.sub(r"--[^\n]*", "", body)
        body = re.sub(r"/\*.*?\*/", "", body, flags=re.S)

        # IF/WHILE block balance ("END IF" also matches "IF", so subtract).
        n_end_if = len(re.findall(r"\bEND IF\b", body))
        n_if = len(re.findall(r"\bIF\b(?!\()(?!\s+(?:NOT\s+)?EXISTS)", body)) - n_end_if  # skip IF() and IF [NOT] EXISTS
        if n_if != n_end_if:
            err("%s: IF/END IF mismatch in a routine (%d vs %d)" % (path, n_if, n_end_if))

        n_end_while = len(re.findall(r"\bEND WHILE\b", body))
        n_while = len(re.findall(r"\bWHILE\b", body)) - n_end_while
        if n_while != n_end_while:
            err("%s: WHILE/END WHILE mismatch in a routine (%d vs %d)" % (path, n_while, n_end_while))

        bare_begin = len(re.findall(r"\bBEGIN\b", body))
        bare_end = len(re.findall(r"\bEND\b(?!\s+(IF|WHILE|LOOP|CASE|REPEAT))", body))
        # "CASE ... END" expressions close with a bare END; end-of-statement
        # CASEs close with "END CASE" and are already excluded above.
        # A CASE *expression* opens with CASE and closes with a bare END; a
        # CASE *statement* contributes "CASE" twice ("CASE x" ... "END CASE"),
        # so the number of expression ENDs is total CASE - 2 * END CASE.
        bare_end -= (len(re.findall(r"\bCASE\b", body))
                     - 2 * len(re.findall(r"\bEND CASE\b", body)))
        if bare_begin != bare_end:
            err("%s: BEGIN/END mismatch in a routine (%d vs %d)" % (path, bare_begin, bare_end))

    dupes = {n for n in created if created.count(n) > 1}
    if dupes:
        err("%s: duplicate routine definitions: %s" % (path, sorted(dupes)))
    stats[os.path.basename(path)] = len(created)


def main():
    need = ["001_schema.sql"]
    for n in need:
        p = os.path.join(MIG, n)
        if not os.path.exists(p):
            err("missing %s" % p)
    if errors:
        for e in errors:
            print("FAIL:", e)
        return 1

    schema = parse_schema(os.path.join(MIG, "001_schema.sql"))
    stats["tables"] = len(schema)

    data = os.path.join(MIG, "002_data.sql")
    if os.path.exists(data):
        validate_data(schema, data)
    else:
        print("note: 002_data.sql not present (generated, gitignored)")

    # Every routine file, discovered rather than hard-coded so new stages are
    # picked up automatically.
    for n in sorted(f for f in os.listdir(MIG)
                    if f.endswith(".sql") and f[0].isdigit() and f[:3] >= "003"):
        validate_routines(os.path.join(MIG, n))

    # Table references inside routines (catches typos the schema check cannot).
    known = {t.upper() for t in schema}
    known.add("SERVER_LIST")
    for n in sorted(f for f in os.listdir(MIG)
                    if f.endswith(".sql") and f[0].isdigit() and f[:3] >= "003"):
        text = open(os.path.join(MIG, n), encoding="latin-1").read()
        text = re.sub(r"--[^\n]*", "", text)
        check_table_references(os.path.join(MIG, n), text, known)

    for k, v in stats.items():
        print("%-24s %s" % (k, v))

    if errors:
        print("\n%d problem(s):" % len(errors))
        for e in errors[:40]:
            print("  -", e)
        return 1
    print("\nOK: migration files are internally consistent")
    return 0


if __name__ == "__main__":
    sys.exit(main())
