#!/usr/bin/env python3
"""Generate MySQL 8.4 migration files from the *unmodified* KO1534_sql.zip.

The SQL Server dump is read straight out of the zip (it is never modified and
never extracted into the repository). The tool emits:

    migrations/mysql/001_schema.sql   -- 104 tables, MySQL 8.4 / InnoDB / utf8mb4
    migrations/mysql/002_data.sql     -- every INSERT from the dump
    migrations/mysql/REPORT.md        -- conversion report + fidelity checks

Stored procedures, functions and the view are *not* auto-translated: they are
extracted to a scratch directory (--routines-dir) and ported by hand into
003_functions.sql / 004_procedures.sql / 005_reconstructed.sql.

Usage:
    python3 tools/sqlserver_to_mysql.py [--zip KO1534_sql.zip]
                                       [--out migrations/mysql]
                                       [--routines-dir DIR]
                                       [--check]
"""

import argparse
import gzip
import shutil
import io
import os
import re
import sys
import zipfile
from collections import Counter, OrderedDict, defaultdict

# --------------------------------------------------------------------------
# Type mapping.  Key: SQL Server type (lower case).  Value: callable(len)->MySQL
# --------------------------------------------------------------------------

def _int_type(_):
    return "INT"

def _identity_type(_):
    return "INT"

TYPES = {
    "int":              _int_type,
    "bigint":           lambda _: "BIGINT",
    "smallint":         lambda _: "SMALLINT",
    # T-SQL tinyint is unsigned 0..255 (Authority uses 255 for bans).
    "tinyint":          lambda _: "TINYINT UNSIGNED",
    "bit":              lambda _: "TINYINT(1)",
    "float":            lambda _: "DOUBLE",
    "real":             lambda _: "FLOAT",
    "datetime":         lambda _: "DATETIME(3)",
    "smalldatetime":    lambda _: "DATETIME",
    "date":             lambda _: "DATE",
    "text":             lambda _: "TEXT",
    "ntext":            lambda _: "TEXT",
    "image":            lambda _: "LONGBLOB",
    "money":            lambda _: "DECIMAL(19,4)",
    "smallmoney":       lambda _: "DECIMAL(10,4)",
    "timestamp":        lambda _: "VARBINARY(8)",
    "uniqueidentifier": lambda n: "CHAR(36)",
}

# Fixed-width binary columns wider than this become VARBINARY (MySQL BINARY()
# is limited to 255 bytes).
BINARY_MAX = 255

# Deliberate schema widening: the server serialises 74 inventory slots
# (INVENTORY_TOTAL = 14 equipped + 28 inventory + 8 cospre + 24 magic bag) but
# the SQL Server schema only stored 73.  SQL Server silently truncated the last
# slot on every save; under MySQL strict mode the same write is a hard error.
# Columns declared as varchar in SQL Server but written/read by the server as
# opaque binary payloads (SQL_BINARY parameter binding).  Under utf8mb4 a
# varchar would reject/replace arbitrary bytes, so these become VARBINARY.
BINARY_OVERRIDES = {
    ("USERDATA", "strSkill"):                "VARBINARY(10)",
    ("USERDATA_SKILLSHORTCUT", "strSkillData"): "VARBINARY(260)",
}

WIDEN = {
    ("USERDATA", "strItem"):      592,   # 74 * 8
    ("USERDATA", "strSerial"):    592,   # 74 * 8
    ("USERDATA", "strUserSeal"):  296,   # 74 * 4
    ("USERDATA", "strItemTime"):  296,   # 74 * 4
}

# The original database is byte oriented (SQL Server varchar + CP1252
# collation).  The dump pads strings with byte 0xA0 and stores opaque binary
# payloads in varchar columns, so the MySQL port keeps the same 1:1 byte
# semantics by using MySQL's latin1 (every byte 0x00-0xFF is valid, PAD SPACE,
# case insensitive - the closest match to SQL_Latin1_General_CP1_CI_AS).
# Any other charset would re-encode the 159k 0xA0-padded values.
CHARSET = "latin1"
COLLATE = "latin1_general_ci"


# --------------------------------------------------------------------------
# Dump reading
# --------------------------------------------------------------------------

def read_dump(zip_path):
    with zipfile.ZipFile(zip_path) as z:
        names = [n for n in z.namelist() if n.lower().endswith(".sql")]
        if not names:
            raise SystemExit("no .sql inside %s" % zip_path)
        raw = z.read(names[0])
    if raw[:2] in (b"\xff\xfe", b"\xfe\xff"):
        text = raw.decode("utf-16")
    else:
        text = raw.decode("utf-8-sig")
    return text.replace("\r\n", "\n").replace("\r", "\n")


def split_batches(text):
    batch, out = [], []
    for line in text.split("\n"):
        if line.strip().upper() == "GO":
            body = "\n".join(batch).strip()
            if body:
                out.append(body)
            batch = []
        else:
            batch.append(line)
    body = "\n".join(batch).strip()
    if body:
        out.append(body)
    return out


def split_sql_segments(text):
    """Split a batch at top-level INSERT statements, ignoring quotes/comments."""
    segs, start = [], None
    i, n = 0, len(text)
    in_str = False
    in_comment = False
    while i < n:
        c = text[i]
        if in_comment:
            if c == "\n":
                in_comment = False
            i += 1
            continue
        if in_str:
            if c == "'":
                if i + 1 < n and text[i + 1] == "'":
                    i += 2
                    continue
                in_str = False
            i += 1
            continue
        # not in string/comment
        if c == "-" and text.startswith("--", i):
            in_comment = True
            i += 2
            continue
        if c == "/" and text.startswith("/*", i):
            end = text.find("*/", i + 2)
            i = (end + 2) if end != -1 else n
            continue
        if c == "'":
            in_str = True
            i += 1
            continue
        if text.startswith("INSERT", i) and (i == 0 or not (text[i-1].isalnum() or text[i-1] == "_")) \
                and re.match(r"INSERT\s+\[", text[i:i + 40], re.I):
            if start is not None:
                segs.append(text[start:i])
            start = i
            i += 6
            continue
        i += 1
    if start is not None:
        segs.append(text[start:])
    return [s.strip() for s in segs if s.strip()]


def strip_comments(text):
    out, i, n = [], 0, len(text)
    in_str = False
    while i < n:
        c = text[i]
        if in_str:
            out.append(c)
            if c == "'":
                if i + 1 < n and text[i + 1] == "'":
                    out.append("'")
                    i += 2
                    continue
                in_str = False
            i += 1
            continue
        if c == "'":
            in_str = True
            out.append(c)
            i += 1
            continue
        if text.startswith("--", i):
            while i < n and text[i] != "\n":
                i += 1
            continue
        if text.startswith("/*", i):
            end = text.find("*/", i + 2)
            i = (end + 2) if end != -1 else n
            continue
        out.append(c)
        i += 1
    return "".join(out)


def first_statement(text):
    for line in strip_comments(text).split("\n"):
        s = line.strip()
        if s:
            return s
    return ""


# --------------------------------------------------------------------------
# CREATE TABLE
# --------------------------------------------------------------------------

COL_RE = re.compile(
    r"^\[(?P<name>[^\]]+)\]\s+\[(?P<type>[a-z_]+)\]\s*"
    r"(?:\(\s*(?P<len>[0-9,\s]+?)\s*\))?"
    r"(?P<rest>.*)$", re.I)


def parse_create_table(batch):
    head = re.search(r"CREATE TABLE \[dbo\]\.\[([^\]]+)\]\s*\(", batch, re.I)
    if not head:
        return None
    table = head.group(1)
    body = batch[head.end():]

    # strip trailing "ON [PRIMARY]" / "TEXTIMAGE_ON ..." and the closing paren
    body = re.sub(r"\)\s*(WITH\s*\(.*?\)\s*)?(TEXTIMAGE_ON\s*\[[^\]]+\]\s*)?"
                  r"(ON\s*\[[^\]]+\]\s*)?$", ")", body, flags=re.S | re.I)

    cols, pk, uniques = [], [], []
    # primary key / unique constraints can span lines
    for m in re.finditer(r"CONSTRAINT\s+\[[^\]]+\]\s+(PRIMARY KEY|UNIQUE)\s+"
                         r"(?:CLUSTERED|NONCLUSTERED)?\s*\((.*?)\)\s*"
                         r"(?:WITH\s*\(.*?\)\s*)?(?:ON\s*\[[^\]]+\]\s*)?", body, re.S | re.I):
        names = [n.strip() for n in re.findall(r"\[([^\]]+)\]", m.group(2))]
        if m.group(1).upper().startswith("PRIMARY"):
            pk = names
        else:
            uniques.append(names)
    body = re.sub(r"CONSTRAINT\s+\[[^\]]+\]\s+(PRIMARY KEY|UNIQUE)[^,]*?(?=(,\s*\[|\)\s*$))",
                  "", body, flags=re.S | re.I)

    for raw_line in body.split("\n"):
        line = raw_line.strip().rstrip(",")
        if not line.startswith("["):
            continue
        m = COL_RE.match(line)
        if not m:
            continue
        rest = m.group("rest")
        ident = bool(re.search(r"\bIDENTITY\s*\(", rest, re.I))
        not_null = bool(re.search(r"\bNOT\s+NULL\b", rest, re.I))
        default = None
        dm = re.search(r"\bDEFAULT\s+(.+?)(?:\s+CONSTRAINT\b|$)", rest, re.I)
        if dm:
            default = dm.group(1).strip()
            while default.startswith("(") and default.endswith(")"):
                default = default[1:-1].strip()
        cols.append(dict(name=m.group("name"), type=m.group("type").lower(),
                         length=(m.group("len") or "").replace(" ", ""),
                         identity=ident, not_null=not_null, default=default))
    return dict(table=table, cols=cols, pk=pk, uniques=uniques)


def convert_default(value):
    if value is None:
        return None
    v = value.strip()
    if re.fullmatch(r"-?\d+(\.\d+)?", v):
        return v
    if re.fullmatch(r"\(+\s*-?\d+\s*\)+", v):
        return re.sub(r"[()\s]", "", v)
    if re.fullmatch(r"getdate\(\)|getutcdate\(\)", v, re.I):
        return "CURRENT_TIMESTAMP(3)"
    m = re.fullmatch(r"N?'((?:[^']|'')*)'", v)
    if m:
        return "'%s'" % m.group(1).replace("''", "'").replace("'", "''")
    return None


def mysql_type(col, table):
    key = (table, col["name"])
    if key in BINARY_OVERRIDES:
        return BINARY_OVERRIDES[key]
    if key in WIDEN:
        return "VARBINARY(%d)" % WIDEN[key]

    t = col["type"]
    n = col["length"]
    if t in ("char", "varchar", "nchar", "nvarchar"):
        size = int(n.split(",")[0]) if n else 1
        base = "CHAR" if t in ("char", "nchar") else "VARCHAR"
        # MySQL CHAR is limited to 255 characters; utf8mb4 CHAR(255) fits.
        if base == "CHAR" and size > 255:
            base, size = "VARCHAR", 255
        return "%s(%d)" % (base, size)
    if t in ("binary", "varbinary"):
        size = int(n.split(",")[0]) if n else 1
        if t == "binary" and size <= BINARY_MAX:
            return "BINARY(%d)" % size
        return "VARBINARY(%d)" % size
    if t in ("decimal", "numeric"):
        if n:
            return "DECIMAL(%s)" % n
        return "DECIMAL(18,0)"
    fn = TYPES.get(t)
    if fn is None:
        raise SystemExit("unmapped column type %r (%s.%s)" % (t, table, col["name"]))
    out = fn(n)
    if col["identity"]:
        if out == "INT":
            out = "INT AUTO_INCREMENT"
        elif out in ("BIGINT", "SMALLINT", "TINYINT UNSIGNED"):
            out += " AUTO_INCREMENT"
        else:
            out = "BIGINT AUTO_INCREMENT"
    return out


# --------------------------------------------------------------------------
# Implicit defaults
#
# The SQL Server dump is full of "NOT NULL, no DEFAULT" columns, and several
# server-side procedures insert partial rows - e.g. ACCOUNT_LOGIN creating a
# TB_USER row with only (strAccountID, strPasswd), CREATE_KNIGHTS inserting
# KNIGHTS without Gold/Points/Mark.  Those columns have no value there, so on
# SQL Server the statement simply failed (error 515); under MySQL's
# STRICT_ALL_TABLES it would fail the same way and the feature would stay
# broken after the port.
#
# To keep NOT NULL (an UPDATE can still never store NULL) while letting the
# server's partial INSERTs work as they clearly intend, every such column gets
# an explicit neutral DEFAULT.  Binary/BLOB columns cannot carry a literal
# default in InnoDB, so those become NULLable instead.
# --------------------------------------------------------------------------
ZERO_DEFAULTS = {
    "TINYINT UNSIGNED": "0",
    "SMALLINT": "0",
    "INT": "0",
    "BIGINT": "0",
    "DOUBLE": "0",
    "DECIMAL": "0",
    "DATETIME": "'1970-01-01 00:00:00'",
    "DATETIME(3)": "'1970-01-01 00:00:00.000'",
    "DATE": "'1970-01-01'",
}

IMPLICIT_DEFAULTS = []      # report entries


def implicit_default(table, name, sqltype):
    """Return (new_sqltype, default_clause, switched_to_nullable)."""
    base = sqltype.split("(")[0].strip().upper()

    if base in ("BINARY", "VARBINARY", "LONGBLOB", "BLOB", "MEDIUMBLOB", "TEXT"):
        return sqltype, None, True

    key = sqltype.upper()
    if key in ZERO_DEFAULTS:
        return sqltype, ZERO_DEFAULTS[key], False
    if base == "DATETIME":
        return sqltype, "'1970-01-01 00:00:00'", False
    if base in ("CHAR", "VARCHAR"):
        return sqltype, "''", False
    return sqltype, "0", False


def emit_table(t):
    table = t["table"]
    lines = []
    for c in t["cols"]:
        sqltype = mysql_type(c, table)
        parts = ["  `%s`" % c["name"], sqltype]
        d = convert_default(c["default"])
        not_null = c["not_null"] or c["identity"]

        if c["not_null"] and not c["identity"] and not d:
            new_type, default, nullable = implicit_default(table, c["name"], sqltype)
            if nullable:
                not_null = False
                IMPLICIT_DEFAULTS.append("%s.%s (%s): NOT NULL -> NULL (no literal default possible)"
                                         % (table, c["name"], sqltype))
            else:
                d = default
                IMPLICIT_DEFAULTS.append("%s.%s (%s): NOT NULL DEFAULT %s added"
                                         % (table, c["name"], sqltype, default))

        parts.append("NOT NULL" if not_null else "NULL")
        if d:
            parts.append("DEFAULT %s" % d)
        lines.append(" ".join(parts))
    pk = list(t["pk"])
    if not pk:
        # MySQL requires AUTO_INCREMENT columns to be a key.
        ai = [c["name"] for c in t["cols"] if c["identity"]]
        if ai:
            pk = ai
    if pk:
        lines.append("  PRIMARY KEY (%s)" % ", ".join("`%s`" % c for c in pk))
    for u in t["uniques"]:
        lines.append("  UNIQUE KEY `UQ_%s_%s` (%s)" % (table, "_".join(u),
                     ", ".join("`%s`" % c for c in u)))
    # InnoDB needs a key for row-based replication; give PK-less tables one.
    if not pk:
        first = t["cols"][0]["name"]
        lines.append("  KEY `IX_%s_first` (`%s`)" % (table, first))
    ddl = "CREATE TABLE `%s` (\n%s\n) ENGINE=InnoDB DEFAULT CHARSET=%s COLLATE=%s;" % (
        table, ",\n".join(lines), CHARSET, COLLATE)
    return ddl


# --------------------------------------------------------------------------
# INSERT
# --------------------------------------------------------------------------

class StringEscaper:
    """Converts the dump's T-SQL literals into MySQL literals."""

    def __init__(self, raw):
        self.raw = raw
        self.i = 0
        self.out = io.StringIO()
        self.stats = Counter()

    def run(self):
        raw, out = self.raw, self.out
        n = len(raw)
        while self.i < n:
            c = raw[self.i]
            # N'...' literal
            if c in "N" and self.i + 1 < n and raw[self.i + 1] == "'":
                self.i += 2
                self._string()
                continue
            if c == "'":
                self.i += 1
                self._string()
                continue
            out.write(c)
            self.i += 1
        return out.getvalue()

    def _string(self):
        raw = self.raw
        n = len(raw)
        buf = bytearray()
        while self.i < n:
            c = raw[self.i]
            if c == "'":
                if self.i + 1 < n and raw[self.i + 1] == "'":
                    buf.extend(b"'")
                    self.i += 2
                    continue
                self.i += 1
                break
            # The dump was exported from a CP1252/varchar database: one
            # character == one original byte.  Recover that byte exactly.
            try:
                buf.extend(c.encode("cp1252"))
            except UnicodeEncodeError:
                self.stats["unmappable_char"] += 1
                buf.extend(c.encode("utf-8"))
            self.i += 1
        if b"\x00" in buf:
            self.stats["binary_literal"] += 1
            self.out.write("0x" + buf.hex().upper())
        else:
            s = buf.decode("latin-1")
            s = s.replace("\\", "\\\\").replace("'", "''")
            s = s.replace("\x00", "")
            self.out.write("'" + s + "'")
            self.stats["string_literal"] += 1


INSERT_RE = re.compile(r"^INSERT\s+\[(?:dbo)\]\.\[([^\]]+)\]", re.I)


def convert_insert(batch):
    """Returns (table, mysql_statement) for one INSERT statement."""
    body = batch.strip()
    # A batch may end with "SET IDENTITY_INSERT ... OFF" after the last INSERT;
    # it is not part of the statement (identity values are preserved through
    # the NO_AUTO_VALUE_ON_ZERO sql_mode instead).
    body = re.sub(r"\n\s*SET\s+IDENTITY_INSERT[^\n]*$", "", body, flags=re.I).strip()
    m = INSERT_RE.match(body)
    table = m.group(1)
    body = re.sub(r"\[dbo\]\.", "", body, flags=re.I)
    body = re.sub(r"\[([^\]]+)\]", r"`\1`", body)
    body = re.sub(r"^INSERT\s+(INTO\s+)?", "INSERT INTO ", body, flags=re.I)
    # CAST(N'...' AS DateTime) -> '...'
    body = re.sub(r"CAST\s*\(\s*(N?'(?:[^']|'')*')\s+AS\s+(?:Small)?DateTime\s*\)",
                  r"\1", body, flags=re.I)
    body = StringEscaper(body).run()
    body = re.sub(r"'(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}:\d{2})",
                  r"'\1 \2", body)
    return table, body.rstrip().rstrip(";") + ";"


# --------------------------------------------------------------------------
# Verification
# --------------------------------------------------------------------------

def count_inserts(text):
    per = Counter()
    for line in text.split("\n"):
        if line.startswith("INSERT INTO `"):
            per[line.split("`")[1]] += 1
    return per


def _human(path):
    """Size of a generated artefact, for the report."""
    if not os.path.exists(path):
        return "not generated"
    size = os.path.getsize(path)
    for unit in ("B", "KB", "MB", "GB"):
        if size < 1024 or unit == "GB":
            return "%.1f %s" % (size, unit)
        size /= 1024.0


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--zip", default="KO1534_sql.zip")
    ap.add_argument("--out", default="migrations/mysql")
    ap.add_argument("--routines-dir", default=None,
                    help="dump the SQL Server procedures/functions/view here for manual porting")
    ap.add_argument("--keep-plain-data", action="store_true",
                    help="also keep the 143 MB uncompressed 002_data.sql")
    ap.add_argument("--check", action="store_true", help="verify generated files only")
    args = ap.parse_args()

    if not os.path.exists(args.zip):
        raise SystemExit("missing %s" % args.zip)

    text = read_dump(args.zip)
    batches = split_batches(text)
    print("batches: %d" % len(batches), file=sys.stderr)

    tables, inserts, routines, views = [], [], [], []
    skipped = Counter()

    for b in batches:
        first = first_statement(b)
        up = first.upper()
        if up.startswith("CREATE TABLE"):
            tables.append(parse_create_table(b))
            continue
        if re.search(r"CREATE\s+(PROCEDURE|PROC)\s+\[dbo\]", b, re.I):
            routines.append(b)
            continue
        if re.search(r"CREATE\s+FUNCTION\s+\[dbo\]", b, re.I):
            routines.append(b)
            continue
        if re.search(r"CREATE\s+VIEW\s+\[dbo\]", b, re.I):
            views.append(b)
            continue

        # Data batches: collect every top-level INSERT, whatever else the batch
        # starts with (e.g. "SET IDENTITY_INSERT ... ON" batches).
        segs = [seg for seg in split_sql_segments(b) if INSERT_RE.match(seg)]
        if segs:
            inserts.extend(segs)
        else:
            key = up.split()[0] if up.split() else "(empty)"
            skipped[key] += 1

    tables.sort(key=lambda t: t["table"])
    print("tables: %d  inserts: %d  routines: %d  views: %d" %
          (len(tables), len(inserts), len(routines), len(views)), file=sys.stderr)
    print("skipped batches by keyword: %s" % dict(skipped), file=sys.stderr)

    os.makedirs(args.out, exist_ok=True)

    # ---------------- schema ----------------
    schema = ["-- MySQL 8.4 schema for KO1534.",
              "-- GENERATED by tools/sqlserver_to_mysql.py from KO1534_sql.zip.",
              "-- Do not edit by hand; change the generator instead.",
              "--",
              "-- Notes:",
              "--   * T-SQL tinyint (unsigned 0..255) -> TINYINT UNSIGNED.",
              "--   * fixed binary(n) <= 255 -> BINARY(n) (zero padded, like SQL Server).",
              "--   * binary(n) > 255 -> VARBINARY(n) (MySQL BINARY() is limited to 255).",
              "--   * USERDATA inventory blobs widened to 74 slots (see generator).",
              "--   * latin1 (byte exact, PAD SPACE, case insensitive) preserves the original",
              "--     CP1252 bytes; the dump pads strings with 0xA0.",
              "",
              "SET NAMES latin1;",
              "SET FOREIGN_KEY_CHECKS=0;",
              "SET SESSION sql_mode='STRICT_ALL_TABLES,NO_ENGINE_SUBSTITUTION,NO_AUTO_VALUE_ON_ZERO';",
              ""]
    for t in tables:
        schema.append(emit_table(t))
        schema.append("")
    schema.append("SET FOREIGN_KEY_CHECKS=1;")
    open(os.path.join(args.out, "001_schema.sql"), "w", encoding="latin-1").write("\n".join(schema) + "\n")

    # ---------------- data ----------------
    data = ["-- Data for KO1534, converted from KO1534_sql.zip by",
            "-- tools/sqlserver_to_mysql.py.  Plain INSERTs (no IGNORE): a conflict",
            "-- must fail loudly instead of silently dropping a row.",
            "SET NAMES latin1;",
            "SET SESSION sql_mode='STRICT_ALL_TABLES,NO_ENGINE_SUBSTITUTION,NO_AUTO_VALUE_ON_ZERO';",
            "SET autocommit=0;",
            ""]
    per_table = Counter()
    for b in inserts:
        table, stmt = convert_insert(b)
        data.append(stmt)
        per_table[table] += 1
    data.append("")
    data.append("COMMIT;")
    data_path = os.path.join(args.out, "002_data.sql")
    with open(data_path, "w", encoding="latin-1") as f:
        f.write("\n".join(data) + "\n")

    # The uncompressed file is 143 MB and stays out of Git; the gzip of it is
    # only ~2 MB (the dump is mostly zero-filled binary and padding), so the
    # .gz IS committed.  That is what makes `docker compose up -d` and the
    # setup scripts work without Python on the developer's machine.
    #
    # IMPORTANT: the MySQL entrypoint imports *every* .sql and .sql.gz in
    # /docker-entrypoint-initdb.d, in filename order.  A leftover
    # 002_data.sql next to 002_data.sql.gz would therefore be imported twice
    # and the second pass would die on duplicate primary keys.  So the plain
    # file is deleted again after it has been compressed and verified (see
    # below); --keep-plain-data exists only for debugging.
    gz_path = data_path + ".gz"
    # mtime=0 / no stored filename: regenerating must produce byte-identical
    # output, otherwise every run would add a new blob to Git.
    with open(data_path, "rb") as src, open(gz_path, "wb") as raw, \
            gzip.GzipFile(filename="", mode="wb", fileobj=raw,
                          compresslevel=9, mtime=0) as dst:
        shutil.copyfileobj(src, dst, length=1 << 20)
    print("wrote %s (%.1f MB compressed)"
          % (gz_path, os.path.getsize(gz_path) / (1024.0 * 1024.0)), file=sys.stderr)

    # ---------------- routines (reference only) ----------------
    if args.routines_dir:
        os.makedirs(args.routines_dir, exist_ok=True)
        index = []
        for b in routines + views:
            name = None
            m = re.search(r"CREATE\s+(?:PROCEDURE|PROC|FUNCTION|VIEW)\s+\[dbo\]\.\[([^\]]+)\]", b, re.I)
            if m:
                name = m.group(1)
            if not name:
                continue
            open(os.path.join(args.routines_dir, name + ".sql"), "w", encoding="utf-8").write(b + "\n")
            index.append(name)
        open(os.path.join(args.routines_dir, "_index.txt"), "w", encoding="utf-8").write("\n".join(sorted(index)))
        print("routines extracted: %d" % len(index), file=sys.stderr)

    # ---------------- report ----------------
    dump_counts = Counter()
    for b in inserts:
        m = INSERT_RE.match(strip_comments(b).strip())
        if m:
            dump_counts[m.group(1)] += 1
    top_level_inserts = 0
    for b in batches:
        if re.search(r"CREATE\s+(PROCEDURE|PROC|FUNCTION|VIEW)\s+\[dbo\]", b, re.I):
            continue          # INSERTs inside routine bodies are not data
        top_level_inserts += len(split_sql_segments(b))
    if top_level_inserts != len(inserts):
        print("WARNING: dump has %d top-level INSERTs, parsed %d"
              % (top_level_inserts, len(inserts)), file=sys.stderr)

    generated = open(os.path.join(args.out, "002_data.sql"), encoding="latin-1").read()
    gen_counts = count_inserts(generated)

    missing = {t: c for t, c in dump_counts.items() if gen_counts.get(t, 0) != c}
    lines = ["# Conversion report", "",
             "Source: `KO1534_sql.zip` (unmodified).",
             "", "| Item | Count |", "|---|---|",
             "| Tables | %d |" % len(tables),
             "| INSERT statements in dump | %d |" % len(inserts),
             "| Top-level INSERT statements seen by scanner | %d |" % top_level_inserts,
             "| INSERT statements generated | %d |" % sum(gen_counts.values()),
             "| Stored procedures / functions (manual port) | %d |" % len(routines),
             "| Views | %d |" % len(views),
             "| 002_data.sql.gz | %s |" % _human(os.path.join(args.out, "002_data.sql.gz")),
             "", "## Rows per table", "", "| Table | Dump | Generated |", "|---|---|---|"]
    for t in sorted(dump_counts):
        lines.append("| %s | %d | %d |" % (t, dump_counts[t], gen_counts.get(t, 0)))
    lines += ["", "## Widened columns", ""]
    for (t, c), size in WIDEN.items():
        lines.append("* `%s`.`%s` -> VARBINARY(%d) (widened from 73 slots)" % (t, c, size))
    lines.append("")
    for (t, c), typ in BINARY_OVERRIDES.items():
        lines.append("* `%s`.`%s` -> %s (binary payload in a varchar column)" % (t, c, typ))
    if IMPLICIT_DEFAULTS:
        lines += ["", "## Implicit defaults (NOT NULL columns that had none)", ""]
        for entry in IMPLICIT_DEFAULTS:
            lines.append("* " + entry)

    lines += ["", "## Result", ""]
    if missing:
        lines.append("**MISMATCH:** " + ", ".join("%s (%d -> %d)" % (t, c, gen_counts.get(t, 0))
                                                   for t, c in missing.items()))
    else:
        lines.append("All INSERT statements accounted for: counts match the dump.")
    open(os.path.join(args.out, "REPORT.md"), "w", encoding="utf-8").write("\n".join(lines) + "\n")

    # The report above re-read the plain file to count what was actually
    # written; now drop it so the directory only holds files the MySQL
    # entrypoint should import.
    if not args.keep_plain_data:
        os.remove(data_path)

    print("wrote schema (%d tables), data (%d inserts)" %
          (len(tables), sum(gen_counts.values())), file=sys.stderr)
    if missing:
        print("MISMATCH: %s" % missing, file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
