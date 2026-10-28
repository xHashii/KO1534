# KO1534 — MySQL 8.4 migration: inspection findings and staged plan

Status: **inspection only.** No server source has been modified yet.
Date: 2026-10-28. Baseline commit: `b0285c5`.

Legend used throughout: **[inspected]** = read/source-analysed, **[compiled]** = built
with a compiler, **[tested]** = executed automatically, **[client-verified]** = run
against the real 1534 client.

---

## 1. What is actually in the repository

| Area | Content | Size |
|---|---|---|
| C++ server | `AIServer/`, `GameServer/`, `LogInServer/`, `shared/`, `N3BASE/`, `scripting/Lua` (Lua 5.1 source) — ~72k lines `.cpp/.h` | 5 projects |
| C++ solution | `ALPHAGAME v1534.sln` — solution header says **Visual Studio 16 (2019)**, `ToolsVersion 15.0` projects, toolsets `v141_xp` / `v142` / `v143`, 8 configurations incl. `Debug-XP`, `Release-XP`, `Template` | — |
| C# rewrite | `Ko1534.sln` + `src/` (36 files, 5 projects, .NET 8) + `docs/ROADMAP.md` | to be removed |
| SQL Server dump | `KO1534_sql.zip` → one file `KO1534.sql`, **UTF-16LE**, 287 MB, 143 MB as UTF-8 | untouched |
| C# MySQL attempt | `migrations/0001_schema.sql` (tables only), `0002_data.sql.gz` + duplicate `0002_data.zip`, `0003_admin_setup.sql`, `tools/*.py`, `docker-compose.yml` (mysql:8.0) | partly reusable |
| Configs | `config/*.ini` — **C#-era format, does not match the C++ INI keys** | rewrite |
| Game data | `data/Map` (68 `.smd` + 30 `.aievt`, 101 MB), `data/Quests` (599 Lua, 3.2 MB) | usable |
| Client | **absent** — no client binaries, no `.tbl`, no `N3` resources; only `data/Map/WarpGateEditor.exe` | **blocker for client verification** |

## 2. Server components and startup order [inspected]

1. **LogInServer** (`LogInServer/main.cpp` → `LoginServer::Startup`)
   - INI `./LogInServer.ini`; reads `[ODBC] DSN, UID, PWD`, `[SETTINGS] PORT` (15100),
     `[SERVER_LIST]`, `[NEWS]`, `[DOWNLOAD]`.
   - DB work: `SELECT … FROM VERSION`, `SELECT … FROM CONCURRENT`,
     `CALL ACCOUNT_LOGIN`, `CALL ACCOUNT_PREMIUM`, `CALL ACCOUNT_LOGOUT`.
   - Protocol: `LS_VERSION_REQ (0x01)` → `uint16 __VERSION` (=1534 = `0x05FE`),
     then JvCryption key exchange, `LS_LOGIN_REQ`, `LS_SERVERLIST`, `LS_NEWS`.
2. **GameServer** (`GameServer/GameServerDlg.cpp` → `CGameServerDlg::Startup`)
   - INI `./GameServer.ini`; reads `[ODBC] GAME_DSN/GAME_UID/GAME_PWD`,
     `ACCOUNT_DSN/ACCOUNT_UID/ACCOUNT_PWD`, `GAME_MARS/ACCOUNT_MARS`, `[SETTINGS]`,
     `[BATTLE]`, `[CASTLE_BATTLE]`, `[ZONE_INFO]`, `[SG_INFO]`, `[AI_SERVER]`,
     `[CLAN_GRADE]`, `[UPGRADE_RATES]`, `[BONUS]`, `[TIMER]`.
   - Opens **two ODBC connections** (`m_GameDB`, `m_AccountDB`), loads ~50 lookup
     tables at boot via `LOAD_TABLE(...)` (`GameServer/LoadServerData.cpp`),
     clears stale `CURRENTUSER` rows, starts Lua 5.1 quest engine, listens on 15001,
     dials the AI server.
   - All per-player persistence goes through `DatabaseThread` → `CDBAgent`
     (`GameServer/DBAgent.cpp`, 2 524 lines) using `{CALL …}`/`{? = CALL …}` escapes.
3. **AIServer** (`AIServer/ServerDlg.cpp`) — INI `./AIServer.ini`, own ODBC
   connection, loads `K_MONSTER`/`K_NPCPOS`/spawn tables, reads `./map/%d.aievt`,
   talks to GameServer on 15002.

Startup is **DB-first**: the game server aborts if the database or the ~50 lookup
tables cannot be loaded.

## 3. Do client and server actually match? [inspected] — cannot be proven yet

- Server version constant: `shared/version.h` → `__VERSION 1534`, `__VERSION_GUARD 2025`.
- Version-dependent packet branches in the source are `#if __VERSION >= 1888` /
  `#if __VERSION >= 1888` style, i.e. the code is genuinely a v1534 lineage and not a
  mislabelled v1888+.
- The SQL dump is internally consistent with 1534 (104 tables, `VERSION` table,
  `ZONE_INFO` with 24 zones, `K_QUEST_HELPER` with 115 scripts).
- **The client itself is not in the repository**, so protocol compatibility,
  opcode numbering and item/UI behaviour **cannot be verified end-to-end today**.
  Everything below that says "client-verified" will stay empty until the client
  binaries are supplied.

## 4. Database surface required by the server [inspected]

- **1 database** (`KO1534`, data file + log file), compatibility level 130,
  `ANSI_PADDING OFF`, `ANSI_NULLS OFF`, `QUOTED_IDENTIFIER OFF`.
- **104 tables**, 171 461 data rows (`ITEM` 123 720, `ITEM_UPGRADE` 15 914,
  `MAKE_ITEM` 10 000, `QUEST_HELPER` 2 924, `ITEM_OP` 2 726, `K_NPCPOS` 1 900, …).
  Only `TB_USER` (1 row), `ACCOUNT_CHAR` (1), `USERDATA` (1), `WAREHOUSE` (1),
  `GAME_OPTIONS` (1) hold account/user state; `CURRENTUSER`, `USER_ITEMS` are empty.
- **104 stored procedures**, **10 scalar functions** (`HashPasswordString`, `IsBanned`,
  `isInClan`, `IsKing`, `isNationSelected`, `IsUserOnlineGame`, `IsValidCharacters`,
  `GET_ACCOUNT_NAME`, `GetNewRace`, `GET_RACE_FOR_ACCOUNT_NATION_TRANSFER`),
  **1 view** (`ACCOUNT_CHAR_VIEW`, a one-column stub), **0 triggers**.
- The C++ server calls **54 of the 104 procedures** (26 as `{? = CALL …}` with a
  return value, 28 as `{CALL …}` with OUT parameters / result sets) plus ~40 inline
  `SELECT/UPDATE/DELETE` statements.
- **9 `IDENTITY` columns** → `AUTO_INCREMENT`. 82 tables have **no primary key** at
  all — same as the original, so "duplicate row" protection stays as weak as upstream.
- **Binary blob columns** (fixed `binary(n)`, zero-padded in SQL Server):
  - `USERDATA`: `strItem` 584, `strSerial` 584, `strUserSeal` 292,
    `strItemTime` 292, `strQuest` 3888, `strQuestData` 1296
  - `WAREHOUSE`: `WarehouseData`/`strSerial` 1536, `strUserSeal`/`WarehouseDataTime` 768
  - `VIP_WAREHOUSE`: 384 / 384 / 192 / 192 — `KNIGHTS.Mark`
- **Transactions**: 10 `BEGIN TRAN`, 13 `COMMIT`, 12 `ROLLBACK` inside procedures;
  13 cursors; 12 `@@ROWCOUNT` checks; 18 `GETDATE()`; 9 `SELECT TOP`; 6 `DATEDIFF`;
  1 `DATEADD`; 5 `ISNULL`.

### Password hashing (do not lose this)

`TB_USER.strPasswd` stores the **client-computed hash** (`HashPasswordString`,
`0x03e8` seed + `0x1a1f11…` table, 28-char output). `ACCOUNT_LOGIN` compares the
received hash string to the stored value. The C# project's
`migrations/0003_admin_setup.sql` overwrote passwords with plaintext `test`, which
**breaks login with an unmodified client**. That file must not survive the migration.

## 5. What has to change in the DB access code for MySQL [inspected]

Reusing the existing ODBC abstraction (`shared/database/OdbcConnection/OdbcCommand/OdbcParameter/OdbcRecordset`)
is practical — it is plain ODBC 3 and does not reference SQL Server APIs — but these
points are MySQL-incompatible and must be fixed:

| # | Where | Problem | Required change |
|---|---|---|---|
| 1 | `OdbcConnection::Connect` | builds `DSN=<name>;UID=…;PWD=…` only | accept a full driver connection string (`DRIVER={MySQL ODBC 8.4 Unicode Driver};SERVER=…;DATABASE=…;CHARSET=utf8mb4`) |
| 2 | `OdbcCommand::Open` | issues `SET NOCOUNT ON` before every statement (SQL Server only, error currently ignored) | drop or make dialect-conditional |
| 3 | 26 call sites (`DBAgent.cpp`, `DBProcess.cpp`) | `{? = CALL proc(…)}` — MySQL ODBC only supports return values for *functions* | `{CALL proc(?OUT, …)}` + add a leading `OUT` param to each ported procedure (parameter order already matches: C++ binds the output value **first**) |
| 4 | `shared/database/OdbcCommand.h` `ADD_ODBC_PARAMETER` | passes `SQL_C_*` **C types** as the SQL data type in `SQLBindParameter`; tolerated by the SQL Server driver, rejected by MySQL Connector/ODBC | map to `SQL_BIT/TINYINT/SMALLINT/INTEGER/BIGINT/CHAR/BINARY` |
| 5 | `DBAgent.cpp` inline SQL | `[Level] [Rank] [Exp] [Zone]` bracket quoting (5 statements), `SET x += 1`, `SELECT TOP(10)`, `ISNULL()`, `DATEDIFF(HOUR,…)`, `FULL OUTER JOIN`, `GETDATE()` | rewrite as MySQL (`backticks`, `x = x + 1`, `LIMIT 10`, `IFNULL`, `TIMESTAMPDIFF`, `UNION`-based equivalent, `NOW()`) |
| 6 | procedures | `@@ROWCOUNT`, `@@ERROR`, `RETURN n`, `SELECT @v = …`, `[identifier]`, `alias = expr` in SELECT list, `GETDATE()`, `CAST(… AS VARBINARY)`, `TOP`, cursors | T-SQL → MySQL port (done per procedure, not by regex) |
| 7 | `m_bMarsEnabled` | MARS has no MySQL equivalent | keep the graceful fallback; procedures must not depend on nested active statements (the code already `release()`s commands before nested calls) |
| 8 | char/collation | dump stores padded `char(21)` (`'admin                '`); MySQL `CHAR` strips trailing spaces on store, and `utf8mb4_0900_ai_ci` is **NO PAD** | use a **PAD SPACE** collation (`utf8mb4_unicode_ci`) so `WHERE strAccountID = 'admin'` keeps matching |

## 6. Gaps and blockers found

**Blockers (need a decision; I will not invent silent replacements):**

1. **The client is not in the repo.** No end-to-end protocol verification is possible.
   Everything up to "login/character/world" can be verified at DB and socket level
   only.
2. **3 procedures called by the server are missing from the dump**:
   `DELETE_CHAR` (character deletion), `KING_ELECTION_RESULTS`,
   `KING_UPDATE_DATABASE` (king/treasury system). Their behaviour has to be
   reconstructed from the C++ call sites + known KO semantics, or deferred.
3. **`SERVER_LIST` table is referenced by the server but does not exist** in the dump
   (`DBAgent.cpp:2111,2119`, king notice broadcast).
4. **Inventory blob size mismatch**: the server serialises **74 slots**
   (`INVENTORY_TOTAL = 14+28+8+24`) = 592/592/296/296 bytes; `USERDATA` stores
   584/584/292/292 = **73 slots**. SQL Server silently truncated the last slot;
   MySQL strict mode will make the whole save fail. Recommended fix: widen the four
   columns to 592/592/296/296 and keep the load path unchanged.
5. **`LOAD_WEB_ITEMMALL` selects `WEB_ITEMMALL.itemtime`, a column that does not
   exist** in the supplied schema (broken upstream too; it only fires on the
   item-mall path).

**Non-blocking data gaps:**

- `data/Quests`: 2 of 115 referenced scripts missing
  (`14434_highprist.lua`, `21611_delaga.lua`).
- `data/Map`: 4 `ZONE_INFO` names differ only by case (`BattleZone.smd` vs
  `battlezone.smd`) — fine on Windows, fails on a case-sensitive filesystem.
- `data/Map/Map/` is a duplicate backup tree (14 files).
- `USER_ITEMS` (`nItemSerial smallint`) cannot hold the 64-bit serials the server
  generates, and `CGameServerDlg::IsDuplicateItem()` is hard-disabled
  (`return false;`). Keep as-is (matches upstream), but note it is *not* an
  anti-duplication mechanism during the inventory stage.

**Environment limits of this workspace:** no MSVC, no `wine`, no Docker, no MySQL
server binary, and outbound network is limited to GitHub/PyPI. So C++ compilation and
live MySQL execution **cannot** be done here. I will produce the code, the migration
SQL and automatically-checkable validation (SQL parsing with `sqlglot`, schema/data
fidelity diff against the dump, procedure↔call-site arity checks), and mark anything
that needs Windows/MySQL as *unverified*.

## 7. Staged plan

Every stage is independently reviewable and ends with a concrete check.

**Stage 1 — Repository cleanup + VS2022 build skeleton**
Remove `Ko1534.sln`, `src/` (C#), `docs/ROADMAP.md`, C#-only config/docs; keep
`ALPHAGAME v1534.sln`, all C++ projects, `data/`, `KO1534_sql.zip`. Rewrite
`README.md`/docs for the C++ project. Retarget solution/projects to **v143 / VS2022**,
drop `*-XP`/`Template` configs, fix hardcoded `C:\KO\…` include paths and
`$(SolutionDir)..\bin` outputs (must stay inside the repo), add `ProjectReference`
for `shared`/`Lua`, keep `Win32`+`x64`. Replace `config/*.ini` with C++-format samples
matching the INI keys the code actually reads (DSN/UID/PWD, no credentials committed).
*Check:* solution opens in VS2022, 5 projects, `msbuild /t:Restore,Build` on Windows.

**Stage 2 — MySQL schema, data and routines (no server changes yet)**
New reproducible files under `migrations/mysql/` generated from the **untouched**
`KO1534_sql.zip`: `001_schema.sql` (104 tables, indexes as in source),
`002_data.sql` (171 461 rows), `003_functions.sql` (10 functions),
`004_procedures.sql` (104 procedures, `RETURN n` → leading `OUT` param),
plus `005_grants_user.sql` and a checksum report. Nothing in the zip is edited.
*Check:* automated fidelity diff — table count, per-table row count, column type
mapping, binary-column byte-for-byte comparison, `sqlglot` MySQL parse of every file.

**Stage 3 — DB layer + call sites**
`OdbcConnection` full-driver connection strings and MySQL driver settings;
`OdbcCommand` SQL-type binding, no `NOCOUNT`; `{? = CALL}` → `{CALL}` and the 5 inline
T-SQL statements rewritten; small dialect notes in `docs/MYSQL_NOTES.md`.
*Check:* static arity/parameter check of every call site against the ported
procedure signatures.

**Stage 4 — Milestone 1 end-to-end (the requested first milestone)**
`account login → character select/create → enter world → save → disconnect →
reconnect with state intact`, driven through the real procedures.
*Checks:* (a) SQL-level replay script that performs the same CALL sequence and
asserts `USERDATA`/`CURRENTUSER`/`ACCOUNT_CHAR` state before and after a
save+reconnect; (b) socket-level replay against LogInServer/GameServer if a Windows
build is available; (c) **client-verified once the client binaries are supplied.**

**Stage 5 — Inventory, warehouse, items, clans**
Widen the inventory blobs (finding #4), verify serial round-trip (74 slots),
warehouse/VIP warehouse, `SEALED_ITEMS`/`USER_SEAL`, clan tables and the
transaction boundaries around `KNIGHTS_*` procedures. Add duplication guards that do
not change protocol behaviour (e.g. unique index on `SEALED_ITEMS.nItemSerial`,
idempotent save).

**Stage 6 — Remaining systems** — mail, rental, king/treasury, ranking, item mall,
premium, quests, and the reconstructed procedures from finding #2.

## 8. Verification status matrix (current)

| Item | Inspected | Compiled | Auto-tested | Client-verified |
|---|---|---|---|---|
| C++ source, build files, INI contract | yes | no (no MSVC here) | no | n/a |
| SQL Server dump structure (tables/rows/routines) | yes | n/a | partial (counts, refs) | n/a |
| Server ↔ database procedure usage | yes | n/a | partial (name/table refs) | n/a |
| C# ↔ C++ equivalence of `migrations/` | yes — **not equivalent** (no routines, plaintext passwords, 0003 wrong) | n/a | no | n/a |
| Client/server protocol | source-level only | no | no | **no — client absent** |

## 9. Decisions I need from you

1. **Client**: can you add the 1534 client binaries (or point at where they should go)
   so the final verification is against the real client?
2. **Missing procedures** (`DELETE_CHAR`, `KING_ELECTION_RESULTS`,
   `KING_UPDATE_DATABASE`) and the missing `SERVER_LIST` table: reconstruct them from
   the C++ call sites (documented as reconstructed), or leave them failing loudly
   until you supply the originals?
3. **Inventory blob width**: widen `USERDATA` binary columns to the 74-slot layout
   the server actually writes (recommended), or keep 73 slots and truncate
   explicitly in C++ to preserve the original on-disk width?

---

## Stage 2 status — database port (current)

### What exists now

| file | state |
|---|---|
| `migrations/mysql/001_schema.sql` | generated, 104 tables, `latin1_general_ci` |
| `migrations/mysql/002_data.sql` | generated, 171,445 INSERTs (143 MB, gitignored) |
| `migrations/mysql/003_functions.sql` | 10 functions + `ACCOUNT_CHAR_VIEW`, hand-ported |
| `migrations/mysql/004_procedures.sql` | 21 procedures (login, char select/create, save, session) |
| `migrations/mysql/005_reconstructed.sql` | `SERVER_LIST`, `DELETE_CHAR`, `KING_ELECTION_RESULTS`, `KING_UPDATE_DATABASE` |
| `migrations/mysql/006_procedures_clan_account.sql` | 18 procedures (clan, friends, seal, daily op, rename, nation transfer) |
| `migrations/mysql/007_procedures_mail_king.sql` | 13 procedures (mail box, king system) |

`tools/validate_mysql_migration.py` and `tools/check_call_sites.py` both pass:
every procedure the C++ calls (52 distinct) exists with a matching parameter
count, and the data file is structurally consistent with the schema.

### Findings worth knowing

1. **Encoding.** The dump is byte-oriented: 159,497 values are padded with byte
   `0xA0` and `varchar` columns carry opaque binary payloads. The schema is
   therefore `latin1` (1 byte = 1 character, PAD SPACE, case-insensitive), which
   keeps those bytes exactly as they were. A UTF-8 schema would double or
   corrupt them.
2. **Dumped procedures that cannot work.** Several routines in the dump declare
   a different parameter list from the C++ call site — `CHANGE_HAIR` (4 vs 6),
   `CHANGE_NEW_ID` (4 vs 5), `ACCOUNT_NATION_TRANSFER` (5 vs 1),
   `KING_CHANGE_TAX` (8 vs 4), `KING_INSERT_PRIZE_EVENT` (4 vs 5),
   `MAIL_BOX_SEND` (10 vs 11), `KING_CANDIDACY_NOTICE_BOARD_PROC` (4 vs 3),
   `DELETE_KNIGHTS` (no return value vs an output parameter). The port follows
   the **call site**, and each file documents the deviation in the routine
   header.
3. **`ROW_COUNT()` after `SELECT`.** MySQL returns -1 (not the row count), so
   `MAIL_BOX_REQUEST_LIST` computes its count explicitly instead of copying the
   T-SQL `@@ROWCOUNT` idiom.
4. **Item duplication.** `MAIL_BOX_GET_ITEM` in T-SQL selected the item and then
   flipped `bStatus` with no transaction; two concurrent requests could both
   receive the item. The port locks the row (`SELECT ... FOR UPDATE`) and flips
   the status in the same transaction.
5. **Double free in the old code.** `AIServer` and `LogInServer` called
   `delete pError` on a `MySqlError *` owned by the connection; fixed while
   porting.
6. **`NOT NULL` columns without a default.** 1,036 of them. The server inserts
   partial rows in several places (account auto-create in `ACCOUNT_LOGIN`, clan
   creation in `CREATE_KNIGHTS`, mail in `MAIL_BOX_SEND`), which on SQL Server
   failed with error 515 and would fail identically under
   `STRICT_ALL_TABLES`. Those columns now carry an explicit neutral `DEFAULT`
   (0 / '' / 1970-01-01); `KING_CANDIDACY_NOTICE_BOARD.strNotice` is the single
   binary column that had to become nullable, because InnoDB cannot give a
   `VARBINARY` a literal default. `NOT NULL` is otherwise preserved, so an
   `UPDATE` still cannot store NULL. Full list: `migrations/mysql/REPORT.md`.
7. **`SERVER_LIST` is a table the dump does not contain**, while the game server
   updates it on every king notice change. Reconstructed with the five columns
   the server actually touches.

### Not verified here

Compilation (no MSVC in this environment), the import into a live MySQL 8.4 and
the client round-trip. Stage 3 (native `libmysqlclient` client) is written but
must be compiled on Windows before any of the above can be called working.
