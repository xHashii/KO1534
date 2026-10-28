# Game Data Layout

The original Knight Online 1534 server resolves all runtime game data relative to
its working directory. This rewrite keeps the same on-disk contract but moves the
root under `data/` (configurable via `GameServer.ini` -> `[Data] DataPath`).

The user's 1534 data is committed in this repository. The layout follows the
original C++ path constants:

| Constant | Original value | This repo |
|---|---|---|
| `MAP_DIR` (shared/globals.h) | `"./map/"` | `data/Map/` |
| `LUA_SCRIPT_DIRECTORY` (GameServer/LuaEngine.h) | `"./Quests/"` | `data/Quests/` |
| AI server map events (AIServer/MAP.cpp) | `MAP_DIR "%d.aievt"` | `data/Map/*.aievt` |

**Map root directory: `data/Map/`** — both `.smd` map files and `.aievt` AI
event files live here. The server working directory should be `data/` so that
`./map/` (case-insensitive on Windows) resolves to `data/Map/`.

```
data/
  Map/
    *.smd            # binary SMD map files, one per zone (31 files)
    *.aievt          # AI event files (16 files)
    Map/             # backup folder (14 .aievt files)
  Quests/
    <questname>      # Lua quest scripts (no extension)
  map/               # placeholder for original MAP_DIR layout
    .gitkeep
```

## Maps — `data/Map/*.smd`

- Format: binary **SMD** (same layout the original `SMDFile::LoadMap` parses:
  `int m_nMapSize`, `float m_fUnitDist`, then `m_nMapSize²` height floats,
  followed by collision data, object events, map tiles, regene events and the
  warp list).
- **Filename = `ZONE_INFO.strZoneName`.** The loader opens
  `MAP_DIR + strZoneName` with a case-insensitive `fopen`. So the `.smd` file on
  disk must match the zone name stored in the `ZONE_INFO` table.
  ZONE_INFO values in the 1534 dump: `karus2004.smd`, `elmo2004.smd`, etc.
- Zone↔file mapping is entirely DB-driven: `MapFileLoad()` reads
  `ServerNo, ZoneNo, strZoneName, InitX, InitZ, InitY` from `ZONE_INFO` and loads
  one `C3DMap` per row. Init coordinates are stored as `/100.0f` floats.

## AI Events — `data/Map/*.aievt`

- The AI server loads `MAP_DIR "%d.aievt"` (e.g., `1.aievt`, `2.aievt`) per zone.
- Files are in `data/Map/` (primary) and `data/Map/Map/` (backup).

## Quests — `data/Quests/`

- Format: **Lua** source files (no extension in the 1534 dump). Each is compiled
  to bytecode (`lua_dump`) and cached; executed via
  `ExecuteScript(user, npc, eventID, reward, filename, bytecode)`.
- **Filename = `K_QUEST_HELPER.strLuaFilename`.** The loader builds
  `LUA_SCRIPT_DIRECTORY + strLuaFilename`. So the file name must match the value
  stored in the `K_QUEST_HELPER` table.
- The original defaults to no cache (`LUA_SCRIPT_CACHE_DISABLED`); the rewrite
  will make caching configurable.

## SQL Dump — `KO1534_sql.zip`

- SQL Server dump of the full 1534 database (`KO1534`), 3.7 MB zipped.
- Auto-converted to MySQL migrations in `migrations/` (see `tools/convert_sql.py`).
- The large generated `migrations/0002_data.sql` is gitignored; it is loaded by
  Docker from the working tree. Regenerate with `python3 tools/convert_sql.py`.
