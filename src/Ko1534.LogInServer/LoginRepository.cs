using Ko1534.Shared.Config;
using Ko1534.Shared.Database;
using Ko1534.Shared.Logging;
using Ko1534.Shared.Packets;

namespace Ko1534.LogInServer;

/// <summary>
/// Handles login database operations — reads/writes TB_USER, VERSION, CURRENTUSER.
/// Matches the C++ LoginRepository/DBProcess class behavior.
///
/// Result codes (from C++ LoginSession.cpp):
///   AUTH_SUCCESS    = 0x01
///   AUTH_NOT_FOUND  = 0x02
///   AUTH_INVALID    = 0x03
///   AUTH_BANNED     = 0x04
///   AUTH_IN_GAME    = 0x05
///   AUTH_ERROR      = 0x06
/// </summary>
public class LoginRepository
{
    private readonly Database _db;
    private readonly bool _autoRegister;

    public short LastVersion { get; set; } = 1534;
    public Dictionary<string, (short Version, short HistoryVersion)> VersionList { get; private set; } = new();

    public LoginRepository(Database db, bool autoRegister)
    {
        Console.WriteLine($"[DBG] LoginRepository constructor: autoRegister={autoRegister}");
        Console.WriteLine($"[DBG] LoginRepository constructor: connecting to DB...");
        _db = db;
        _autoRegister = autoRegister;
        Console.WriteLine($"[DBG] LoginRepository constructor: complete");
    }

    public bool LoadVersionList()
    {
        Console.WriteLine($"[DBG]   LoadVersionList: querying VERSION table...");
        Console.WriteLine($"[DBG]   LoadVersionList: SQL = SELECT sVersion, sHistoryVersion, strFilename FROM VERSION");
        try
        {
            var result = _db.Query("SELECT sVersion, sHistoryVersion, strFilename FROM VERSION");
            Console.WriteLine($"[DBG]   LoadVersionList: query returned {result?.Count ?? 0} rows");
            VersionList.Clear();

            if (result != null && result.Count > 0)
            {
                // C++: m_sLastVersion = 0; then update from DB rows
                LastVersion = 0;
                foreach (var row in result)
                {
                    var fileName = row.GetString("strFilename");
                    var version = row.GetInt16("sVersion");
                    var historyVersion = row.GetInt16("sHistoryVersion");
                    Console.WriteLine($"[DBG]     Version: {fileName} = v{version} (history={historyVersion})");
                    VersionList[fileName] = (version, historyVersion);

                    if (LastVersion < version)
                    {
                        Console.WriteLine($"[DBG]     New latest version found: {version}");
                        LastVersion = version;
                    }
                }
            }

            if (VersionList.Count == 0)
            {
                Console.WriteLine($"[DBG]   LoadVersionList: no versions found, using default 1534");
            }

            Console.WriteLine($"[DBG]   LoadVersionList: done. Count={VersionList.Count}, Latest={LastVersion}");
            return true;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[DBG]   LoadVersionList: ERROR: {ex.Message}");
            Console.WriteLine($"[DBG]   LoadVersionList: continuing with default version 1534");
            VersionList.Clear();
            return true; // Non-fatal — server can run without version list
        }
    }

    public void LoadUserCountList(List<ServerEntry> servers)
    {
        Console.WriteLine($"[DBG]   LoadUserCountList: loading user counts for {servers.Count} servers...");
        try
        {
            Console.WriteLine($"[DBG]   LoadUserCountList: SQL = SELECT COUNT(*) AS COUNT, nServerNo AS SERVER FROM CURRENTUSER GROUP BY nServerNo");
            var result = _db.Query("SELECT COUNT(*) AS COUNT, nServerNo AS SERVER FROM CURRENTUSER GROUP BY nServerNo");
            Console.WriteLine($"[DBG]   LoadUserCountList: query returned {result?.Count ?? 0} rows");

            if (result != null)
            {
                foreach (var row in result)
                {
                    var serverId = row.GetInt16("SERVER");
                    var count = row.GetInt32("COUNT");
                    Console.WriteLine($"[DBG]     Server ID={serverId}: {count} online users");

                    foreach (var server in servers)
                    {
                        if (server.ServerId == serverId)
                        {
                            Console.WriteLine($"[DBG]       Matched to server \"{server.Name}\"");
                            server.UserCount = (short)count;
                            break;
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[DBG]   LoadUserCountList: ERROR: {ex.Message}");
        }
    }

    // ── LOGIN ───────────────────────────────────────────────────────────
    // Returns byte result code:
    //   0x01 = AUTH_SUCCESS
    //   0x02 = AUTH_NOT_FOUND
    //   0x03 = AUTH_INVALID (password mismatch)
    //   0x04 = AUTH_BANNED
    //   0x05 = AUTH_IN_GAME
    //   0x06 = AUTH_ERROR

    public async Task<byte> AccountLoginAsync(string acc, string password)
    {
        Console.WriteLine($"[DBG]   AccountLoginAsync: looking up account \"{acc}\"...");

        try
        {
            Console.WriteLine($"[DBG]   AccountLoginAsync: querying TB_USER...");
            Console.WriteLine($"[DBG]   AccountLoginAsync: SQL = SELECT strAccountID, strPasswd, strAuthority FROM TB_USER WHERE strAccountID = '{acc}'");
            var result = _db.Query($"SELECT strAccountID, strPasswd, strAuthority FROM TB_USER WHERE strAccountID = '{acc.Replace("'", "''")}'");
            Console.WriteLine($"[DBG]   AccountLoginAsync: query returned {result?.Count ?? 0} rows");

            if (result != null && result.Count > 0)
            {
                var row = result[0];
                string storedAccount = row.GetString("strAccountID");
                string storedPassword = row.GetString("strPasswd");
                byte auth = row.GetByte("strAuthority");

                Console.WriteLine($"[DBG]   AccountLoginAsync: found account \"{storedAccount}\"");
                Console.WriteLine($"[DBG]   AccountLoginAsync: stored password = \"{storedPassword}\"");
                Console.WriteLine($"[DBG]   AccountLoginAsync: provided password = \"{password}\"");
                Console.WriteLine($"[DBG]   AccountLoginAsync: password match = {storedPassword == password}");
                Console.WriteLine($"[DBG]   AccountLoginAsync: authority = {auth} (255=banned)");

                if (storedPassword == password)
                {
                    // Check if banned (strAuthority == 255)
                    if (auth == 255)
                    {
                        Console.WriteLine($"[DBG]   AccountLoginAsync: ACCOUNT IS BANNED");
                        return 0x04; // AUTH_BANNED
                    }

                    // Check if already in game (CURRENTUSER has a record)
                    Console.WriteLine($"[DBG]   AccountLoginAsync: checking if account is currently in-game...");
                    Console.WriteLine($"[DBG]   AccountLoginAsync: SQL = SELECT nServerNo FROM CURRENTUSER WHERE strAccountID = '{acc}'");
                    var currentUserResult = _db.Query($"SELECT nServerNo FROM CURRENTUSER WHERE strAccountID = '{acc.Replace("'", "''")}'");
                    Console.WriteLine($"[DBG]   AccountLoginAsync: CURRENTUSER query returned {currentUserResult?.Count ?? 0} rows");

                    if (currentUserResult != null && currentUserResult.Count > 0)
                    {
                        short currentServer = currentUserResult[0].GetInt16("nServerNo");
                        Console.WriteLine($"[DBG]   AccountLoginAsync: account IS IN GAME on server {currentServer}");
                        return 0x05; // AUTH_IN_GAME
                    }
                    else
                    {
                        Console.WriteLine($"[DBG]   AccountLoginAsync: account is NOT in game");
                    }

                    Console.WriteLine($"[DBG]   AccountLoginAsync: LOGIN SUCCESS");
                    return 0x01; // AUTH_SUCCESS
                }
                else
                {
                    Console.WriteLine($"[DBG]   AccountLoginAsync: password mismatch");
                    return 0x03; // AUTH_INVALID
                }
            }
            else
            {
                Console.WriteLine($"[DBG]   AccountLoginAsync: account not found in DB");
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[DBG]   AccountLoginAsync: DB ERROR: {ex.Message}");
            return 0x06; // AUTH_ERROR
        }

        // Auto-register if not found
        if (_autoRegister)
        {
            Console.WriteLine($"[DBG]   AccountLoginAsync: auto-register is ON, creating account...");
            Console.WriteLine($"[DBG]   AccountLoginAsync: calling AccountCreateAsync...");
            var createResult = await AccountCreateAsync(acc, password);
            if (createResult == 0x01)
            {
                Console.WriteLine($"[DBG]   AccountLoginAsync: auto-register SUCCESS");
                return 0x01; // AUTH_SUCCESS
            }
            Console.WriteLine($"[DBG]   AccountLoginAsync: auto-register FAILED");
            return 0x02; // AUTH_NOT_FOUND
        }

        Console.WriteLine($"[DBG]   AccountLoginAsync: auto-register is OFF, returning NOT_FOUND");
        return 0x02; // AUTH_NOT_FOUND
    }

    // ── CREATE (for auto-register only) ─────────────────────────────────

    public async Task<byte> AccountCreateAsync(string acc, string password)
    {
        Console.WriteLine($"[DBG]   AccountCreateAsync: creating account \"{acc}\"");
        Console.WriteLine($"[DBG]   AccountCreateAsync: password = \"{password}\"");

        try
        {
            Console.WriteLine($"[DBG]   AccountCreateAsync: inserting into TB_USER...");
            string sql = $"INSERT INTO TB_USER (strAccountID, strPasswd, strSealPasswd, bPremiumType, sHours, strAuthority, dtCreateTime) VALUES ('{acc.Replace("'", "''")}', '{password.Replace("'", "''")}', '00000000', 0, 0, 0, NOW())";
            Console.WriteLine($"[DBG]   AccountCreateAsync: SQL = {sql}");
            _db.Execute(sql);
            Console.WriteLine($"[DBG]   AccountCreateAsync: insert successful");
            return 0x01; // AUTH_SUCCESS
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[DBG]   AccountCreateAsync: ERROR: {ex.Message}");
            return 0x02; // AUTH_NOT_FOUND
        }
    }

    // ── PREMIUM ─────────────────────────────────────────────────────────
    // C++ returns int16 (hours), -1 means not premium

    public async Task<short> AccountPremiumAsync(string acc)
    {
        Console.WriteLine($"[DBG]   AccountPremiumAsync: checking premium for \"{acc}\"...");

        try
        {
            Console.WriteLine($"[DBG]   AccountPremiumAsync: SQL = SELECT bPremiumType FROM TB_USER WHERE strAccountID = '{acc.Replace("'", "''")}'");
            var result = _db.Query($"SELECT bPremiumType FROM TB_USER WHERE strAccountID = '{acc.Replace("'", "''")}'");
            Console.WriteLine($"[DBG]   AccountPremiumAsync: query returned {result?.Count ?? 0} rows");

            if (result != null && result.Count > 0)
            {
                short premiumHours = result[0].GetByte("bPremiumType") > 0 ? (short)9999 : (short)-1;
                Console.WriteLine($"[DBG]   AccountPremiumAsync: premium hours = {premiumHours}");
                return premiumHours;
            }
            else
            {
                Console.WriteLine($"[DBG]   AccountPremiumAsync: PREMIUM=false (account not found)");
                return -1;
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[DBG]   AccountPremiumAsync: ERROR: {ex.Message}");
            return -1;
        }
    }
}
