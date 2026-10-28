using Ko1534.Shared.Database;
using Ko1534.Shared.Packets;

namespace Ko1534.GameServer;

/// <summary>
/// Database agent for the Game Server.
/// Matches the C++ CDBAgent class behavior.
/// Handles account login, character loading/saving, and related DB operations.
/// </summary>
public class DBAgent
{
    private Database _gameDB = null!;
    private Database _accountDB = null!;
    private readonly object _lock = new();

    public DBAgent(Database gameDB, Database accountDB)
    {
        _gameDB = gameDB;
        _accountDB = accountDB;
    }

    // ── Account operations ────────────────────────────────────────────

    /// <summary>
    /// Account login via stored procedure GAME_LOGIN.
    /// Returns: 1 = success, 0 = invalid, -1 = error
    /// </summary>
    public int AccountLogin(string accountId, string password)
    {
        try
        {
            var result = _gameDB.Query(
                $"SELECT strAuthority FROM TB_USER WHERE strAccountID = '{accountId.Replace("'", "''")}' AND strPasswd = '{password.Replace("'", "''")}'");

            if (result != null && result.Count > 0)
            {
                var auth = result[0].GetByte("strAuthority");
                if (auth == 255) return 4; // BANNED
                return 1; // SUCCESS
            }
            return 0; // NOT_FOUND
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[DBAgent] AccountLogin error: {ex.Message}");
            return -1; // ERROR
        }
    }

    /// <summary>
    /// Nation selection. Returns the nation if valid, 0 otherwise.
    /// </summary>
    public byte NationSelect(string accountId, byte nation)
    {
        try
        {
            var result = _gameDB.Query(
                $"SELECT bNation FROM TB_USER_NATION WHERE strAccountID = '{accountId.Replace("'", "''")}'");

            if (result != null && result.Count > 0)
            {
                var storedNation = result[0].GetByte("bNation");
                if (storedNation == nation)
                    return nation;
            }
            return 0;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[DBAgent] NationSelect error: {ex.Message}");
            return 0;
        }
    }

    /// <summary>
    /// Get all character IDs for an account.
    /// Returns true if characters exist.
    /// </summary>
    public bool GetAllCharID(string accountId, out string charId1, out string charId2, out string charId3)
    {
        charId1 = "";
        charId2 = "";
        charId3 = "";

        try
        {
            var result = _gameDB.Query(
                $"SELECT strCharID1, strCharID2, strCharID3 FROM ACCOUNT_CHAR WHERE strAccountID = '{accountId.Replace("'", "''")}'");

            if (result != null && result.Count > 0)
            {
                charId1 = result[0].GetString("strCharID1");
                charId2 = result[0].GetString("strCharID2");
                charId3 = result[0].GetString("strCharID3");
                return true;
            }
            return false;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[DBAgent] GetAllCharID error: {ex.Message}");
            return false;
        }
    }

    /// <summary>
    /// Create a new character.
    /// Returns: 1 = success, 0 = failure
    /// </summary>
    public int CreateNewChar(string accountId, int index, string charId, byte race, ushort classType,
        uint hair, byte face, byte str, byte sta, byte dex, byte intVal, byte cha)
    {
        try
        {
            _gameDB.Execute(
                $"INSERT INTO USERDATA (strUserID, strAccountID, Race, Class, HairRGB, [Level], Face, Zone, strItem, strItemTime, bStr, bSta, bDex, bInt, bCha) " +
                $"VALUES ('{charId.Replace("'", "''")}', '{accountId.Replace("'", "''")}', {race}, {classType}, {hair}, 1, {face}, 0, '', '', {str}, {sta}, {dex}, {intVal}, {cha})");

            _gameDB.Execute(
                $"INSERT INTO ACCOUNT_CHAR (strAccountID, strCharID1, strCharID2, strCharID3) VALUES ('{accountId.Replace("'", "''")}', " +
                (index == 0 ? $"'{charId.Replace("'", "''")}'" : "NULL") + ", " +
                (index == 1 ? $"'{charId.Replace("'", "''")}'" : "NULL") + ", " +
                (index == 2 ? $"'{charId.Replace("'", "''")}'" : "NULL") + ")");

            return 1;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[DBAgent] CreateNewChar error: {ex.Message}");
            return 0;
        }
    }

    /// <summary>
    /// Delete a character.
    /// Returns: 1 = success, 0 = failure
    /// </summary>
    public int DeleteChar(string accountId, int index, string charId, string socNo)
    {
        try
        {
            _gameDB.Execute($"DELETE FROM USERDATA WHERE strUserID = '{charId.Replace("'", "''")}'");

            _gameDB.Execute(
                $"UPDATE ACCOUNT_CHAR SET strCharID{index + 1} = NULL WHERE strAccountID = '{accountId.Replace("'", "''")}'");

            return 1;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[DBAgent] DeleteChar error: {ex.Message}");
            return 0;
        }
    }

    /// <summary>
    /// Load character info into a packet for the client.
    /// </summary>
    public void LoadCharInfo(string charId, Packet result)
    {
        try
        {
            var result_rows = _gameDB.Query(
                $"SELECT Race, Class, HairRGB, [Level], Face, Zone, strItem, strItemTime FROM USERDATA WHERE strUserID = '{charId.Replace("'", "''")}'");

            byte race = 0, level = 0, face = 0, zone = 0;
            ushort classType = 0;
            uint hair = 0;
            string itemData = "";
            string itemTime = "";

            if (result_rows != null && result_rows.Count > 0)
            {
                race = result_rows[0].GetByte("Race");
                classType = result_rows[0].GetUInt16("Class");
                hair = result_rows[0].GetUInt32("HairRGB");
                level = result_rows[0].GetByte("Level");
                face = result_rows[0].GetByte("Face");
                zone = result_rows[0].GetByte("Zone");
                itemData = result_rows[0].GetString("strItem");
                itemTime = result_rows[0].GetString("strItemTime");
            }

            result.AppendString(charId);
            result.AppendByte(race);
            result.AppendUInt16(classType);
            result.AppendByte(level);
            result.AppendByte(face);
            result.AppendUInt32(hair);
            result.AppendByte(zone);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[DBAgent] LoadCharInfo error: {ex.Message}");
        }
    }

    /// <summary>
    /// Load full user data from USERDATA table.
    /// Returns true if data was loaded.
    /// </summary>
    public bool LoadUserData(string accountId, string charId, User user)
    {
        try
        {
            var rows = _gameDB.Query(
                $"SELECT * FROM USERDATA WHERE strUserID = '{charId.Replace("'", "''")}'");

            if (rows == null || rows.Count == 0)
                return false;

            var row = rows[0];
            user.Race = row.GetByte("Race");
            user.Class = row.GetByte("Class");
            user.Level = row.GetByte("Level");
            user.Hp = row.GetInt32("HP");
            user.MaxHp = row.GetInt32("MaxHP");
            user.Mp = row.GetInt32("MP");
            user.MaxMp = row.GetInt32("MaxMP");
            user.Exp = row.GetInt32("EXP");
            user.Gold = row.GetInt32("Gold");
            user.Np = row.GetInt32("NP");

            return true;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[DBAgent] LoadUserData error: {ex.Message}");
            return false;
        }
    }

    /// <summary>
    /// Save user data to USERDATA table.
    /// Returns true if successful.
    /// </summary>
    public bool UpdateUser(string charId, User user)
    {
        try
        {
            _gameDB.Execute(
                $"UPDATE USERDATA SET HP = {user.Hp}, MaxHP = {user.MaxHp}, MP = {user.Mp}, MaxMP = {user.MaxMp}, " +
                $"EXP = {user.Exp}, Gold = {user.Gold}, NP = {user.Np} " +
                $"WHERE strUserID = '{charId.Replace("'", "''")}'");

            return true;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[DBAgent] UpdateUser error: {ex.Message}");
            return false;
        }
    }

    /// <summary>
    /// Save user data on logout.
    /// </summary>
    public bool UpdateUserOnLogout(string charId, User user)
    {
        return UpdateUser(charId, user);
    }

    /// <summary>
    /// Set login info (server IP, server number) for the account.
    /// </summary>
    public bool SetLogInInfo(string accountId, string charId, string serverIp, short serverNo, string clientIp, byte init)
    {
        try
        {
            _gameDB.Execute(
                $"UPDATE CURRENTUSER SET strServerIP = '{serverIp}', nServerNo = {serverNo}, strClientIP = '{clientIp}' " +
                $"WHERE strAccountID = '{accountId.Replace("'", "''")}'");

            return true;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[DBAgent] SetLogInInfo error: {ex.Message}");
            return false;
        }
    }

    /// <summary>
    /// Clear user from CURRENTUSER table on logout.
    /// </summary>
    public void AccountLogout(string accountId)
    {
        try
        {
            _gameDB.Execute($"DELETE FROM CURRENTUSER WHERE strAccountID = '{accountId.Replace("'", "''")}'");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[DBAgent] AccountLogout error: {ex.Message}");
        }
    }

    /// <summary>
    /// Update concurrent user count for a server/zone.
    /// </summary>
    public void UpdateConCurrentUserCount(int serverNo, int zoneNo, int count)
    {
        // Implementation depends on DB schema
    }
}
