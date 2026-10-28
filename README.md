# Ko1534 — Knight Online 1534 server rewrite in modern C#

A from-scratch C# rewrite of the **ALPHAGAME v1534** Knight Online server
(`__VERSION 1534`). The original C++ sources are kept in this repository as the
authoritative reference; the new implementation lives under `src/`.

The original targets Windows / Winsock2 IOCP / ODBC (SQL Server). The rewrite
targets **.NET 8** with **MySQL 8** (run in Docker) and reproduces the KO
wire protocol (framing + `JvCryption` crypto) byte-for-byte.

## Repository layout

```
Ko1534.sln                     # .NET 8 solution
src/Ko1534.Shared/              # foundation: packets, crypto, config, logging, database
src/Ko1534.LogInServer/         # login server (M2)
src/Ko1534.GameServer/         # game server (stub — M3+)
src/Ko1534.AIServer/           # AI server (stub — M8+)
config/                        # sample .ini configs (no real credentials)
docker-compose.yml             # local MySQL 8 (auto-loads migrations)
docs/ROADMAP.md                # milestone plan and status
migrations/                    # MySQL schema/migrations (from the SQL Server dump)
data/                          # maps (.smd), AI events (.aievt), quests (Lua)
```

The legacy C++ projects (`AIServer/`, `GameServer/`, `LogInServer/`, `shared/`,
`scripting/`, `N3BASE/`) are retained as reference only.

## Prerequisites

- .NET 8 SDK
- Docker (for MySQL) — or a reachable MySQL 8 server

## Build

```powershell
dotnet build Ko1534.sln -c Release
```

## Start MySQL

```powershell
docker compose up -d
```

The Docker MySQL image auto-loads `migrations/0001_schema.sql` and
`migrations/0002_data.sql.gz` on first startup (alphabetical order).

## Run the login server

```powershell
dotnet run --project src/Ko1534.LogInServer -c Release -- config/LogInServer.ini
```

It listens on `0.0.0.0:15100` and logs to `./Logs/`.

## Configuration & secrets

- Sample configs live in `config/`. Copy and edit; do **not** commit real
  credentials.
- `.gitignore` excludes `*.local.ini`, `*.secret.ini`, `.env`, and database
  dumps.
- Logs never record passwords (a deliberate improvement over the original, which
  logged them).

## Status

See `docs/ROADMAP.md` for the milestone plan and per-milestone verification
status. Current: **M0 (hygiene) + M1 (foundation) + M2 (login) done.**
