-- ===========================================================================
--  KO1534  ->  MySQL 8.4 migration  :  005_reconstructed.sql
-- ===========================================================================
--
--  RECONSTRUCTED OBJECTS -- READ THIS FIRST
--  ----------------------------------------
--  The supplied dump (KO1534_sql.zip) is incomplete: four database objects
--  that the C++ server calls are simply not present in it, and the login /
--  character-select / king-election paths cannot work without them.
--
--      table  SERVER_LIST
--      proc   DELETE_CHAR              GameServer/DBAgent.cpp:237  (WIZ_DEL_CHAR)
--      proc   KING_ELECTION_RESULTS    GameServer/DBAgent.cpp:1960
--      proc   KING_UPDATE_DATABASE     GameServer/DBAgent.cpp:2060
--
--  Nothing here is copied from another KO release; each object was written
--  from the C++ call sites (parameter order, result-set column order, return
--  codes) and from the surviving sibling routines (CREATE_NEW_CHAR,
--  KING_ELECTION_PROC, KING_UPDATE_ELECTION_LIST, KING_UPDATE_ELECTION_STATUS,
--  King_user, King_Demote).  They are therefore *plausible*, not original:
--
--    * DELETE_CHAR  - column list is derived from every table that is keyed by
--                     a character name; the original may additionally have
--                     touched tables that no longer exist.
--    * KING_ELECTION_RESULTS - the 7-column result set is exact (the C++ reads
--                     positions 1..7); which rows are produced for rank 2 /
--                     rank 1 is inferred from CKingSystem::GetElectionResults.
--    * KING_UPDATE_DATABASE - maps (nation, national treasury, king tax) onto
--                     KING_SYSTEM.nNationalTreasury / nTerritoryTax.
--    * SERVER_LIST  - only GroupID, strKarusKing, strKarusKingNotice,
--                     strElmoradKing, strElmoradKingNotice are used by the
--                     server (CDBAgent::UpdateNationIntro).
--
--  Everything is idempotent: CREATE TABLE IF NOT EXISTS + DROP PROCEDURE IF
--  EXISTS, so re-running this file is safe.
-- ===========================================================================

SET NAMES latin1;
SET SESSION sql_mode='STRICT_ALL_TABLES,NO_ENGINE_SUBSTITUTION,NO_AUTO_VALUE_ON_ZERO';

-- ---------------------------------------------------------------------------
-- SERVER_LIST  (reconstructed)
--
-- One row per server group.  The game server only ever runs
--     UPDATE SERVER_LIST SET strKarusKing = ?, strKarusKingNotice = ?
--      WHERE GroupID = ?
-- so the table must have at least those columns.  The remaining columns that a
-- typical KO login server keeps here (IP, name, player caps) are *not* read by
-- this 1534 build - it takes them from LogInServer.ini [SERVER_LIST] instead -
-- so they are not invented here.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `SERVER_LIST` (
  `GroupID`            TINYINT UNSIGNED NOT NULL,
  `strKarusKing`       CHAR(21)        NULL,
  `strKarusKingNotice` VARCHAR(1024)   NULL,
  `strElmoradKing`     CHAR(21)        NULL,
  `strElmoradKingNotice` VARCHAR(1024) NULL,
  PRIMARY KEY (`GroupID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

-- One group per nation block; the game server passes GroupID = SERVER_NUM + 1.
INSERT INTO `SERVER_LIST` (`GroupID`, `strKarusKing`, `strKarusKingNotice`,
                           `strElmoradKing`, `strElmoradKingNotice`)
SELECT 1, NULL, NULL, NULL, NULL
 WHERE NOT EXISTS (SELECT 1 FROM `SERVER_LIST` WHERE `GroupID` = 1);

DELIMITER $$

-- ---------------------------------------------------------------------------
-- DELETE_CHAR  (reconstructed)
--
-- Call site:  {? = CALL DELETE_CHAR(?, %d, ?, ?)}     -- account, index, char, socno
-- Return:     0 success, -1 bad request / character not owned by the account,
--             -3 database error (-2 is the C++ "generic error" default).
--
-- The character row in USERDATA is the anchor; every other table is cleaned up
-- in the same transaction so a half-deleted character can never be selected
-- again.  Clan membership is refused by CUser::DelCharToAgent (clan leaders)
-- but plain members are unlinked from KNIGHTS_USER; the clan itself is kept.
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `DELETE_CHAR`$$
CREATE PROCEDURE `DELETE_CHAR`(
    OUT p_result    TINYINT,
    IN  p_accountID VARCHAR(21),
    IN  p_index     INT,
    IN  p_charID    VARCHAR(21),
    IN  p_socNo     VARCHAR(32))
    MODIFIES SQL DATA
proc: BEGIN
    DECLARE v_slot  VARCHAR(21) DEFAULT NULL;
    DECLARE v_nation TINYINT UNSIGNED DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result = -3;
    END;

    -- Validation: the account must exist, the slot must hold this character
    -- and the index must match the slot the client claims to delete.
    SELECT CASE p_index WHEN 0 THEN strCharID1 WHEN 1 THEN strCharID2
                        WHEN 2 THEN strCharID3 END,
           bNation
      INTO v_slot, v_nation
      FROM ACCOUNT_CHAR
     WHERE strAccountID = p_accountID
     LIMIT 1;

    IF p_index < 0 OR p_index > 2 OR v_slot IS NULL
       OR TRIM(v_slot) <> TRIM(p_charID) THEN
        SET p_result = -1;
        LEAVE proc;
    END IF;

    -- The original also compared the client's social-security number against
    -- a TB_USER column; that column does not exist in the supplied schema, so
    -- p_socNo is accepted and not verified.  (Documented in
    -- docs/MIGRATION_ASSESSMENT.md.)
    START TRANSACTION;

    DELETE FROM USERDATA                WHERE strUserID = p_charID;
    DELETE FROM USER_SAVED_MAGIC        WHERE strCharID = p_charID;
    DELETE FROM USERDATA_SKILLSHORTCUT  WHERE strCharID = p_charID;
    DELETE FROM USER_DAILY_OP           WHERE strUserID = p_charID;
    DELETE FROM USER_SEAL               WHERE strUserID = p_charID;
    DELETE FROM SEALED_ITEMS            WHERE strUserID = p_charID;
    DELETE FROM USER_RENTAL_ITEM        WHERE strUserID = p_charID;
    DELETE FROM FRIEND_LIST             WHERE strUserID = p_charID;
    DELETE FROM KNIGHTS_USER            WHERE strUserID = p_charID;
    DELETE FROM ITEMLER                 WHERE strUserId = p_charID;
    DELETE FROM WAREHOUSE_ITEMLER       WHERE strUserId = p_charID;
    DELETE FROM DELLOS_TAX              WHERE strCharID = p_charID;
    DELETE FROM KING_BALLOT_BOX         WHERE strCharID = p_charID;
    DELETE FROM KING_CANDIDACY_NOTICE_BOARD WHERE strUserID = p_charID;
    DELETE FROM KING_NOMINATION_LIST    WHERE strNominator = p_charID
                                           OR strNominee  = p_charID;
    DELETE FROM CURRENTUSER             WHERE strCharID = p_charID;

    -- Free the slot in ACCOUNT_CHAR and keep bCharNum consistent.
    UPDATE ACCOUNT_CHAR
       SET strCharID1 = IF(p_index = 0, NULL, strCharID1),
           strCharID2 = IF(p_index = 1, NULL, strCharID2),
           strCharID3 = IF(p_index = 2, NULL, strCharID3),
           bCharNum   = IF(bCharNum > 0, bCharNum - 1, 0)
     WHERE strAccountID = p_accountID;

    COMMIT;
    SET p_result = 0;
END$$

-- ---------------------------------------------------------------------------
-- KING_ELECTION_RESULTS  (reconstructed)
--
-- Call site:  {CALL KING_ELECTION_RESULTS(%d)}       -- nation
-- Result set (exact column order, read by CKingSystem::GetElectionResults):
--     1 strUserID  2 bRank  3 sClanID  4 bMonth  5 sYear
--     6 kingvotes  7 totalvotes
--
--   bRank = 2 -> senator (byType 3 list), bRank = 1 -> elected king.
--   bMonth / sYear are the next election schedule, taken from KING_SYSTEM.
--   kingvotes / totalvotes are the winner's votes and the nation's total.
--
-- Read-only on purpose: the election lists are reset by
-- KING_UPDATE_ELECTION_STATUS, which the server calls separately.
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `KING_ELECTION_RESULTS`$$
CREATE PROCEDURE `KING_ELECTION_RESULTS`(IN p_nation TINYINT UNSIGNED)
    READS SQL DATA
proc: BEGIN
    DECLARE v_month TINYINT UNSIGNED DEFAULT 0;
    DECLARE v_year  SMALLINT DEFAULT 0;
    DECLARE v_total INT DEFAULT 0;

    SELECT byMonth, sYear INTO v_month, v_year
      FROM KING_SYSTEM WHERE byNation = p_nation LIMIT 1;

    SELECT COALESCE(SUM(nMoney), 0) INTO v_total
      FROM KING_ELECTION_LIST WHERE byNation = p_nation AND byType = 4;

    SELECT r.strUserID, r.bRank, r.sClanID, r.bMonth, r.sYear,
           r.kingvotes, r.totalvotes
      FROM (
        -- senators
        SELECT l.strName AS strUserID, 2 AS bRank, l.nKnights AS sClanID,
               v_month AS bMonth, v_year AS sYear,
               0 AS kingvotes, 0 AS totalvotes
          FROM KING_ELECTION_LIST l
         WHERE l.byNation = p_nation AND l.byType = 3 AND l.strName IS NOT NULL
        UNION ALL
        -- elected king: the best-placed candidate from the vote list
        SELECT w.strName, 1, w.nKnights, v_month, v_year, w.nMoney, v_total
          FROM (SELECT strName, nKnights, nMoney
                  FROM KING_ELECTION_LIST
                 WHERE byNation = p_nation AND byType = 4 AND strName IS NOT NULL
                 ORDER BY nMoney DESC LIMIT 1) w
        UNION ALL
        -- fallback: the king row written by King_user / KING_UPDATE_ELECTION_LIST
        SELECT k.strName, 1, k.nKnights, v_month, v_year, 0, 0
          FROM KING_ELECTION_LIST k
         WHERE k.byNation = p_nation AND k.byType = 1 AND k.strName IS NOT NULL
           AND NOT EXISTS (SELECT 1 FROM KING_ELECTION_LIST v
                            WHERE v.byNation = p_nation AND v.byType = 4)
      ) r
     ORDER BY r.bRank ASC;
END$$

-- ---------------------------------------------------------------------------
-- KING_UPDATE_DATABASE  (reconstructed)
--
-- Call site:  {? = CALL KING_UPDATE_DATABASE(%d, %d, %d)}
--             nation, national treasury, king tax
-- Return:     1 updated, 0 nation not present in KING_SYSTEM, -3 error.
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `KING_UPDATE_DATABASE`$$
CREATE PROCEDURE `KING_UPDATE_DATABASE`(
    OUT p_result            SMALLINT,
    IN  p_nation            TINYINT UNSIGNED,
    IN  p_nationalTreasury  INT,
    IN  p_kingTax           INT)
    MODIFIES SQL DATA
proc: BEGIN
    DECLARE v_count INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result = -3;
    END;

    UPDATE KING_SYSTEM
       SET nNationalTreasury = p_nationalTreasury,
           nTerritoryTax     = p_kingTax
     WHERE byNation = p_nation;

    SET v_count = ROW_COUNT();
    SET p_result = IF(v_count > 0, 1, 0);
END$$

DELIMITER ;
