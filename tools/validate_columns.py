#!/usr/bin/env python3
"""Validate that INSERT columns exist in their table schema."""
import re
import sys

# Parse schema to extract table -> columns mapping
table_columns = {}
current_table = None
current_cols = []

with open('migrations/0001_schema.sql', 'r', encoding='utf-8') as f:
    for line in f:
        line = line.strip()
        m = re.match(r'CREATE TABLE `([^`]+)`\(', line)
        if m:
            current_table = m.group(1)
            current_cols = []
            continue
        
        if current_table:
            if line.startswith(')'):
                table_columns[current_table] = set(current_cols)
                current_table = None
                current_cols = []
                continue
            # Extract column name (first word after backtick)
            m = re.match(r'`([^`]+)`\s+\w', line)
            if m:
                current_cols.append(m.group(1))

print(f'Parsed {len(table_columns)} tables from schema', file=sys.stderr)

# Check INSERT statements
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

        m = re.match(r'INSERT INTO `([^`]+)` \((.+?)\) VALUES', line)
        if not m:
            continue

        table = m.group(1)
        cols_str = m.group(2)
        cols = [c.strip().strip('`') for c in cols_str.split(',')]

        if table not in table_columns:
            errors.append(f'Line {lineno}: Table {table} not in schema')
            continue

        existing = table_columns[table]
        for col in cols:
            if col not in existing:
                errors.append(f'Line {lineno}: Table {table} column `{col}` not found in schema')

print(f'Checked {checked} INSERT statements against schema', file=sys.stderr)
print(f'Errors: {len(errors)}')
for e in errors[:30]:
    print(f'  {e}')
sys.exit(1 if errors else 0)
