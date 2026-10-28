-- MySQL 8.4 functions and view for KO1534.
--
-- Ported by hand from the ten SQL Server scalar functions in KO1534_sql.zip.
-- The originals are reproduced in docs/sqlserver/SQLSERVER_ROUTINES.md for
-- comparison.
--
-- MySQL notes:
--   * A MySQL function may not contain transactions, so anything that needed
--     one stayed a procedure.
--   * `SELECT @v = expr FROM ...` (T-SQL) became `SELECT expr INTO v FROM ...`.
--   * T-SQL LEN() ignores trailing spaces -> CHAR_LENGTH(RTRIM(...)).
--   * Identifier quoting is backticks; [Rank]/[Level]/[Zone]/[Exp] are
--     reserved words in MySQL 8.
--   * TINYINT UNSIGNED columns keep the 0..255 range of T-SQL tinyint.

SET NAMES utf8mb4;

DROP FUNCTION IF EXISTS `HashPasswordString`;
DROP FUNCTION IF EXISTS `IsBanned`;
DROP FUNCTION IF EXISTS `isInClan`;
DROP FUNCTION IF EXISTS `IsKing`;
DROP FUNCTION IF EXISTS `isNationSelected`;
DROP FUNCTION IF EXISTS `IsUserOnlineGame`;
DROP FUNCTION IF EXISTS `IsValidCharacters`;
DROP FUNCTION IF EXISTS `GET_ACCOUNT_NAME`;
DROP FUNCTION IF EXISTS `GetNewRace`;
DROP FUNCTION IF EXISTS `GET_RACE_FOR_ACCOUNT_NATION_TRANSFER`;

DELIMITER $$

-- ---------------------------------------------------------------------------
-- HashPasswordString
--
-- Client-side password hash.  The 1534 client hashes the typed password with
-- this exact algorithm and sends the 28-character result as the "password";
-- TB_USER.strPasswd stores that result verbatim, which is why ACCOUNT_LOGIN
-- can simply compare strings.
--
-- Ported bit-for-bit from T-SQL.  The T-SQL original relies on implicit
-- conversions (varbinary->int is big-endian, int->varbinary(4) keeps the low
-- four bytes, POWER(2.0,n) rounds through float); the port reproduces those
-- semantics explicitly with unsigned 64-bit arithmetic.
--
-- Verified: HashPasswordString('admin') = 'RQ4F74043XIKH1', which is the hash
-- stored for account `admin` in the supplied dump.
-- ---------------------------------------------------------------------------
CREATE FUNCTION `HashPasswordString`(p_inputPassword VARCHAR(50))
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE v_encodingArray VARBINARY(64) DEFAULT
        0x1a1f110a1e1018021d08140f1c0b0d041317000c0e1b06121503090716011905121d07190f1f161b091a030d130e140b050217100a181c11061e00150c080401;
    DECLARE v_alphabetArray CHAR(36) DEFAULT '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    DECLARE v_startKey INT DEFAULT 1000;             -- 0x03e8

    DECLARE v_len INT;
    DECLARE v_i INT DEFAULT 0;
    DECLARE v_out VARCHAR(56) DEFAULT '';

    DECLARE v_block VARBINARY(4);
    DECLARE v_b0, v_b1, v_b2, v_b3 INT;
    DECLARE v_encoded BIGINT UNSIGNED;
    DECLARE v_key BIGINT UNSIGNED;
    DECLARE v_tmp BIGINT UNSIGNED;
    DECLARE v_counter INT;
    DECLARE v_acc BIGINT UNSIGNED;
    DECLARE v_shift INT;
    DECLARE v_put BIGINT UNSIGNED;
    DECLARE v_upper BIGINT UNSIGNED;
    DECLARE v_diff BIGINT UNSIGNED;
    DECLARE v_j INT;

    -- T-SQL LEN() ignores trailing spaces.
    SET v_len = CHAR_LENGTH(RTRIM(p_inputPassword));
    WHILE v_len % 4 <> 0 DO
        SET v_len = v_len + 1;
    END WHILE;

    WHILE v_i < v_len DO
        -- CAST(REVERSE(SUBSTRING(@inputPassword, @i+1, 4)) AS VARBINARY(4)),
        -- converted to int big-endian.
        SET v_block = CAST(REVERSE(SUBSTRING(p_inputPassword, v_i + 1, 4)) AS BINARY);
        SET v_b0 = IFNULL(ORD(SUBSTRING(v_block, 1, 1)), 0);
        SET v_b1 = IFNULL(ORD(SUBSTRING(v_block, 2, 1)), 0);
        SET v_b2 = IFNULL(ORD(SUBSTRING(v_block, 3, 1)), 0);
        SET v_b3 = IFNULL(ORD(SUBSTRING(v_block, 4, 1)), 0);
        SET v_encoded = v_b0 * 16777216 + v_b1 * 65536 + v_b2 * 256 + v_b3;

        SET v_key = (v_encoded + v_startKey) & 0xFFFFFFFF;
        SET v_counter = 0;
        SET v_acc = 0;

        WHILE v_key > 0 DO
            SET v_tmp = v_key;
            SET v_key = v_key DIV 2;
            IF (v_tmp & 1) <> 0 THEN
                SET v_shift = IFNULL(ORD(SUBSTRING(v_encodingArray, v_counter + 1, 1)), 0);
                SET v_acc = (v_acc + CAST(POWER(2, v_shift) AS UNSIGNED)) & 0xFFFFFFFF;
            END IF;
            SET v_counter = v_counter + 1;
        END WHILE;

        -- Seven base-36 digits, least significant first.
        SET v_put = v_acc;
        SET v_j = 0;
        WHILE v_j < 7 DO
            SET v_upper = v_put DIV 36;
            SET v_diff = v_put - v_upper * 36;
            SET v_out = CONCAT(v_out, SUBSTRING(v_alphabetArray, v_diff + 1, 1));
            SET v_put = v_upper;
            SET v_j = v_j + 1;
        END WHILE;

        SET v_i = v_i + 4;
    END WHILE;

    RETURN v_out;
END$$

-- ---------------------------------------------------------------------------
-- IsBanned: any character on the account has Authority 255.
-- ---------------------------------------------------------------------------
CREATE FUNCTION `IsBanned`(p_strAccountID VARCHAR(21))
RETURNS TINYINT UNSIGNED
READS SQL DATA
BEGIN
    DECLARE v_result TINYINT UNSIGNED;

    SELECT Authority INTO v_result FROM USERDATA
     WHERE strUserID IN (SELECT strCharID1 FROM ACCOUNT_CHAR WHERE strAccountID = p_strAccountID);
    IF (v_result = 255) THEN RETURN 1; END IF;

    SELECT Authority INTO v_result FROM USERDATA
     WHERE strUserID IN (SELECT strCharID2 FROM ACCOUNT_CHAR WHERE strAccountID = p_strAccountID);
    IF (v_result = 255) THEN RETURN 1; END IF;

    SELECT Authority INTO v_result FROM USERDATA
     WHERE strUserID IN (SELECT strCharID3 FROM ACCOUNT_CHAR WHERE strAccountID = p_strAccountID);
    IF (v_result = 255) THEN RETURN 1; END IF;

    RETURN 0;
END$$

-- ---------------------------------------------------------------------------
-- isInClan: 1 if the account has at least one character in a clan.
-- ---------------------------------------------------------------------------
CREATE FUNCTION `isInClan`(p_strAccountID VARCHAR(50))
RETURNS TINYINT UNSIGNED
READS SQL DATA
BEGIN
    DECLARE v_count TINYINT UNSIGNED DEFAULT 0;

    SELECT COUNT(strUserID) INTO v_count FROM USERDATA
     WHERE Knights <> 0
       AND (   strUserID IN (SELECT strCharID1 FROM ACCOUNT_CHAR
                              WHERE strAccountID = p_strAccountID AND CHAR_LENGTH(strCharID1) <> 0)
            OR strUserID IN (SELECT strCharID2 FROM ACCOUNT_CHAR
                              WHERE strAccountID = p_strAccountID AND CHAR_LENGTH(strCharID2) <> 0)
            OR strUserID IN (SELECT strCharID3 FROM ACCOUNT_CHAR
                              WHERE strAccountID = p_strAccountID AND CHAR_LENGTH(strCharID3) <> 0));

    RETURN IFNULL(v_count, 0);
END$$

-- ---------------------------------------------------------------------------
-- IsKing
-- ---------------------------------------------------------------------------
CREATE FUNCTION `IsKing`(p_CharID VARCHAR(20))
RETURNS TINYINT UNSIGNED
READS SQL DATA
BEGIN
    DECLARE v_count INT DEFAULT 0;

    SELECT COUNT(strKingName) INTO v_count FROM KING_SYSTEM WHERE strKingName = p_CharID;

    RETURN IF(v_count = 0, 0, 1);
END$$

-- ---------------------------------------------------------------------------
-- isNationSelected
-- ---------------------------------------------------------------------------
CREATE FUNCTION `isNationSelected`(p_strAccountID VARCHAR(50))
RETURNS TINYINT UNSIGNED
READS SQL DATA
BEGIN
    DECLARE v_count INT DEFAULT 0;

    SELECT COUNT(strAccountID) INTO v_count FROM ACCOUNT_CHAR WHERE strAccountID = p_strAccountID;

    RETURN IFNULL(v_count, 0);
END$$

-- ---------------------------------------------------------------------------
-- IsUserOnlineGame: 5 if the account still has a CURRENTUSER row.
-- ---------------------------------------------------------------------------
CREATE FUNCTION `IsUserOnlineGame`(p_strAccountID VARCHAR(20))
RETURNS TINYINT UNSIGNED
READS SQL DATA
BEGIN
    DECLARE v_count INT DEFAULT 0;

    SELECT COUNT(*) INTO v_count FROM CURRENTUSER WHERE strAccountID = p_strAccountID;

    RETURN IF(v_count > 0, 5, 0);
END$$

-- ---------------------------------------------------------------------------
-- IsValidCharacters: 0 if the name only contains the allowed characters.
-- ---------------------------------------------------------------------------
CREATE FUNCTION `IsValidCharacters`(p_SData VARCHAR(8000))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_rx VARCHAR(8000) DEFAULT 'qwertyuopasdfghjklizxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890';
    DECLARE v_len INT;
    DECLARE v_i INT DEFAULT 1;
    DECLARE v_letter VARCHAR(1);
    DECLARE v_match INT DEFAULT 0;

    SET v_len = CHAR_LENGTH(RTRIM(p_SData));

    scan: BEGIN
        WHILE v_i < (v_len + 1) DO
            SET v_letter = TRIM(SUBSTRING(p_SData, v_i, 1));
            IF LOCATE(v_letter, v_rx) = 0 THEN
                SET v_match = 1;
                LEAVE scan;
            END IF;
            SET v_i = v_i + 1;
        END WHILE;
    END scan;

    RETURN v_match;
END$$

-- ---------------------------------------------------------------------------
-- GET_ACCOUNT_NAME: account that owns a character name.
-- ---------------------------------------------------------------------------
CREATE FUNCTION `GET_ACCOUNT_NAME`(p_strUserId CHAR(21))
RETURNS VARCHAR(21)
READS SQL DATA
BEGIN
    DECLARE v_accountID VARCHAR(21) DEFAULT NULL;

    SELECT strAccountID INTO v_accountID FROM ACCOUNT_CHAR
     WHERE strCharID1 = p_strUserId AND strCharID1 IS NOT NULL;
    SELECT strAccountID INTO v_accountID FROM ACCOUNT_CHAR
     WHERE strCharID2 = p_strUserId AND strCharID2 IS NOT NULL;
    SELECT strAccountID INTO v_accountID FROM ACCOUNT_CHAR
     WHERE strCharID3 = p_strUserId AND strCharID3 IS NOT NULL;

    RETURN TRIM(v_accountID);
END$$

-- ---------------------------------------------------------------------------
-- GetNewRace: race remap used by nation transfer / class change.
-- ---------------------------------------------------------------------------
CREATE FUNCTION `GetNewRace`(p_bRace TINYINT UNSIGNED, p_bClass TINYINT UNSIGNED)
RETURNS TINYINT UNSIGNED
DETERMINISTIC
BEGIN
    DECLARE v_race TINYINT UNSIGNED DEFAULT p_bRace;

    IF p_bRace = 1 THEN SET v_race = 11;
    ELSEIF p_bRace = 2 THEN SET v_race = 12;
    ELSEIF p_bRace = 3 THEN SET v_race = 12;
    ELSEIF p_bRace = 4 THEN SET v_race = 13;
    ELSEIF p_bRace = 11 THEN SET v_race = 1;
    ELSEIF p_bRace = 12 AND p_bClass IN (201,205,206) THEN SET v_race = 1;
    ELSEIF p_bRace = 13 AND p_bClass IN (201,205,206) THEN SET v_race = 1;
    ELSEIF p_bRace = 12 AND p_bClass IN (202,207,208) THEN SET v_race = 2;
    ELSEIF p_bRace = 13 AND p_bClass IN (202,207,208) THEN SET v_race = 2;
    ELSEIF p_bRace = 12 AND p_bClass IN (203,209,210) THEN SET v_race = 3;
    ELSEIF p_bRace = 13 AND p_bClass IN (203,209,210) THEN SET v_race = 4;
    ELSEIF p_bRace = 12 AND p_bClass IN (204,211,212) THEN SET v_race = 2;
    ELSEIF p_bRace = 13 AND p_bClass IN (204,211,212) THEN SET v_race = 4;
    END IF;

    RETURN v_race;
END$$

-- ---------------------------------------------------------------------------
-- GET_RACE_FOR_ACCOUNT_NATION_TRANSFER
-- ---------------------------------------------------------------------------
CREATE FUNCTION `GET_RACE_FOR_ACCOUNT_NATION_TRANSFER`(p_Race TINYINT UNSIGNED,
                                                       p_Class TINYINT UNSIGNED)
RETURNS TINYINT UNSIGNED
DETERMINISTIC
BEGIN
    DECLARE v_race TINYINT UNSIGNED DEFAULT p_Race;

    IF p_Race = 1 THEN SET v_race = 12;
    ELSEIF p_Race = 2 THEN SET v_race = 12;
    ELSEIF p_Race = 3 THEN SET v_race = 12;
    ELSEIF p_Race = 4 THEN SET v_race = 13;
    ELSEIF p_Race = 11 THEN SET v_race = 1;
    ELSEIF p_Race IN (12,13) AND p_Class IN (201,205,206) THEN SET v_race = 1;
    ELSEIF p_Race IN (12,13) AND p_Class IN (202,207,208) THEN SET v_race = 2;
    ELSEIF p_Race IN (12,13) AND p_Class IN (203,209,210) THEN SET v_race = 3;
    ELSEIF p_Race IN (12,13) AND p_Class IN (204,211,212) THEN SET v_race = 2;
    END IF;

    RETURN v_race;
END$$

DELIMITER ;

-- ---------------------------------------------------------------------------
-- ACCOUNT_CHAR_VIEW (identical to the SQL Server definition)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE SQL SECURITY INVOKER VIEW `ACCOUNT_CHAR_VIEW` AS
    SELECT `ACCOUNT_CHAR`.`strAccountID` FROM `ACCOUNT_CHAR`;
