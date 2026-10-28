# MySQL port notes

What changed, why, and what to watch when running it.

## Encoding — `latin1`, not `utf8mb4`

The original database is byte oriented. Analysing the dump:

* 159,497 string values are padded with byte `0xA0` (SQL Server's non-breaking
  space used as padding), most of them in `ITEM_UPGRADE`, `MAGIC*`, `K_NPC`.
* Several `varchar`/`char` columns carry opaque binary payloads (skill shortcuts,
  seal data, notices) that the server reads back with `FetchBinary`.

If those bytes are interpreted as UTF-8, `0xA0` becomes `0xC2 0xA0` on re-encode
and every padded comparison and every opaque payload changes length. The schema
therefore uses MySQL's `latin1` with `latin1_general_ci` (1 byte = 1 character,
PAD SPACE, case insensitive — the closest equivalent of the original
`SQL_Latin1_General_CP1_CI_AS`), and the servers connect with
`charset = latin1`.

Binary payload columns are additionally typed as `VARBINARY`
(`USERDATA.strSkill`, `USERDATA.strItem`, `USERDATA.strSerial`,
`USERDATA.strUserSeal`, `USERDATA.strItemTime`, `USERDATA.strQuest`,
`USERDATA.strQuestData`, `USERDATA_SKILLSHORTCUT.strSkillData`,
`WAREHOUSE.*`, `KING_CANDIDACY_NOTICE_BOARD.strNotice`), so no charset
conversion can ever touch them.

## Schema

* `tinyint` → `TINYINT UNSIGNED`, `bit` → `TINYINT(1)`, `float` → `DOUBLE`,
  `datetime` → `DATETIME(3)`, `smalldatetime` → `DATETIME`, `image` →
  `LONGBLOB`, `text` → `TEXT`.
* `IDENTITY` → `AUTO_INCREMENT`; identity values are preserved through
  `NO_AUTO_VALUE_ON_ZERO` (the import sets that `sql_mode`).
* The `USERDATA` arrays were widened from the dump's 73-slot layout to the
  74-slot layout the 1534 client actually uses (`strItem`/`strSerial` 592 bytes,
  `strUserSeal`/`strItemTime` 296 bytes).
* 81 of the 104 tables had no primary key in the dump. They still don't — adding
  a surrogate key would change `ROW_COUNT()` semantics for the ported
  procedures. They only carry the same index the dump had.

## Stored routines

Porting conventions (`003`–`007`):

| T-SQL | MySQL |
|---|---|
| `RETURN n` | leading `OUT p_result`, then `LEAVE proc` |
| `SELECT @x = col` | `SELECT col INTO v_x` |
| `@@ROWCOUNT` | `ROW_COUNT()` (never right after a `SELECT` — returns -1) |
| `@@ERROR` | `DECLARE EXIT HANDLER FOR SQLEXCEPTION` + `ROLLBACK` |
| `GETDATE()` | `NOW(3)` |
| `DATEDIFF(HH, a, b)` | `TIMESTAMPDIFF(HOUR, a, b)` |
| `col += n` | `col = col + n` |
| `INSERT ... SELECT ... WHERE col = @x` inside `UPDATE` | plain `UPDATE` (T-SQL `FROM` clauses removed) |
| reserved words | backticked (`` `Rank` ``, `` `Class` ``, `` `Level` ``, `` `Exp` ``, `` `Zone` ``) |

Where the dumped routine and the C++ call site disagreed, the call site wins;
`tools/check_call_sites.py` enforces this (52 procedures, all matching) and each
such routine carries a comment explaining the deviation.

## Database client

`shared/database/` no longer contains any ODBC code:

| before | now |
|---|---|
| `OdbcConnection` (`SQLDriverConnect` with a DSN) | `MySqlConnection` (`mysql_real_connect` with host/port/db/user/pass) |
| `OdbcCommand` (server-side prepared statements) | `MySqlCommand` (statement rendering + `mysql_real_query`) |
| `OdbcParameter` / `OdbcRecordset` | `MySqlParameter` / `MySqlRecordset` |

The **call sites did not change** — no `.cpp` file outside `shared/database/`
needed edits to its SQL. `MySqlCommand` translates the ODBC idioms:

```text
{? = CALL ACCOUNT_LOGIN(?, ?)}
  ->  SET @ko_return_value = NULL; CALL ACCOUNT_LOGIN(@ko_return_value, 'id', 'pw'); SELECT @ko_return_value

{CALL LOAD_USER_DATA(?, ?)}
  ->  CALL LOAD_USER_DATA('id', 'char')
```

* every `?` is replaced, in `AddParameter` order, by an escaped literal;
* strings are escaped with `mysql_real_escape_string` under the connection's
  charset, binary parameters are sent as `0x…` hex (byte exact);
* result sets are buffered client side (`mysql_store_result`), so
  `hasData()` / `MoveNext()` / `FetchX(pos)` behave exactly as before;
* the trailing `SELECT @ko_return_value` is consumed and written back into the
  output parameter, so `Execute()` returns with the OUT value already set.

There is no server-side prepare, no `odbcad32.exe` step, and no DSN anywhere:
Navicat / HeidiSQL / the MySQL CLI can connect with the same host/user/password.

## Configuration

```ini
[DATABASE]
HOST = 127.0.0.1
PORT = 3306
NAME = KO1534
USER = ko1534
PASSWORD = ko1534        ; the throwaway local default - change it anywhere real
CHARSET = latin1
CONNECT_TIMEOUT = 15
```

The game server reads `[ACCOUNT_DATABASE]` for the account tables and falls back
to `[DATABASE]` if it is missing. Old `[ODBC]` / `[GAME_ODBC]` / `[ACCOUNT_ODBC]`
sections are no longer read — if they are still present they are ignored.

## SQL that SQL Server accepted and MySQL does not

The migration converted the dump and the stored routines, but the servers also
build statements in C++, and those had never been executed until the first real
run. Both servers died on the first table they load:

```
AIServer   : Loaded table [MAGIC]
             ERROR : ... near 'Range, UseStanding, Etc FROM MAGIC'
GameServer : Loaded table [ITEM]
             ERROR : ... near 'Range, Weight, Duration, ... FROM ITEM'
```

Four kinds of statement had to be rewritten. All are SQL Server extensions:

| written for SQL Server | why it fails on MySQL 8 | now |
|---|---|---|
| `SELECT Num, Range, Weight …` | `RANGE` is a **reserved word** since 8.0 | `` `Range` `` |
| `SELECT [Level], [Exp] FROM LEVEL_UP` | `[…]` is array syntax, not an identifier | `` `Level`, `Exp` `` |
| `SET Loyalty += %d` | no compound assignment in `SET` | `SET Loyalty = Loyalty + %d` |
| `DATEDIFF(HOUR, dtUpdateTime, getdate())` | `DATEDIFF` takes two dates; the unit form is T-SQL | `TIMESTAMPDIFF(HOUR, dtUpdateTime, NOW())` |
| `SELECT TOP(10) … ISNULL(x, 0) … FULL OUTER JOIN` | `LIMIT`, `IFNULL`, and no `FULL OUTER JOIN` | `… IFNULL(…) … LEFT JOIN … ORDER BY … LIMIT 10` |

Only three columns of the whole schema (1022 in `001_schema.sql`) are reserved
words: `Range`, `Rank`, `group`. `Range` was the one in the table lists;
`GetColumns()` in `ItemTableSet.h`, `MagicTableSet.h` and `MagicType1Set.h` now
writes it back-quoted, and `MySqlRecordset::Read()` quotes every plain
identifier in the list and the table name defensively, which also converts any
`[Name]` it is handed.

`tools/check_inline_sql.py` checks this without a server: every
`GetColumns()` column must exist in the table that `GetTableName()` names, must
not be an unquoted reserved word, and every SQL literal in the C++ is scanned
for T-SQL constructs. `tools/check_sql_syntax.py` parses the same literals with
sqlglot as MySQL, which is how `SET x += 1` above was found.

`MySqlRecordset::Read()` now also prints the statement it sent when a load
fails, because the client's message only quotes the fragment it choked on:

```
ERROR: Could not load table, the error received was:
You have an error in your SQL syntax ... near 'Range, Weight, ...' at line 1
  statement: SELECT `Num`, `strName`, ..., `Range`, `Weight`, ... FROM `ITEM`
```

Backticks around `Range` mean the fixed list is in use; `Range` without them
means the `.exe` is older than the sources, which the build stamp printed at
startup now answers directly.

Three procedures are defined but never called from the C++ (`INSERT_CURRENTUSER`,
`LOAD_SEALED_ITEM_DATA`, `SKILLSHORTCUT_LOAD`), so nothing has exercised them yet;
`tools/check_call_sites.py` reports them on every run.

## Windows PowerShell and native stderr

Every script in `tools\` sets `$ErrorActionPreference = "Stop"`. In Windows
PowerShell 5.1 that turns anything a native program writes to stderr into a
terminating error as soon as the output is redirected (`2>$null`, `2>&1`) - so a
harmless warning aborts the script:

```
docker : mysql: [Warning] Using a password on the command line interface can be insecure.
    + CategoryInfo          : NotSpecified: (...) [RemoteException], RemoteException
    + FullyQualifiedErrorId : NativeCommandError
```

`tools\lib\NativeCommand.ps1` provides `Invoke-Native`, which captures stdout
and stderr separately and keeps the real exit code, so a warning is data rather
than a failure. `tools/check_powershell.py` fails the check list if a script
redirects a native program's stderr directly again, or calls `Invoke-Native`
without loading the library.

## Verification status

| item | status |
|---|---|
| schema/data/routine generation | generated, statically validated |
| routine parameter counts vs C++ call sites | checked by `tools/check_call_sites.py` (52/52) |
| `shared/database` type-check (g++ -fsyntax-only, stub headers) | passes — `tools/syntax_check_db_layer.sh` |
| `002_data.sql.gz` reproducible (same sha256 on every run) | verified |
| gzip round-trip equals the generated 143 MB SQL | verified (byte count + sha256) |
| `docker-compose.yml` parses as YAML, mounts and env as intended | checked |
| full import into MySQL 8.4 by the container entrypoint | **verified on a developer machine**: 105 tables, 65 routines (after fixing the CASE syntax error in 006) |
| row data imported (002_data.sql.gz) | implied by the above — 003..007 only run after 002 succeeds |
| non-Docker setup scripts (`setup_database.ps1` / `.sh`) | **not run** |
| C++ build (VS2022, x64, MSVC 19.4x) | **AIServer.exe and LogInServer.exe link** on a developer machine; GameServer was still failing at the last run (fixed since, not yet re-run) |
| C++ build, Win32 | **not attempted** — Oracle's MySQL 8.x packages are x64-only, so it needs a 32-bit client library (MariaDB Connector/C) |
| import into MySQL 8.4 (`docker compose up -d` or the setup scripts) | **not verified** — no MySQL/Docker in this environment |
| startup schema check (`shared/database/SchemaCheck.h`) | type-checks, **not compiled by MSVC** |
| login / character / world round-trip with the client | **not verified** |

## Getting the database in place

Three equivalent routes, in order of convenience:

1. `docker compose up -d` — the container imports `001` … `007` on first start of
   an empty volume, gzip included. Nothing else to do.
2. `tools/setup_database.ps1` (Windows) / `tools/setup_database.sh` (Linux,
   macOS) — same import against an existing MySQL, no Docker, no Python. Both
   refuse to touch a database that already has `TB_USER` unless forced.
3. `mysql < file` by hand, in filename order.

Two invariants make route 1 work, and both are easy to break:

* **The directory must contain one copy of the data.** The entrypoint imports
  *every* `.sql` and `.sql.gz` it finds, in filename order. A plain
  `002_data.sql` left behind next to `002_data.sql.gz` would be imported twice
  and the second pass would fail on duplicate primary keys — which is why the
  generator deletes the plain file again after compressing it
  (`--keep-plain-data` keeps it for debugging, and then route 1 must not be
  used until it is removed).
* **`002` must stay gzipped and committed.** It is 2.0 MB compressed against
  143 MB plain; the `.gitignore` ignores the plain name and un-ignores the
  `.gz`, so a `git clean -xdf` does not leave the compose file with nothing to
  import.
