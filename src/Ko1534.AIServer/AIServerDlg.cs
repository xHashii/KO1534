using System.Collections.Concurrent;
using System.Net;
using System.Net.Sockets;
using Ko1534.Shared.Config;
using Ko1534.Shared.Database;
using Ko1534.Shared.Packets;

namespace Ko1534.AIServer;

/// <summary>
/// Main AI Server class.
/// Matches the C++ CServerDlg class behavior.
/// Handles NPC AI, pathfinding, and communication with game servers.
/// </summary>
public class AIServerDlg
{
    private readonly TcpListener _listener;
    private Database _gameDB = null!;
    private readonly CancellationTokenSource _cts = new();
    private readonly ConcurrentDictionary<short, AIGameSocket> _sockets = new();
    private readonly ConcurrentDictionary<ushort, AiNpc> _npcs = new();
    private readonly ConcurrentDictionary<ushort, AiUser> _users = new();
    private readonly ConcurrentDictionary<int, AIMap> _maps = new();
    private readonly ConcurrentDictionary<ushort, NpcThread> _npcThreads = new();
    private int _nextSocketId = 0;
    private bool _running = false;

    // Configuration
    public int AIServerPort { get; private set; } = 15002;
    public string GameDsn { get; private set; } = "";
    public string GameUid { get; private set; } = "";
    public string GamePwd { get; private set; } = "";
    public byte MaxLevel { get; private set; } = 80;

    // Server state
    public int CurrentYear, CurrentMonth, CurrentDate, CurrentHour, CurrentMinute;
    public byte CurrentWeather = 1;
    public bool IsNight;
    public byte BattleOpen = 1; // 0: closed, 1: open

    // NPC tables (simplified)
    public Dictionary<uint, object> MagicTable { get; } = new();
    public Dictionary<uint, object> NpcTable { get; } = new();
    public Dictionary<uint, object> ItemTable { get; } = new();

    // Total NPC counter
    private int _totalNpc;
    private int _currentNpc;
    private int _totalMaps;

    public AIServerDlg()
    {
        _listener = new TcpListener(IPAddress.Any, 0);
    }

    public bool Startup()
    {
        Console.WriteLine($"[DBG] ── AIServer Startup() begin ──");
        Console.WriteLine($"[DBG] Server started on {DateTime.Now:yyyy-MM-dd HH:mm:ss}");

        // Load INI
        Console.WriteLine($"[DBG] Step 1: Loading AIServer.ini...");
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

        // Load tables
        Console.WriteLine($"[DBG] Step 3: Loading game tables...");
        LoadTables();

        // Load maps
        Console.WriteLine($"[DBG] Step 4: Loading maps...");
        LoadMaps();

        // Start listener
        Console.WriteLine($"[DBG] Step 5: Starting TcpListener on 0.0.0.0:{AIServerPort}...");
        _listener.Start();
        Console.WriteLine($"[DBG]   Listener started.");

        _running = true;
        Console.WriteLine($"[DBG] ── Startup() complete ──");
        return true;
    }

    private bool LoadConfig()
    {
        var ini = new IniFile(IniFile.FindIni("AIServer.ini"));

        AIServerPort = ini.GetInt("SETTINGS", "PORT", 15002);
        MaxLevel = (byte)ini.GetInt("SETTINGS", "GAMEMAXLEVEL", 80);

        // Game DB - C# uses direct MySQL connection
        string host = ini.GetString("GAME_ODBC", "HOST", "127.0.0.1");
        int port = ini.GetInt("GAME_ODBC", "PORT", 3306);
        GameUid = ini.GetString("GAME_ODBC", "USER", "ko");
        GamePwd = ini.GetString("GAME_ODBC", "PASSWORD", "");
        string db = ini.GetString("GAME_ODBC", "DATABASE", "KO1534");
        bool pooling = ini.GetBool("GAME_ODBC", "POOLING", true);
        int connTimeout = ini.GetInt("GAME_ODBC", "CONNECTION_TIMEOUT", 15);
        int cmdTimeout = ini.GetInt("GAME_ODBC", "COMMAND_TIMEOUT", 30);
        _gameDB = new Database(host, port, GameUid, GamePwd, db, pooling, connTimeout, cmdTimeout);

        Console.WriteLine($"[DBG]   Config loaded: Port={AIServerPort}, MaxLevel={MaxLevel}");
        return true;
    }

    private void LoadTables()
    {
        Console.WriteLine($"[DBG]   Loading game tables from DB...");

        // Load MAGIC table (skill data)
        try
        {
            var magicRows = _gameDB.Query("SELECT * FROM MAGIC");
            foreach (var row in magicRows)
            {
                uint skillId = row.GetUInt32("MagicNum");
                MagicTable.Add(skillId, new object());
            }
            Console.WriteLine($"[DBG]    Magic table: {MagicTable.Count} entries");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[DBG]    Magic table: skipped ({ex.Message})");
        }

        // Load K_NPC table (NPC definitions)
        try
        {
            var npcRows = _gameDB.Query("SELECT * FROM K_NPC");
            foreach (var row in npcRows)
            {
                ushort sid = row.GetUInt16("sSid");
                NpcTable.Add(sid, new object());
            }
            Console.WriteLine($"[DBG]    NPC table: {NpcTable.Count} entries");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[DBG]    NPC table: skipped ({ex.Message})");
        }

        // Load ITEM table (item definitions)
        try
        {
            var itemRows = _gameDB.Query("SELECT * FROM ITEM");
            foreach (var row in itemRows)
            {
                uint itemNum = row.GetUInt32("Num");
                ItemTable.Add(itemNum, new object());
            }
            Console.WriteLine($"[DBG]    Item table: {ItemTable.Count} entries");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[DBG]    Item table: skipped ({ex.Message})");
        }

        // Load K_MONSTER table (monster definitions)
        try
        {
            var monsterRows = _gameDB.Query("SELECT * FROM K_MONSTER");
            foreach (var row in monsterRows)
            {
                ushort sid = row.GetUInt16("sSid");
                NpcTable.Add(sid, new object());
            }
            Console.WriteLine($"[DBG]    K_MONSTER table: {NpcTable.Count} total entries");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[DBG]    K_MONSTER table: skipped ({ex.Message})");
        }

        Console.WriteLine($"[DBG]   Table loading complete.");
    }

    private void LoadMaps()
    {
        Console.WriteLine($"[DBG]   Loading maps from DB...");

        // No map table in schema — create a default map for zone 1
        var defaultMap = new AIMap(1, "Default");
        _maps[1] = defaultMap;
        _totalMaps = _maps.Count;
        Console.WriteLine($"[DBG]    Created {_totalMaps} default map(s)");
    }

    public async Task RunAsync()
    {
        Console.WriteLine($"[DBG] ── RunAsync() begin ──");

        // Start timer threads
        _ = Task.Run(() => Timer_CheckAliveTest(_cts.Token));
        _ = Task.Run(() => Timer_CheckLiveTimes(_cts.Token));
        _ = Task.Run(() => Timer_UpdateGameTime(_cts.Token));

        // Accept loop
        while (_running && !_cts.IsCancellationRequested)
        {
            try
            {
                var client = await _listener.AcceptTcpClientAsync(_cts.Token);
                var socketId = NextSocketId();
                var socket = new AIGameSocket(client, socketId, this);
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
        return (short)(Interlocked.Increment(ref _nextSocketId) % AIConstants.MaxSocket);
    }

    public void DisconnectSocket(short socketId)
    {
        if (_sockets.TryRemove(socketId, out var socket))
        {
            Console.WriteLine($"[DBG] Disconnected socket {socketId} ({socket.RemoteIP})");
        }
    }

    /// <summary>
    /// Main packet handler for game server packets.
    /// </summary>
    public void HandleGamePacket(AIGameSocket socket, Packet pkt)
    {
        switch (pkt.Opcode)
        {
            case 0x01: // AG_LOGIN (game server login to AI server)
                HandleServerLogin(socket, pkt);
                break;
            case 0x02: // AG_CHECK_ALIVE
                Packet ack = new Packet(0x02);
                socket.Send(ack);
                break;
            case 0x03: // AG_SERVER_INFO
                HandleServerInfo(socket, pkt);
                break;
            case 0x04: // AG_NPC_INFO_ALL
                HandleNpcInfoAll(socket, pkt);
                break;
            case 0x07: // AG_NPC_INFO
                HandleNpcInfo(socket, pkt);
                break;
            case 0x08: // AG_NPC_REGION_UPDATE
                HandleNpcRegionUpdate(socket, pkt);
                break;
            case 0x0E: // AG_NPC_DEAD
                HandleNpcDead(socket, pkt);
                break;
            case 0x0F: // AG_NPC_INOUT
                HandleNpcInOut(socket, pkt);
                break;
            case 0x10: // AG_BATTLE_EVENT
                HandleBattleEvent(socket, pkt);
                break;
            case 0x12: // AG_GATE_OPEN
                HandleGateOpen(socket, pkt);
                break;
            case 0x14: // AG_NPC_HP_CHANGE
                HandleNpcHpChange(socket, pkt);
                break;
            case 0x16: // AG_NPC_SPAWN_REQ
                HandleNpcSpawnReq(socket, pkt);
                break;
            case 0x17: // AG_NPC_KILL_REQ
                HandleNpcKillReq(socket, pkt);
                break;
            case 0x18: // AG_NPC_UPDATE
                HandleNpcUpdate(socket, pkt);
                break;
            case 0x19: // AG_USER_INFO_ALL
                HandleUserInfoAll(socket, pkt);
                break;
            case 0x1A: // AG_PARTY_INFO_ALL
                HandlePartyInfoAll(socket, pkt);
                break;
            case 0x1B: // AG_TIME_WEATHER
                HandleTimeWeather(socket, pkt);
                break;
            default:
                Console.WriteLine($"[DBG] Unhandled AI packet opcode 0x{pkt.Opcode:X2} from {socket.RemoteIP}");
                break;
        }
    }

    private void HandleServerLogin(AIGameSocket socket, Packet pkt)
    {
        Console.WriteLine($"[DBG] AI Server: Game server {socket.RemoteIP} logged in (socketId={socket.SocketId})");
        // Send login response
        Packet response = new Packet(0x01);
        response.AppendByte(0x01); // success
        socket.Send(response);
    }

    private void HandleServerInfo(AIGameSocket socket, Packet pkt)
    {
        Console.WriteLine($"[DBG] AI Server: Received server info from {socket.RemoteIP}");
    }

    private void HandleNpcInfoAll(AIGameSocket socket, Packet pkt)
    {
        Console.WriteLine($"[DBG] AI Server: Received NPC info all from {socket.RemoteIP}");
        // Parse NPC positions and update local NPC data
    }

    private void HandleNpcInfo(AIGameSocket socket, Packet pkt)
    {
        Console.WriteLine($"[DBG] AI Server: Received NPC info from {socket.RemoteIP}");
    }

    private void HandleNpcRegionUpdate(AIGameSocket socket, Packet pkt)
    {
        Console.WriteLine($"[DBG] AI Server: Received NPC region update from {socket.RemoteIP}");
    }

    private void HandleNpcDead(AIGameSocket socket, Packet pkt)
    {
        Console.WriteLine($"[DBG] AI Server: NPC died, processing...");
        // Process NPC death - drop loot, respawn timer
    }

    private void HandleNpcInOut(AIGameSocket socket, Packet pkt)
    {
        Console.WriteLine($"[DBG] AI Server: NPC in/out from {socket.RemoteIP}");
    }

    private void HandleBattleEvent(AIGameSocket socket, Packet pkt)
    {
        Console.WriteLine($"[DBG] AI Server: Battle event from {socket.RemoteIP}");
        // Process battle event - spawn event NPCs, etc.
    }

    private void HandleGateOpen(AIGameSocket socket, Packet pkt)
    {
        Console.WriteLine($"[DBG] AI Server: Gate open from {socket.RemoteIP}");
    }

    private void HandleNpcHpChange(AIGameSocket socket, Packet pkt)
    {
        Console.WriteLine($"[DBG] AI Server: NPC HP change from {socket.RemoteIP}");
    }

    private void HandleNpcSpawnReq(AIGameSocket socket, Packet pkt)
    {
        Console.WriteLine($"[DBG] AI Server: NPC spawn request from {socket.RemoteIP}");
        // Spawn NPC in AI server
    }

    private void HandleNpcKillReq(AIGameSocket socket, Packet pkt)
    {
        Console.WriteLine($"[DBG] AI Server: NPC kill request from {socket.RemoteIP}");
    }

    private void HandleNpcUpdate(AIGameSocket socket, Packet pkt)
    {
        Console.WriteLine($"[DBG] AI Server: NPC update from {socket.RemoteIP}");
    }

    private void HandleUserInfoAll(AIGameSocket socket, Packet pkt)
    {
        Console.WriteLine($"[DBG] AI Server: User info all from {socket.RemoteIP}");
    }

    private void HandlePartyInfoAll(AIGameSocket socket, Packet pkt)
    {
        Console.WriteLine($"[DBG] AI Server: Party info all from {socket.RemoteIP}");
    }

    private void HandleTimeWeather(AIGameSocket socket, Packet pkt)
    {
        Console.WriteLine($"[DBG] AI Server: Time/weather from {socket.RemoteIP}");
    }

    // ---- Broadcast methods ----

    public void Send_All(Packet pkt)
    {
        foreach (var socket in _sockets.Values)
        {
            socket.Send(pkt);
        }
    }

    public void SendSystemMsg(string msg, int type = 0)
    {
        Packet pkt = new Packet(0x0A); // AG_SYSTEM_MSG
        pkt.AppendByte((byte)type);
        pkt.AppendString(msg);
        Send_All(pkt);
    }

    // ---- Timer threads ----

    private async Task Timer_CheckAliveTest(CancellationToken token)
    {
        Console.WriteLine($"[DBG] Timer_CheckAliveTest started (10s interval)");
        while (!token.IsCancellationRequested)
        {
            try
            {
                // Check for dead NPCs, respawn timers, etc.
                foreach (var npc in _npcs.Values)
                {
                    if (npc.IsDead && npc.RespawnTime > 0)
                    {
                        npc.RespawnTime--;
                        if (npc.RespawnTime <= 0)
                        {
                            npc.Respawn();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[DBG] Timer_CheckAliveTest error: {ex.Message}");
            }

            try { await Task.Delay(10000, token); }
            catch (OperationCanceledException) { break; }
        }
    }

    private async Task Timer_CheckLiveTimes(CancellationToken token)
    {
        Console.WriteLine($"[DBG] Timer_CheckLiveTimes started (30s interval)");
        while (!token.IsCancellationRequested)
        {
            try
            {
                // Check NPC live times, remove expired event NPCs
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[DBG] Timer_CheckLiveTimes error: {ex.Message}");
            }

            try { await Task.Delay(30000, token); }
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

        foreach (var thread in _npcThreads.Values)
        {
            thread.Stop();
        }

        Console.WriteLine($"[DBG] Shutdown() complete");
    }
}
