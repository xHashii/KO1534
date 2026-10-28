-- MySQL 8.4 stored procedures for KO1534 -- milestone 1 set.
--
-- Ported by hand from the T-SQL procedures in KO1534_sql.zip.  The SQL Server
-- original is kept in docs/sqlserver/SQLSERVER_ROUTINES.md for comparison.
--
-- Conventions used by this port (must match the C++ call sites):
--
--   * T-SQL `RETURN <int>` becomes a leading `OUT p_result <type>` parameter.
--     The C++ binds the output parameter *first* (it used to be the
--     "{? = CALL ...}" return value), so the argument order is unchanged.
--   * Procedures that already had OUTPUT parameters keep them in place.
--   * `@@ROWCOUNT = 0` -> `ROW_COUNT() = 0` immediately after the statement.
--   * `@@ERROR` -> `DECLARE EXIT HANDLER FOR SQLEXCEPTION` + ROLLBACK.
--   * `GETDATE()` -> `NOW(3)`; `DATEDIFF(HH,...)` -> `TIMESTAMPDIFF(HOUR,...)`.
--   * Identifiers such as [Rank], [Level], [Exp], [Zone] are reserved words in
--     MySQL 8 and are backticked.
--   * Binary blobs are VARBINARY; the server writes 74 inventory slots
--     (592/592/296/296 bytes), which is why USERDATA is widened.

SET NAMES utf8mb4;

DROP PROCEDURE IF EXISTS `ACCOUNT_LOGIN`;
DROP PROCEDURE IF EXISTS `ACCOUNT_PREMIUM`;
DROP PROCEDURE IF EXISTS `ACCOUNT_LOGOUT`;
DROP PROCEDURE IF EXISTS `GAME_LOGIN`;
DROP PROCEDURE IF EXISTS `NATION_SELECT`;
DROP PROCEDURE IF EXISTS `CREATE_NEW_CHAR`;
DROP PROCEDURE IF EXISTS `CHANGE_HAIR`;
DROP PROCEDURE IF EXISTS `SET_LOGIN_INFO`;
DROP PROCEDURE IF EXISTS `CLEAR_REMAIN_USERS`;
DROP PROCEDURE IF EXISTS `INSERT_CURRENTUSER`;
DROP PROCEDURE IF EXISTS `LOAD_USER_DATA`;
DROP PROCEDURE IF EXISTS `UPDATE_USER_DATA`;
DROP PROCEDURE IF EXISTS `LOAD_RENTAL_DATA`;
DROP PROCEDURE IF EXISTS `LOAD_SEAL_USER`;
DROP PROCEDURE IF EXISTS `LOAD_SEAL_PASSWD`;
DROP PROCEDURE IF EXISTS `LOAD_SEALED_ITEM_DATA`;
DROP PROCEDURE IF EXISTS `LOAD_PREMIUM_SERVICE_USER`;
DROP PROCEDURE IF EXISTS `SAVE_PREMIUM_SERVICE_USER`;
DROP PROCEDURE IF EXISTS `SKILLSHORTCUT_LOAD`;
DROP PROCEDURE IF EXISTS `SKILLSHORTCUT_SAVE`;
DROP PROCEDURE IF EXISTS `LOAD_WEB_ITEMMALL`;

DELIMITER $$

-- ---------------------------------------------------------------------------
-- ACCOUNT_LOGIN  (LogInServer)
--   returns 1 = ok, 3 = wrong password
--   Auto-registers the account on first login, storing the client-supplied
--   hash verbatim (exactly like the T-SQL original).
-- ---------------------------------------------------------------------------
CREATE PROCEDURE `ACCOUNT_LOGIN`(
    OUT p_result    TINYINT UNSIGNED,
    IN  p_accountID VARCHAR(21),
    IN  p_passwd    VARCHAR(28))
    MODIFIES SQL DATA
proc: BEGIN
    DECLARE v_count INT DEFAULT 0;
    DECLARE v_hash  VARCHAR(64) DEFAULT NULL;

    SELECT COUNT(*) INTO v_count FROM TB_USER WHERE strAccountID = p_accountID;

    IF v_count = 0 THEN
        INSERT INTO TB_USER (strAccountID, strPasswd) VALUES (p_accountID, p_passwd);
        SET p_result = 1;
        LEAVE proc;
    END IF;

    SELECT strPasswd INTO v_hash FROM TB_USER WHERE strAccountID = p_accountID LIMIT 1;

    IF v_hash IS NULL OR v_hash <> p_passwd THEN
        SET p_result = 3;
        LEAVE proc;
    END IF;

    DELETE FROM CURRENTUSER WHERE strAccountID = p_accountID;
    SET p_result = 1;
END$$

-- ---------------------------------------------------------------------------
-- ACCOUNT_PREMIUM  (LogInServer) -> remaining premium hours, or -1
-- ---------------------------------------------------------------------------
CREATE PROCEDURE `ACCOUNT_PREMIUM`(
    OUT p_result    SMALLINT,
    IN  p_accountID VARCHAR(21))
    READS SQL DATA
BEGIN
    DECLARE v_hours SMALLINT DEFAULT NULL;

    SELECT TIMESTAMPDIFF(HOUR, NOW(), dtPremiumTime) INTO v_hours
      FROM TB_USER WHERE strAccountID = p_accountID LIMIT 1;

    IF v_hours IS NULL OR v_hours <= 0 THEN
        SET p_result = -1;
    ELSE
        SET p_result = v_hours;
    END IF;
END$$

-- ---------------------------------------------------------------------------
-- ACCOUNT_LOGOUT
-- ---------------------------------------------------------------------------
CREATE PROCEDURE `ACCOUNT_LOGOUT`(IN p_accountID VARCHAR(21))
    MODIFIES SQL DATA
BEGIN
    DELETE FROM CURRENTUSER WHERE strAccountID = p_accountID;
END$$

-- ---------------------------------------------------------------------------
-- GAME_LOGIN  (GameServer)
--   -1 bad account/password or authority 9, 0 = nation not selected,
--   1 = Karus, 2 = El Morad, 18 = banned, 21 = server full.
-- ---------------------------------------------------------------------------
CREATE PROCEDURE `GAME_LOGIN`(
    OUT p_result    TINYINT,
    IN  p_accountID VARCHAR(21),
    IN  p_passwd    VARCHAR(28))
    READS SQL DATA
proc: BEGIN
    DECLARE v_count       INT DEFAULT 0;
    DECLARE v_password    VARCHAR(64) DEFAULT NULL;
    DECLARE v_authority   TINYINT UNSIGNED DEFAULT NULL;
    DECLARE v_premiumType TINYINT UNSIGNED DEFAULT NULL;
    DECLARE v_freeLimit   SMALLINT DEFAULT NULL;
    DECLARE v_preLimit    SMALLINT DEFAULT NULL;
    DECLARE v_serverIP    VARCHAR(50) DEFAULT NULL;
    DECLARE v_maint       TINYINT UNSIGNED DEFAULT NULL;
    DECLARE v_totalUsers  INT DEFAULT 0;
    DECLARE v_nation      TINYINT UNSIGNED DEFAULT NULL;

    SELECT COUNT(*) INTO v_count FROM TB_USER WHERE strAccountID = p_accountID;
    IF v_count = 0 THEN
        SET p_result = -1;
        LEAVE proc;
    END IF;

    SELECT strPasswd, strAuthority, bPremiumType
      INTO v_password, v_authority, v_premiumType
      FROM TB_USER WHERE strAccountID = p_accountID LIMIT 1;

    IF v_password IS NULL OR v_password <> p_passwd OR v_authority = 9 THEN
        SET p_result = -1;
        LEAVE proc;
    END IF;

    IF IsBanned(p_accountID) = 1 THEN
        SET p_result = 18;
        LEAVE proc;
    END IF;

    SELECT FreeLimit, PremiumLimit, ServerIPAddress, MaintenanceMode
      INTO v_freeLimit, v_preLimit, v_serverIP, v_maint
      FROM GAME_OPTIONS WHERE MaintenanceMode = 0 LIMIT 1;

    IF v_maint = 1 AND v_authority <> 0 THEN
        SET p_result = 6;
        LEAVE proc;
    END IF;

    SELECT COUNT(strServerIP) INTO v_totalUsers
      FROM CURRENTUSER WHERE strServerIP = v_serverIP;

    IF (v_premiumType = 0 AND v_totalUsers >= v_freeLimit)
       OR (v_premiumType > 0 AND v_totalUsers >= v_preLimit) THEN
        SET p_result = 21;
        LEAVE proc;
    END IF;

    SELECT COUNT(*) INTO v_count FROM ACCOUNT_CHAR WHERE strAccountID = p_accountID;
    IF v_count = 0 THEN
        SET p_result = 0;
        LEAVE proc;
    END IF;

    SELECT bNation INTO v_nation FROM ACCOUNT_CHAR WHERE strAccountID = p_accountID LIMIT 1;
    SET p_result = v_nation;
END$$

-- ---------------------------------------------------------------------------
-- NATION_SELECT: create ACCOUNT_CHAR + WAREHOUSE rows on first nation choice.
-- ---------------------------------------------------------------------------
CREATE PROCEDURE `NATION_SELECT`(
    OUT p_result    TINYINT UNSIGNED,
    IN  p_accountID VARCHAR(21),
    IN  p_nation    TINYINT UNSIGNED)
    MODIFIES SQL DATA
proc: BEGIN
    DECLARE v_count INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result = 0;
    END;

    START TRANSACTION;

    SELECT COUNT(strAccountID) INTO v_count FROM ACCOUNT_CHAR WHERE strAccountID = p_accountID;
    IF v_count = 0 THEN
        INSERT INTO ACCOUNT_CHAR (strAccountID, bNation) VALUES (p_accountID, p_nation);
    END IF;

    SELECT COUNT(strAccountID) INTO v_count FROM WAREHOUSE WHERE strAccountID = p_accountID;
    IF v_count = 0 THEN
        INSERT INTO WAREHOUSE (strAccountID, nMoney, dwTime, WarehouseData,
                               strSerial, strUserSeal, WarehouseDataTime)
        VALUES (p_accountID, 0, 0, 0x00, 0x00, 0x00, 0x00);
    END IF;

    COMMIT;
    SET p_result = p_nation;
END$$

-- ---------------------------------------------------------------------------
-- CREATE_NEW_CHAR
--   0 ok, 2 invalid race/nation, 3 name taken, 4 database error
-- ---------------------------------------------------------------------------
CREATE PROCEDURE `CREATE_NEW_CHAR`(
    OUT p_result    TINYINT,
    IN  p_accountID VARCHAR(21),
    IN  p_index     TINYINT UNSIGNED,
    IN  p_charID    VARCHAR(21),
    IN  p_race      TINYINT UNSIGNED,
    IN  p_class     SMALLINT,
    IN  p_hair      INT,
    IN  p_face      TINYINT UNSIGNED,
    IN  p_str       TINYINT UNSIGNED,
    IN  p_sta       TINYINT UNSIGNED,
    IN  p_dex       TINYINT UNSIGNED,
    IN  p_intel     TINYINT UNSIGNED,
    IN  p_cha       TINYINT UNSIGNED)
    MODIFIES SQL DATA
proc: BEGIN
    DECLARE v_nation   TINYINT UNSIGNED DEFAULT NULL;
    DECLARE v_count    INT DEFAULT 0;
    DECLARE v_affected INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result = 4;
    END;

    SELECT bNation INTO v_nation FROM ACCOUNT_CHAR WHERE strAccountID = p_accountID LIMIT 1;

    IF v_nation = 1 AND p_race > 10 THEN SET p_result = 2; LEAVE proc; END IF;
    IF v_nation = 2 AND p_race < 10 THEN SET p_result = 2; LEAVE proc; END IF;
    IF v_nation <> 1 AND v_nation <> 2 THEN SET p_result = 2; LEAVE proc; END IF;

    SELECT COUNT(strUserID) INTO v_count FROM USERDATA WHERE strUserID = p_charID;
    IF v_count > 0 THEN SET p_result = 3; LEAVE proc; END IF;

    START TRANSACTION;

    IF p_index = 0 THEN
        UPDATE ACCOUNT_CHAR SET strCharID1 = p_charID, bCharNum = bCharNum + 1
         WHERE strAccountID = p_accountID;
    ELSEIF p_index = 1 THEN
        UPDATE ACCOUNT_CHAR SET strCharID2 = p_charID, bCharNum = bCharNum + 1
         WHERE strAccountID = p_accountID;
    ELSEIF p_index = 2 THEN
        UPDATE ACCOUNT_CHAR SET strCharID3 = p_charID, bCharNum = bCharNum + 1
         WHERE strAccountID = p_accountID;
    END IF;

    SET v_affected = ROW_COUNT();
    IF v_affected = 0 THEN
        ROLLBACK;
        SET p_result = 4;
        LEAVE proc;
    END IF;

    INSERT INTO USERDATA (strUserID, Nation, Race, Class, HairRGB, Face,
                          Strong, Sta, Dex, Intel, Cha, dtCreateTime)
    VALUES (p_charID, v_nation, p_race, p_class, p_hair, p_face,
            p_str, p_sta, p_dex, p_intel, p_cha, NOW(3));

    COMMIT;
    SET p_result = 0;
END$$

-- ---------------------------------------------------------------------------
-- CHANGE_HAIR: 0 ok, 1 no such character / not owned by the account
--
--   Call site: {? = CALL CHANGE_HAIR(?, ?, %d, %d, %d)}   (DBAgent.cpp:220)
--              (OUT, account, character, opcode, face, hair)
--
--   The six-parameter call-site shape is used because the C++ binds six values;
--   a four-parameter procedure could never have been called.  bOpcode tells the
--   server which hair encoding the client used (0 = legacy conversion, 2 = hair
--   change item); both write the same two columns, so it only gates ownership
--   verification here.
-- ---------------------------------------------------------------------------
CREATE PROCEDURE `CHANGE_HAIR`(
    OUT p_result    TINYINT,
    IN  p_accountID VARCHAR(21),
    IN  p_charID    VARCHAR(21),
    IN  p_opcode    TINYINT UNSIGNED,
    IN  p_face      TINYINT UNSIGNED,
    IN  p_hair      INT)
    MODIFIES SQL DATA
proc: BEGIN
    DECLARE v_count INT DEFAULT 0;

    -- Only a character that belongs to this account may be restyled.
    SELECT COUNT(*) INTO v_count
      FROM ACCOUNT_CHAR
     WHERE strAccountID = p_accountID
       AND (strCharID1 = p_charID OR strCharID2 = p_charID OR strCharID3 = p_charID);

    IF v_count = 0 THEN
        SET p_result = 1;
        LEAVE proc;
    END IF;

    UPDATE USERDATA SET HairRGB = p_hair, Face = p_face WHERE strUserID = p_charID;
    SET p_result = 0;
END$$

-- ---------------------------------------------------------------------------
-- SET_LOGIN_INFO: returns 1 on success
-- ---------------------------------------------------------------------------
CREATE PROCEDURE `SET_LOGIN_INFO`(
    OUT p_result    TINYINT UNSIGNED,
    IN  p_accountID VARCHAR(21),
    IN  p_charID    VARCHAR(21),
    IN  p_serverNo  SMALLINT,
    IN  p_serverIP  VARCHAR(50),
    IN  p_clientIP  VARCHAR(50),
    IN  p_init      TINYINT UNSIGNED)
    MODIFIES SQL DATA
BEGIN
    IF p_init = 1 THEN
        INSERT INTO CURRENTUSER (strAccountID, strCharID, nServerNo, strServerIP, strClientIP)
        VALUES (p_accountID, p_charID, p_serverNo, p_serverIP, p_clientIP);
    ELSE
        UPDATE CURRENTUSER SET nServerNo = p_serverNo, strServerIP = p_serverIP
         WHERE strAccountID = p_accountID;
    END IF;

    UPDATE TB_USER SET strClientIP = p_clientIP WHERE strAccountID = p_accountID;

    SET p_result = 1;
END$$

-- ---------------------------------------------------------------------------
-- CLEAR_REMAIN_USERS: drop stale sessions after an unclean shutdown.
-- ---------------------------------------------------------------------------
CREATE PROCEDURE `CLEAR_REMAIN_USERS`(IN p_serverIP VARCHAR(50))
    MODIFIES SQL DATA
BEGIN
    DELETE FROM CURRENTUSER WHERE strServerIP = p_serverIP;
END$$

-- ---------------------------------------------------------------------------
-- INSERT_CURRENTUSER (legacy helper kept for parity)
-- ---------------------------------------------------------------------------
CREATE PROCEDURE `INSERT_CURRENTUSER`(
    IN  p_accountID VARCHAR(50),
    IN  p_charID    VARCHAR(50),
    IN  p_serverNo  INT,
    IN  p_serverIP  VARCHAR(50),
    IN  p_clientIP  VARCHAR(50),
    OUT p_result    SMALLINT)
    MODIFIES SQL DATA
BEGIN
    INSERT INTO CURRENTUSER (strAccountID, strCharID, nServerNo, strServerIP, strClientIP)
    VALUES (p_accountID, p_charID, p_serverNo, p_serverIP, p_clientIP);
    SET p_result = 1;
END$$

-- ---------------------------------------------------------------------------
-- LOAD_USER_DATA: the 42-column result set the game server reads in
-- CUser::LoadFromDatabase.  Column order is load-bearing.
-- ---------------------------------------------------------------------------
CREATE PROCEDURE `LOAD_USER_DATA`(
    IN p_accountID VARCHAR(21),
    IN p_charID    VARCHAR(21))
    READS SQL DATA
proc: BEGIN
    DECLARE v_count INT DEFAULT 0;

    SELECT COUNT(*) INTO v_count FROM ACCOUNT_CHAR
     WHERE strAccountID = p_accountID
       AND (strCharID1 = p_charID OR strCharID2 = p_charID OR strCharID3 = p_charID);

    IF v_count = 0 THEN
        -- T-SQL returned an empty result set here; so do we.
        SELECT Nation, Race, `Class`, HairRGB, `Rank`, Title, `Level`, `Exp`,
               Loyalty, Face, City, Knights, Fame, Hp, Mp, Sp, Strong, Sta, Dex,
               Intel, Cha, Authority, Points, Gold, `Zone`, Bind, PX, PZ, PY,
               dwTime, strSkill, strItem, strSerial, strUserSeal, strItemTime,
               sQuestCount, strQuest, sQuestDataCount, strQuestData,
               MannerPoint, LoyaltyMonthly, strMemo
          FROM USERDATA WHERE 1 = 0;
        LEAVE proc;
    END IF;

    SELECT Nation, Race, `Class`, HairRGB, `Rank`, Title, `Level`, `Exp`,
           Loyalty, Face, City, Knights, Fame, Hp, Mp, Sp, Strong, Sta, Dex,
           Intel, Cha, Authority, Points, Gold, `Zone`, Bind, PX, PZ, PY,
           dwTime, strSkill, strItem, strSerial, strUserSeal, strItemTime,
           sQuestCount, strQuest, sQuestDataCount, strQuestData,
           MannerPoint, LoyaltyMonthly, strMemo
      FROM USERDATA WHERE strUserID = p_charID;
END$$

-- ---------------------------------------------------------------------------
-- UPDATE_USER_DATA: the full character save.
-- ---------------------------------------------------------------------------
CREATE PROCEDURE `UPDATE_USER_DATA`(
    IN p_charID          VARCHAR(21),
    IN p_nation          TINYINT UNSIGNED,
    IN p_race            TINYINT UNSIGNED,
    IN p_class           SMALLINT,
    IN p_hair            INT,
    IN p_rank            TINYINT UNSIGNED,
    IN p_title           TINYINT UNSIGNED,
    IN p_level           TINYINT UNSIGNED,
    IN p_exp             BIGINT,
    IN p_loyalty         INT,
    IN p_face            TINYINT UNSIGNED,
    IN p_city            TINYINT UNSIGNED,
    IN p_knights         SMALLINT,
    IN p_fame            TINYINT UNSIGNED,
    IN p_hp              SMALLINT,
    IN p_mp              SMALLINT,
    IN p_sp              SMALLINT,
    IN p_str             TINYINT UNSIGNED,
    IN p_sta             TINYINT UNSIGNED,
    IN p_dex             TINYINT UNSIGNED,
    IN p_intel           TINYINT UNSIGNED,
    IN p_cha             TINYINT UNSIGNED,
    IN p_authority       TINYINT UNSIGNED,
    IN p_points          SMALLINT,
    IN p_gold            INT,
    IN p_zone            TINYINT UNSIGNED,
    IN p_bind            SMALLINT,
    IN p_x               INT,
    IN p_z               INT,
    IN p_y               INT,
    IN p_time            INT,
    IN p_questCount      SMALLINT,
    IN p_questDataCount  SMALLINT,
    IN p_skill           VARBINARY(10),
    IN p_item            VARBINARY(592),
    IN p_serial          VARBINARY(592),
    IN p_userSeal        VARBINARY(296),
    IN p_itemTime        VARBINARY(296),
    IN p_quest           VARBINARY(3888),
    IN p_questData       VARBINARY(1296),
    IN p_mannerPoint     INT,
    IN p_loyaltyMonthly  INT,
    IN p_memo            VARCHAR(21))
    MODIFIES SQL DATA
BEGIN
    UPDATE USERDATA SET
        Nation          = p_nation,
        Race            = p_race,
        `Class`         = p_class,
        HairRGB         = p_hair,
        `Rank`          = p_rank,
        Title           = p_title,
        `Level`         = p_level,
        `Exp`           = p_exp,
        Loyalty         = p_loyalty,
        Face            = p_face,
        City            = p_city,
        Knights         = p_knights,
        Fame            = p_fame,
        Hp              = p_hp,
        Mp              = p_mp,
        Sp              = p_sp,
        Strong          = p_str,
        Sta             = p_sta,
        Dex             = p_dex,
        Intel           = p_intel,
        Cha             = p_cha,
        Authority       = p_authority,
        Points          = p_points,
        Gold            = p_gold,
        `Zone`          = p_zone,
        Bind            = p_bind,
        PX              = p_x,
        PZ              = p_z,
        PY              = p_y,
        dwTime          = p_time,
        strSkill        = p_skill,
        strItem         = p_item,
        strSerial       = p_serial,
        strUserSeal     = p_userSeal,
        strItemTime     = p_itemTime,
        sQuestCount     = p_questCount,
        strQuest        = p_quest,
        sQuestDataCount = p_questDataCount,
        strQuestData    = p_questData,
        MannerPoint     = p_mannerPoint,
        LoyaltyMonthly  = p_loyaltyMonthly,
        dtUpdateTime    = NOW(3),
        strMemo         = p_memo
    WHERE strUserID = p_charID;
END$$

-- ---------------------------------------------------------------------------
-- LOAD_RENTAL_DATA: result set first, then expiry cleanup (as in T-SQL).
-- ---------------------------------------------------------------------------
CREATE PROCEDURE `LOAD_RENTAL_DATA`(IN p_accountID CHAR(21))
    MODIFIES SQL DATA
BEGIN
    SELECT strUserID, byRentalType, byRegType, nRentalIndex, nItemIndex,
           sDurability, nSerialNumber, nRentalMoney, sRentalTime,
           TIMESTAMPDIFF(MINUTE, timeRental, NOW()) AS sDuringTime,
           timeRental
      FROM USER_RENTAL_ITEM
     WHERE strAccountID = p_accountID;

    DELETE FROM USER_RENTAL_ITEM
     WHERE strAccountID = p_accountID
       AND byRentalType IN (2, 3)
       AND sRentalTime < TIMESTAMPDIFF(MINUTE, timeRental, NOW());

    UPDATE USER_RENTAL_ITEM SET nRentalMoney = 0
     WHERE strAccountID = p_accountID AND byRentalType = 2 AND nRentalMoney > 0;
END$$

-- ---------------------------------------------------------------------------
-- Seal helpers
-- ---------------------------------------------------------------------------
CREATE PROCEDURE `LOAD_SEAL_USER`(IN p_charID VARCHAR(21))
    READS SQL DATA
BEGIN
    SELECT `Level`, `Exp`, Race, `Class`, Strong, Sta, Dex, Intel, Cha, Gold,
           strSkill, strItem
      FROM USERDATA WHERE strUserID = p_charID;
END$$

CREATE PROCEDURE `LOAD_SEAL_PASSWD`(IN p_accountID VARCHAR(21))
    READS SQL DATA
BEGIN
    SELECT strSealPasswd FROM TB_USER WHERE strAccountID = p_accountID;
END$$

CREATE PROCEDURE `LOAD_SEALED_ITEM_DATA`(IN p_accountID CHAR(21))
    READS SQL DATA
BEGIN
    SELECT nItemSerial, nItemID, bSealType
      FROM SEALED_ITEMS WHERE strAccountID = p_accountID;
END$$

-- ---------------------------------------------------------------------------
-- Premium service
-- ---------------------------------------------------------------------------
CREATE PROCEDURE `LOAD_PREMIUM_SERVICE_USER`(
    IN  p_accountID CHAR(20),
    OUT p_type      TINYINT UNSIGNED,
    OUT p_time      SMALLINT)
    READS SQL DATA
BEGIN
    DECLARE v_premiumType TINYINT UNSIGNED DEFAULT NULL;
    DECLARE v_time        SMALLINT DEFAULT NULL;

    SELECT bPremiumType, TIMESTAMPDIFF(HOUR, NOW(), dtPremiumTime)
      INTO v_premiumType, v_time
      FROM TB_USER WHERE strAccountID = p_accountID LIMIT 1;

    IF v_time IS NULL OR v_time <= 0 THEN
        SET p_type = 0;
        SET p_time = 0;
    ELSE
        SET p_type = v_premiumType;
        SET p_time = v_time;
    END IF;
END$$

CREATE PROCEDURE `SAVE_PREMIUM_SERVICE_USER`(
    IN p_accountID CHAR(20),
    IN p_charID    CHAR(20),
    IN p_type      TINYINT UNSIGNED,
    IN p_time      SMALLINT)
    MODIFIES SQL DATA
BEGIN
    UPDATE TB_USER
       SET bPremiumType = p_type,
           dtPremiumTime = DATE_ADD(NOW(3), INTERVAL p_time HOUR),
           sHours = p_time
     WHERE strAccountID = p_accountID;

    INSERT INTO MAIL_BOX (strSenderID, strRecipientID, strSubject, strMessage,
                          bType, nItemID, sCount, sDurability)
    SELECT 'KnightOnline', p_charID, strItemName, 'Premium Bonus Item', 2,
           nItemID, sCount, sDurability
      FROM PREMIUM_ITEM_LETTER_GIFT WHERE bType = p_type;
END$$

-- ---------------------------------------------------------------------------
-- Skill shortcuts (strSkillData is an opaque 260-byte payload)
-- ---------------------------------------------------------------------------
CREATE PROCEDURE `SKILLSHORTCUT_LOAD`(IN p_charID VARCHAR(21))
    READS SQL DATA
BEGIN
    SELECT nCount, strSkillData FROM USERDATA_SKILLSHORTCUT WHERE strCharID = p_charID;
END$$

CREATE PROCEDURE `SKILLSHORTCUT_SAVE`(
    IN p_charID    VARCHAR(21),
    IN p_count     SMALLINT,
    IN p_skillData VARBINARY(260))
    MODIFIES SQL DATA
BEGIN
    DECLARE v_count INT DEFAULT 0;

    SELECT COUNT(*) INTO v_count FROM USERDATA_SKILLSHORTCUT WHERE strCharID = p_charID;
    IF v_count = 0 THEN
        INSERT INTO USERDATA_SKILLSHORTCUT (strCharID, nCount, strSkillData)
        VALUES (p_charID, 0, '');
    END IF;

    UPDATE USERDATA_SKILLSHORTCUT
       SET nCount = p_count, strSkillData = p_skillData
     WHERE strCharID = p_charID;
END$$

-- ---------------------------------------------------------------------------
-- LOAD_WEB_ITEMMALL
--
-- The T-SQL original selects `itemtime` from WEB_ITEMMALL, but that column
-- does not exist in the supplied schema, so the original procedure always
-- failed.  The C++ reader expects five columns (it reads positions 2, 3 and 5),
-- so the fifth column is supplied as a literal 0 to keep the contract.
-- Documented in docs/MIGRATION_ASSESSMENT.md (finding 5).
-- ---------------------------------------------------------------------------
CREATE PROCEDURE `LOAD_WEB_ITEMMALL`(IN p_charID CHAR(21))
    MODIFIES SQL DATA
BEGIN
    START TRANSACTION;

    SELECT strAccountID, ItemID, ItemCount, BuyTime, 0 AS itemtime
      FROM WEB_ITEMMALL WHERE strCharID = p_charID;

    DELETE FROM WEB_ITEMMALL WHERE strCharID = p_charID;

    COMMIT;
END$$

DELIMITER ;
