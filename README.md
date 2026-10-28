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

## Quick start

```powershell
git clone https://github.com/xHashii/KO1534.git
cd KO1534
git checkout arena/86bd8e59-ko1534        # or: git pull origin arena/86bd8e59-ko1534

docker compose up -d                      # MySQL 8.4 + automatic import of 001..007
docker compose ps                         # wait for STATUS = healthy

msbuild "ALPHAGAME v1534.sln" /m /p:Configuration=Debug /p:Platform=Win32

powershell -ExecutionPolicy Bypass -File tools\dev_run.ps1
```

Then start the client from `Client\KnightOnLine.exe` (`Client\Server.ini` already
points at `127.0.0.1`). Details and the bitness caveat for the build are in
steps 1–3 below.

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
* a MySQL-protocol client library for the **server build** (see step 1) —
  `libmysql.lib` from a 64-bit MySQL install, or MariaDB Connector/C for a
  32-bit build. The database itself does not need it.

## 1. Build

The server is built for **Win32 (x86)**, the same target the project has always
used. Two settings drive the compile and the link, both overridable from the
command line:

| MSBuild property | meaning | default |
|---|---|---|
| `MYSQL_ROOT` | install prefix containing `include\mysql.h` and `lib\` | `C:\Program Files\MySQL\MySQL Server 8.4` |
| `MySQLClientLib` | import library to link | `libmysql.lib` |

**Mind the bitness.** Oracle's MySQL 8.x Windows packages are x64-only, so
`libmysql.lib` from a MySQL 8 server install cannot be linked into a Win32
executable (`LNK1112: module machine type 'x64' conflicts with target machine
type 'x86'`). Pick one of these:

* **32-bit client library** (keeps Win32): install *MariaDB Connector/C 3.x*
  (win32 package — same `mysql.h` API, MySQL protocol, supports
  `caching_sha2_password`). `tools/build.ps1` finds it on its own; by hand it is
  `/p:MYSQL_ROOT="C:\Program Files\MariaDB\MariaDB Connector C 3.4" /p:MySQLClientLib=libmariadb.lib`.
* **x64 build**: `/p:Platform=x64` against an ordinary MySQL 8.4 install. The
  server and the client are separate processes, so the wire protocol is
  unaffected — but the x64 build has not been verified in this port, and any
  32-bit assumption in the original sources would show up here.
* **Old 32-bit MySQL client** (Connector/C 6.1): works only if the account uses
  `mysql_native_password`, which MySQL 8.4 disables by default. Not recommended.

`libmysql.dll` / `libmariadb.dll` must be next to the executables or on `PATH`.

A command-line build of the whole solution — `tools/build.ps1` finds MSBuild
with `vswhere`, auto-detects the client library and copies the DLL next to the
executables, so it works from a plain PowerShell window:

```powershell
powershell -ExecutionPolicy Bypass -File tools\build.ps1
```

Useful switches: `-Configuration Release`, `-Platform x64`, `-Clean`, and
`-MySqlRoot 'C:\path\to\client'` when the install is somewhere unusual.
When no client library is found it lists the installs it did see instead of
failing with `LNK1104`.

The manual equivalent, from a *Developer PowerShell for VS 2022* window:

```powershell
msbuild "ALPHAGAME v1534.sln" /m /p:Configuration=Debug /p:Platform=Win32 /p:MySQLClientLib=libmariadb.lib
```

Output lands in `bin\Debug\Win32\` (see `OutDir` in the project files).

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

### Where the servers look for files

Every runtime path is relative to the **working directory of the process**, not
to the folder the `.exe` is in:

| what | opened as |
|---|---|
| `GameServer.ini`, `LogInServer.ini`, `AIServer.ini` | `./<name>.ini` |
| zone data | `./map/*.smd`, `./map/*.aievt` |
| quest scripts | `./Quests/*.lua` |
| log directory | `./Logs/` (created on startup) |
| `Notice.txt`, `Notice_up.txt` | `./` — optional, missing is not an error |

The intended layout is therefore **everything beside the `.exe`**, in the folder
you build into (`bin\Debug\Win32`):

```
bin\Debug\Win32\
├── GameServer.exe  LogInServer.exe  AIServer.exe
├── GameServer.ini           copied from config\ by tools\dev_run.ps1
├── LogInServer.ini
├── AIServer.ini
├── Map\                     junction to data\Map   (101 MB, not copied)
├── Quests\                  junction to data\Quests (3.2 MB)
└── Logs\                    created on startup
```

`tools\dev_run.ps1` builds that folder for you: it copies `config\*.ini` next
to the executables, creates `Map\` and `Quests\` junctions to `data\`, and
starts each server with `bin\Debug\Win32` as its working directory.

Starting the `.exe` by hand (double-click, or from any other directory) also
works: each server begins by looking for a directory that contains `Map` and
`Quests` — the current directory first, then its own folder, then `data\`
below and the parents of the `.exe` — and switches to the one it finds, printing

```
Working directory: C:\...\bin\Debug\Win32
```

as its first line. If it finds none it prints every path it tried and exits, so
a missing `Map\` never turns into a silent "zone not found" later. The `.ini`
files are not searched for: they must be in that directory, and the server warns
if its own `.ini` is missing there.

`config\*.ini` is a *copy source* — the servers never read `config\`. Edit the
copy beside the executables (or `config\` and delete the copy, and `dev_run.ps1`
puts the new one back). An earlier version of this script copied the `.ini` files
into `data\`; those copies are no longer read and can be deleted.

Which server needs what:

| file/folder | GameServer | LogInServer | AIServer |
|---|---|---|---|
| `GameServer.ini` | yes | – | – |
| `LogInServer.ini` | – | yes | – |
| `AIServer.ini` | – | – | yes |
| `Map\*.smd` | yes | – | yes |
| `Map\*.aievt` | – | – | yes |
| `Quests\*.lua` | yes | – | – |

Verified against the database dump: all 30 rows of `ZONE_INFO` have their
`.smd` present in `data\Map`, and the one zone with a room event (61) has
`61.aievt`. Two quest scripts named by `QUEST_HELPER` are absent from
`data\Quests` (`14434_highprist.lua`, `21611_delaga.lua` — `21610_delaga.lua`
exists); those NPCs log "Could not compile Lua script" when used, and nothing
else is affected.

### Both steps together

```powershell
powershell -ExecutionPolicy Bypass -File tools\dev_run.ps1
```

builds the solution, starts MySQL, waits until the schema is actually imported,
copies `config\*.ini` next to the executables, links `Map\`/`Quests\` there, and
launches **AIServer → LogInServer → GameServer** from `bin\<Config>\<Platform>\`.

It also refuses to start a binary that is older than the newest source file, and
each server prints its own build time as its first line:

```
GameServer.exe build 2026-10-28 14:02:11
Working directory: C:\...\bin\Debug\x64
```

so "the fix is in the source but not in the .exe" shows up in the log instead of
looking like a bug. `-NoBuild` skips the build (the staleness check still runs),
`-NoLaunch` stops after the database and the file layout are ready.

### What gets imported

| file | contents |
|---|---|
| `migrations/mysql/001_schema.sql` | 104 tables (types, collation, keys) |
| `migrations/mysql/005_reconstructed.sql` | the reconstructed objects **and** `SERVER_LIST` (the 105th base table) |
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
python3 tools/check_sql_syntax.py             # parses every statement (needs sqlglot)
python3 tools/check_projects.py               # .vcxproj/.sln consistency (paths, /ZI vs /Gy-)
python3 tools/check_inline_sql.py             # SQL built inside the C++, vs the schema
tools/syntax_check_db_layer.sh                # type-checks shared/database on Linux
tools/tests/run_tests.sh                      # C++ unit tests (quoting, runtime paths)
python3 tools/check_powershell.py             # native-stderr trap, dot-sources, brackets
```

All eight must print `OK` before you build or import. `check_inline_sql.py` is the
one that catches the MySQL-8 problems inside hand-written statements: a reserved
word used as a column name (`Range`), T-SQL spellings (`[Level]`, `TOP(n)`,
`ISNULL()`, `FULL OUTER JOIN`, `DATEDIFF`, `getdate()`), and column names that
the schema does not have. It checks all 65 `GetColumns()` lists (854 column names) column by
column against the table each list belongs to. `check_sql_syntax.py` is the one
that catches grammar mistakes inside stored routines without a MySQL server;
`sqlglot` is an optional install (`pip install sqlglot`) and the script says so
instead of failing when it is missing. The gzip is byte-for-byte
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

`config/*.ini` holds the templates; `tools\dev_run.ps1` copies them next to the
executables (see "Where the servers look for files"), so edit the copy there. The game server
additionally reads `[ACCOUNT_DATABASE]` (falls back to `[DATABASE]` when
absent). The committed values are the local Docker setup — change them for
anything that is not a throwaway local database, and never commit the result.

Start order: **AIServer → LogInServer → GameServer**, working directory set to
the folder containing `data\Map`.

If a server starts before the database is ready, or against an empty *or
partly imported* schema, it says so — with the table and routine counts — and
names the command to run. It no longer fails somewhere deep inside a table load.

A failed import does **not** resume: the container stops at the first bad file
and the next `docker compose up -d` finds a non-empty data directory and skips
the import. Always reset after a failure:

```powershell
docker compose down -v
docker compose up -d
```

## 4. Accounts, characters and GM

### Registration is automatic — there is nothing to enable

No registration switch, no web panel, no external account service. The login
server creates the account itself the first time a name is used:

```
migrations/mysql/004_procedures.sql   ACCOUNT_LOGIN
    SELECT COUNT(*) INTO v_count FROM TB_USER WHERE strAccountID = p_accountID;
    IF v_count = 0 THEN
        INSERT INTO TB_USER (strAccountID, strPasswd) VALUES (p_accountID, p_passwd);
```

Call site: `LogInServer/DBProcess.cpp:89`, reached from every login attempt
(`LoginSession.cpp:91`). Type an account name and password that have never been
used and the account exists from then on. The same name with a different
password returns 3 (`AUTH_INVALID`).

A fresh account has no characters: pick a nation in the client and create one
(`ACCOUNT_CHAR` holds three slots, `strCharID1..3`; `CREATE_CHARACTER` adds the
`ACCOUNT_CHAR` row itself if it is missing).

Limits enforced before the query runs (`LoginSession.cpp:148`, `MAX_ID_SIZE` /
`MAX_PW_SIZE` in `shared/globals.h`):

* **account**: letters and digits only — no spaces, `_`, `-` or symbols — 1 to 20
  characters (`WordGuardSystem`).
* **password**: at most 28 characters. The client never sends the text: it sends
  a 28-character hash (`HashPasswordString`), and that hash is what
  `TB_USER.strPasswd` holds. So never store a plaintext password there — an
  account created by hand must use the function:

```sql
-- same result the client produces for password 'test123'
CALL ACCOUNT_LOGIN(@r, 'tester', HashPasswordString('test123'));
SELECT @r;          -- 1 = account created (or password matched), 3 = wrong password
```

### The supplied data already has an account, and its character is a GM

`migrations/mysql/002_data.sql.gz` ships one account and one character:

| table | values |
|---|---|
| `TB_USER` | `admin`, `strPasswd = RQ4F74043XIKH1` |
| `ACCOUNT_CHAR` | `admin` → `bNation 2`, one slot, `strCharID1 = GiR` |
| `USERDATA` | `GiR`, level 79, zone 21, `Authority = 0` |

`RQ4F74043XIKH1` is what `HashPasswordString('admin')` returns (the port of that
function was checked against this row), so **log in as `admin` / `admin` and pick
`GiR`** — that character is already a game master.

### Authority: 0 is the GM, 1 is a player

`shared/globals.h` (`AuthorityTypes`) and `GameServer/User.h:354`:

| value | meaning |
|---|---|
| 0 | `AUTHORITY_GAME_MASTER` — full GM |
| 1 | `AUTHORITY_PLAYER` |
| 11 | muted |
| 12 | attack disabled |
| 250 | limited GM |
| 255 | banned |

Authority is **per character** (`USERDATA.Authority`), read when the character is
loaded (`DBAgent.cpp:380`). `TB_USER.strAuthority` is a different, account-level
flag (a value of 9 blocks login in `ACCOUNT_PREMIUM`).

One thing to know before letting anyone else play: `USERDATA.Authority` has
`DEFAULT 0` and `CREATE_CHARACTER` does not set it, so **every new character is
created as a GM**. The original server relied on its website to set 1, which is
what a panel was for. Without one:

```sql
SELECT strUserID, Authority, Level, Zone FROM USERDATA;          -- who is what
UPDATE USERDATA SET Authority = 1 WHERE strUserID = 'SomePlayer'; -- make normal
UPDATE USERDATA SET Authority = 0 WHERE strUserID = 'GiR';        -- make GM
```

### GM commands

Typed in normal chat with a `+` prefix (`CHAT_COMMAND_PREFIX` in
`GameServer/ChatHandler.h`), and only when `isGM()` is true — the whole table is
in `GameServer/ChatHandler.cpp:12` and `:60`.

| command | does |
|---|---|
| `+give_item <char> <itemID> [count]` | gives an item (item IDs are `ITEM.Num`) |
| `+zonechange <zoneID>` | teleport to a zone (`ZONE_INFO`) |
| `+monsummon <id>` / `+npcsummon <id>` / `+monkill` | spawn / kill monsters and NPCs |
| `+exp_change <char> <n>` / `+noah_change <char> <n>` / `+np_change <char> <n>` | add (or subtract, with a negative number) exp / gold / loyalty to an **online** player |
| `+exp_add <pct>` / `+np_add <pct>` / `+money_add <pct>` | server-wide event bonuses (0 ends) |
| `+notice <text>` / `+count` / `+kill <char>` / `+permitconnect <char>` | broadcast, who is online, disconnect, unban |
| `+reload_tables` / `+reload_magics` / `+reload_quests` / `+reload_notice` / `+reload_ranks` | reload data without restarting |
| `+open1` … `+open6`, `+close`, `+snowopen`, `+siegewarfare`, `+tp_all`, `+nt`, `+summonknights <clan>`, `+down` | war zones, teleports, nation change, shutdown |

### Refreshing the procedures by hand

The routines are created by **root** on the container's first import, so
replacing them with the application user fails:

```
ERROR 1227 (42000) at line 22: Access denied; you need (at least one of) the
SYSTEM_USER privilege(s) for this operation
```

Use root (password from `.env`, `ko1534root` by default) and let `cmd` do the
redirection, because PowerShell has no `<`:

```powershell
cmd /c "docker compose exec -T mysql mysql -uroot -pko1534root KO1534 < migrations\mysql\004_procedures.sql"
```

A reset (`docker compose down -v && docker compose up -d`) re-imports everything
as root and avoids the question.

### Do you need a web panel?

Not for testing, and not for registration on a small server: the client-side
auto-registration above covers it, and accounts created that way already carry
the correct hash. A panel only earns its keep for things the game client cannot
do — cash shop top-ups, bans while the server is down, password resets — and it
would have to reimplement `HashPasswordString` to create accounts. If you ever
want that, the simplest version is a page that runs the same
`CALL ACCOUNT_LOGIN(@r, ?, HashPasswordString(?))` against this database.

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
