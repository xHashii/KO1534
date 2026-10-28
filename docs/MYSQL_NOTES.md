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
PASSWORD = change_me
CHARSET = latin1
CONNECT_TIMEOUT = 15
```

The game server reads `[ACCOUNT_DATABASE]` for the account tables and falls back
to `[DATABASE]` if it is missing. Old `[ODBC]` / `[GAME_ODBC]` / `[ACCOUNT_ODBC]`
sections are no longer read — if they are still present they are ignored.

## Verification status

| item | status |
|---|---|
| schema/data/routine generation | generated, statically validated |
| routine parameter counts vs C++ call sites | checked by `tools/check_call_sites.py` (52/52) |
| `shared/database` type-check (g++ -fsyntax-only, stub headers) | passes — `tools/syntax_check_db_layer.sh` |
| C++ build (VS2022, Win32) | **not verified** — needs Windows |
| import into MySQL 8.4 | **not verified** — needs a server |
| login / character / world round-trip with the client | **not verified** |
