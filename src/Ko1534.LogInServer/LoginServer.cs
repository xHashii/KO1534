using System.Net;
using System.Net.Sockets;
using Ko1534.Shared.Config;
using Ko1534.Shared.Database;
using Ko1534.Shared.Logging;
using Ko1534.Shared.Packets;

namespace Ko1534.LogInServer;

/// <summary>
/// Main login server. Reads config, connects to DB, listens for client connections.
/// Matches the C++ LoginServer class behavior.
/// </summary>
public class LoginServer
{
    private readonly LoginServerConfig _config;
    private readonly Database _db;
    private readonly LoginRepository _repo;
    private readonly TcpListener _listener;
    private readonly CancellationTokenSource _cts = new();
    private readonly object _serverListLock = new();
    private readonly Packet _serverListPacket = new(0);
    private byte[] _newsBytes = Array.Empty<byte>();

    public short LastVersion => _repo.LastVersion;
    public string FtpUrl => _config.FtpUrl;
    public string FtpPath => _config.FtpPath;
    public Dictionary<string, (short Version, short HistoryVersion)> PatchList => _repo.VersionList;
    public LoginRepository GetRepository() => _repo;

    public LoginServer(LoginServerConfig config)
    {
        Logger.Debug("LoginServer constructor called");
        Logger.Debug("  Creating Database connection object...");
        Logger.Debug("  Creating LoginRepository...");
        Logger.Debug($"  Creating TcpListener on IPAddress.Any:{config.Port}");
        _config = config;
        _db = new Database(config.DbHost, config.DbPort, config.DbUser, config.DbPassword,
            config.DbName, config.DbPooling, config.DbConnectionTimeout, config.DbCommandTimeout);
        _repo = new LoginRepository(_db, config.AutoRegister);
        _listener = new TcpListener(IPAddress.Any, config.Port);
        Logger.Debug("LoginServer constructor complete");
    }

    public bool Startup()
    {
        Logger.Debug("── Startup() begin ──");
        Logger.Debug($"Server started on {DateTime.Now:yyyy-MM-dd HH:mm:ss.fff}");

        // Connect to database
        Logger.Debug("Step 1: Connecting to database...");
        Logger.Debug($"  Connection string: {_db.ConnectionString}");
        bool dbConnected = _db.Connect(out string error);
        Logger.Debug($"  Connect() returned: {dbConnected}");
        if (!dbConnected)
        {
            Logger.Debug($"  ERROR: {error}");
            Logger.Debug("  ── Startup() FAILED at DB connect ──");
            return false;
        }
        Logger.Debug("  Connected to database server.");

        // Load version list
        Logger.Debug("Step 2: Loading version list...");
        bool versionLoaded = _repo.LoadVersionList();
        Logger.Debug($"  LoadVersionList() returned: {versionLoaded}");
        if (!versionLoaded)
        {
            Logger.Debug("  ── Startup() FAILED at version list ──");
            return false;
        }
        Logger.Debug($"  Version list loaded. Count={_repo.VersionList.Count}");
        foreach (var (filename, (version, historyVersion)) in _repo.VersionList)
        {
            Logger.Debug($"    {filename}: v={version} (history={historyVersion})");
        }
        Logger.Debug($"  Latest version: {LastVersion}");

        // Build news from INI
        Logger.Debug("Step 3: Building news...");
        BuildNews();
        Logger.Debug($"  News content length: {_newsBytes.Length}");
        if (_newsBytes.Length > 0)
        {
            Logger.Debug($"  News content: \"{System.Text.Encoding.Latin1.GetString(_newsBytes)}\"");
        }

        // Build initial server list packet
        Logger.Debug("Step 4: Building initial server list packet...");
        UpdateServerList();
        Logger.Debug($"  Server list packet size: {_serverListPacket.UsedSize} bytes");

        // Start listener
        Logger.Debug("Step 5: Starting TcpListener...");
        _listener.Start();
        Logger.Debug($"  Listener started on 0.0.0.0:{_config.Port}");

        Logger.Debug("── Startup() complete ──");
        return true;
    }

    public async Task RunAsync()
    {
        Logger.Debug("── RunAsync() begin ──");
        Logger.Debug("Starting server list update timer...");
        _ = Task.Run(() => UpdateUserCountLoop(_cts.Token));

        Logger.Debug("Entering accept loop...");
        while (!_cts.IsCancellationRequested)
        {
            try
            {
                Logger.Debug("  Waiting for client connection...");
                var client = await _listener.AcceptTcpClientAsync(_cts.Token);
                Logger.Debug($"  ACCEPTED: {client.Client.RemoteEndPoint}");
                Logger.Debug("  Creating LoginSession...");
                var session = new LoginSession(client, this);
                Logger.Debug("  Starting session read loop...");
                session.Start();
            }
            catch (OperationCanceledException)
            {
                Logger.Debug("  Accept loop cancelled (shutdown).");
                break;
            }
            catch (Exception ex)
            {
                Logger.Debug($"  ERROR accepting connection: {ex.Message}");
            }
        }
        Logger.Debug("── RunAsync() end ──");
    }

    public void Shutdown()
    {
        Logger.Debug("Shutdown() called");
        _cts.Cancel();
        _listener.Stop();
        Logger.Debug("Shutdown() complete");
    }

    private void BuildNews()
    {
        Logger.Debug($"  BuildNews(): parsing {_config.News.Count} news entries...");
        // C++ format: title + '#' + uint8(0) + '\n' + message + '#'
        var ms = new System.IO.MemoryStream();
        foreach (var news in _config.News)
        {
            Logger.Debug($"    News entry: title=\"{news.Title}\", message=\"{news.Message}\"");
            var titleBytes = System.Text.Encoding.Latin1.GetBytes(news.Title);
            ms.Write(titleBytes, 0, titleBytes.Length);
            ms.WriteByte((byte)'#');
            ms.WriteByte((byte)0);
            ms.WriteByte((byte)'\n');
            var msgBytes = System.Text.Encoding.Latin1.GetBytes(news.Message);
            ms.Write(msgBytes, 0, msgBytes.Length);
            ms.WriteByte((byte)'#');
        }
        _newsBytes = ms.ToArray();
        Logger.Debug($"  BuildNews() done. Content length={_newsBytes.Length}");
    }

    public byte[] GetNewsBytes() => _newsBytes;

    public void GetServerList(Packet result)
    {
        Logger.Debug($"  GetServerList(): appending {_serverListPacket.UsedSize} bytes to result");
        lock (_serverListLock)
        {
            result.AppendRaw(_serverListPacket.Storage, _serverListPacket.UsedSize);
        }
    }

    public void UpdateServerList()
    {
        Logger.Debug("  UpdateServerList(): loading user counts from DB...");
        _repo.LoadUserCountList(_config.Servers);
        Logger.Debug("  UpdateServerList(): rebuilding packet...");

        lock (_serverListLock)
        {
            _serverListPacket.Clear();
            _serverListPacket.AppendByte((byte)_config.Servers.Count);
            Logger.Debug($"    Server count: {_config.Servers.Count}");

            foreach (var server in _config.Servers)
            {
                Logger.Debug($"    Server: {server.Name} (ID={server.ServerId})");
                Logger.Debug($"      IP={server.Ip}, LAN={server.LanIp}");
                Logger.Debug($"      UserCount={server.UserCount}, PlayerCap={server.PlayerCap}");
                Logger.Debug($"      KarusKing=\"{server.KarusKingName}\", KarusNotice=\"{server.KarusNotice}\"");
                Logger.Debug($"      ElMoradKing=\"{server.ElMoradKingName}\", ElMoradNotice=\"{server.ElMoradNotice}\"");

                _serverListPacket.AppendString(server.Ip);
                // LAN IP only included for version >= 1888
                // Version 1534 does NOT include LAN IP
                _serverListPacket.AppendString(server.Name);

                if (server.UserCount <= server.PlayerCap)
                {
                    _serverListPacket.AppendInt16(server.UserCount);
                }
                else
                {
                    _serverListPacket.AppendInt16(-1);
                }

                _serverListPacket.AppendInt16(server.ServerId);
                _serverListPacket.AppendInt16(server.GroupId);
                _serverListPacket.AppendInt16(server.PlayerCap);
                _serverListPacket.AppendInt16(server.FreePlayerCap);
                _serverListPacket.AppendByte(0);

                _serverListPacket.AppendString(server.KarusKingName);
                _serverListPacket.AppendString(server.KarusNotice);
                _serverListPacket.AppendString(server.ElMoradKingName);
                _serverListPacket.AppendString(server.ElMoradNotice);
            }
        }
        Logger.Debug($"  UpdateServerList(): packet size={_serverListPacket.UsedSize} bytes");
        Logger.Debug("  UpdateServerList(): packet hex:");
        var hex = new char[_serverListPacket.UsedSize * 2];
        for (int i = 0; i < _serverListPacket.UsedSize; i++)
        {
            byte b = _serverListPacket.Storage[i];
            hex[i * 2] = (char)(((b >> 4) < 10 ? '0' + (b >> 4) : 'A' + (b >> 4) - 10));
            hex[i * 2 + 1] = (char)(((b & 0x0F) < 10 ? '0' + (b & 0x0F) : 'A' + (b & 0x0F) - 10));
        }
        Logger.Debug($"    {new string(hex)}");
    }

    private async Task UpdateUserCountLoop(CancellationToken token)
    {
        Logger.Debug("  UpdateUserCountLoop: started (60s interval)");
        while (!token.IsCancellationRequested)
        {
            try
            {
                Logger.Debug("  UpdateUserCountLoop: updating server list...");
                UpdateServerList();
            }
            catch (Exception ex)
            {
                Logger.Debug($"  UpdateUserCountLoop: ERROR: {ex.Message}");
            }

            try
            {
                await Task.Delay(60_000, token);
            }
            catch (OperationCanceledException)
            {
                Logger.Debug("  UpdateUserCountLoop: cancelled");
                break;
            }
        }
        Logger.Debug("  UpdateUserCountLoop: ended");
    }
}
