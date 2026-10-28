# Conversion report

Source: `KO1534_sql.zip` (unmodified).

| Item | Count |
|---|---|
| Tables | 104 |
| INSERT statements in dump | 171445 |
| Top-level INSERT statements seen by scanner | 171445 |
| INSERT statements generated | 171445 |
| Stored procedures / functions (manual port) | 118 |
| Views | 1 |

## Rows per table

| Table | Dump | Generated |
|---|---|---|
| ACCOUNT_CHAR | 1 | 1 |
| BATTLE | 1 | 1 |
| COEFFICIENT | 24 | 24 |
| CONCURRENT | 3 | 3 |
| EVENT | 43 | 43 |
| EVENT_SCHEDULER | 12 | 12 |
| EVENT_TRIGGER | 100 | 100 |
| FISHING_ITEM | 200 | 200 |
| GAME_OPTIONS | 1 | 1 |
| HOME | 2 | 2 |
| ITEM | 123720 | 123720 |
| ITEMUP_PROBABILITY | 1 | 1 |
| ITEM_EXCHANGE1 | 2333 | 2333 |
| ITEM_EXCHANGE_CRASH | 220 | 220 |
| ITEM_EXCHANGE_EXP | 194 | 194 |
| ITEM_GROUP | 7 | 7 |
| ITEM_OP | 2726 | 2726 |
| ITEM_UPGRADE | 15914 | 15914 |
| KING_SYSTEM | 2 | 2 |
| KNIGHTS | 1 | 1 |
| KNIGHTS_CAPE | 224 | 224 |
| KNIGHTS_RATING | 1 | 1 |
| KNIGHTS_SIEGE_WARFARE | 1 | 1 |
| KNIGHTS_USER | 1 | 1 |
| K_MONSTER | 1486 | 1486 |
| K_MONSTER_ITEM | 758 | 758 |
| K_NPC | 1384 | 1384 |
| K_NPCPOS | 1900 | 1900 |
| K_OBJECTPOS | 1039 | 1039 |
| LEVEL_UP | 83 | 83 |
| MAGIC | 1886 | 1886 |
| MAGIC_TYPE1 | 204 | 204 |
| MAGIC_TYPE2 | 74 | 74 |
| MAGIC_TYPE3 | 750 | 750 |
| MAGIC_TYPE4 | 692 | 692 |
| MAGIC_TYPE5 | 38 | 38 |
| MAGIC_TYPE6 | 181 | 181 |
| MAGIC_TYPE7 | 17 | 17 |
| MAGIC_TYPE8 | 32 | 32 |
| MAGIC_TYPE9 | 35 | 35 |
| MAIL_BOX | 5 | 5 |
| MAKE_DEFENSIVE | 20 | 20 |
| MAKE_ITEM | 10000 | 10000 |
| MAKE_ITEM_GRADECODE | 9 | 9 |
| MAKE_ITEM_GROUP | 34 | 34 |
| MAKE_ITEM_LARECODE | 25 | 25 |
| MAKE_WEAPON | 20 | 20 |
| MINING_ITEM | 200 | 200 |
| MONSTER_CHALLENGE | 3 | 3 |
| MONSTER_CHALLENGE_SUMMON_LIST | 168 | 168 |
| MONSTER_JURAID_MOUNTAIN_RESPAWN_LIST | 136 | 136 |
| MONSTER_RESPAWN_LIST | 14 | 14 |
| MONSTER_RESPAWN_LIST_INFORMATION | 22 | 22 |
| MONSTER_STONE_RESPAWN_LIST | 504 | 504 |
| MONSTER_SUMMON_LIST | 48 | 48 |
| MONSTER_SUMMON_LIST_ZONE | 33 | 33 |
| PREMIUM_ITEM | 6 | 6 |
| PREMIUM_ITEM_EXP | 10 | 10 |
| PREMIUM_ITEM_LETTER_GIFT | 16 | 16 |
| QUEST_HELPER | 2924 | 2924 |
| QUEST_MONSTER | 150 | 150 |
| SERVER_RESOURCE | 158 | 158 |
| SET_ITEM | 138 | 138 |
| START_POSITION | 55 | 55 |
| START_POSITION_RANDOM | 16 | 16 |
| TB_USER | 1 | 1 |
| USERDATA | 1 | 1 |
| USERDATA_SKILLSHORTCUT | 1 | 1 |
| USER_DAILY_OP | 3 | 3 |
| USER_KNIGHTS_RANK | 200 | 200 |
| USER_PERSONAL_RANK | 200 | 200 |
| USER_SAVED_MAGIC | 1 | 1 |
| VERSION | 1 | 1 |
| VOTE_REWARD_LOGS | 1 | 1 |
| WAREHOUSE | 1 | 1 |
| ZONE_INFO | 30 | 30 |

## Widened columns

* `USERDATA`.`strItem` -> VARBINARY(592) (widened from 73 slots)
* `USERDATA`.`strSerial` -> VARBINARY(592) (widened from 73 slots)
* `USERDATA`.`strUserSeal` -> VARBINARY(296) (widened from 73 slots)
* `USERDATA`.`strItemTime` -> VARBINARY(296) (widened from 73 slots)

* `USERDATA`.`strSkill` -> VARBINARY(10) (binary payload in a varchar column)
* `USERDATA_SKILLSHORTCUT`.`strSkillData` -> VARBINARY(260) (binary payload in a varchar column)

## Result

All INSERT statements accounted for: counts match the dump.
