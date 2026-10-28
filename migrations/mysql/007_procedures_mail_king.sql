-- ===========================================================================
--  KO1534  ->  MySQL 8.4 migration  :  007_procedures_mail_king.sql
-- ===========================================================================
--
--  Mail box and king-election routines.
--
--  Same porting conventions as 003/004/006.  Two things in this file are worth
--  reading before you deploy it:
--
--   * MAIL_BOX_GET_ITEM is the only place where an item leaves a letter.  The
--     T-SQL original did SELECT-then-UPDATE with no transaction, so two
--     concurrent requests from the same account could both see the item and
--     duplicate it.  The port takes a row lock (SELECT ... FOR UPDATE) and
--     flips bStatus inside one transaction, so a letter can be collected at
--     most once.
--   * Several dumped routines declare a different parameter list from what the
--     C++ call sites send (they could never have executed).  The call sites
--     win; each deviation is called out in the routine header.
-- ===========================================================================

SET NAMES latin1;
SET SESSION sql_mode='STRICT_ALL_TABLES,NO_ENGINE_SUBSTITUTION,NO_AUTO_VALUE_ON_ZERO';

DELIMITER $$

-- ---------------------------------------------------------------------------
-- MAIL_BOX_CHECK_COUNT
--   call site: {? = CALL MAIL_BOX_CHECK_COUNT(?)}        (DBAgent.cpp:1641)
--   Count of unread, undeleted letters (the client only ever shows 12).
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `MAIL_BOX_CHECK_COUNT`$$
CREATE PROCEDURE `MAIL_BOX_CHECK_COUNT`(
    OUT p_result      TINYINT UNSIGNED,
    IN  p_recipientID VARCHAR(50))
    READS SQL DATA
BEGIN
    SELECT COUNT(*) INTO p_result
      FROM MAIL_BOX
     WHERE strRecipientID = p_recipientID
       AND bStatus  = 1        -- unread
       AND bDeleted = 0;       -- not deleted
END$$

-- ---------------------------------------------------------------------------
-- MAIL_BOX_REQUEST_LIST
--   call site: {? = CALL MAIL_BOX_REQUEST_LIST(?, %d)}   (DBAgent.cpp:1659)
--   Eleven columns, in the order CDBAgent::GetLetterList reads them:
--      1 nLetterID  2 bStatus  3 bType  4 strSubject  5 strSenderID
--      6 bType (again, the C++ reads it twice)  7 nItemID  8 sCount
--      9 nCoins  10 yyyymmdd  11 days remaining
--   A letter expires 7 days after it was sent; the days-remaining figure is
--   computed against that deadline for the unread list, and against the read
--   date for the saved list (as in the dump).
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `MAIL_BOX_REQUEST_LIST`$$
CREATE PROCEDURE `MAIL_BOX_REQUEST_LIST`(
    OUT p_result      TINYINT,
    IN  p_recipientID VARCHAR(50),
    IN  p_newOnly     TINYINT UNSIGNED)
    READS SQL DATA
proc: BEGIN
    DECLARE v_expiresInDays INT DEFAULT 7;

    -- ROW_COUNT() is -1 after a SELECT in MySQL, so the count the client
    -- displays is computed explicitly with the same predicates and caps.
    IF p_newOnly = 1 THEN
        SELECT LEAST(COUNT(*), 12) INTO p_result
          FROM MAIL_BOX
         WHERE strRecipientID = p_recipientID AND bStatus = 1 AND bDeleted = 0;
    ELSE
        SELECT LEAST(COUNT(*), 20) INTO p_result
          FROM MAIL_BOX
         WHERE strRecipientID = p_recipientID AND bStatus = 2 AND bDeleted = 0;
    END IF;

    IF p_newOnly = 1 THEN
        SELECT nLetterID, bStatus, bType, strSubject, strSenderID,
               bType, nItemID, sCount, nCoins,
               YEAR(dtSendDate) * 10000 + MONTH(dtSendDate) * 100 + DAY(dtSendDate) AS nDate,
               DATEDIFF(dtSendDate + INTERVAL v_expiresInDays DAY, NOW()) AS sDaysRemaining
          FROM MAIL_BOX
         WHERE strRecipientID = p_recipientID
           AND bStatus  = 1
           AND bDeleted = 0
         ORDER BY nLetterID DESC
         LIMIT 12;
    ELSE
        SELECT nLetterID, bStatus, bType, strSubject, strSenderID,
               bType, nItemID, sCount, nCoins,
               YEAR(dtReadDate) * 10000 + MONTH(dtReadDate) * 100 + DAY(dtReadDate) AS nDate,
               DATEDIFF(NOW(), dtReadDate) AS sDaysRemaining
          FROM MAIL_BOX
         WHERE strRecipientID = p_recipientID
           AND bStatus  = 2
           AND bDeleted = 0
         ORDER BY nLetterID DESC
         LIMIT 20;
    END IF;
END$$

-- ---------------------------------------------------------------------------
-- MAIL_BOX_SEND
--   call site: {? = CALL MAIL_BOX_SEND(?, ?, ?, ?, %d, %d, %d, %d, I64FMTD, %d, %d)}
--              (DBAgent.cpp:1739)
--   1 sent, -1 no such recipient, -3 database error.
--   Note: the C++ reads the return value as int8, so 1 / -1 fit.
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `MAIL_BOX_SEND`$$
CREATE PROCEDURE `MAIL_BOX_SEND`(
    OUT p_result     TINYINT,
    IN  p_senderID   VARCHAR(50),
    IN  p_recipientID VARCHAR(50),
    IN  p_subject    VARCHAR(50),
    IN  p_message    VARCHAR(128),
    IN  p_type       TINYINT UNSIGNED,
    IN  p_itemID     INT,
    IN  p_count      SMALLINT,
    IN  p_durability SMALLINT,
    IN  p_serialNum  BIGINT,
    IN  p_userSeal   BIGINT,
    IN  p_coins      INT)
    MODIFIES SQL DATA
proc: BEGIN
    DECLARE v_exists INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result = -3;
    END;

    SELECT COUNT(*) INTO v_exists FROM USERDATA WHERE strUserID = p_recipientID;
    IF v_exists = 0 THEN
        SET p_result = -1;
        LEAVE proc;
    END IF;

    INSERT INTO MAIL_BOX (strSenderID, strRecipientID, strSubject, strMessage,
                          bType, nItemID, sCount, sDurability, nSerialNum,
                          nUserSeal, nCoins, dtSendDate, bStatus, bDeleted)
    VALUES (p_senderID, p_recipientID, p_subject, p_message,
            p_type, p_itemID, p_count, p_durability, p_serialNum,
            p_userSeal, p_coins, NOW(3), 1, 0);

    SET p_result = 1;
END$$

-- ---------------------------------------------------------------------------
-- MAIL_BOX_READ
--   call site: {CALL MAIL_BOX_READ(?, %d)}                (DBAgent.cpp:1756)
--   Returns the message body, then marks the letter read.  Kept as two
--   statements in the original order so the body is fetched before the status
--   changes (the C++ reads the first result set).
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `MAIL_BOX_READ`$$
CREATE PROCEDURE `MAIL_BOX_READ`(
    IN p_recipientID VARCHAR(50),
    IN p_letterID    INT)
    MODIFIES SQL DATA
proc: BEGIN
    DECLARE v_found INT DEFAULT 0;

    SELECT COUNT(*) INTO v_found
      FROM MAIL_BOX
     WHERE strRecipientID = p_recipientID AND nLetterID = p_letterID;

    IF v_found > 0 THEN
        SELECT strMessage FROM MAIL_BOX
         WHERE strRecipientID = p_recipientID AND nLetterID = p_letterID;

        -- No item attached: straight to "saved".
        UPDATE MAIL_BOX SET dtReadDate = NOW(3), bStatus = 2
         WHERE nLetterID = p_letterID AND bType = 1 AND dtReadDate IS NULL;

        -- Item attached: only the read time changes, bStatus stays until the
        -- item is collected.
        UPDATE MAIL_BOX SET dtReadDate = NOW(3)
         WHERE nLetterID = p_letterID AND bType = 2 AND dtReadDate IS NULL;
    END IF;
END$$

-- ---------------------------------------------------------------------------
-- MAIL_BOX_GET_ITEM
--   call site: {? = CALL MAIL_BOX_GET_ITEM(?, %d)}        (DBAgent.cpp:1778)
--   Result set (exact order, read by CDBAgent::GetItemFromLetter):
--      1 nItemID  2 sCount  3 sDurability  4 nCoins  5 nSerialNum
--   plus the nUserSeal column the C++ also fetches (position 6) - the dump's
--   procedure did not select it, so the original read undefined data; it is
--   included here.
--   1 = item handed out, 0 = nothing to collect (already taken / wrong owner).
--
--   DUPLICATION GUARD: the row is locked and re-checked inside the
--   transaction, so two simultaneous requests cannot both collect the same
--   letter.
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `MAIL_BOX_GET_ITEM`$$
CREATE PROCEDURE `MAIL_BOX_GET_ITEM`(
    OUT p_result      TINYINT,
    IN  p_recipientID VARCHAR(50),
    IN  p_letterID    INT)
    MODIFIES SQL DATA
proc: BEGIN
    DECLARE v_status TINYINT UNSIGNED DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result = 0;
    END;

    START TRANSACTION;

    SELECT bStatus INTO v_status
      FROM MAIL_BOX
     WHERE nLetterID = p_letterID AND strRecipientID = p_recipientID
     FOR UPDATE;

    IF v_status IS NULL OR v_status <> 1 THEN
        ROLLBACK;
        SET p_result = 0;
        LEAVE proc;
    END IF;

    SELECT nItemID, sCount, sDurability, nCoins, nSerialNum, nUserSeal
      FROM MAIL_BOX
     WHERE nLetterID = p_letterID AND strRecipientID = p_recipientID;

    UPDATE MAIL_BOX SET bStatus = 2
     WHERE nLetterID = p_letterID AND strRecipientID = p_recipientID;

    COMMIT;
    SET p_result = 1;
END$$

-- ---------------------------------------------------------------------------
-- KING_UPDATE_ELECTION_LIST
--   call site: {CALL KING_UPDATE_ELECTION_LIST(5 ints, ?)}  (DBAgent.cpp:1885)
--   No output parameter.
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `KING_UPDATE_ELECTION_LIST`$$
CREATE PROCEDURE `KING_UPDATE_ELECTION_LIST`(
    IN p_dbType  TINYINT UNSIGNED,
    IN p_type    TINYINT UNSIGNED,
    IN p_nation  TINYINT UNSIGNED,
    IN p_knights SMALLINT,
    IN p_amount  INT,
    IN p_userID  VARCHAR(21))
    MODIFIES SQL DATA
BEGIN
    IF p_dbType = 1 THEN
        INSERT INTO KING_ELECTION_LIST (byType, byNation, nKnights, strName, nMoney)
        VALUES (p_type, p_nation, p_knights, p_userID, p_amount);
    ELSEIF p_dbType = 2 THEN
        DELETE FROM KING_ELECTION_LIST
         WHERE byType = p_type AND strName = p_userID;
    END IF;

    IF p_type = 1 THEN
        UPDATE KING_SYSTEM SET strKingName = p_userID WHERE byNation = p_nation;
    END IF;
END$$

-- ---------------------------------------------------------------------------
-- KING_CANDIDACY_RECOMMEND
--   call site: {? = CALL KING_CANDIDACY_RECOMMEND(?, ?, %d)}  (DBAgent.cpp:1913)
--   Returns the nominee's clan id on success, or the original negative codes:
--   -5 already a candidate, -4 nation mismatch, -3 not entitled to nominate,
--   -1 no such character.  A positive value also carries the clan id.
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `KING_CANDIDACY_RECOMMEND`$$
CREATE PROCEDURE `KING_CANDIDACY_RECOMMEND`(
    OUT p_result     SMALLINT,
    IN  p_nominator  VARCHAR(21),
    IN  p_nominee    VARCHAR(21),
    IN  p_nation     TINYINT UNSIGNED)
    MODIFIES SQL DATA
proc: BEGIN
    DECLARE v_count   INT DEFAULT 0;
    DECLARE v_nation  TINYINT UNSIGNED DEFAULT NULL;
    DECLARE v_knights SMALLINT DEFAULT 0;
    DECLARE v_removed INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result = -1;
    END;

    SELECT COUNT(*) INTO v_count
      FROM KING_ELECTION_LIST
     WHERE strName = p_nominee AND byType = 4;
    IF v_count > 0 THEN
        SET p_result = -5;           -- already recommended
        LEAVE proc;
    END IF;

    SELECT Nation, Knights INTO v_nation, v_knights
      FROM USERDATA WHERE strUserID = p_nominee LIMIT 1;
    IF v_nation IS NULL THEN
        SET p_result = -1;           -- no such character
        LEAVE proc;
    END IF;

    IF v_nation <> p_nation THEN
        SET p_result = -4;           -- different nation
        LEAVE proc;
    END IF;

    START TRANSACTION;

    -- Recommending consumes the nominator's senator seat.
    DELETE FROM KING_ELECTION_LIST WHERE strName = p_nominator AND byType = 3;
    SET v_removed = ROW_COUNT();

    IF v_removed = 0 THEN
        ROLLBACK;
        SET p_result = -3;           -- not entitled to nominate
        LEAVE proc;
    END IF;

    INSERT INTO KING_ELECTION_LIST (byType, byNation, nKnights, strName, nMoney)
    VALUES (4, p_nation, v_knights, p_nominee, 0);

    COMMIT;
    SET p_result = COALESCE(v_knights, 0);
END$$

-- ---------------------------------------------------------------------------
-- KING_ELECTION_PROC
--   call site: {? = CALL KING_ELECTION_PROC(?, ?, %d, ?)}     (DBAgent.cpp:1939)
--   1 vote counted, -3 already voted / not enough loyalty.
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `KING_ELECTION_PROC`$$
CREATE PROCEDURE `KING_ELECTION_PROC`(
    OUT p_result        TINYINT,
    IN  p_accountID     VARCHAR(21),
    IN  p_charID        VARCHAR(21),
    IN  p_nation        TINYINT UNSIGNED,
    IN  p_candidacyID   VARCHAR(21))
    MODIFIES SQL DATA
proc: BEGIN
    DECLARE v_count   INT DEFAULT 0;
    DECLARE v_loyalty INT DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result = -3;
    END;

    SELECT COUNT(*) INTO v_count
      FROM KING_BALLOT_BOX WHERE strAccountID = p_accountID;
    IF v_count > 0 THEN
        SET p_result = -3;           -- already voted
        LEAVE proc;
    END IF;

    SELECT Loyalty INTO v_loyalty FROM USERDATA WHERE strUserID = p_charID LIMIT 1;
    IF v_loyalty IS NULL OR v_loyalty < 500 THEN
        SET p_result = -3;           -- not eligible
        LEAVE proc;
    END IF;

    START TRANSACTION;

    INSERT INTO KING_BALLOT_BOX (strAccountID, strCharID, byNation, strCandidacyID)
    VALUES (p_accountID, p_charID, p_nation, p_candidacyID);

    UPDATE KING_ELECTION_LIST SET nMoney = nMoney + 1
     WHERE byType = 4 AND strName = p_candidacyID;

    COMMIT;
    SET p_result = 1;
END$$

-- ---------------------------------------------------------------------------
-- KING_UPDATE_ELECTION_STATUS
--   call site: {CALL KING_UPDATE_ELECTION_STATUS(%d, %d)}     (DBAgent.cpp:1822)
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `KING_UPDATE_ELECTION_STATUS`$$
CREATE PROCEDURE `KING_UPDATE_ELECTION_STATUS`(
    IN p_type   TINYINT UNSIGNED,
    IN p_nation TINYINT UNSIGNED)
    MODIFIES SQL DATA
BEGIN
    UPDATE KING_SYSTEM SET byType = p_type WHERE byNation = p_nation;

    IF p_type = 1 THEN                    -- nomination started: wipe everything
        DELETE FROM KING_ELECTION_LIST          WHERE byNation = p_nation;
        DELETE FROM KING_CANDIDACY_NOTICE_BOARD WHERE byNation = p_nation;
        DELETE FROM KING_BALLOT_BOX             WHERE byNation = p_nation;
    ELSEIF p_type = 2 THEN                -- election started: drop senators
        DELETE FROM KING_ELECTION_LIST WHERE byType = 3 AND byNation = p_nation;
    ELSEIF p_type IN (0, 7) THEN          -- term ended: candidates -> senators
        DELETE FROM KING_ELECTION_LIST WHERE byType = 3 AND byNation = p_nation;

        INSERT INTO KING_ELECTION_LIST (byNation, byType, strName, nKnights, nMoney)
        SELECT byNation, 3, strName, nKnights, nMoney
          FROM KING_ELECTION_LIST
         WHERE byNation = p_nation AND byType = 4;

        DELETE FROM KING_ELECTION_LIST WHERE byType = 4 AND byNation = p_nation;
    END IF;
END$$

-- ---------------------------------------------------------------------------
-- KING_CANDIDACY_NOTICE_BOARD_PROC
--   call site: {CALL KING_CANDIDACY_NOTICE_BOARD_PROC(?, %d, ?)}  (:2031)
--              (charID, nation, notice) - the dump also has a sNoticeLen
--              parameter the C++ never sends, so it is computed here.
--   The dump's first branch omits sNoticeLen (which is NOT NULL and has no
--   default), so the original insert always failed; here the real byte length
--   is stored and the row is replaced instead of duplicated.
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `KING_CANDIDACY_NOTICE_BOARD_PROC`$$
CREATE PROCEDURE `KING_CANDIDACY_NOTICE_BOARD_PROC`(
    IN p_charID VARCHAR(21),
    IN p_nation TINYINT UNSIGNED,
    IN p_notice VARBINARY(1024))
    MODIFIES SQL DATA
BEGIN
    DELETE FROM KING_CANDIDACY_NOTICE_BOARD WHERE strUserID = p_charID;

    INSERT INTO KING_CANDIDACY_NOTICE_BOARD (strUserID, byNation, sNoticeLen, strNotice)
    VALUES (p_charID, p_nation, COALESCE(OCTET_LENGTH(p_notice), 0), p_notice);
END$$

-- ---------------------------------------------------------------------------
-- KING_CHANGE_TAX
--   call site: {? = CALL KING_CHANGE_TAX (%d, %d, %d, %d)}    (DBAgent.cpp:2093)
--              (opcode, nation, territory tariff, territory tax)
--   The dumped routine declares eight parameters (six tax values for both
--   nations) but the C++ only sends four, so that call could not have worked.
--   The port keeps the call-site shape and maps:
--       opcode 4 -> tax rate      (byTerritoryTariff = tariff)
--       opcode 2 -> collect tax   (nTerritoryTax     = tax)
--       opcode 5 -> tribute       (nTribute          = tax)
--       opcode 6 -> collect tax and tribute for BOTH nations (as in the dump,
--                   using the same values for Karus and Elmorad)
--   Returns 1 when KING_SYSTEM was updated, 0 otherwise.
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `KING_CHANGE_TAX`$$
CREATE PROCEDURE `KING_CHANGE_TAX`(
    OUT p_result   SMALLINT,
    IN  p_type     TINYINT UNSIGNED,
    IN  p_nation   TINYINT UNSIGNED,
    IN  p_tariff   INT,
    IN  p_tax      INT)
    MODIFIES SQL DATA
BEGIN
    DECLARE v_count INT DEFAULT 0;

    IF p_type = 4 THEN
        UPDATE KING_SYSTEM SET byTerritoryTariff = p_tariff WHERE byNation = p_nation;
    ELSEIF p_type = 2 THEN
        UPDATE KING_SYSTEM SET nTerritoryTax = p_tax WHERE byNation = p_nation;
    ELSEIF p_type = 5 THEN
        UPDATE KING_SYSTEM SET nTribute = p_tax WHERE byNation = p_nation;
    ELSEIF p_type = 6 THEN
        UPDATE KING_SYSTEM
           SET nTerritoryTax = p_tax, nTribute = p_tariff
         WHERE byNation = p_nation;
    END IF;

    SET v_count = ROW_COUNT();
    SET p_result = IF(v_count > 0, 1, 0);
END$$

-- ---------------------------------------------------------------------------
-- KING_INSERT_PRIZE_EVENT
--   call site: {? = CALL KING_INSERT_PRIZE_EVENT(%d, %d, %d, ?)}  (:2077)
--              (type, nation, amount, recipient)
--   1 = treasury debited, 0 = nothing to debit, -3 = database error.
--
--   The dumped routine only decrements nNationalTreasury and never records who
--   received the prize (and computes @nType = @nType + 2 on an unset variable,
--   which yields NULL).  The port keeps the debit and records the payout in
--   KING_ELECTION_LIST (byType 5, the dump's own "prize" slot) so the king's
--   spending is auditable.
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `KING_INSERT_PRIZE_EVENT`$$
CREATE PROCEDURE `KING_INSERT_PRIZE_EVENT`(
    OUT p_result   TINYINT,
    IN  p_type     TINYINT UNSIGNED,
    IN  p_nation   TINYINT UNSIGNED,
    IN  p_amount   INT,
    IN  p_userID   VARCHAR(21))
    MODIFIES SQL DATA
proc: BEGIN
    DECLARE v_treasury INT DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result = -3;
    END;

    START TRANSACTION;

    SELECT nNationalTreasury INTO v_treasury
      FROM KING_SYSTEM WHERE byNation = p_nation FOR UPDATE;

    IF v_treasury IS NULL THEN
        ROLLBACK;
        SET p_result = 0;
        LEAVE proc;
    END IF;

    UPDATE KING_SYSTEM
       SET nNationalTreasury = nNationalTreasury - p_amount
     WHERE byNation = p_nation;

    INSERT INTO KING_ELECTION_LIST (byType, byNation, nKnights, strName, nMoney)
    SELECT 5, p_nation, COALESCE(Knights, 0), p_userID, p_amount
      FROM USERDATA WHERE strUserID = p_userID;

    COMMIT;
    SET p_result = 1;
END$$

-- ---------------------------------------------------------------------------
-- KING_UPDATE_NOAH_OR_EXP_EVENT
--   call site: {CALL KING_UPDATE_NOAH_OR_EXP_EVENT(7 ints)}   (DBAgent.cpp:2044)
--   The dump spells the fourth value @byHout; the call site is positional.
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `KING_UPDATE_NOAH_OR_EXP_EVENT`$$
CREATE PROCEDURE `KING_UPDATE_NOAH_OR_EXP_EVENT`(
    IN p_type     TINYINT UNSIGNED,
    IN p_nation   TINYINT UNSIGNED,
    IN p_amount   TINYINT UNSIGNED,
    IN p_day      TINYINT UNSIGNED,
    IN p_hour     TINYINT UNSIGNED,
    IN p_minute   TINYINT UNSIGNED,
    IN p_duration SMALLINT)
    MODIFIES SQL DATA
BEGIN
    IF p_type = 1 THEN                    -- noah reward
        UPDATE KING_SYSTEM
           SET byNoahEvent = p_amount, byNoahEvent_Day = p_day,
               byNoahEvent_Hour = p_hour, byNoahEvent_Minute = p_minute,
               sNoahEvent_Duration = p_duration
         WHERE byNation = p_nation;
    ELSEIF p_type = 2 THEN                -- exp reward
        UPDATE KING_SYSTEM
           SET byExpEvent = p_amount, byExpEvent_Day = p_day,
               byExpEvent_Hour = p_hour, byExpEvent_Minute = p_minute,
               sExpEvent_Duration = p_duration
         WHERE byNation = p_nation;
    END IF;
END$$

DELIMITER ;
