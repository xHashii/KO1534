-- ===========================================================================
--  KO1534  ->  MySQL 8.4 migration  :  006_procedures_clan_account.sql
-- ===========================================================================
--
--  Clan / friends / name change / seal / daily-op / account routines.
--
--  Porting conventions are the same as in 003_functions.sql / 004_procedures.sql:
--    * T-SQL `RETURN n`            -> leading OUT parameter (C++ binds the
--                                     output parameter first), then LEAVE.
--    * `SELECT @x = col`           -> `SELECT col INTO v_x`.
--    * `@@ROWCOUNT`                -> ROW_COUNT() (careful: it reflects the
--                                     last statement, so it is captured at once).
--    * `col += n`                  -> `col = col + n`.
--    * `@@ERROR`                   -> DECLARE EXIT HANDLER FOR SQLEXCEPTION.
--    * reserved words (`Rank`, `Class`, `Level`, `Exp`, `Zone`, `Gold`) are
--      backticked.
--
--  Where a routine in the dump disagrees with the C++ call site (parameter
--  count or order), the CALL SITE WINS and the deviation is documented in the
--  routine header, because a mismatch means the original call could never have
--  succeeded.
-- ===========================================================================

SET NAMES latin1;
SET SESSION sql_mode='STRICT_ALL_TABLES,NO_ENGINE_SUBSTITUTION,NO_AUTO_VALUE_ON_ZERO';

DELIMITER $$

-- ---------------------------------------------------------------------------
-- UPDATE_SAVED_MAGIC
--   call site: {CALL UPDATE_SAVED_MAGIC(?, 19 ints)}   (DBAgent.cpp:757)
--   Upserts the 10 memorised skills.  Nothing is returned.
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `UPDATE_SAVED_MAGIC`$$
CREATE PROCEDURE `UPDATE_SAVED_MAGIC`(
    IN p_charID VARCHAR(21),
    IN p_s1 INT, IN p_d1 SMALLINT, IN p_s2 INT, IN p_d2 SMALLINT,
    IN p_s3 INT, IN p_d3 SMALLINT, IN p_s4 INT, IN p_d4 SMALLINT,
    IN p_s5 INT, IN p_d5 SMALLINT, IN p_s6 INT, IN p_d6 SMALLINT,
    IN p_s7 INT, IN p_d7 SMALLINT, IN p_s8 INT, IN p_d8 SMALLINT,
    IN p_s9 INT, IN p_d9 SMALLINT, IN p_s10 INT, IN p_d10 SMALLINT)
    MODIFIES SQL DATA
BEGIN
    DECLARE v_count INT DEFAULT 0;

    SELECT COUNT(*) INTO v_count FROM USER_SAVED_MAGIC WHERE strCharID = p_charID;

    IF v_count = 0 THEN
        INSERT INTO USER_SAVED_MAGIC (strCharID,
            nSkill1, nDuring1, nSkill2, nDuring2, nSkill3, nDuring3,
            nSkill4, nDuring4, nSkill5, nDuring5, nSkill6, nDuring6,
            nSkill7, nDuring7, nSkill8, nDuring8, nSkill9, nDuring9,
            nSkill10, nDuring10)
        VALUES (p_charID,
            p_s1, p_d1, p_s2, p_d2, p_s3, p_d3,
            p_s4, p_d4, p_s5, p_d5, p_s6, p_d6,
            p_s7, p_d7, p_s8, p_d8, p_s9, p_d9,
            p_s10, p_d10);
    ELSE
        UPDATE USER_SAVED_MAGIC SET
            nSkill1 = p_s1, nDuring1 = p_d1, nSkill2 = p_s2, nDuring2 = p_d2,
            nSkill3 = p_s3, nDuring3 = p_d3, nSkill4 = p_s4, nDuring4 = p_d4,
            nSkill5 = p_s5, nDuring5 = p_d5, nSkill6 = p_s6, nDuring6 = p_d6,
            nSkill7 = p_s7, nDuring7 = p_d7, nSkill8 = p_s8, nDuring8 = p_d8,
            nSkill9 = p_s9, nDuring9 = p_d9, nSkill10 = p_s10, nDuring10 = p_d10
        WHERE strCharID = p_charID;
    END IF;
END$$

-- ---------------------------------------------------------------------------
-- USER_ITEM_SEAL
--   call site: {? = CALL USER_ITEM_SEAL(?, ?, ?, I64FMTD, %d, %d)}  (:898)
--   4 = wrong seal password, 1 = ok, 2 = unknown seal type.
--   bSealType 1/3 seal the item, 2 unseals it.
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `USER_ITEM_SEAL`$$
CREATE PROCEDURE `USER_ITEM_SEAL`(
    OUT p_result      TINYINT,
    IN  p_accountID   VARCHAR(21),
    IN  p_charID      VARCHAR(21),
    IN  p_passwd      VARCHAR(8),
    IN  p_itemSerial  BIGINT,
    IN  p_itemID      INT,
    IN  p_sealType    TINYINT UNSIGNED)
    MODIFIES SQL DATA
proc: BEGIN
    DECLARE v_passwd VARCHAR(8) DEFAULT NULL;

    SELECT strSealPasswd INTO v_passwd
      FROM TB_USER WHERE strAccountID = p_accountID LIMIT 1;

    IF p_sealType < 3 AND (v_passwd IS NULL OR TRIM(v_passwd) <> TRIM(p_passwd)) THEN
        SET p_result = 4;
        LEAVE proc;
    END IF;

    IF p_sealType IN (1, 3) THEN
        INSERT INTO SEALED_ITEMS (strAccountID, strUserID, nItemSerial, nItemID, bSealType)
        VALUES (p_accountID, p_charID, p_itemSerial, p_itemID, p_sealType);
    ELSEIF p_sealType = 2 THEN
        DELETE FROM SEALED_ITEMS
         WHERE strAccountID = p_accountID AND strUserID = p_charID
           AND nItemSerial = p_itemSerial AND nItemID = p_itemID;
    ELSE
        SET p_result = 2;
        LEAVE proc;
    END IF;

    SET p_result = 1;
END$$

-- ---------------------------------------------------------------------------
-- INSERT_USER_SEALED
--   call site: {CALL INSERT_USER_SEALED(?, ?, 11 ints, ?, ?)}      (:2426)
--   Stores the sealed character snapshot.  USER_SEAL.bSkillPoints is
--   BINARY(50) in the dump but the procedure only sends 10 bytes; the parameter
--   is therefore VARBINARY(50) (BINARY would be zero padded on read).
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `INSERT_USER_SEALED`$$
CREATE PROCEDURE `INSERT_USER_SEALED`(
    IN p_userID     VARCHAR(21),
    IN p_serial     BINARY(8),
    IN p_sealSerial INT,
    IN p_raceSatis  TINYINT UNSIGNED,
    IN p_class      SMALLINT,
    IN p_level      TINYINT UNSIGNED,
    IN p_expPercent SMALLINT,
    IN p_str        TINYINT UNSIGNED,
    IN p_sta        TINYINT UNSIGNED,
    IN p_dex        TINYINT UNSIGNED,
    IN p_intel      TINYINT UNSIGNED,
    IN p_cha        TINYINT UNSIGNED,
    IN p_gold       INT,
    IN p_skill      VARBINARY(50),
    IN p_item       VARBINARY(670))
    MODIFIES SQL DATA
BEGIN
    DELETE FROM USER_SEAL WHERE strUserID = p_userID;

    INSERT INTO USER_SEAL (strUserID, strSerial, SealSerial, bRaceSatis, sClass,
                           bLevel, lExp, Stat_STR, Stat_STA, Stat_DEX, Stat_INT,
                           Stat_CHA, bGold, bSkillPoints, strItem)
    VALUES (p_userID, p_serial, p_sealSerial, p_raceSatis, p_class,
            p_level, p_expPercent, p_str, p_sta, p_dex, p_intel,
            p_cha, p_gold, p_skill, p_item);
END$$

-- ---------------------------------------------------------------------------
-- INSERT_FRIEND_LIST / DELETE_FRIEND_LIST
--   call sites: {? = CALL INSERT_FRIEND_LIST(?, ?)}   (DBAgent.cpp:943)
--               {? = CALL DELETE_FRIEND_LIST(?, ?)}   (DBAgent.cpp:961)
--   0 = ok, 1 = no friend list row / insert failed, 2 = no free slot (insert)
--   or friend not in the list (delete).  Exactly the original codes.
--
--   The original reads all 24 slots into 24 T-SQL variables and then walks an
--   IF/ELSE IF chain; here the slot index is computed with one CASE expression
--   and applied with a CASE statement, which is the same logic with one round
--   trip instead of one per candidate slot.
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `INSERT_FRIEND_LIST`$$
CREATE PROCEDURE `INSERT_FRIEND_LIST`(
    OUT p_result    TINYINT,
    IN  p_userID    VARCHAR(21),
    IN  p_friend    VARCHAR(21))
    MODIFIES SQL DATA
proc: BEGIN
    DECLARE v_count INT DEFAULT 0;
    DECLARE v_slot  INT DEFAULT NULL;

    SELECT COUNT(*) INTO v_count FROM FRIEND_LIST WHERE strUserID = p_userID;
    IF v_count = 0 THEN
        INSERT INTO FRIEND_LIST (strUserID, strFriend1) VALUES (p_userID, p_friend);
        SET p_result = 0;
        LEAVE proc;
    END IF;

    SELECT CASE
               WHEN strFriend1 IS NULL THEN 1
               WHEN strFriend2 IS NULL THEN 2
               WHEN strFriend3 IS NULL THEN 3
               WHEN strFriend4 IS NULL THEN 4
               WHEN strFriend5 IS NULL THEN 5
               WHEN strFriend6 IS NULL THEN 6
               WHEN strFriend7 IS NULL THEN 7
               WHEN strFriend8 IS NULL THEN 8
               WHEN strFriend9 IS NULL THEN 9
               WHEN strFriend10 IS NULL THEN 10
               WHEN strFriend11 IS NULL THEN 11
               WHEN strFriend12 IS NULL THEN 12
               WHEN strFriend13 IS NULL THEN 13
               WHEN strFriend14 IS NULL THEN 14
               WHEN strFriend15 IS NULL THEN 15
               WHEN strFriend16 IS NULL THEN 16
               WHEN strFriend17 IS NULL THEN 17
               WHEN strFriend18 IS NULL THEN 18
               WHEN strFriend19 IS NULL THEN 19
               WHEN strFriend20 IS NULL THEN 20
               WHEN strFriend21 IS NULL THEN 21
               WHEN strFriend22 IS NULL THEN 22
               WHEN strFriend23 IS NULL THEN 23
               WHEN strFriend24 IS NULL THEN 24
               ELSE NULL
           END
      INTO v_slot
      FROM FRIEND_LIST WHERE strUserID = p_userID LIMIT 1;

    IF v_slot IS NULL THEN
        SET p_result = 2;
        LEAVE proc;
    END IF;

    CASE v_slot
        WHEN 1 THEN UPDATE FRIEND_LIST SET strFriend1 = p_friend WHERE strUserID = p_userID;
        WHEN 2 THEN UPDATE FRIEND_LIST SET strFriend2 = p_friend WHERE strUserID = p_userID;
        WHEN 3 THEN UPDATE FRIEND_LIST SET strFriend3 = p_friend WHERE strUserID = p_userID;
        WHEN 4 THEN UPDATE FRIEND_LIST SET strFriend4 = p_friend WHERE strUserID = p_userID;
        WHEN 5 THEN UPDATE FRIEND_LIST SET strFriend5 = p_friend WHERE strUserID = p_userID;
        WHEN 6 THEN UPDATE FRIEND_LIST SET strFriend6 = p_friend WHERE strUserID = p_userID;
        WHEN 7 THEN UPDATE FRIEND_LIST SET strFriend7 = p_friend WHERE strUserID = p_userID;
        WHEN 8 THEN UPDATE FRIEND_LIST SET strFriend8 = p_friend WHERE strUserID = p_userID;
        WHEN 9 THEN UPDATE FRIEND_LIST SET strFriend9 = p_friend WHERE strUserID = p_userID;
        WHEN 10 THEN UPDATE FRIEND_LIST SET strFriend10 = p_friend WHERE strUserID = p_userID;
        WHEN 11 THEN UPDATE FRIEND_LIST SET strFriend11 = p_friend WHERE strUserID = p_userID;
        WHEN 12 THEN UPDATE FRIEND_LIST SET strFriend12 = p_friend WHERE strUserID = p_userID;
        WHEN 13 THEN UPDATE FRIEND_LIST SET strFriend13 = p_friend WHERE strUserID = p_userID;
        WHEN 14 THEN UPDATE FRIEND_LIST SET strFriend14 = p_friend WHERE strUserID = p_userID;
        WHEN 15 THEN UPDATE FRIEND_LIST SET strFriend15 = p_friend WHERE strUserID = p_userID;
        WHEN 16 THEN UPDATE FRIEND_LIST SET strFriend16 = p_friend WHERE strUserID = p_userID;
        WHEN 17 THEN UPDATE FRIEND_LIST SET strFriend17 = p_friend WHERE strUserID = p_userID;
        WHEN 18 THEN UPDATE FRIEND_LIST SET strFriend18 = p_friend WHERE strUserID = p_userID;
        WHEN 19 THEN UPDATE FRIEND_LIST SET strFriend19 = p_friend WHERE strUserID = p_userID;
        WHEN 20 THEN UPDATE FRIEND_LIST SET strFriend20 = p_friend WHERE strUserID = p_userID;
        WHEN 21 THEN UPDATE FRIEND_LIST SET strFriend21 = p_friend WHERE strUserID = p_userID;
        WHEN 22 THEN UPDATE FRIEND_LIST SET strFriend22 = p_friend WHERE strUserID = p_userID;
        WHEN 23 THEN UPDATE FRIEND_LIST SET strFriend23 = p_friend WHERE strUserID = p_userID;
        WHEN 24 THEN UPDATE FRIEND_LIST SET strFriend24 = p_friend WHERE strUserID = p_userID;
    END CASE;

    SET p_result = 0;
END$$

DROP PROCEDURE IF EXISTS `DELETE_FRIEND_LIST`$$
CREATE PROCEDURE `DELETE_FRIEND_LIST`(
    OUT p_result    TINYINT,
    IN  p_userID    VARCHAR(21),
    IN  p_friend    VARCHAR(21))
    MODIFIES SQL DATA
proc: BEGIN
    DECLARE v_count INT DEFAULT 0;
    DECLARE v_slot  INT DEFAULT NULL;

    SELECT COUNT(*) INTO v_count FROM FRIEND_LIST WHERE strUserID = p_userID;
    IF v_count = 0 THEN
        SET p_result = 1;
        LEAVE proc;
    END IF;

    SELECT CASE
               WHEN strFriend1 = p_friend THEN 1
               WHEN strFriend2 = p_friend THEN 2
               WHEN strFriend3 = p_friend THEN 3
               WHEN strFriend4 = p_friend THEN 4
               WHEN strFriend5 = p_friend THEN 5
               WHEN strFriend6 = p_friend THEN 6
               WHEN strFriend7 = p_friend THEN 7
               WHEN strFriend8 = p_friend THEN 8
               WHEN strFriend9 = p_friend THEN 9
               WHEN strFriend10 = p_friend THEN 10
               WHEN strFriend11 = p_friend THEN 11
               WHEN strFriend12 = p_friend THEN 12
               WHEN strFriend13 = p_friend THEN 13
               WHEN strFriend14 = p_friend THEN 14
               WHEN strFriend15 = p_friend THEN 15
               WHEN strFriend16 = p_friend THEN 16
               WHEN strFriend17 = p_friend THEN 17
               WHEN strFriend18 = p_friend THEN 18
               WHEN strFriend19 = p_friend THEN 19
               WHEN strFriend20 = p_friend THEN 20
               WHEN strFriend21 = p_friend THEN 21
               WHEN strFriend22 = p_friend THEN 22
               WHEN strFriend23 = p_friend THEN 23
               WHEN strFriend24 = p_friend THEN 24
               ELSE NULL
           END
      INTO v_slot
      FROM FRIEND_LIST WHERE strUserID = p_userID LIMIT 1;

    IF v_slot IS NULL THEN
        SET p_result = 2;
        LEAVE proc;
    END IF;

    CASE v_slot
        WHEN 1 THEN UPDATE FRIEND_LIST SET strFriend1 = NULL WHERE strUserID = p_userID;
        WHEN 2 THEN UPDATE FRIEND_LIST SET strFriend2 = NULL WHERE strUserID = p_userID;
        WHEN 3 THEN UPDATE FRIEND_LIST SET strFriend3 = NULL WHERE strUserID = p_userID;
        WHEN 4 THEN UPDATE FRIEND_LIST SET strFriend4 = NULL WHERE strUserID = p_userID;
        WHEN 5 THEN UPDATE FRIEND_LIST SET strFriend5 = NULL WHERE strUserID = p_userID;
        WHEN 6 THEN UPDATE FRIEND_LIST SET strFriend6 = NULL WHERE strUserID = p_userID;
        WHEN 7 THEN UPDATE FRIEND_LIST SET strFriend7 = NULL WHERE strUserID = p_userID;
        WHEN 8 THEN UPDATE FRIEND_LIST SET strFriend8 = NULL WHERE strUserID = p_userID;
        WHEN 9 THEN UPDATE FRIEND_LIST SET strFriend9 = NULL WHERE strUserID = p_userID;
        WHEN 10 THEN UPDATE FRIEND_LIST SET strFriend10 = NULL WHERE strUserID = p_userID;
        WHEN 11 THEN UPDATE FRIEND_LIST SET strFriend11 = NULL WHERE strUserID = p_userID;
        WHEN 12 THEN UPDATE FRIEND_LIST SET strFriend12 = NULL WHERE strUserID = p_userID;
        WHEN 13 THEN UPDATE FRIEND_LIST SET strFriend13 = NULL WHERE strUserID = p_userID;
        WHEN 14 THEN UPDATE FRIEND_LIST SET strFriend14 = NULL WHERE strUserID = p_userID;
        WHEN 15 THEN UPDATE FRIEND_LIST SET strFriend15 = NULL WHERE strUserID = p_userID;
        WHEN 16 THEN UPDATE FRIEND_LIST SET strFriend16 = NULL WHERE strUserID = p_userID;
        WHEN 17 THEN UPDATE FRIEND_LIST SET strFriend17 = NULL WHERE strUserID = p_userID;
        WHEN 18 THEN UPDATE FRIEND_LIST SET strFriend18 = NULL WHERE strUserID = p_userID;
        WHEN 19 THEN UPDATE FRIEND_LIST SET strFriend19 = NULL WHERE strUserID = p_userID;
        WHEN 20 THEN UPDATE FRIEND_LIST SET strFriend20 = NULL WHERE strUserID = p_userID;
        WHEN 21 THEN UPDATE FRIEND_LIST SET strFriend21 = NULL WHERE strUserID = p_userID;
        WHEN 22 THEN UPDATE FRIEND_LIST SET strFriend22 = NULL WHERE strUserID = p_userID;
        WHEN 23 THEN UPDATE FRIEND_LIST SET strFriend23 = NULL WHERE strUserID = p_userID;
        WHEN 24 THEN UPDATE FRIEND_LIST SET strFriend24 = NULL WHERE strUserID = p_userID;
    END CASE;

    SET p_result = 0;
END$$

-- ---------------------------------------------------------------------------
-- CREATE_KNIGHTS
--   call site: {? = CALL CREATE_KNIGHTS(%d, %d, %d, ?, ?)}          (:1122)
--   returns 0 ok, 3 name taken, 6 database error (C++ maps the rest itself).
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `CREATE_KNIGHTS`$$
CREATE PROCEDURE `CREATE_KNIGHTS`(
    OUT p_result    TINYINT,
    IN  p_clanID    SMALLINT,
    IN  p_nation    TINYINT UNSIGNED,
    IN  p_flag      TINYINT UNSIGNED,
    IN  p_name      VARCHAR(21),
    IN  p_chief     VARCHAR(21))
    MODIFIES SQL DATA
proc: BEGIN
    DECLARE v_count INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result = 6;
    END;

    SELECT COUNT(*) INTO v_count FROM KNIGHTS WHERE IDName = p_name;
    IF v_count > 0 THEN
        SET p_result = 3;
        LEAVE proc;
    END IF;

    START TRANSACTION;

    INSERT INTO KNIGHTS (IDNum, Nation, Flag, IDName, Chief, Members, dtCreateTime)
    VALUES (p_clanID, p_nation, p_flag, p_name, p_chief, 1, NOW(3));

    INSERT INTO KNIGHTS_USER (sIDNum, strUserID) VALUES (p_clanID, p_chief);
    UPDATE USERDATA SET Knights = p_clanID, Fame = 0 WHERE strUserID = p_chief;

    COMMIT;
    SET p_result = 0;
END$$

-- ---------------------------------------------------------------------------
-- UPDATE_KNIGHTS
--   call site: {? = CALL UPDATE_KNIGHTS(%d, ?, %d, %d)}            (:1138)
--              (bType + 0x10, charID, clanID, domination)
--   0 ok, 2 char missing / db error, 7 no such clan, 8 clan full / limit.
--   Membership changes are wrapped in one transaction so that a failure can
--   never leave a character half-joined (duplication / data-loss guard).
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `UPDATE_KNIGHTS`$$
CREATE PROCEDURE `UPDATE_KNIGHTS`(
    OUT p_result     TINYINT,
    IN  p_type       TINYINT UNSIGNED,
    IN  p_charID     VARCHAR(21),
    IN  p_clanID     SMALLINT,
    IN  p_domination TINYINT UNSIGNED)
    MODIFIES SQL DATA
proc: BEGIN
    DECLARE v_clanCount  INT DEFAULT 0;
    DECLARE v_members    SMALLINT DEFAULT 0;
    DECLARE v_userCount  INT DEFAULT 0;
    DECLARE v_charCount  INT DEFAULT 0;
    DECLARE v_vc1 VARCHAR(21) DEFAULT NULL;
    DECLARE v_vc2 VARCHAR(21) DEFAULT NULL;
    DECLARE v_vc3 VARCHAR(21) DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result = 2;
    END;

    SELECT COUNT(*) INTO v_clanCount FROM KNIGHTS WHERE IDNum = p_clanID;
    IF v_clanCount = 0 THEN
        SET p_result = 7;
        LEAVE proc;
    END IF;

    SELECT Members, ViceChief_1, ViceChief_2, ViceChief_3
      INTO v_members, v_vc1, v_vc2, v_vc3
      FROM KNIGHTS WHERE IDNum = p_clanID LIMIT 1;

    IF p_type = 18 THEN
        SELECT COUNT(*) INTO v_userCount FROM USERDATA WHERE Knights = p_clanID;
        IF v_members >= 36 OR v_userCount >= 36 THEN
            SET p_result = 8;
            LEAVE proc;
        END IF;
    ELSEIF v_members > 36 THEN
        SET p_result = 8;
        LEAVE proc;
    END IF;

    SELECT COUNT(*) INTO v_charCount FROM USERDATA WHERE strUserID = p_charID;
    IF v_charCount = 0 THEN
        SET p_result = 2;
        LEAVE proc;
    END IF;

    START TRANSACTION;

    IF p_type = 18 THEN                                  -- join
        UPDATE KNIGHTS SET Members = Members + 1 WHERE IDNum = p_clanID;
        INSERT INTO KNIGHTS_USER (sIDNum, strUserID) VALUES (p_clanID, p_charID);
        UPDATE USERDATA SET Knights = p_clanID WHERE strUserID = p_charID;

    ELSEIF p_type IN (19, 20, 23) THEN                   -- withdraw/remove/reject
        IF v_members <= 1 THEN
            UPDATE KNIGHTS SET Members = 1 WHERE IDNum = p_clanID;
        ELSE
            UPDATE KNIGHTS SET Members = Members - 1 WHERE IDNum = p_clanID;
        END IF;

        DELETE FROM KNIGHTS_USER WHERE strUserID = p_charID;

        IF v_vc1 = p_charID THEN
            UPDATE KNIGHTS SET ViceChief_1 = NULL WHERE IDNum = p_clanID;
        END IF;
        IF v_vc2 = p_charID THEN
            UPDATE KNIGHTS SET ViceChief_2 = NULL WHERE IDNum = p_clanID;
        END IF;
        IF v_vc3 = p_charID THEN
            UPDATE KNIGHTS SET ViceChief_3 = NULL WHERE IDNum = p_clanID;
        END IF;

    ELSEIF p_type IN (25, 95) THEN                       -- new chief / handover
        UPDATE KNIGHTS SET Chief = p_charID WHERE IDNum = p_clanID;

        IF v_vc1 = p_charID THEN
            UPDATE KNIGHTS SET ViceChief_1 = NULL WHERE IDNum = p_clanID;
        END IF;
        IF v_vc2 = p_charID THEN
            UPDATE KNIGHTS SET ViceChief_2 = NULL WHERE IDNum = p_clanID;
        END IF;
        IF v_vc3 = p_charID THEN
            UPDATE KNIGHTS SET ViceChief_3 = NULL WHERE IDNum = p_clanID;
        END IF;

    ELSEIF p_type = 26 THEN                              -- vice chief
        IF v_vc1 IS NOT NULL AND v_vc2 IS NOT NULL AND v_vc3 IS NOT NULL THEN
            ROLLBACK;
            SET p_result = 8;
            LEAVE proc;
        END IF;

        IF v_vc1 IS NULL THEN
            UPDATE KNIGHTS SET ViceChief_1 = p_charID WHERE IDNum = p_clanID;
        ELSEIF v_vc2 IS NULL THEN
            UPDATE KNIGHTS SET ViceChief_2 = p_charID WHERE IDNum = p_clanID;
        ELSE
            UPDATE KNIGHTS SET ViceChief_3 = p_charID WHERE IDNum = p_clanID;
        END IF;

    ELSEIF p_type = 27 THEN                              -- officer (2nd vice slot)
        UPDATE KNIGHTS SET ViceChief_2 = p_charID WHERE IDNum = p_clanID;

    ELSEIF p_type = 76 THEN                              -- clan point method
        UPDATE KNIGHTS SET ClanPointMethod = p_domination WHERE IDNum = p_clanID;
    END IF;

    IF p_type = 20 THEN                                  -- full removal
        UPDATE USERDATA SET Knights = 0, Fame = 0 WHERE strUserID = p_charID;
        DELETE FROM KNIGHTS_USER WHERE strUserID = p_charID;
    END IF;

    COMMIT;
    SET p_result = 0;
END$$

-- ---------------------------------------------------------------------------
-- DELETE_KNIGHTS
--   call site: {? = CALL DELETE_KNIGHTS (%d)}                      (:1166)
--   The dump has no return value; the C++ binds an output, so one is added.
--   0 = deleted, 1 = no such clan, -3 = database error.
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `DELETE_KNIGHTS`$$
CREATE PROCEDURE `DELETE_KNIGHTS`(
    OUT p_result TINYINT,
    IN  p_clanID SMALLINT)
    MODIFIES SQL DATA
proc: BEGIN
    DECLARE v_count INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result = -3;
    END;

    SELECT COUNT(*) INTO v_count FROM KNIGHTS WHERE IDNum = p_clanID;
    IF v_count = 0 THEN
        SET p_result = 1;
        LEAVE proc;
    END IF;

    START TRANSACTION;

    DELETE FROM KNIGHTS WHERE IDNum = p_clanID;
    DELETE FROM KNIGHTS_USER WHERE sIDNum = p_clanID;

    DELETE FROM KNIGHTS_ALLIANCE WHERE sMainAllianceKnights = p_clanID;
    UPDATE KNIGHTS_ALLIANCE SET sSubAllianceKnights = 0 WHERE sSubAllianceKnights = p_clanID;
    UPDATE KNIGHTS_ALLIANCE SET sMercenaryClan_1 = 0 WHERE sMercenaryClan_1 = p_clanID;
    UPDATE KNIGHTS_ALLIANCE SET sMercenaryClan_2 = 0 WHERE sMercenaryClan_2 = p_clanID;

    UPDATE KNIGHTS SET sAllianceKnights = 0 WHERE sAllianceKnights = p_clanID;
    UPDATE USERDATA SET Knights = 0, Fame = 0 WHERE Knights = p_clanID;

    COMMIT;
    SET p_result = 0;
END$$

-- ---------------------------------------------------------------------------
-- UPDATE_KNIGHTS_ALLIANCE
--   call site: {CALL UPDATE_KNIGHTS_ALLIANCE(%d, %d, %d, %d, %d)}  (:1105)
--   44 create, 46 add member, 47/48 remove/penalty, 49 destroy.
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `UPDATE_KNIGHTS_ALLIANCE`$$
CREATE PROCEDURE `UPDATE_KNIGHTS_ALLIANCE`(
    IN p_type         TINYINT UNSIGNED,
    IN p_allianceIdx  SMALLINT,
    IN p_knightsIdx   SMALLINT,
    IN p_emptyIdx     TINYINT UNSIGNED,
    IN p_siegeFlag    TINYINT UNSIGNED)
    MODIFIES SQL DATA
BEGIN
    DECLARE v_sub SMALLINT DEFAULT 0;
    DECLARE v_merc1 SMALLINT DEFAULT 0;
    DECLARE v_merc2 SMALLINT DEFAULT 0;

    IF p_type = 44 THEN                              -- create alliance
        INSERT INTO KNIGHTS_ALLIANCE (sMainAllianceKnights, sSubAllianceKnights,
                                      sMercenaryClan_1, sMercenaryClan_2)
        VALUES (p_allianceIdx, 0, 0, 0);

        UPDATE KNIGHTS SET bySiegeFlag = p_siegeFlag, sAllianceKnights = p_allianceIdx
         WHERE IDNum = p_allianceIdx;

    ELSEIF p_type = 46 THEN                          -- add a member
        IF p_emptyIdx = 1 THEN
            UPDATE KNIGHTS_ALLIANCE SET sSubAllianceKnights = p_knightsIdx
             WHERE sMainAllianceKnights = p_allianceIdx;
        ELSEIF p_emptyIdx = 2 THEN
            UPDATE KNIGHTS_ALLIANCE SET sMercenaryClan_1 = p_knightsIdx
             WHERE sMainAllianceKnights = p_allianceIdx;
        ELSEIF p_emptyIdx = 3 THEN
            UPDATE KNIGHTS_ALLIANCE SET sMercenaryClan_2 = p_knightsIdx
             WHERE sMainAllianceKnights = p_allianceIdx;
        END IF;

        UPDATE KNIGHTS SET bySiegeFlag = p_siegeFlag, sAllianceKnights = p_allianceIdx
         WHERE IDNum = p_knightsIdx;

    ELSEIF p_type IN (47, 48) THEN                   -- remove / punish
        SELECT sSubAllianceKnights, sMercenaryClan_1, sMercenaryClan_2
          INTO v_sub, v_merc1, v_merc2
          FROM KNIGHTS_ALLIANCE WHERE sMainAllianceKnights = p_allianceIdx LIMIT 1;

        IF v_sub = p_knightsIdx THEN
            UPDATE KNIGHTS_ALLIANCE SET sSubAllianceKnights = 0
             WHERE sMainAllianceKnights = p_allianceIdx;
        END IF;
        IF v_merc1 = p_knightsIdx THEN
            UPDATE KNIGHTS_ALLIANCE SET sMercenaryClan_1 = 0
             WHERE sMainAllianceKnights = p_allianceIdx;
        END IF;
        IF v_merc2 = p_knightsIdx THEN
            UPDATE KNIGHTS_ALLIANCE SET sMercenaryClan_2 = 0
             WHERE sMainAllianceKnights = p_allianceIdx;
        END IF;

        UPDATE KNIGHTS SET bySiegeFlag = 0, sAllianceKnights = 0 WHERE IDNum = p_knightsIdx;

    ELSEIF p_type = 49 THEN                          -- destroy alliance
        SELECT sSubAllianceKnights, sMercenaryClan_1, sMercenaryClan_2
          INTO v_sub, v_merc1, v_merc2
          FROM KNIGHTS_ALLIANCE WHERE sMainAllianceKnights = p_allianceIdx LIMIT 1;

        UPDATE KNIGHTS SET bySiegeFlag = 0, sAllianceKnights = 0 WHERE IDNum = p_allianceIdx;

        IF v_sub <> 0 THEN
            UPDATE KNIGHTS SET bySiegeFlag = 0, sAllianceKnights = 0 WHERE IDNum = v_sub;
        END IF;
        IF v_merc1 <> 0 THEN
            UPDATE KNIGHTS SET bySiegeFlag = 0, sAllianceKnights = 0 WHERE IDNum = v_merc1;
        END IF;
        IF v_merc2 <> 0 THEN
            UPDATE KNIGHTS SET bySiegeFlag = 0, sAllianceKnights = 0 WHERE IDNum = v_merc2;
        END IF;

        DELETE FROM KNIGHTS_ALLIANCE WHERE sMainAllianceKnights = p_allianceIdx;
    END IF;
END$$

-- ---------------------------------------------------------------------------
-- DONATE_CLAN_POINTS
--   call site: {CALL DONATE_CLAN_POINTS(?, %d, %d)}                (:1381)
--   The dump uses `ClanPointFund += n`; MySQL only has the expanded form.
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `DONATE_CLAN_POINTS`$$
CREATE PROCEDURE `DONATE_CLAN_POINTS`(
    IN p_userID VARCHAR(21),
    IN p_clanID SMALLINT,
    IN p_points INT)
    MODIFIES SQL DATA
BEGIN
    UPDATE KNIGHTS SET ClanPointFund = ClanPointFund + p_points WHERE IDNum = p_clanID;
    UPDATE KNIGHTS_USER SET nDonatedNP = nDonatedNP + p_points
     WHERE sIDNum = p_clanID AND strUserID = p_userID;
END$$

-- ---------------------------------------------------------------------------
-- UPDATE_KNIGHT_CASH
--   call site: {CALL UPDATE_KNIGHT_CASH (?, %d)}                  (:2228)
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `UPDATE_KNIGHT_CASH`$$
CREATE PROCEDURE `UPDATE_KNIGHT_CASH`(
    IN p_accountID VARCHAR(21),
    IN p_cash      INT)
    MODIFIES SQL DATA
BEGIN
    UPDATE TB_USER SET CashPoint = CashPoint + p_cash WHERE strAccountID = p_accountID;
END$$

-- ---------------------------------------------------------------------------
-- INSERT_USER_DAILY_OP / UPDATE_USER_DAILY_OP
--   call sites: {CALL INSERT_USER_DAILY_OP(?, 8 ints)}            (:2173)
--               {CALL UPDATE_USER_DAILY_OP(?, %d, %d)}            (:2185)
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `INSERT_USER_DAILY_OP`$$
CREATE PROCEDURE `INSERT_USER_DAILY_OP`(
    IN p_charID       VARCHAR(21),
    IN p_chaosMap     INT,
    IN p_userRank     INT,
    IN p_personalRank INT,
    IN p_kingWing     INT,
    IN p_warder1      INT,
    IN p_warder2      INT,
    IN p_keeper       INT,
    IN p_loyaltyWing  INT)
    MODIFIES SQL DATA
BEGIN
    DELETE FROM USER_DAILY_OP WHERE strUserID = p_charID;

    INSERT INTO USER_DAILY_OP (strUserID, ChaosMapTime, UserRankRewardTime,
                               PersonalRankRewardTime, KingWingTime,
                               WarderKillerTime1, WarderKillerTime2,
                               KeeperKillerTime, UserLoyaltyWingRewardTime)
    VALUES (p_charID, p_chaosMap, p_userRank, p_personalRank, p_kingWing,
            p_warder1, p_warder2, p_keeper, p_loyaltyWing);
END$$

DROP PROCEDURE IF EXISTS `UPDATE_USER_DAILY_OP`$$
CREATE PROCEDURE `UPDATE_USER_DAILY_OP`(
    IN p_charID   VARCHAR(21),
    IN p_type     TINYINT UNSIGNED,
    IN p_unixTime INT)
    MODIFIES SQL DATA
BEGIN
    CASE p_type
        WHEN 1 THEN UPDATE USER_DAILY_OP SET ChaosMapTime = p_unixTime WHERE strUserID = p_charID;
        WHEN 2 THEN UPDATE USER_DAILY_OP SET UserRankRewardTime = p_unixTime WHERE strUserID = p_charID;
        WHEN 3 THEN UPDATE USER_DAILY_OP SET PersonalRankRewardTime = p_unixTime WHERE strUserID = p_charID;
        WHEN 4 THEN UPDATE USER_DAILY_OP SET KingWingTime = p_unixTime WHERE strUserID = p_charID;
        WHEN 5 THEN UPDATE USER_DAILY_OP SET WarderKillerTime1 = p_unixTime WHERE strUserID = p_charID;
        WHEN 6 THEN UPDATE USER_DAILY_OP SET WarderKillerTime2 = p_unixTime WHERE strUserID = p_charID;
        WHEN 7 THEN UPDATE USER_DAILY_OP SET KeeperKillerTime = p_unixTime WHERE strUserID = p_charID;
        WHEN 8 THEN UPDATE USER_DAILY_OP SET UserLoyaltyWingRewardTime = p_unixTime WHERE strUserID = p_charID;
        ELSE BEGIN END;
    END CASE;
END$$

-- ---------------------------------------------------------------------------
-- UPDATE_ACCOUNT_CHAR
--   call site: {CALL UPDATE_ACCOUNT_CHAR(?, ?, %d)}                (:2507)
--   bRent 0/1/2 assigns slot N, bRent 3 clears the slot holding the character.
--   The original `RETURN` (no value) is a no-op here.
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `UPDATE_ACCOUNT_CHAR`$$
CREATE PROCEDURE `UPDATE_ACCOUNT_CHAR`(
    IN p_accountID VARCHAR(21),
    IN p_userID    VARCHAR(21),
    IN p_rent      TINYINT UNSIGNED)
    MODIFIES SQL DATA
BEGIN
    DECLARE v_id1 VARCHAR(21) DEFAULT NULL;
    DECLARE v_id2 VARCHAR(21) DEFAULT NULL;
    DECLARE v_id3 VARCHAR(21) DEFAULT NULL;

    IF p_rent = 0 THEN
        UPDATE ACCOUNT_CHAR SET strCharID1 = p_userID, bCharNum = bCharNum + 1
         WHERE strAccountID = p_accountID;
    ELSEIF p_rent = 1 THEN
        UPDATE ACCOUNT_CHAR SET strCharID2 = p_userID, bCharNum = bCharNum + 1
         WHERE strAccountID = p_accountID;
    ELSEIF p_rent = 2 THEN
        UPDATE ACCOUNT_CHAR SET strCharID3 = p_userID, bCharNum = bCharNum + 1
         WHERE strAccountID = p_accountID;
    ELSEIF p_rent = 3 THEN
        SELECT strCharID1, strCharID2, strCharID3 INTO v_id1, v_id2, v_id3
          FROM ACCOUNT_CHAR WHERE strAccountID = p_accountID LIMIT 1;

        IF v_id1 = p_userID THEN
            UPDATE ACCOUNT_CHAR SET strCharID1 = NULL, bCharNum = bCharNum - 1
             WHERE strAccountID = p_accountID;
        ELSEIF v_id2 = p_userID THEN
            UPDATE ACCOUNT_CHAR SET strCharID2 = NULL, bCharNum = bCharNum - 1
             WHERE strAccountID = p_accountID;
        ELSEIF v_id3 = p_userID THEN
            UPDATE ACCOUNT_CHAR SET strCharID3 = NULL, bCharNum = bCharNum - 1
             WHERE strAccountID = p_accountID;
        END IF;
    END IF;
END$$

-- ---------------------------------------------------------------------------
-- UPDATE_SIEGE
--   call site: {CALL UPDATE_SIEGE (%d, %d, %d, %d, %d, %d)}        (:2238)
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `UPDATE_SIEGE`$$
CREATE PROCEDURE `UPDATE_SIEGE`(
    IN p_castleIdx SMALLINT,
    IN p_knightsIdx SMALLINT,
    IN p_warType   TINYINT UNSIGNED,
    IN p_warDay    TINYINT UNSIGNED,
    IN p_warTime   TINYINT UNSIGNED,
    IN p_warMinute TINYINT UNSIGNED)
    MODIFIES SQL DATA
BEGIN
    UPDATE KNIGHTS_SIEGE_WARFARE SET
        bySiegeType    = p_warType,
        byWarDay       = p_warDay,
        byWarTime      = p_warTime,
        byWarMinute    = p_warMinute,
        sChallengeList_1 = sMasterKnights,
        sMasterKnights   = p_knightsIdx,
        sChallengeList_3 = 0, sChallengeList_4 = 0, sChallengeList_5 = 0,
        sChallengeList_6 = 0, sChallengeList_7 = 0, sChallengeList_8 = 0,
        sChallengeList_9 = 0, sChallengeList_10 = 0
     WHERE sCastleIndex = p_castleIdx;
END$$

-- ---------------------------------------------------------------------------
-- CHANGE_NEW_ID
--   call site: {? = CALL CHANGE_NEW_ID(%d, ?, ?, ?, 1)}            (:1533)
--              (serverNo, accountID, oldCharID, newCharID, 1)
--   The dump declares only 4 parameters, so the original call could never have
--   succeeded against the dumped procedure.  The call-site signature is used
--   here; the trailing literal `1` is accepted as p_flag and ignored.
--   Returns 1 invalid/duplicate name, 3 success (as in the dump).
--   All renames happen in one transaction: if any table fails, nothing is
--   renamed (a half-renamed character would be lost).
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `CHANGE_NEW_ID`$$
CREATE PROCEDURE `CHANGE_NEW_ID`(
    OUT p_result    SMALLINT,
    IN  p_serverNo  INT,
    IN  p_accountID VARCHAR(21),
    IN  p_oldCharID VARCHAR(21),
    IN  p_newCharID VARCHAR(21),
    IN  p_flag      INT)
    MODIFIES SQL DATA
proc: BEGIN
    DECLARE v_count INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result = 2;
    END;

    IF IsValidCharacters(p_newCharID) = 1 THEN
        SET p_result = 1;
        LEAVE proc;
    END IF;

    SELECT COUNT(*) INTO v_count FROM USERDATA WHERE strUserID = p_newCharID;
    IF v_count > 0 THEN
        SET p_result = 1;
        LEAVE proc;
    END IF;

    START TRANSACTION;

    UPDATE ACCOUNT_CHAR SET strCharID1 = p_newCharID
     WHERE strCharID1 = p_oldCharID AND strCharID1 IS NOT NULL;
    UPDATE ACCOUNT_CHAR SET strCharID2 = p_newCharID
     WHERE strCharID2 = p_oldCharID AND strCharID2 IS NOT NULL;
    UPDATE ACCOUNT_CHAR SET strCharID3 = p_newCharID
     WHERE strCharID3 = p_oldCharID AND strCharID3 IS NOT NULL;

    UPDATE USERDATA SET strUserID = p_newCharID WHERE strUserID = p_oldCharID;

    UPDATE KNIGHTS_USER SET strUserID = p_newCharID WHERE strUserID = p_oldCharID;
    UPDATE KNIGHTS SET Chief = p_newCharID WHERE Chief = p_oldCharID;
    UPDATE KNIGHTS SET ViceChief_1 = p_newCharID WHERE ViceChief_1 = p_oldCharID;
    UPDATE KNIGHTS SET ViceChief_2 = p_newCharID WHERE ViceChief_2 = p_oldCharID;
    UPDATE KNIGHTS SET ViceChief_3 = p_newCharID WHERE ViceChief_3 = p_oldCharID;

    -- the dump deletes the memorised skills (the slot indices belong to the
    -- old name), then re-points the remaining per-character rows.
    DELETE FROM USER_SAVED_MAGIC WHERE strCharID = p_oldCharID;

    UPDATE FRIEND_LIST SET strUserID = p_newCharID WHERE strUserID = p_oldCharID;

    UPDATE USER_RENTAL_ITEM SET strUserID = p_newCharID WHERE strUserID = p_oldCharID;
    UPDATE RENTAL_ITEM SET strLenderCharID = p_newCharID WHERE strLenderCharID = p_oldCharID;
    UPDATE RENTAL_ITEM SET strBorrowerCharID = p_newCharID WHERE strBorrowerCharID = p_oldCharID;
    UPDATE RENTAL_ITEM_LIST SET strBorrowerCharID = p_newCharID WHERE strBorrowerCharID = p_oldCharID;

    UPDATE CURRENTUSER SET strCharID = p_newCharID WHERE strCharID = p_oldCharID;
    UPDATE USERDATA_SKILLSHORTCUT SET strCharID = p_newCharID WHERE strCharID = p_oldCharID;
    UPDATE BATTLE SET strUserName = p_newCharID WHERE strUserName = p_oldCharID;
    UPDATE USER_DAILY_OP SET strUserID = p_newCharID WHERE strUserID = p_oldCharID;
    UPDATE USER_SEAL SET strUserID = p_newCharID WHERE strUserID = p_oldCharID;
    UPDATE SEALED_ITEMS SET strUserID = p_newCharID WHERE strUserID = p_oldCharID;
    UPDATE MAIL_BOX SET strSenderID = p_newCharID WHERE strSenderID = p_oldCharID;
    UPDATE MAIL_BOX SET strRecipientID = p_newCharID WHERE strRecipientID = p_oldCharID;

    COMMIT;
    SET p_result = 3;
END$$

-- ---------------------------------------------------------------------------
-- CHANGE_NEW_CLANID
--   call site: {? = CALL CHANGE_NEW_CLANID(?, ?)}                  (:1551)
--   2 name taken, 16 renamed (codes as in the dump).
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `CHANGE_NEW_CLANID`$$
CREATE PROCEDURE `CHANGE_NEW_CLANID`(
    OUT p_result   SMALLINT,
    IN  p_clanID   VARCHAR(30),
    IN  p_newClanID VARCHAR(30))
    MODIFIES SQL DATA
proc: BEGIN
    DECLARE v_count INT DEFAULT 0;
    DECLARE v_idNum SMALLINT DEFAULT NULL;

    SELECT COUNT(IDName) INTO v_count FROM KNIGHTS WHERE IDName = p_newClanID;
    IF v_count > 0 THEN
        SET p_result = 2;
        LEAVE proc;
    END IF;

    SELECT IDNum INTO v_idNum FROM KNIGHTS WHERE IDName = p_clanID LIMIT 1;
    IF v_idNum IS NULL THEN
        SET p_result = 2;
        LEAVE proc;
    END IF;

    UPDATE KNIGHTS SET IDName = p_newClanID WHERE IDNum = v_idNum;
    SET p_result = 16;
END$$

-- ---------------------------------------------------------------------------
-- ACCOUNT_NATION_TRANSFER
--   call site: {? = CALL ACCOUNT_NATION_TRANSFER(?)}               (:2209)
--              (accountID) - ONE parameter.
--   The dump declares accountID plus four race overrides, which the C++ never
--   sends (that call could not have worked).  Here the new race is derived per
--   character with GET_RACE_FOR_ACCOUNT_NATION_TRANSFER(Race, Class), the
--   function the dump ships for exactly this purpose.
--   0 = transferred, 2 = a character is still in a clan, 3 = database error.
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `ACCOUNT_NATION_TRANSFER`$$
CREATE PROCEDURE `ACCOUNT_NATION_TRANSFER`(
    OUT p_result    TINYINT,
    IN  p_accountID VARCHAR(21))
    MODIFIES SQL DATA
proc: BEGIN
    DECLARE v_accountCount  INT DEFAULT 0;
    DECLARE v_currentNation TINYINT UNSIGNED DEFAULT 0;
    DECLARE v_charNum       TINYINT UNSIGNED DEFAULT 0;
    DECLARE v_newNation     TINYINT UNSIGNED DEFAULT 0;
    DECLARE v_clanCount     INT DEFAULT 0;
    DECLARE v_c1 VARCHAR(21) DEFAULT NULL;
    DECLARE v_c2 VARCHAR(21) DEFAULT NULL;
    DECLARE v_c3 VARCHAR(21) DEFAULT NULL;
    DECLARE v_race  TINYINT UNSIGNED DEFAULT 0;
    DECLARE v_class SMALLINT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result = 3;
    END;

    SELECT COUNT(*) INTO v_accountCount FROM TB_USER WHERE strAccountID = p_accountID;
    IF v_accountCount = 0 THEN
        SET p_result = 0;
        LEAVE proc;
    END IF;

    SELECT bNation, bCharNum, strCharID1, strCharID2, strCharID3
      INTO v_currentNation, v_charNum, v_c1, v_c2, v_c3
      FROM ACCOUNT_CHAR WHERE strAccountID = p_accountID LIMIT 1;

    IF v_charNum = 0 THEN
        SET p_result = 0;
        LEAVE proc;
    END IF;

    -- The C++ returns the value to the client as "characters are in a clan".
    SELECT COUNT(*) INTO v_clanCount
      FROM KNIGHTS_USER
     WHERE strUserID IN (COALESCE(v_c1, ''), COALESCE(v_c2, ''), COALESCE(v_c3, ''));
    IF v_clanCount > 0 THEN
        SET p_result = 2;
        LEAVE proc;
    END IF;

    SET v_newNation = IF(v_currentNation = 1, 2, 1);

    START TRANSACTION;

    IF v_c1 IS NOT NULL THEN
        SELECT Race, `Class` INTO v_race, v_class
          FROM USERDATA WHERE strUserID = v_c1 LIMIT 1;
        SET v_race = GET_RACE_FOR_ACCOUNT_NATION_TRANSFER(v_race, v_class);
        IF v_newNation = 1 THEN
            SET v_class = v_class - 100;
        ELSE
            SET v_class = v_class + 100;
        END IF;
        UPDATE USERDATA SET Nation = v_newNation, Race = v_race, `Class` = v_class,
               Knights = 0, Fame = 0, `Rank` = 0, Title = 0, `Zone` = 21,
               PX = 81700, PZ = 51500, PY = 0
         WHERE strUserID = v_c1;
        UPDATE KING_SYSTEM SET strKingName = NULL
         WHERE strKingName = v_c1 AND strKingName IS NOT NULL
           AND byNation = v_currentNation;
    END IF;
    IF v_c2 IS NOT NULL THEN
        SELECT Race, `Class` INTO v_race, v_class
          FROM USERDATA WHERE strUserID = v_c2 LIMIT 1;
        SET v_race = GET_RACE_FOR_ACCOUNT_NATION_TRANSFER(v_race, v_class);
        IF v_newNation = 1 THEN
            SET v_class = v_class - 100;
        ELSE
            SET v_class = v_class + 100;
        END IF;
        UPDATE USERDATA SET Nation = v_newNation, Race = v_race, `Class` = v_class,
               Knights = 0, Fame = 0, `Rank` = 0, Title = 0, `Zone` = 21,
               PX = 81700, PZ = 51500, PY = 0
         WHERE strUserID = v_c2;
        UPDATE KING_SYSTEM SET strKingName = NULL
         WHERE strKingName = v_c2 AND strKingName IS NOT NULL
           AND byNation = v_currentNation;
    END IF;
    IF v_c3 IS NOT NULL THEN
        SELECT Race, `Class` INTO v_race, v_class
          FROM USERDATA WHERE strUserID = v_c3 LIMIT 1;
        SET v_race = GET_RACE_FOR_ACCOUNT_NATION_TRANSFER(v_race, v_class);
        IF v_newNation = 1 THEN
            SET v_class = v_class - 100;
        ELSE
            SET v_class = v_class + 100;
        END IF;
        UPDATE USERDATA SET Nation = v_newNation, Race = v_race, `Class` = v_class,
               Knights = 0, Fame = 0, `Rank` = 0, Title = 0, `Zone` = 21,
               PX = 81700, PZ = 51500, PY = 0
         WHERE strUserID = v_c3;
        UPDATE KING_SYSTEM SET strKingName = NULL
         WHERE strKingName = v_c3 AND strKingName IS NOT NULL
           AND byNation = v_currentNation;
    END IF;

    UPDATE ACCOUNT_CHAR SET bNation = v_newNation WHERE strAccountID = p_accountID;

    COMMIT;
    SET p_result = 0;
END$$

DELIMITER ;
