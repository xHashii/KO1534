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
migrations/mysql/          the MySQL port (see below)
tools/                     migration generator + static validators
docs/                      migration notes and findings
```

## Prerequisites

* Visual Studio 2022 (v143 toolset), **Win32/x86** for the 1534 client
* MySQL Server 8.4 LTS (8.0 works too)
* MySQL Connector/C 8.x (the client library, `libmysql.dll` + `libmysql.lib`)

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

## 2. Create the database

```sql
CREATE DATABASE KO1534 CHARACTER SET latin1 COLLATE latin1_general_ci;
CREATE USER 'ko1534'@'%' IDENTIFIED BY 'change_me';
GRANT ALL PRIVILEGES ON KO1534.* TO 'ko1534'@'%';
```

`latin1` is deliberate and not an oversight — see `docs/MYSQL_NOTES.md`
(“Encoding”). Do not switch the schema to `utf8mb4`.

## 3. Import

Files are applied in order (`mysql -u ko1534 -p KO1534 < file.sql`):

| file | contents |
|---|---|
| `migrations/mysql/001_schema.sql` | 104 tables (types, collation, keys) |
| `migrations/mysql/002_data.sql` | 171,445 rows — **generated, not committed** |
| `migrations/mysql/003_functions.sql` | 10 functions + `ACCOUNT_CHAR_VIEW` |
| `migrations/mysql/004_procedures.sql` | login / character / session procedures |
| `migrations/mysql/005_reconstructed.sql` | reconstructed objects (see below) |
| `migrations/mysql/006_procedures_clan_account.sql` | clan, friends, seals, daily ops, nation transfer |
| `migrations/mysql/007_procedures_mail_king.sql` | mail box and king election |

`002_data.sql` is 143 MB and is regenerated from the untouched
`KO1534_sql.zip`:

```bash
python3 tools/sqlserver_to_mysql.py --routines-dir /tmp/ko/routines
python3 tools/validate_mysql_migration.py     # static checks, no server needed
python3 tools/check_call_sites.py             # C++ CALL vs procedure signatures
```

Both validators must print `OK` before you import.

## 4. Configure and run

Copy `config/*.ini` next to the executables and edit the `[DATABASE]` blocks:

```ini
[DATABASE]
HOST = 127.0.0.1
PORT = 3306
NAME = KO1534
USER = ko1534
PASSWORD = change_me
CHARSET = latin1
```

No DSN, no ODBC driver manager, no `odbcad32.exe`. The game server additionally
reads `[ACCOUNT_DATABASE]` (falls back to `[DATABASE]` when absent).

Start order: **AIServer → LogInServer → GameServer**, working directory of the
game server set to the folder containing `data\Map`.

## 5. Verify

The checks that actually run in this repository (Linux, no MySQL, no MSVC) are
the two validators above. Everything else — compiling with VS2022, importing
into a live MySQL 8.4, and logging in with the real client — has to be done on
Windows and is **not** claimed as verified here. `docs/MYSQL_NOTES.md` lists
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
