using System.Collections.Concurrent;
using System.Net;
using System.Net.Sockets;
using Ko1534.Shared.Config;
using Ko1534.Shared.Database;
using Ko1534.Shared.Packets;

namespace Ko1534.GameServer;

/// <summary>
/// Main Game Server class.
/// Matches the C++ CGameServerDlg class behavior.
/// </summary>
public class GameServerDlg
{
    private readonly TcpListener _listener;
    private Database _gameDB = null!;
    private Database _accountDB = null!;
    private readonly CancellationTokenSource _cts = new();
    private readonly ConcurrentDictionary<short, GameSocket> _sockets = new();
    private readonly ConcurrentDictionary<short, AISocket> _aiSockets = new();
    private readonly ConcurrentDictionary<string, short> _accountSessions = new();
    private readonly object _serverListLock = new();
    private int _nextSocketId = 0;
    private int _nextAiSocketId = 0;

    // Configuration
    public int GamePort { get; private set; }
    public int GameMaxLevel { get; private set; }
    public string GameDsn { get; private set; } = "";
    public string GameUid { get; private set; } = "";
    public string GamePwd { get; private set; } = "";
    public string AccountDsn { get; private set; } = "";
    public string AccountUid { get; private set; } = "";
    public string AccountPwd { get; private set; } = "";
    public string GameMars { get; private set; } = "";
    public int MyInfo { get; private set; }
    public int ServerNum { get; private set; }
    public string ServerIp { get; private set; } = "127.0.0.1";
    public string ServerName { get; private set; } = "Ko1534 Server";
    public short ServerId { get; private set; }
    public string AiServerIp { get; private set; } = "127.0.0.1";
    public int AiServerPort { get; private set; } = 15002;

    // Battle zones
    public int[] BattleDays { get; private set; } = new int[GSConstants.WarDayCount];
    public int[] BattleStartTime { get; private set; } = new int[GSConstants.WarZoneCount];
    public int[] BattleZones { get; private set; } = new int[GSConstants.WarZoneCount];

    // Time
    public int Weather { get; private set; }
    public bool IsNight { get; private set; }

    // Server state
    public int UserCount { get; private set; }
    public int MaxOnline { get; private set; } = 3000;
    private bool _running = false;

    // Tables (simplified)
    public Dictionary<uint, MagicTable> MagicTable { get; } = new();
    public Dictionary<uint, object> ItemTable { get; } = new();
    public Dictionary<uint, object> MonsterTable { get; } = new();
    public Dictionary<uint, object> KnightsTable { get; } = new();
    public Dictionary<uint, object> QuestTable { get; } = new();

    // Time/Weather
    public int CurrentYear, CurrentMonth, CurrentDate, CurrentHour, CurrentMinute;
    public byte CurrentWeather = 1;

    public static GameServerDlg? Instance { get; private set; }

    public GameServerDlg()
    {
        _listener = new TcpListener(IPAddress.Any, 0);
        Instance = this;
    }

    public bool Startup()
    {
        Console.WriteLine($"[DBG] ── GameServer Startup() begin ──");
        Console.WriteLine($"[DBG] Server started on {DateTime.Now:yyyy-MM-dd HH:mm:ss}");

        // Load INI
        Console.WriteLine($"[DBG] Step 1: Loading GameServer.ini...");
        if (!LoadConfig())
            return false;

        // Connect DB
        Console.WriteLine($"[DBG] Step 2: Connecting to game database...");
        if (!_gameDB.Connect(out string err))
        {
            Console.WriteLine($"[DBG] ERROR connecting to game DB: {err}");
            return false;
        }
        Console.WriteLine($"[DBG]   Connected to game DB.");

        // Connect account DB
        Console.WriteLine($"[DBG] Step 3: Connecting to account database...");
        if (!_accountDB.Connect(out string err2))
        {
            Console.WriteLine($"[DBG] WARNING: Could not connect to account DB: {err2}");
        }
        else
        {
            Console.WriteLine($"[DBG]   Connected to account DB.");
        }

        // Load tables
        Console.WriteLine($"[DBG] Step 4: Loading game tables...");
        LoadTables();

        // Start listener
        Console.WriteLine($"[DBG] Step 5: Starting TcpListener on 0.0.0.0:{GamePort}...");
        _listener.Start();
        Console.WriteLine($"[DBG]   Listener started.");

        _running = true;
        Console.WriteLine($"[DBG] ── Startup() complete ──");
        return true;
    }

    private bool LoadConfig()
    {
        var ini = new IniFile(IniFile.FindIni(GSConstants.GameServerIni));

        GamePort = ini.GetInt("SETTINGS", "PORT", 15001);
        GameMaxLevel = ini.GetInt("SETTINGS", "GAMEMAXLEVEL", 80);
        MaxOnline = ini.GetInt("SETTINGS", "MAXONLINE", 3000);

        // Game DB - C# uses direct MySQL connection
        string gameHost = ini.GetString("GAME_ODBC", "HOST", "127.0.0.1");
        int gamePort = ini.GetInt("GAME_ODBC", "PORT", 3306);
        GameUid = ini.GetString("GAME_ODBC", "USER", "ko");
        GamePwd = ini.GetString("GAME_ODBC", "PASSWORD", "");
        string gameDb = ini.GetString("GAME_ODBC", "DATABASE", "KO1534");
        bool gamePooling = ini.GetBool("GAME_ODBC", "POOLING", true);
        int gameConnTimeout = ini.GetInt("GAME_ODBC", "CONNECTION_TIMEOUT", 15);
        int gameCmdTimeout = ini.GetInt("GAME_ODBC", "COMMAND_TIMEOUT", 30);
        _gameDB = new Database(gameHost, gamePort, GameUid, GamePwd, gameDb, gamePooling, gameConnTimeout, gameCmdTimeout);

        // Account DB
        string accHost = ini.GetString("ACCOUNT_ODBC", "HOST", "127.0.0.1");
        int accPort = ini.GetInt("ACCOUNT_ODBC", "PORT", 3306);
        AccountUid = ini.GetString("ACCOUNT_ODBC", "USER", "ko");
        AccountPwd = ini.GetString("ACCOUNT_ODBC", "PASSWORD", "");
        string accDb = ini.GetString("ACCOUNT_ODBC", "DATABASE", "KO1534");
        bool accPooling = ini.GetBool("ACCOUNT_ODBC", "POOLING", true);
        int accConnTimeout = ini.GetInt("ACCOUNT_ODBC", "CONNECTION_TIMEOUT", 15);
        int accCmdTimeout = ini.GetInt("ACCOUNT_ODBC", "COMMAND_TIMEOUT", 30);
        _accountDB = new Database(accHost, accPort, AccountUid, AccountPwd, accDb, accPooling, accConnTimeout, accCmdTimeout);

        MyInfo = ini.GetInt("ZONE_INFO", "MY_INFO", 1);
        ServerNum = ini.GetInt("ZONE_INFO", "SERVER_NUM", 1);
        ServerIp = ini.GetString("ZONE_INFO", $"SERVER_IP_{MyInfo:D2}", "127.0.0.1");
        ServerName = ini.GetString("ZONE_INFO", $"SERVER_{MyInfo:D2}", "Ko1534 Server");
        ServerId = (short)ini.GetInt("ZONE_INFO", $"SERVER_{MyInfo:D2}_ID", MyInfo);

        AiServerIp = ini.GetString("AI_SERVER", "IP", "127.0.0.1");
        AiServerPort = ini.GetInt("AI_SERVER", "PORT", 15002);

        Weather = ini.GetInt("TIMER", "WEATHER", 1);

        // Load battle zone info
        for (int i = 0; i < GSConstants.WarZoneCount; i++)
        {
            BattleStartTime[i] = ini.GetInt("BATTLE", $"START_TIME{i}", 0);
            BattleZones[i] = ini.GetInt("BATTLE", $"WAR_ZONE{i}", 0);
        }
        for (int i = 0; i < GSConstants.WarDayCount; i++)
        {
            BattleDays[i] = ini.GetInt("BATTLE", $"DAYS{i}", 0);
        }

        Console.WriteLine($"[DBG]   Config loaded: Port={GamePort}, MaxLevel={GameMaxLevel}");
        Console.WriteLine($"[DBG]   AI Server: {AiServerIp}:{AiServerPort}");
        Console.WriteLine($"[DBG]   Server: {ServerName} (ID={ServerId}, IP={ServerIp})");
        return true;
    }

    private void LoadTables()
    {
        Console.WriteLine($"[DBG]   Loading game tables from DB...");

        // Load magic table
        var magicRows = _gameDB.Query("SELECT * FROM MAGIC");
        foreach (var row in magicRows)
        {
            uint skillId = row.GetUInt32("MagicNum");
            MagicTable mt = new();
            MagicTable[skillId] = mt;
        }
        Console.WriteLine($"[DBG]    Magic table: {MagicTable.Count} entries");

        // Load item table
        var itemRows = _gameDB.Query("SELECT * FROM ITEM");
        foreach (var row in itemRows)
        {
            uint itemNum = row.GetUInt32("Num");
            ItemTable[itemNum] = new object();
        }
        Console.WriteLine($"[DBG]    Item table: {ItemTable.Count} entries");

        // Load monster table
        var monsterRows = _gameDB.Query("SELECT * FROM K_MONSTER");
        foreach (var row in monsterRows)
        {
            uint monsterId = row.GetUInt32("sSid");
            MonsterTable[monsterId] = new object();
        }
        Console.WriteLine($"[DBG]    Monster table: {MonsterTable.Count} entries");

        Console.WriteLine($"[DBG]   Table loading complete.");
    }

    public async Task RunAsync()
    {
        Console.WriteLine($"[DBG] ── RunAsync() begin ──");

        // Start timer threads
        _ = Task.Run(() => Timer_CheckGameEvents(_cts.Token));
        _ = Task.Run(() => Timer_UpdateGameTime(_cts.Token));
        _ = Task.Run(() => Timer_UpdateSessions(_cts.Token));

        // Try connecting to AI server
        _ = Task.Run(() => AIServerConnect());

        // Accept loop
        while (_running && !_cts.IsCancellationRequested)
        {
            try
            {
                var client = await _listener.AcceptTcpClientAsync(_cts.Token);
                var socketId = NextSocketId();
                var socket = new GameSocket(client, socketId, this);
                _sockets[socketId] = socket;
                Console.WriteLine($"[DBG] ACCEPTED: {socket.RemoteIP} (socketId={socketId})");
                _ = socket.StartReadLoop();
            }
            catch (OperationCanceledException)
            {
                break;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[DBG] ERROR accepting connection: {ex.Message}");
            }
        }

        Console.WriteLine($"[DBG] ── RunAsync() end ──");
    }

    private short NextSocketId()
    {
        return (short)(Interlocked.Increment(ref _nextSocketId) % GSConstants.MaxSocket);
    }

    private short NextAiSocketId()
    {
        return (short)(Interlocked.Increment(ref _nextAiSocketId) % 100);
    }

    public void DisconnectSocket(short socketId)
    {
        if (_sockets.TryRemove(socketId, out var socket))
        {
            Console.WriteLine($"[DBG] Disconnected socket {socketId} ({socket.RemoteIP})");
            UserCount = _sockets.Count;
        }
    }

    public void DisconnectAISocket(short socketId)
    {
        _aiSockets.TryRemove(socketId, out _);
        Console.WriteLine($"[DBG] AI Socket {socketId} disconnected");
    }

    /// <summary>
    /// Main packet handler for game client packets.
    /// </summary>
    public void HandleGamePacket(GameSocket socket, Packet pkt)
    {
        switch (pkt.Opcode)
        {
            case (byte)WizOpcodes.WIZ_VERSION_CHECK:
                HandleVersionCheck(socket, pkt);
                break;
            case (byte)WizOpcodes.WIZ_CRYPTION:
                HandleCryption(socket, pkt);
                break;
            case (byte)WizOpcodes.WIZ_LOGIN:
                HandleLogin(socket, pkt);
                break;
            case (byte)WizOpcodes.WIZ_GAMESTART:
                HandleGameStart(socket, pkt);
                break;
            case (byte)WizOpcodes.WIZ_SEL_NATION:
                HandleSelNation(socket, pkt);
                break;
            case (byte)WizOpcodes.WIZ_ALLCHAR_INFO_REQ:
                HandleAllCharInfo(socket, pkt);
                break;
            case (byte)WizOpcodes.WIZ_NEW_CHAR:
                HandleNewChar(socket, pkt);
                break;
            case (byte)WizOpcodes.WIZ_DEL_CHAR:
                HandleDelChar(socket, pkt);
                break;
            case (byte)WizOpcodes.WIZ_SEL_CHAR:
                HandleSelChar(socket, pkt);
                break;
            case (byte)WizOpcodes.WIZ_MYINFO:
                HandleMyInfo(socket, pkt);
                break;
            case (byte)WizOpcodes.WIZ_LOGOUT:
                HandleLogout(socket, pkt);
                break;
            case (byte)WizOpcodes.WIZ_MOVE:
                HandleMove(socket, pkt);
                break;
            case (byte)WizOpcodes.WIZ_CHAT:
                HandleChat(socket, pkt);
                break;
            case (byte)WizOpcodes.WIZ_ATTACK:
                HandleAttack(socket, pkt);
                break;
            case (byte)WizOpcodes.WIZ_USER_INOUT:
                HandleUserInOut(socket, pkt);
                break;
            case (byte)WizOpcodes.WIZ_NPC_INOUT:
                HandleNpcInOut(socket, pkt);
                break;
            case (byte)WizOpcodes.WIZ_WEATHER:
                HandleWeather(socket, pkt);
                break;
            case (byte)WizOpcodes.WIZ_TIME:
                HandleTime(socket, pkt);
                break;
            default:
                Console.WriteLine($"[DBG] Unhandled game packet opcode 0x{pkt.Opcode:X2} from {socket.RemoteIP}");
                break;
        }
    }

    private void HandleVersionCheck(GameSocket socket, Packet pkt)
    {
        Console.WriteLine($"[DBG] VERSION_CHECK from {socket.RemoteIP}");
        Packet response = new Packet(WizOpcodes.WIZ_VERSION_CHECK);
        response.AppendByte(0x00); // version result (0 = OK)
        socket.Send(response);
    }

    private void HandleCryption(GameSocket socket, Packet pkt)
    {
        Console.WriteLine($"[DBG] CRYPTION from {socket.RemoteIP}");
        ulong publicKey = socket.GenerateCryptoKey();

        Packet response = new Packet(WizOpcodes.WIZ_CRYPTION);
        response.AppendUInt64(publicKey);
        socket.Send(response);

        socket.EnableCrypto();
    }

    private void HandleLogin(GameSocket socket, Packet pkt)
    {
        Console.WriteLine($"[DBG] WIZ_LOGIN from {socket.RemoteIP}");

        string accountId = pkt.ReadString();
        string password = pkt.ReadString();

        Console.WriteLine($"[DBG]   Login attempt: account=\"{accountId}\"");

        // In a full implementation, verify with account DB
        // For now, accept all connections (matching C++ behavior when DB is not configured)
        var user = new User(accountId, socket.SocketId, this);
        socket.User = user;
        user.SetSocket(socket);
        _accountSessions[accountId] = socket.SocketId;
        UserCount = _sockets.Count;

        Packet response = new Packet(WizOpcodes.WIZ_LOGIN);
        response.AppendByte(0x01); // success
        response.AppendString(accountId);
        response.AppendInt16(socket.SocketId);
        response.AppendInt16(ServerId);
        response.AppendString(ServerIp);
        response.AppendInt16((short)GamePort);
        socket.Send(response);
    }

    private void HandleGameStart(GameSocket socket, Packet pkt)
    {
        Console.WriteLine($"[DBG] GAMESTART from {socket.RemoteIP}");

        if (socket.User == null) return;

        // Create user in game
        socket.User.OnConnect();
        UserCount = _sockets.Count;

        // Send initial game data
        Packet response = new Packet(WizOpcodes.WIZ_GAMESTART);
        socket.Send(response);
    }

    private void HandleSelNation(GameSocket socket, Packet pkt)
    {
        Console.WriteLine($"[DBG] SEL_NATION from {socket.RemoteIP}");
        if (socket.User == null) return;

        byte nation = pkt.ReadByte();
        Console.WriteLine($"[DBG]   Nation: {nation}");

        // Store nation selection
        socket.User.Nation = nation;

        Packet response = new Packet(WizOpcodes.WIZ_SEL_NATION);
        response.AppendByte(nation); // Success
        socket.Send(response);
    }

    private void HandleAllCharInfo(GameSocket socket, Packet pkt)
    {
        Console.WriteLine($"[DBG] ALLCHAR_INFO_REQ from {socket.RemoteIP}");
        if (socket.User == null) return;

        string accountId = socket.User.AccountId;
        Console.WriteLine($"[DBG]   Account: {accountId}");

        Packet response = new Packet(WizOpcodes.WIZ_ALLCHAR_INFO_REQ);
        response.AppendByte(1); // Success flag

        // Load characters from DB
        var rows = _gameDB.Query($"SELECT strCharID1, strCharID2, strCharID3 FROM ACCOUNT_CHAR WHERE strAccountID = '{accountId}'");
        if (rows.Count > 0)
        {
            string char1 = rows[0].GetString("strCharID1") ?? "";
            string char2 = rows[0].GetString("strCharID2") ?? "";
            string char3 = rows[0].GetString("strCharID3") ?? "";

            Console.WriteLine($"[DBG]   Char1: {char1}, Char2: {char2}, Char3: {char3}");

            // Load character info for each slot
            LoadCharInfo(char1, response);
            LoadCharInfo(char2, response);
            LoadCharInfo(char3, response);
        }
        else
        {
            // No characters - return empty slots
            for (int i = 0; i < 3; i++)
            {
                response.AppendString("");
                response.AppendByte(0); // Level
                response.AppendByte(0); // Class
                response.AppendByte(0); // Nation
            }
        }

        socket.Send(response);
    }

    private void LoadCharInfo(string charName, Packet response)
    {
        if (string.IsNullOrEmpty(charName))
        {
            response.AppendString("");
            response.AppendByte(0);
            response.AppendByte(0);
            response.AppendByte(0);
            return;
        }

        var rows = _gameDB.Query($"SELECT * FROM USERDATA WHERE strUserID = '{charName}'");
        if (rows.Count > 0)
        {
            var row = rows[0];
            response.AppendString(charName);
            response.AppendByte(row.GetByte("Level"));
            response.AppendByte((byte)row.GetInt16("Class"));
            response.AppendByte(row.GetByte("Nation"));
            Console.WriteLine($"[DBG]   Loaded char: {charName} Lv{row.GetByte("Level")}");
        }
        else
        {
            response.AppendString(charName);
            response.AppendByte(1); // Default level
            response.AppendByte(0);
            response.AppendByte(0);
        }
    }

    private void HandleNewChar(GameSocket socket, Packet pkt)
    {
        Console.WriteLine($"[DBG] NEW_CHAR from {socket.RemoteIP}");
        if (socket.User == null) return;

        byte charIndex = pkt.ReadByte();
        string charName = pkt.ReadString();
        byte race = pkt.ReadByte();
        short classId = pkt.ReadInt16();
        byte face = pkt.ReadByte();
        uint hair = pkt.ReadUInt32();
        byte str = pkt.ReadByte();
        byte sta = pkt.ReadByte();
        byte dex = pkt.ReadByte();
        byte intStat = pkt.ReadByte();
        byte cha = pkt.ReadByte();

        Console.WriteLine($"[DBG]   Create: slot={charIndex}, name={charName}, race={race}, class={classId}");
        Console.WriteLine($"[DBG]   Stats: STR={str} STA={sta} DEX={dex} INT={intStat} CHA={cha}");

        // Validate
        if (charIndex > 2)
        {
            Packet errResponse = new Packet(WizOpcodes.WIZ_NEW_CHAR);
            errResponse.AppendByte(0x02); // NEWCHAR_NO_MORE
            socket.Send(errResponse);
            return;
        }

        if (str + sta + dex + intStat + cha > 300)
        {
            Packet errResponse = new Packet(WizOpcodes.WIZ_NEW_CHAR);
            errResponse.AppendByte(0x03); // NEWCHAR_INVALID_DETAILS
            socket.Send(errResponse);
            return;
        }

        if (str < 50 || sta < 50 || dex < 50 || intStat < 50 || cha < 50)
        {
            Packet errResponse = new Packet(WizOpcodes.WIZ_NEW_CHAR);
            errResponse.AppendByte(0x04); // NEWCHAR_STAT_TOO_LOW
            socket.Send(errResponse);
            return;
        }

        // Create character in DB
        string accountId = socket.User.AccountId;

        // Update ACCOUNT_CHAR
        string col = $"strCharID{charIndex + 1}";
        _gameDB.Execute($"UPDATE ACCOUNT_CHAR SET {col} = '{charName}' WHERE strAccountID = '{accountId}'");

        // Create USERDATA entry
        _gameDB.Execute($"INSERT INTO USERDATA (strUserID, Nation, Race, Class, HairRGB, Rank, Title, Level, Exp, Loyalty, Face, City, Knights, Fame, Hp, Mp, Sp, Strong, Sta, Dex, Intel, Cha, Authority, Points, Gold, Zone, Bind, PX, PZ, PY, dwTime, strSkill, strItem, strSerial, strUserSeal, strItemTime, sQuestCount, strQuest, sQuestDataCount, strQuestData, MannerPoint, LoyaltyMonthly, iSavedCONT, dtCreateTime) VALUES ('{charName}', {race}, {race}, {classId}, {hair}, 0, 0, 1, 0, 0, {face}, 1, 0, 0, 100, 50, 50, {str}, {sta}, {dex}, {intStat}, {cha}, 1, 0, 0, 1, 0, 0, 0, 0, 0, '', '', '', '', '', 0, '', 0, '', 0, 0, 0, NOW())");

        Packet response = new Packet(WizOpcodes.WIZ_NEW_CHAR);
        response.AppendByte(0x01); // Success
        socket.Send(response);

        Console.WriteLine($"[DBG]   Character created: {charName}");
    }

    private void HandleDelChar(GameSocket socket, Packet pkt)
    {
        Console.WriteLine($"[DBG] DEL_CHAR from {socket.RemoteIP}");
        if (socket.User == null) return;

        byte charIndex = pkt.ReadByte();
        string charName = pkt.ReadString();
        string socNo = pkt.ReadString();

        Console.WriteLine($"[DBG]   Delete: slot={charIndex}, name={charName}");

        if (charIndex > 2)
        {
            Packet errResponse = new Packet(WizOpcodes.WIZ_DEL_CHAR);
            errResponse.AppendByte(0x00); // Fail
            errResponse.AppendByte(0xFF); // Invalid slot
            socket.Send(errResponse);
            return;
        }

        string accountId = socket.User.AccountId;

        // Delete character
        _gameDB.Execute($"DELETE FROM USERDATA WHERE strUserID = '{charName}'");

        // Clear from ACCOUNT_CHAR
        string col = $"strCharID{charIndex + 1}";
        _gameDB.Execute($"UPDATE ACCOUNT_CHAR SET {col} = NULL WHERE strAccountID = '{accountId}'");

        Packet response = new Packet(WizOpcodes.WIZ_DEL_CHAR);
        response.AppendByte(0x01); // Success
        response.AppendByte(charIndex);
        socket.Send(response);

        Console.WriteLine($"[DBG]   Character deleted: {charName}");
    }

    private void HandleSelChar(GameSocket socket, Packet pkt)
    {
        Console.WriteLine($"[DBG] SEL_CHAR from {socket.RemoteIP}");
        if (socket.User == null) return;

        string charName = pkt.ReadString();
        byte init = pkt.ReadByte();

        Console.WriteLine($"[DBG]   Select: {charName}, init={init}");

        string accountId = socket.User.AccountId;

        // Load character data
        var rows = _gameDB.Query($"SELECT * FROM USERDATA WHERE strUserID = '{charName}'");
        if (rows.Count == 0)
        {
            Console.WriteLine($"[DBG]   ERROR: Character not found");
            socket.Disconnect();
            return;
        }

        var charRow = rows[0];
        socket.User.CharName = charName;
        socket.User.Level = charRow.GetByte("Level");
        socket.User.Class = (byte)charRow.GetInt16("Class");
        socket.User.Nation = charRow.GetByte("Nation");

        Console.WriteLine($"[DBG]   Loaded: {charName} Lv{socket.User.Level} Class{socket.User.Class}");

        // Send success
        Packet response = new Packet(WizOpcodes.WIZ_SEL_CHAR);
        response.AppendByte(0x01); // Success
        socket.Send(response);

        // Start game
        HandleGameStart(socket, pkt);
    }

    private void HandleMyInfo(GameSocket socket, Packet pkt)
    {
        Console.WriteLine($"[DBG] MYINFO from {socket.RemoteIP}");

        if (socket.User == null) return;

        Packet response = new Packet(WizOpcodes.WIZ_MYINFO);
        socket.User.GetInOut(response, (byte)InOutType.In);
        socket.Send(response);
    }

    private void HandleLogout(GameSocket socket, Packet pkt)
    {
        Console.WriteLine($"[DBG] LOGOUT from {socket.RemoteIP}");
        if (socket.User != null)
        {
            socket.User.OnDisconnect();
        }
        socket.Disconnect();
    }

    private void HandleMove(GameSocket socket, Packet pkt)
    {
        // Handle movement packets
        if (socket.User != null)
        {
            socket.User.HandleMove(pkt);
        }
    }

    private void HandleChat(GameSocket socket, Packet pkt)
    {
        byte chatType = pkt.ReadByte();
        string message = pkt.ReadString();
        Console.WriteLine($"[DBG] CHAT from {socket.RemoteIP}: [{chatType}] {message}");
    }

    private void HandleAttack(GameSocket socket, Packet pkt)
    {
        if (socket.User != null)
        {
            socket.User.HandleAttack(pkt);
        }
    }

    private void HandleUserInOut(GameSocket socket, Packet pkt)
    {
        // Handle user in/out notifications
    }

    private void HandleNpcInOut(GameSocket socket, Packet pkt)
    {
        // Handle NPC in/out notifications
    }

    private void HandleWeather(GameSocket socket, Packet pkt)
    {
        // Send current weather
        Packet response = new Packet(WizOpcodes.WIZ_WEATHER);
        response.AppendByte(CurrentWeather);
        socket.Send(response);
    }

    private void HandleTime(GameSocket socket, Packet pkt)
    {
        // Send current game time
        Packet response = new Packet(WizOpcodes.WIZ_TIME);
        response.AppendByte((byte)CurrentHour);
        response.AppendByte((byte)CurrentMinute);
        response.AppendByte((byte)(IsNight ? 1 : 0));
        socket.Send(response);
    }

    // ---- AI Server communication ----

    public void Send_AIServer(Packet pkt)
    {
        lock (_aiSockets)
        {
            foreach (var aiSocket in _aiSockets.Values)
            {
                aiSocket.Send(pkt);
            }
        }
    }

    public async Task AIServerConnect()
    {
        while (_running && !_cts.IsCancellationRequested)
        {
            try
            {
                Console.WriteLine($"[DBG] AIServerConnect: trying {AiServerIp}:{AiServerPort}");
                var client = new TcpClient();
                await client.ConnectAsync(AiServerIp, AiServerPort);
                Console.WriteLine($"[DBG] AIServerConnect: connected!");

                var socketId = NextAiSocketId();
                var aiSocket = new AISocket(client, socketId, this);
                _aiSockets[socketId] = aiSocket;

                await aiSocket.StartReadLoop();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[DBG] AIServerConnect: {ex.Message}, retrying in 5s...");
            }

            await Task.Delay(5000, _cts.Token);
        }
    }

    public void HandleAIPacket(AISocket aiSocket, Packet pkt)
    {
        switch (pkt.Opcode)
        {
            case 0x01: // AG_LOGIN / AI server login
                Console.WriteLine($"[DBG] AI server login from {aiSocket.RemoteIP}");
                break;
            case 0x02: // AG_CHECK_ALIVE
                Packet ack = new Packet(0x02);
                aiSocket.Send(ack);
                break;
            case 0x04: // AG_NPC_INFO_ALL
                Console.WriteLine($"[DBG] AI server sent NPC info all");
                break;
            case 0x08: // AG_NPC_REGION_UPDATE
                // Handle NPC region updates
                break;
            case 0x10: // AG_BATTLE_EVENT
                Console.WriteLine($"[DBG] AI server sent battle event");
                break;
            default:
                Console.WriteLine($"[DBG] Unhandled AI packet opcode 0x{pkt.Opcode:X2}");
                break;
        }
    }

    // ---- Timer threads ----

    private async Task Timer_CheckGameEvents(CancellationToken token)
    {
        Console.WriteLine($"[DBG] Timer_CheckGameEvents started (1s interval)");
        while (!token.IsCancellationRequested)
        {
            try
            {
                // Check for scheduled events, battle zone timers, etc.
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[DBG] Timer_CheckGameEvents error: {ex.Message}");
            }

            try { await Task.Delay(1000, token); }
            catch (OperationCanceledException) { break; }
        }
    }

    private async Task Timer_UpdateGameTime(CancellationToken token)
    {
        Console.WriteLine($"[DBG] Timer_UpdateGameTime started (1s interval)");
        while (!token.IsCancellationRequested)
        {
            try
            {
                UpdateGameTime();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[DBG] Timer_UpdateGameTime error: {ex.Message}");
            }

            try { await Task.Delay(1000, token); }
            catch (OperationCanceledException) { break; }
        }
    }

    private void UpdateGameTime()
    {
        var now = DateTime.Now;
        CurrentYear = now.Year;
        CurrentMonth = now.Month;
        CurrentDate = now.Day;
        CurrentHour = now.Hour;
        CurrentMinute = now.Minute;
        IsNight = CurrentHour >= 22 || CurrentHour < 6;
    }

    private async Task Timer_UpdateSessions(CancellationToken token)
    {
        Console.WriteLine($"[DBG] Timer_UpdateSessions started (30s interval)");
        while (!token.IsCancellationRequested)
        {
            try
            {
                // Check for idle sessions, disconnect after timeout
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[DBG] Timer_UpdateSessions error: {ex.Message}");
            }

            try { await Task.Delay(30000, token); }
            catch (OperationCanceledException) { break; }
        }
    }

    // ---- Broadcast methods ----

    public void Send_All(Packet pkt)
    {
        foreach (var socket in _sockets.Values)
        {
            socket.Send(pkt);
        }
    }

    public void Shutdown()
    {
        Console.WriteLine($"[DBG] Shutdown() called");
        _running = false;
        _cts.Cancel();
        _listener.Stop();

        foreach (var socket in _sockets.Values)
        {
            socket.Disconnect();
        }

        foreach (var aiSocket in _aiSockets.Values)
        {
            aiSocket.Disconnect();
        }

        Console.WriteLine($"[DBG] Shutdown() complete");
    }
}
