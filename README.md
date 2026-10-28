# Knight Online 1534 — C++ server on MySQL 8.4

The original **ALPHAGAME v1534** Knight Online server (`__VERSION 1534`), kept in
its original C++ form and moved from SQL Server (ODBC) to **MySQL 8.4 LTS**.

Nothing about the gameplay, the wire protocol or the client changes. The work is
limited to:

* the database schema, data and stored routines (T-SQL → MySQL),
* the database client inside the server (`shared/database/`: ODBC → native
  `libmysqlclient`),
* the project files (Visual Studio 2022), configuration and docs.

The C# rewrite that used to live in `src/` has been removed.

## Repository layout

```
ALPHAGAME v1534.sln        Visual Studio 2022 solution (C++)
AIServer/  GameServer/  LogInServer/  shared/  scripting/  N3BASE/
Client/                    the 1534 client tree
data/                      Map\ and Quests\ the game server loads at runtime
KO1534_sql.zip             original SQL Server dump (kept byte-identical)
config/                    sample .ini files — copy next to the executables
migrations/mysql/          the MySQL port; imported automatically on first run
docker-compose.yml         one-command MySQL 8.4 with that import built in
.env.example               overrides for the container (copy to .env)
tools/                     migration generator, setup scripts, static validators
docs/                      migration notes and findings
```

## Prerequisites

* Visual Studio 2022 (v143 toolset), **Win32/x86** for the 1534 client
* MySQL 8.4 LTS — either Docker Desktop, or a local install you point
  `tools/setup_database.ps1` at
* MySQL Connector/C 8.x (the client library, `libmysql.dll` + `libmysql.lib`)
  — this is for the *server* build, not for the database setup

## 1. Build

Open `ALPHAGAME v1534.sln`, set the environment variable that the projects use
for the client library, then build the solution:

```powershell
setx MYSQL_ROOT "C:\Program Files\MySQL\MySQL Connector C 8.4"
```

Roughly a dozen translation units include `mysql.h`, so the projects add
`$(MYSQL_ROOT)\include` to the include path and link `libmysql.lib`. Copy
`libmysql.dll` next to the executables (or add its folder to `PATH`).

Platform: **Win32**. The client is 32-bit and speaks the original packet format;
an x64 server build would need a rebuild of the whole socket/crypto layer and is
not part of this port.

## 2. Database (automatic)

The migration files are executed for you. Docker is the shortest path:

```powershell
copy .env.example .env      # optional - the defaults already work
docker compose up -d
```

That is the whole database step. MySQL 8.4 starts, and on the **first** start of
an empty volume the container executes every file in
`migrations/mysql/` in order (`docker-entrypoint-initdb.d`), including the
gzipped data file, which it decompresses itself. Nothing to type, no Python, no
`mysql.exe`. The import takes a couple of minutes (143 MB of `INSERT`s); wait
for the container to become healthy:

```powershell
docker compose ps                  # STATUS: healthy when the import is done
docker compose logs -f mysql       # ...or watch it happen
```

The result is reachable exactly as the sample configs expect:

```
host 127.0.0.1:3306   database KO1534   user ko1534   password ko1534
```

Change those in `.env` **and** in `config\*.ini` if you do not want the dev
defaults. The container only imports when its data volume is empty; to start
over:

```powershell
docker compose down -v
docker compose up -d
```

### Without Docker

If you already have MySQL 8.4 installed, `tools/setup_database.ps1` does the
same thing with your own `mysql.exe` (creates the database and the app user,
imports `001` → the data → `003`…`007`, and refuses to touch a database that
already has the schema unless you pass `-Force`):

```powershell
powershell -ExecutionPolicy Bypass -File tools\setup_database.ps1
```

`tools/setup_database.sh` is the same for Linux/macOS. Neither needs Python.

### Both steps together

```powershell
powershell -ExecutionPolicy Bypass -File tools\dev_run.ps1
```

starts MySQL, waits until the schema is actually imported, copies
`config\*.ini` where the servers look for them, and launches
**AIServer → LogInServer → GameServer** from `bin\<Config>\Win32\`.

### What gets imported

| file | contents |
|---|---|
| `migrations/mysql/001_schema.sql` | 104 tables (types, collation, keys) |
| `migrations/mysql/002_data.sql.gz` | 171,445 rows, gzipped (2.0 MB) |
| `migrations/mysql/003_functions.sql` | 10 functions + `ACCOUNT_CHAR_VIEW` |
| `migrations/mysql/004_procedures.sql` | login / character / session procedures |
| `migrations/mysql/005_reconstructed.sql` | reconstructed objects (see below) |
| `migrations/mysql/006_procedures_clan_account.sql` | clan, friends, seals, daily ops, nation transfer |
| `migrations/mysql/007_procedures_mail_king.sql` | mail box and king election |

`001_schema.sql` uses plain `CREATE TABLE`, so a second import fails loudly
instead of silently keeping stale data. The uncompressed `002_data.sql`
(143 MB) is not committed — it is regenerated from the untouched
`KO1534_sql.zip`, and the generator also rewrites the committed `.gz`:

```bash
python3 tools/sqlserver_to_mysql.py --routines-dir /tmp/ko/routines
python3 tools/validate_mysql_migration.py     # static checks, no server needed
python3 tools/check_call_sites.py             # C++ CALL vs procedure signatures
tools/syntax_check_db_layer.sh                # type-checks shared/database on Linux
```

Both validators must print `OK` before you import. The gzip is byte-for-byte
reproducible (`mtime=0`, no stored filename), so regenerating it produces no
diff; the generator deletes the plain file again on purpose, because the MySQL
entrypoint would import both copies and the second one would die on duplicate
keys.

## 3. Configure

Point a browser/editor at the database with the same values (Navicat, HeidiSQL
and `mysql.exe` all work — there is no DSN or ODBC driver manager involved):

```ini
[DATABASE]
HOST = 127.0.0.1
PORT = 3306
NAME = KO1534
USER = ko1534
PASSWORD = ko1534
CHARSET = latin1
```

`config/*.ini` holds the templates; copy them next to the executables (or into
`data\`, which `tools\dev_run.ps1` does for you) and edit. The game server
additionally reads `[ACCOUNT_DATABASE]` (falls back to `[DATABASE]` when
absent). The committed values are the local Docker setup — change them for
anything that is not a throwaway local database, and never commit the result.

Start order: **AIServer → LogInServer → GameServer**, working directory set to
the folder containing `data\Map`.

If a server starts before the database is ready, or against an empty schema, it
says so and names the command to run — it no longer fails somewhere deep inside
a table load.

## 5. Verify

The checks that actually run in this repository (Linux, no MySQL, no MSVC) are
the two validators and the type-check script above. Everything else —
compiling with VS2022, importing into a live MySQL 8.4, and logging in with the
real client — has to be done on Windows and is **not** claimed as verified
here. `docs/MYSQL_NOTES.md` lists
exactly what has been inspected, generated, statically checked and what is still
open.

## Notes

* `KO1534_sql.zip` and its contents are untouched; all MySQL work lives in new
  files under `migrations/mysql/`.
* No credentials are committed — only the `config/*.ini` templates.
* Four objects the server calls are absent from the dump and were reconstructed
  from the C++ call sites: `DELETE_CHAR`, `KING_ELECTION_RESULTS`,
  `KING_UPDATE_DATABASE` and the `SERVER_LIST` table. They are marked as
  reconstructed both in `005_reconstructed.sql` and in `docs/MIGRATION_ASSESSMENT.md`.
