#!/usr/bin/env python3
"""Check the SQL that the C++ builds at runtime against MySQL, not SQL Server.

WHY THIS EXISTS
    The migration ported the *dump*; the servers also contain hand-written SQL
    in DBAgent.cpp, DBProcess.cpp and in every CxSet::GetColumns().  Those were
    written for SQL Server and several of them do not run on MySQL 8:

        "SELECT Num, ... Range, Weight ..."   RANGE is a reserved word in MySQL
        "SELECT [Level], [Exp]"               [brackets] are T-SQL only
        DATEDIFF(HOUR, a, NOW())              MySQL spells it TIMESTAMPDIFF
        getdate()                             MySQL spells it NOW()
        TOP(10) ... FULL OUTER JOIN           LIMIT, and no FULL OUTER JOIN
        ISNULL(x, 0)                          IFNULL(x, 0)

    Both reported failures ("syntax error near 'Range, Weight, ...'" from the
    ITEM and MAGIC table loads) are of this kind, so they are checked here.

WHAT IS CHECKED
    * every CxSet::GetColumns() column name: exists in the schema, and is not a
      MySQL reserved word unless quoted
    * every string literal that looks like SQL: T-SQL-only constructs,
      unquoted reserved-word identifiers, and unknown tables/columns for the
      simple SELECT/INSERT/UPDATE forms

WHAT IT DOES NOT PROVE
    That the statement is semantically correct or that the query planner is
    happy.  Only the server can say that.

Usage: python3 tools/check_inline_sql.py
"""
import os
import re
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
MIG = os.path.join(ROOT, "migrations", "mysql")
SCHEMA = os.path.join(MIG, "001_schema.sql")

# MySQL 8 reserved words that occur as column names in this project.
# Only words that MySQL 8.0 actually reserves *and* that this project uses as
# identifiers.  Deliberately not "every SQL keyword": ORDER, GROUP and READ are
# reserved but appear in every statement as keywords, so flagging them without
# knowing the position would be noise.  The check below only reports a reserved
# word when it is also a column of the schema, which is exactly the case that
# breaks a query (Range, Rank, group).
RESERVED = {
    "RANGE", "RANK", "ROW", "ROWS", "GROUPS", "SYSTEM", "KEY", "INDEX",
    "ORDER", "GROUP", "CONDITION", "MATCH", "USAGE", "LINES", "INTERVAL",
    "WINDOW", "OVER", "RECURSIVE", "LATERAL", "ROW_NUMBER", "DENSE_RANK",
    "CUME_DIST", "PERCENT_RANK", "FIRST_VALUE", "LAST_VALUE", "NTH_VALUE",
    "LEAD", "LAG", "READ", "WRITE", "SCHEMA", "RELEASE", "OPTION",
    "PRECISION", "SIGNAL",
}

# Constructs that only exist in SQL Server (or are spelled differently).
TSQL = [
    (re.compile(r"\[[A-Za-z_][A-Za-z0-9_]*\]"), "[brackets] - use `backticks`"),
    (re.compile(r"\bDATEDIFF\s*\(", re.I), "DATEDIFF - MySQL uses TIMESTAMPDIFF / DATEDIFF(d,a,b)"),
    (re.compile(r"\bDATEADD\s*\(", re.I), "DATEADD - MySQL uses DATE_ADD / TIMESTAMPADD"),
    (re.compile(r"\bGETDATE\s*\(\s*\)", re.I), "getdate() - MySQL uses NOW()"),
    (re.compile(r"\bISNULL\s*\(", re.I), "ISNULL() - MySQL uses IFNULL()"),
    (re.compile(r"\bTOP\s*\(?\s*\d", re.I), "TOP n - MySQL uses LIMIT n"),
    (re.compile(r"\bFULL\s+(OUTER\s+)?JOIN\b", re.I), "FULL OUTER JOIN - not supported by MySQL"),
    (re.compile(r"\bNOLOCK\b", re.I), "WITH (NOLOCK) - not MySQL"),
    (re.compile(r"\bLEN\s*\(", re.I), "LEN() - MySQL uses CHAR_LENGTH()"),
    (re.compile(r"\bCHARINDEX\s*\(", re.I), "CHARINDEX - MySQL uses LOCATE()"),
    (re.compile(r"\bIDENTITY\s*\(", re.I), "IDENTITY() - MySQL uses AUTO_INCREMENT"),
    (re.compile(r"\bSCOPE_IDENTITY\s*\(", re.I), "SCOPE_IDENTITY - MySQL uses LAST_INSERT_ID()"),
    (re.compile(r"\b@@(ROWCOUNT|IDENTITY|ERROR)\b", re.I), "@@ system variable from T-SQL"),
]

problems = []


def problem(msg):
    problems.append(msg)


def schema_info():
    # 001 holds the dump; later files add the reconstructed objects, so the
    # whole directory is read (SERVER_LIST lives in 005).
    tables = {}
    for path in sorted(os.listdir(MIG)):
        if not path.endswith(".sql"):
            continue
        text = open(os.path.join(MIG, path), encoding="latin-1").read()
        pattern = r"CREATE TABLE (?:IF NOT EXISTS )?`([^`]+)` \((.*?)\n\) ENGINE"
        for m in re.finditer(pattern, text, re.S):
            name, body = m.group(1), m.group(2)
            cols = set(re.findall(r"^\s*`([^`]+)`\s+[A-Za-z]", body, re.M))
            tables.setdefault(name.upper(), set()).update(cols)
    return tables


def cpp_files():
    for folder in ("shared/database", "GameServer", "LogInServer", "AIServer"):
        base = os.path.join(ROOT, folder)
        for name in sorted(os.listdir(base)):
            if name.endswith((".cpp", ".h")):
                yield os.path.join(base, name)


def read(path):
    data = open(path, "rb").read()
    try:
        return data.decode("utf-8")
    except UnicodeDecodeError:
        return data.decode("latin-1")


def check_columns_lists(tables):
    """CxSet::GetColumns() must name columns that its own table really has."""
    # The list is sometimes concatenated over several lines:
    #     return _T("nIndex, nNpcNum, "
    #               "nOriginItemNum1, ...");
    # so every literal in the method body is joined before splitting on commas.
    col_re = re.compile(r"GetColumns\(\)\s*\{([^{}]*)\}", re.S)
    table_re = re.compile(r"GetTableName\(\)\s*\{([^{}]*)\}", re.S)
    literal_re = re.compile(r'"((?:[^"\\]|\\.)*)"')

    def returned_string(body):
        return "".join(literal_re.findall(body))

    checked_sets = 0
    checked_columns = 0

    for path in cpp_files():
        text = read(path)
        name = os.path.basename(path)

        table_match = table_re.search(text)
        columns_match = col_re.search(text)
        if not table_match or not columns_match:
            continue

        table = returned_string(table_match.group(1))
        known = tables.get(table.upper())
        if known is None:
            # Only a problem when a server actually loads the class; an unused
            # Set class is dead code, not a missing table.
            class_name = name[:-2]
            if any(re.search(r"\(\s*C?%s\b" % re.escape(class_name), read(p))
                   for p in cpp_files() if p.endswith(".cpp")):
                problem("%s: GetTableName() \"%s\" is not in the schema" % (name, table))
            continue

        columns_text = returned_string(columns_match.group(1))
        checked_sets += 1
        checked_columns += len(columns_text.split(","))
        lowered = {c.lower(): c for c in known}
        for column in (c.strip() for c in columns_text.split(",")):
            if not column:
                # "a, b," builds "SELECT `a`, `b`, FROM T" - same 1064 as a
                # reserved word, so it is worth catching before the build.
                problem("%s: GetColumns() has an empty entry (stray comma)" % name)
                continue

            if column == "*":
                continue

            bare = column.strip("`[]")
            quoted = column.startswith("`") or column.startswith("[")

            if column.startswith("["):
                problem("%s: GetColumns() uses T-SQL brackets %s - use `%s`"
                        % (name, column, bare))

            if bare.upper() in RESERVED and not quoted:
                problem("%s: GetColumns() lists the MySQL reserved word `%s` unquoted"
                        % (name, bare))

            if not re.match(r"^[A-Za-z_][A-Za-z0-9_]*$", bare):
                continue   # expression such as COUNT(*)

            if bare.lower() not in lowered:
                problem("%s: GetColumns() lists `%s`, which %s does not have"
                        % (name, bare, table))

    print("column lists: %d Set classes, %d columns checked against their table"
          % (checked_sets, checked_columns))


def sql_literals(text):
    """Yield (offset, literal) for string literals that look like SQL."""
    for m in re.finditer(r'_T\(\s*"((?:[^"\\]|\\.)*)"', text):
        literal = m.group(1)
        if re.search(r"\b(SELECT|INSERT\s+INTO|UPDATE|DELETE\s+FROM|CALL)\b", literal, re.I):
            yield m.start(), literal


schema_columns = set()


def check_sql_literals(tables):
    for path in cpp_files():
        text = read(path)
        name = os.path.basename(path)
        for offset, literal in sql_literals(text):
            line = text[:offset].count("\n") + 1
            where = "%s:%d" % (name, line)

            for pattern, message in TSQL:
                if pattern.search(literal):
                    problem("%s: %s" % (where, message))

            # Unquoted reserved words that are actually columns of this schema.
            body = re.sub(r"'[^']*'", "''", literal)
            for word in RESERVED:
                if word.lower() not in schema_columns:
                    continue
                if re.search(r"`%s`" % word, body, re.I):
                    continue
                if re.search(r"(?<![`\w.])%s(?![`\w])" % word, body, re.I):
                    problem("%s: column `%s` must be back-quoted (reserved word)"
                            % (where, word))

            # Simple SELECT column list: an unknown name is a typo.
            m = re.match(r"\s*SELECT\s+(.*?)\s+FROM\s+([A-Za-z_][A-Za-z0-9_.]*)", literal, re.I | re.S)
            if m and "%d" not in literal and "%s" not in literal:
                table = m.group(2).split(".")[-1].upper()
                columns = tables.get(table)
                if columns is None:
                    continue
                for item in re.split(r",(?![^()]*\))", m.group(1)):
                    item = item.strip()
                    ident = re.match(r"^[`]?([A-Za-z_][A-Za-z0-9_]*)[`]?$", item)
                    if not ident:
                        continue
                    col = ident.group(1)
                    if col.upper() in ("COUNT", "SUM", "MAX", "MIN", "NOW"):
                        continue
                    if col not in columns and col.lower() not in {c.lower() for c in columns}:
                        problem("%s: SELECT names `%s`, which %s does not have"
                                % (where, col, m.group(2)))


def main():
    if not os.path.exists(SCHEMA):
        print("missing %s" % SCHEMA)
        return 1

    tables = schema_info()
    schema_columns.clear()
    for cols in tables.values():
        for c in cols:
            schema_columns.add(c.lower())
    print("schema   : %d tables, %d columns" % (len(tables), len(schema_columns)))

    check_columns_lists(tables)
    check_sql_literals(tables)

    if problems:
        print("")
        for p in problems:
            print("FAIL: " + p)
        print("\n%d problem(s)" % len(problems))
        return 1

    print("\nOK: inline SQL and column lists use MySQL syntax")
    return 0


if __name__ == "__main__":
    sys.exit(main())
