# Ko1534 Implementation Roadmap

Each phase produces a runnable milestone. Verification = `dotnet build` (Debug)
+ `dotnet run` + matching-client checklist. The original C++ sources are the
source of truth for behavior.

## Phase 0 — Foundation ✅ (Rebuilt)

Project scaffold, shared library, config, logging, database layer.

| Milestone | Status | What |
|---|---|---|
| **M0** Repo hygiene | ✅ | `.gitignore`, removed C# build artifacts, solution, Docker |
| **M1** Shared library | ✅ | ByteBuffer, Packet, PacketOpcodes, Crc32, JvCryption, IniFile, ServerConfig, Logger, Database |
| **M2** Login server | ✅ | LoginSession framing, 7 login opcodes, inlined auth (TB_USER/CURRENTUSER), SQL migrations, configs |

## Phase 1 — Game Server Core

Get a character into the world and move around.

| Milestone | Status | What |
|---|---|---|
| **M3** Game server auth & character flow | ⬜ Next | `WIZ_VERSION_CHECK` → `WIZ_LOGIN` → `WIZ_SEL_NATION` → `WIZ_ALLCHAR_INFO_REQ` → `WIZ_NEW_CHAR/DEL_CHAR/SEL_CHAR` → `WIZ_GAMESTART` → `WIZ_MYINFO` |
| **M4** World basics | ⬜ | Move/rotate/attack, chat, region user/NPC in/out, regeneration, weather/time, warp |
| **M5** AI server | ⬜ | Monster AI, zone event scripts (`.aievt`), game↔AI integration, battle zones |

## Phase 2 — Systems & Economy

| Milestone | Status | What |
|---|---|---|
| **M6** Items & economy | ⬜ | Inventory, warehouse, trade, merchant, letters, USER_ITEMS |
| **M7** Magic, NPCs, quests (Lua 5.1) | ⬜ | Magic tables, NPC scripts, Lua quest engine (replaces vendored Lua interpreter) |

## Phase 3 — Social & Events

| Milestone | Status | What |
|---|---|---|
| **M8** Knights/clan, king system, events, BBS | ⬜ | KNIGHTS_USER, clan management, king/castle, events, bulletin board |
| **M9** Siege & nation | ⬜ | Castle siege, nation transfer queue, PvP zones |

## Phase 4 — Hardening

| Milestone | Status | What |
|---|---|---|
| **M10** Production readiness | ⬜ | Versioned migrations, transactions, backups, Docker images, performance, final verification |

---

## Current State (Phase 0 complete, Phase 1 next)

**What works:** Login server compiles and runs. Connects to MySQL, loads
VERSION/CONCURRENT tables, accepts client connections, handles all 7 login
opcodes. Auth is inlined in C# (no stored procedures) matching the original
`ACCOUNT_LOGIN`/`ACCOUNT_PREMIUM` semantics.

**What's next: M3 — Game server auth & character flow.**

The game server needs:
1. Game server wire protocol (encrypted, CRC32) — extend the shared KOSocket pattern for game-server-specific framing.
2. `GAME_LOGIN` — account-to-session binding, check if account is already in game (`CURRENTUSER` table), insert/update session.
3. `NATION_SELECT` — assign nation (Karus/El Morad), update `TB_USER`.
4. `ALLCHAR_INFO_REQ` — load character list from `ACCOUNT_CHAR`.
5. `NEW_CHAR` / `DEL_CHAR` / `SEL_CHAR` — create/delete/select character.
6. `GAMESTART` — transition to game state, load user data from `USERDATA`.
7. `MYINFO` — send full user info (stats, items, magic, etc.).

**Data path:** `data/Map/*.smd` (maps), `data/Map/*.aievt` (AI events),
`data/Quests/*` (Lua quest scripts). Server working directory = `data/`.

## Database

SQL Server dump (`KO1534_sql.zip`) auto-converted to MySQL migrations:
- `migrations/0001_schema.sql` — 104 tables (committed)
- `migrations/0002_data.sql.gz` — 171k inserts (committed, auto-loaded by Docker)
- `tools/convert_sql.py` — regeneration script

Key tables: `TB_USER` (accounts), `ACCOUNT_CHAR` (characters), `CURRENTUSER`
(session tracking), `KNIGHTS_USER` (clan), `PREMIUM_SERVICE_USER`, `ZONE_INFO`
(zone↔map mapping), `CONCURRENT` (user counts), `BATTLE`, `COEFFICIENT`,
`USER_ITEMS`, `USER_DAILY_OP`.

No stored procedures — all auth logic is inlined in C# repositories.

## Build & Run

```bash
# Build
dotnet build Ko1534.sln -c Release

# Start MySQL (auto-loads migrations on first run)
docker compose up -d

# Run the login server
dotnet run --project src/Ko1534.LogInServer -c Release -- config/LogInServer.ini
```

## Matching-Client Test Checklist (Login Server)

1. Start MySQL (`docker compose up -d`) — confirms "Connected to database server."
2. Run the login server; confirm it logs listening on port 15100.
3. Launch the 1534 client; point it at the login server IP:15100.
4. Expect: `LS_VERSION_REQ (0x01)` → version `0x05FE` (1534).
5. Expect: `LS_CRYPTION (0xF2)` → public key, then crypto enabled.
6. Expect: `LS_LOGIN_REQ (0xF3)` → result code; `SUCCESS` for a valid account.
7. Expect: `LS_SERVERLIST (0xF5)` → server list from INI + CONCURRENT.
8. Expect: `LS_NEWS (0xF6)` → news from INI.
9. Negative tests: bad account → `NOT FOUND`; bad password → `INVALID`.

**Sample admin account** (from the SQL dump): `admin` / `RQ4F74043XIKH1`
