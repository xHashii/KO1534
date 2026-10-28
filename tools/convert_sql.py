#!/usr/bin/env python3
"""Convert SQL Server dump (KO1534_utf8.sql) to MySQL migration scripts.

Extracts CREATE TABLE and INSERT statements, skips stored procedures and
other SQL Server-specific statements. Converts T-SQL syntax to MySQL.
"""
import re, os, sys

def split_batches(text):
    """Split SQL text into batches separated by GO."""
    batches = []
    current = []
    for line in text.split('\n'):
        if line.strip() == 'GO':
            batch = '\n'.join(current).strip()
            if batch:
                batches.append(batch)
            current = []
        else:
            current.append(line)
    batch = '\n'.join(current).strip()
    if batch:
        batches.append(batch)
    return batches

def strip_set_stmts(text):
    """Strip SQL Server SET statements so classification works."""
    text = re.sub(r'SET IDENTITY_INSERT[^\n]*', '', text, flags=re.IGNORECASE)
    text = re.sub(r'SET ANSI_NULLS (ON|OFF)', '', text, flags=re.IGNORECASE)
    text = re.sub(r'SET QUOTED_IDENTIFIER (ON|OFF)', '', text, flags=re.IGNORECASE)
    return text

def first_meaningful(text):
    """Get the first non-comment, non-empty line."""
    for line in text.split('\n'):
        s = line.strip()
        if s and not s.startswith('--') and not s.startswith('/*'):
            return s
    return ''

def convert_create_table(batch):
    """Convert T-SQL CREATE TABLE to MySQL."""
    batch = re.sub(r'/\*\*.*?\*/', '', batch, flags=re.DOTALL)
    batch = re.sub(r'--[^\n]*', '', batch)
    batch = strip_set_stmts(batch)
    batch = batch.strip()

    if not batch.startswith('CREATE TABLE'):
        return None

    # Strip SQL Server table options BEFORE [name] -> `name` conversion
    # so [PRIMARY] doesn't become `PRIMARY` and get stuck in output.
    batch = re.sub(r'\bTEXTIMAGE[\s_]+ON\b', '', batch, flags=re.IGNORECASE)
    batch = re.sub(r'ON\s+\[PRIMARY\]', '', batch, flags=re.IGNORECASE)
    batch = re.sub(r'\s+\[PRIMARY\]', '', batch, flags=re.IGNORECASE)
    batch = re.sub(r'ON\s+`PRIMARY`', '', batch, flags=re.IGNORECASE)

    batch = re.sub(r'\[dbo\]\.', '', batch)
    batch = re.sub(r'\[([^\]]+)\]', r'`\1`', batch)

    type_subs = [
        (r'`int`', 'INT'),
        (r'`bigint`', 'BIGINT'),
        (r'`smallint`', 'SMALLINT'),
        (r'`tinyint`', 'TINYINT'),
        (r'`varchar`\s*\(\s*(\d+)\s*\)', r'VARCHAR(\1)'),
        (r'`char`\s*\(\s*(\d+)\s*\)', r'CHAR(\1)'),
        (r'`nvarchar`\s*\(\s*(\d+)\s*\)', r'VARCHAR(\1)'),
        (r'`datetime`', 'DATETIME'),
        (r'`bit`', 'TINYINT(1)'),
        (r'`decimal`\s*\(\s*(\d+)\s*,\s*(\d+)\s*\)', r'DECIMAL(\1,\2)'),
        (r'`numeric`\s*\(\s*(\d+)\s*,\s*(\d+)\s*\)', r'DECIMAL(\1,\2)'),
        (r'`float`', 'FLOAT'),
        (r'`real`', 'FLOAT'),
        (r'`text`', 'TEXT'),
        (r'`ntext`', 'TEXT'),
        (r'`binary`\s*\(\s*(\d+)\s*\)', r'BINARY(\1)'),
        (r'`varbinary`\s*\(\s*(\d+)\s*\)', r'VARBINARY(\1)'),
        (r'`uniqueidentifier`', 'VARCHAR(36)'),
        (r'`smalldatetime`', 'DATETIME'),
        (r'`image`', 'LONGBLOB'),
    ]
    for pat, rep in type_subs:
        batch = re.sub(pat, rep, batch, flags=re.IGNORECASE)

    # MySQL BINARY max = 255 bytes, CHAR max = 255 chars (utf8mb4).
    # Convert larger BINARY -> VARBINARY, larger CHAR -> VARCHAR.
    # Use negative lookbehind so VARBINARY/VARCHAR aren't matched.
    batch = re.sub(r'(?<!VAR)BINARY\((\d+)\)',
                   lambda m: f'VARBINARY({m.group(1)})' if int(m.group(1)) > 255 else f'BINARY({m.group(1)})',
                   batch, flags=re.IGNORECASE)
    batch = re.sub(r'(?<!VAR)CHAR\((\d+)\)',
                   lambda m: f'VARCHAR({m.group(1)})' if int(m.group(1)) > 255 else f'CHAR({m.group(1)})',
                   batch, flags=re.IGNORECASE)

    batch = re.sub(r'IDENTITY\s*\(\s*\d+\s*,\s*\d+\s*\)', 'AUTO_INCREMENT', batch, flags=re.IGNORECASE)

    # MySQL doesn't allow AUTO_INCREMENT on DECIMAL columns — use BIGINT instead.
    batch = re.sub(r'DECIMAL\(\d+,\d+\)\s+AUTO_INCREMENT', 'BIGINT AUTO_INCREMENT', batch, flags=re.IGNORECASE)

    batch = re.sub(r'PRIMARY KEY CLUSTERED', 'PRIMARY KEY', batch, flags=re.IGNORECASE)
    batch = re.sub(r'CONSTRAINT\s+`[^`]+`\s+', '', batch, flags=re.IGNORECASE)
    batch = re.sub(r'WITH\s*\(.*?\)\s*', '', batch, flags=re.DOTALL | re.IGNORECASE)
    batch = re.sub(r'ON\s+`PRIMARY`', '', batch, flags=re.IGNORECASE)
    batch = re.sub(r',\s*\)', ')', batch)

    batch = re.sub(r'[ \t]+', ' ', batch)
    batch = re.sub(r'\n\s*', '\n', batch)
    batch = batch.strip()

    if 'ENGINE=' not in batch.upper():
        batch += ' ENGINE=InnoDB DEFAULT CHARSET=utf8mb4'

    # Add PRIMARY KEY on AUTO_INCREMENT column if no PRIMARY KEY exists.
    # MySQL requires AUTO_INCREMENT columns to be defined as a key.
    if 'AUTO_INCREMENT' in batch and 'PRIMARY KEY' not in batch:
        ai_match = re.search(r'`(\w+)`\s+\w+(?:\(\d+,\d+\))?\s+AUTO_INCREMENT', batch)
        if ai_match:
            col = ai_match.group(1)
            batch = re.sub(r'\)\s*ENGINE', f',\nPRIMARY KEY (`{col}`)\n) ENGINE', batch)

    return batch + ';'

def _convert_single_insert(line):
    """Convert a single T-SQL INSERT line to MySQL."""
    line = re.sub(r'\[dbo\]\.', '', line)
    line = re.sub(r'INSERT\s+\[([^\]]+)\]', r'INSERT IGNORE INTO `\1`', line, flags=re.IGNORECASE)
    line = re.sub(r'\[([^\]]+)\]', r'`\1`', line)
    # Handle CAST(... AS DateTime/SmallDateTime) with N-string or regular string
    line = re.sub(r"CAST\s*\(\s*(?:N)?'((?:[^']|'')*)'\s+AS\s+(?:Small)?DateTime\s*\)", r"'\1'", line, flags=re.IGNORECASE)
    line = re.sub(r"N'((?:[^']|'')*)'", r"'\1'", line)
    line = re.sub(r"'(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}:\d{2})", r"'\1 \2", line)
    line = line.strip()
    return line + ';'

def convert_insert(batch):
    """Convert T-SQL INSERT batch to MySQL. Returns a list of statements."""
    batch = re.sub(r'/\*\*.*?\*/', '', batch, flags=re.DOTALL)
    batch = re.sub(r'--[^\n]*', '', batch)
    batch = strip_set_stmts(batch)
    batch = batch.strip()

    if not batch:
        return []

    results = []
    for line in batch.split('\n'):
        line = line.strip()
        if line.startswith('INSERT'):
            converted = _convert_single_insert(line)
            if converted:
                results.append(converted)
    return results

def escape_newlines_in_strings(raw):
    """Replace newlines inside SQL strings with \\n to prevent multi-line splits.
    Also converts binary string literals (containing null bytes) to hex literals.

    The SQL Server dump contains N-strings with embedded newlines (e.g.
    N'Peddler\\r\\n'), which causes INSERT statements to span multiple lines.
    This function escapes those newlines so each INSERT stays on one line.

    Binary data in VARBINARY columns contains raw null bytes (\\x00), which
    MySQL's mysql client rejects without --binary-mode.  These are converted
    to 0x... hex literals so they can be imported normally.
    """
    result = bytearray()
    in_string = False
    string_buffer = bytearray()
    i = 0
    while i < len(raw):
        c = raw[i]

        # Check for N' prefix (N-string start)
        if not in_string and c == ord('N') and i + 1 < len(raw) and raw[i+1] == ord("'"):
            in_string = True
            string_buffer = bytearray(b"N'")
            i += 2
            continue

        # Check for regular string start
        if not in_string and c == ord("'"):
            in_string = True
            string_buffer = bytearray(b"'")
            i += 1
            continue

        # Check for escaped quote ('' inside string)
        if in_string and c == ord("'") and i + 1 < len(raw) and raw[i+1] == ord("'"):
            string_buffer.append(c)
            string_buffer.append(c)
            i += 2
            continue

        # Check for closing quote
        if in_string and c == ord("'"):
            string_buffer.append(c)
            if b"\x00" in string_buffer:
                # Binary string — convert to hex literal 0x...
                content = bytes(string_buffer)
                if content.startswith(b"N'"):
                    content = content[2:-1]   # strip N' and closing '
                else:
                    content = content[1:-1]   # strip ' and closing '
                content = content.replace(b"''", b"'")  # unescape
                hex_str = content.hex().upper()
                result.extend(b"0x")
                result.extend(hex_str.encode())
            else:
                # Text string — output with escaped newlines
                idx = 0
                while idx < len(string_buffer):
                    bc = string_buffer[idx]
                    if bc == ord('\r'):
                        result.extend(b'\\n')
                        if idx + 1 < len(string_buffer) and string_buffer[idx + 1] == ord('\n'):
                            idx += 2
                        else:
                            idx += 1
                    elif bc == ord('\n'):
                        result.extend(b'\\n')
                        idx += 1
                    else:
                        result.append(bc)
                        idx += 1
            in_string = False
            string_buffer = bytearray()
            i += 1
            continue

        # Inside string — buffer raw bytes (don't escape yet)
        if in_string:
            string_buffer.append(c)
            i += 1
            continue

        # Not inside string — pass through
        result.append(c)
        i += 1

    return bytes(result)


def main():
    input_file = 'KO1534_utf8.sql'
    if not os.path.exists(input_file):
        print(f"ERROR: {input_file} not found", file=sys.stderr)
        sys.exit(1)

    with open(input_file, 'rb') as f:
        raw = f.read()

    # Pre-process: escape newlines inside strings
    raw = escape_newlines_in_strings(raw)

    text = raw.decode('utf-8-sig', errors='replace')
    text = text.replace('\r\n', '\n').replace('\r', '\n')
    batches = split_batches(text)
    print(f"Total batches: {len(batches)}", file=sys.stderr)

    schema_stmts = []
    data_stmts = []
    skipped = 0
    errors = []

    for i, batch in enumerate(batches):
        stripped = strip_set_stmts(batch)
        first = first_meaningful(stripped)
        if not first:
            continue

        if first.startswith('CREATE TABLE'):
            try:
                converted = convert_create_table(batch)
                if converted:
                    schema_stmts.append(converted)
                else:
                    errors.append(f"Batch {i}: CREATE TABLE returned None")
            except Exception as e:
                errors.append(f"Batch {i}: CREATE TABLE error: {e}")
        elif first.startswith('INSERT'):
            try:
                converted = convert_insert(batch)
                data_stmts.extend(converted)
            except Exception as e:
                errors.append(f"Batch {i}: INSERT error: {e}")
        else:
            skipped += 1

    # Deduplicate INSERT statements — the original dump has some
    # duplicate rows (e.g. K_OBJECTPOS) that would cause MySQL ERROR 1062.
    seen = set()
    unique_stmts = []
    for stmt in data_stmts:
        if stmt not in seen:
            seen.add(stmt)
            unique_stmts.append(stmt)
    dup_count = len(data_stmts) - len(unique_stmts)
    if dup_count > 0:
        print(f"Removed {dup_count} duplicate INSERT statements", file=sys.stderr)
    data_stmts = unique_stmts

    os.makedirs('migrations', exist_ok=True)

    schema_path = 'migrations/0001_schema.sql'
    with open(schema_path, 'w', encoding='utf-8') as f:
        f.write('-- Auto-converted from SQL Server dump (KO1534.sql).\n')
        f.write('-- MySQL 8 / utf8mb4. Review before production use.\n')
        f.write('SET FOREIGN_KEY_CHECKS=0;\n')
        f.write("SET sql_mode='NO_AUTO_VALUE_ON_ZERO';\n\n")
        for stmt in schema_stmts:
            f.write(stmt + '\n\n')
        f.write('SET FOREIGN_KEY_CHECKS=1;\n')

    data_path = 'migrations/0002_data.sql'
    with open(data_path, 'w', encoding='utf-8') as f:
        f.write('-- Auto-converted from SQL Server dump (KO1534.sql).\n')
        f.write('SET FOREIGN_KEY_CHECKS=0;\n')
        f.write("SET sql_mode='NO_AUTO_VALUE_ON_ZERO';\n\n")
        for stmt in data_stmts:
            f.write(stmt + '\n')
        f.write('\nSET FOREIGN_KEY_CHECKS=1;\n')

    print(f"Schema: {len(schema_stmts)} tables -> {schema_path}", file=sys.stderr)
    print(f"Data: {len(data_stmts)} inserts -> {data_path}", file=sys.stderr)
    print(f"Skipped: {skipped} (procedures, SET, etc.)", file=sys.stderr)
    if errors:
        print(f"Errors: {len(errors)}", file=sys.stderr)
        for e in errors[:10]:
            print(f"  {e}", file=sys.stderr)

if __name__ == '__main__':
    main()
