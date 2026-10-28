#!/usr/bin/env python3
"""Validate MySQL INSERT statements for column/value count mismatches."""
import re
import sys

errors = []
checked = 0

with open('migrations/0002_data.sql', 'r', encoding='utf-8') as f:
    for lineno, line in enumerate(f, 1):
        line = line.strip()
        if not line or line.startswith('--') or line.startswith('SET'):
            continue
        if not line.startswith('INSERT INTO'):
            continue
        checked += 1

        # Extract table name, columns, and values
        m = re.match(r'INSERT INTO `([^`]+)` \((.+?)\) VALUES \((.+)\);$', line)
        if not m:
            errors.append(f'Line {lineno}: Cannot parse INSERT: {line[:120]}')
            continue

        table = m.group(1)
        cols_str = m.group(2)
        vals_str = m.group(3)

        # Count columns (split by comma, strip backticks)
        cols = [c.strip().strip('`') for c in cols_str.split(',')]
        num_cols = len(cols)

        # Count values using state machine (handles commas inside strings)
        vals = []
        in_quote = False
        current = ''
        i2 = 0
        while i2 < len(vals_str):
            c = vals_str[i2]
            if c == "'" and not in_quote:
                in_quote = True
                current += c
            elif c == "'" and in_quote:
                # Check for escaped quote ''
                if i2 + 1 < len(vals_str) and vals_str[i2 + 1] == "'":
                    current += c + c
                    i2 += 2
                    continue
                in_quote = False
                current += c
            elif c == ',' and not in_quote:
                vals.append(current.strip())
                current = ''
            else:
                current += c
            i2 += 1
        vals.append(current.strip())
        num_vals = len(vals)

        if num_cols != num_vals:
            errors.append(f'Line {lineno}: Table {table} has {num_cols} cols but {num_vals} vals')

        # Check for duplicate columns
        if len(cols) != len(set(cols)):
            errors.append(f'Line {lineno}: Table {table} has duplicate columns: {cols}')

print(f'Checked {checked} INSERT statements')
print(f'Errors: {len(errors)}')
for e in errors[:30]:
    print(f'  {e}')
sys.exit(1 if errors else 0)
