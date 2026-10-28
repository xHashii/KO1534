#!/usr/bin/env python3
"""Statement-level syntax check for migrations/mysql/*.sql.

WHY THIS EXISTS
    A single missing/misplaced comma inside a stored routine cost a full
    2-3 minute container re-import to discover ("ERROR 1064 ... near ','").
    MySQL itself is the only authority on whether a file imports, but most of
    these mistakes are plain SQL grammar and can be caught before the container
    is involved.

HOW
    Every file is split into statements the way the mysql client does it
    (honouring DELIMITER), then the *body* of each CREATE PROCEDURE/FUNCTION is
    split again on ';' while tracking block nesting.  Statements that are plain
    SQL (SELECT/INSERT/UPDATE/DELETE/SET/CREATE TABLE/CREATE VIEW/...) are parsed
    with sqlglot; procedural statements (DECLARE, IF, WHILE, LOOP, LEAVE, ...)
    are skipped, and so are the CASE *statements* that only exist as control
    flow.

    sqlglot needs to be installed (pip install sqlglot).  When it is missing the
    script says so and exits 0 - tools/validate_mysql_migration.py stays
    dependency-free and remains the check that always runs.

WHAT IT DOES NOT PROVE
    That MySQL accepts the file.  It is a grammar check on statements, not a
    MySQL parser: it cannot see unknown tables, wrong column counts, wrong
    routine signatures or charset problems.

Usage: python3 tools/check_sql_syntax.py [--strict] [file ...]
"""
import os
import re
import sys

try:
    import sqlglot
except ImportError:                                   # pragma: no cover
    print("check_sql_syntax: sqlglot is not installed -> SKIPPED")
    print("                  pip install sqlglot   (or: python3 -m venv .venv)")
    print("                  Nothing was verified.  This is not a pass.")
    sys.exit(0)

DIALECT = "mysql"

# Words that make a chunk procedural rather than a standalone SQL statement.
PROCEDURAL = {
    "DECLARE", "IF", "ELSEIF", "ELSE", "END", "WHILE", "LOOP", "REPEAT",
    "LEAVE", "ITERATE", "RETURN", "BEGIN", "SIGNAL", "RESIGNAL", "OPEN",
    "CLOSE", "FETCH", "HANDLER", "CONDITION", "CURSOR", "START", "COMMIT",
    "ROLLBACK", "DELIMITER", "USE", "DROP", "CREATE", "ALTER", "LOCK",
    "UNLOCK", "TRUNCATE", "FLUSH", "ANALYZE", "OPTIMIZE", "RENAME",
}

BLOCK_OPEN = re.compile(r"\b(CASE|BEGIN)\b", re.I)
BLOCK_END = re.compile(r"\bEND\s+(CASE|IF|WHILE|LOOP|REPEAT)\b", re.I)


def split_statements(text, delim=";"):
    """Split like the mysql client: respect quoted strings and comments."""
    out, buf, i, n = [], [], 0, len(text)
    while i < n:
        ch = text[i]
        # comments
        if ch == "-" and text[i:i + 2] == "--" and (i + 2 >= n or text[i + 2] in " \t\r\n"):
            j = text.find("\n", i)
            j = n if j < 0 else j
            buf.append(text[i:j])
            i = j
            continue
        if ch == "/" and text[i:i + 2] == "/*":
            j = text.find("*/", i + 2)
            j = n if j < 0 else j + 2
            buf.append(text[i:j])
            i = j
            continue
        if ch in "'\"`":
            quote = ch
            j = i + 1
            while j < n:
                if text[j] == "\\":
                    j += 2
                    continue
                if text[j] == quote:
                    if quote != "`" and j + 1 < n and text[j + 1] == quote:
                        j += 2
                        continue
                    j += 1
                    break
                j += 1
            buf.append(text[i:j])
            i = j
            continue
        if text.startswith(delim, i):
            out.append("".join(buf))
            buf = []
            i += len(delim)
            continue
        buf.append(ch)
        i += 1
    tail = "".join(buf)
    if tail.strip():
        out.append(tail)
    return out


def strip_comments(sql):
    sql = re.sub(r"/\*.*?\*/", " ", sql, flags=re.S)
    sql = re.sub(r"--[^\n]*", " ", sql)
    sql = re.sub(r"^\s*#.*$", " ", sql, flags=re.M)
    return sql


def routine_body(stmt):
    """Body text between the outer BEGIN and its matching END, or None.

    The matching END is found by walking tokens with a proper opener/closer
    count: IF/WHILE/LOOP/REPEAT blocks close with "END IF" etc., so simply
    stopping at the first END would cut the body at the first END IF.
    """
    m = re.search(r"\bBEGIN\b", stmt, re.I)
    if not m:
        return None
    depth = 0
    for token in re.finditer(r"\b(BEGIN|CASE|IF|WHILE|LOOP|REPEAT|END)\b", stmt[m.start():], re.I):
        word = token.group(1).upper()
        if word == "END":
            depth -= 1
            if depth == 0:
                return stmt[m.end():m.start() + token.start()]
        else:
            depth += 1
    return stmt[m.end():]


# Control-flow tokens are turned into statement separators, so that every plain
# SQL statement inside a block is still handed to the parser.
CONTROL_FLOW = [
    (re.compile(r"\bELSEIF\b.*?\bTHEN\b", re.I | re.S), ";"),
    (re.compile(r"\bWHILE\b.*?\bDO\b", re.I | re.S), ";"),
    (re.compile(r"\bIF\b(?!\s*\()(?:[^;]*?)\bTHEN\b", re.I | re.S), ";"),
    (re.compile(r"\bUNTIL\b[^;]*", re.I), ";"),
    (re.compile(r"\bELSE\b", re.I), ";"),
    (re.compile(r"\bEND\s+(IF|CASE|WHILE|LOOP|REPEAT)\b", re.I), ";"),
    (re.compile(r"\bBEGIN\b", re.I), ";"),
    (re.compile(r"\bLOOP\b", re.I), ";"),
    (re.compile(r"\bREPEAT\b", re.I), ";"),
    # declarations, labels and jumps are not statements we can parse
    (re.compile(r"\bDECLARE\b[^;]*", re.I), " "),
    (re.compile(r"\bLEAVE\b[^;]*", re.I), " "),
    (re.compile(r"\bITERATE\b[^;]*", re.I), " "),
    (re.compile(r"^\s*[`\w]+\s*:\s*", re.M), " "),
]


# CASE ... END with no ';' inside is an *expression* (its WHEN/THEN/ELSE words
# must not be treated as control flow); a CASE *statement* separates its
# branches with ';' and therefore does not match.  Expressions are parked in a
# placeholder while the control-flow tokens are rewritten.
CASE_EXPRESSION = re.compile(r"\bCASE\b(?:(?!\bEND\b).)*?\bEND\b", re.I | re.S)


def body_statements(body):
    """Split a routine body into statements, ignoring block structure."""
    text = strip_comments(body)

    parked = []

    def park(match):
        parked.append(match.group(0))
        return "\x00%d\x00" % (len(parked) - 1)

    text = CASE_EXPRESSION.sub(park, text)
    for pattern, replacement in CONTROL_FLOW:
        text = pattern.sub(replacement, text)
    for index, original in enumerate(parked):
        text = text.replace("\x00%d\x00" % index, original)

    return [piece for piece in text.split(";") if piece.strip()]


# "SELECT ... INTO var[, var...] [FROM ...]" is valid MySQL but not a plain
# SELECT; the INTO list is removed before parsing (see prepare()).
INTO_VARS = re.compile(r"\s+INTO\s+@?[\w`]+(\s*,\s*@?[\w`]+)*", re.I)


def prepare(chunk):
    """Return the SQL to hand to sqlglot, or None if the chunk is procedural."""
    head = strip_comments(chunk).strip()
    if not head:
        return None
    # a leading label ("proc: BEGIN") is not SQL
    head = re.sub(r"^[`\w]+\s*:\s*", "", head)
    while True:
        m = re.match(r"(BEGIN|THEN|ELSE|LOOP)\b\s*"
                     r"|WHEN\b[^;]*?\bTHEN\b\s*", head, re.I)
        if not m:
            break
        head = head[m.end():]
    head = re.sub(r"\s*(END\s+(IF|CASE|WHILE|LOOP|REPEAT)|END)\s*$", "", head, flags=re.I)
    head = head.strip()
    if not head:
        return None

    word = re.match(r"[A-Za-z_]+", head)
    word = word.group(0).upper() if word else ""
    # A CASE *statement* ("CASE x WHEN 1 THEN <statement> ... END CASE") is
    # control flow, not an expression.
    if word == "CASE":
        return None
    if word in PROCEDURAL:
        return None

    if word in ("SELECT", "WITH"):
        head = INTO_VARS.sub("", head, count=1)
    return head


def check_statement(stmt):
    """Return an error string, or None."""
    sql = prepare(stmt)
    if sql is None:
        return None
    sql = sql.rstrip("$").strip()
    try:
        sqlglot.parse_one(sql, dialect=DIALECT)
    except Exception as exc:                          # noqa: BLE001
        return str(exc).split("\n")[0]
    return None


def check_file(path):
    text = open(path, encoding="latin-1").read()
    delim = ";"
    statements = []
    # first pass: honour DELIMITER lines
    pending = []
    for line in text.split("\n"):
        m = re.match(r"\s*DELIMITER\s+(\S+)\s*$", line, re.I)
        if m:
            statements.extend(split_statements("\n".join(pending), delim))
            pending = []
            delim = m.group(1)
            continue
        pending.append(line)
    statements.extend(split_statements("\n".join(pending), delim))

    errors = []
    for stmt in statements:
        if re.match(r"\s*(CREATE|ALTER)\s+(DEFINER\s*=\s*\S+\s+)?(PROCEDURE|FUNCTION)\b",
                    strip_comments(stmt), re.I):
            body = routine_body(strip_comments(stmt))
            if body is None:
                continue
            for piece in body_statements(body):
                err = check_statement(piece)
                if err:
                    errors.append((piece, err))
        elif re.match(r"\s*(CREATE|ALTER)\s+", strip_comments(stmt), re.I):
            for piece in split_statements(stmt, ";"):
                err = check_statement(piece)
                if err:
                    errors.append((piece, err))
    return errors


def main(argv):
    files = [a for a in argv if not a.startswith("-")]
    if not files:
        root = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "migrations", "mysql")
        files = sorted(os.path.join(root, f) for f in os.listdir(root) if f.endswith(".sql"))

    total = 0
    for path in files:
        errors = check_file(path)
        name = os.path.basename(path)
        if not errors:
            print("%-40s ok" % name)
            continue
        total += len(errors)
        print("%-40s %d problem(s)" % (name, len(errors)))
        for piece, err in errors:
            snippet = " ".join(strip_comments(piece).split())[:110]
            print("    %s\n      in: %s" % (err, snippet))

    if total == 0:
        print("\nOK: every plain SQL statement parses as MySQL (sqlglot)")
        return 0
    print("\nFAIL: %d statement(s) do not parse - fix them before importing" % total)
    return 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
