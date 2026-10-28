using Ko1534.LogInServer;
using Ko1534.Shared.Config;
using Ko1534.Shared.Logging;
using System.Runtime.InteropServices;

// ═══════════════════════════════════════════════════════════════════
//  Entry point — FULL DEBUG MODE
// ═══════════════════════════════════════════════════════════════════

void DBG(string msg) => Logger.Debug(msg);

DBG("═══════════════════════════════════════════════════════════");
DBG("  Ko1534 LoginServer STARTING");
DBG("═══════════════════════════════════════════════════════════");
DBG($"Process start time: {DateTime.Now:yyyy-MM-dd HH:mm:ss.fff}");
DBG($"Current working directory: {Directory.GetCurrentDirectory()}");
DBG($"Current process ID: {Environment.ProcessId}");
DBG($"Available processors: {Environment.ProcessorCount}");
DBG($"OS: {RuntimeInformation.OSDescription}");
DBG($".NET version: {Environment.Version}");
DBG("");

    string configPath = args.Length > 0 ? args[0] : IniFile.FindIni("LogInServer.ini");
DBG($"Config path argument: \"{configPath}\"");
DBG($"Config file exists: {File.Exists(configPath)}");

if (!File.Exists(configPath))
{
    DBG("ERROR: Config file not found!");
    DBG($"Looking in: {Directory.GetCurrentDirectory()}");
    DBG("Available directories:");
    foreach (var dir in Directory.GetDirectories("."))
    {
        DBG($"  {Path.GetFileName(dir)}");
    }
}

try
{
    Logger.Init("./Logs", "LoginServer.log");
    DBG("Logger initialized successfully (file + console)");
}
catch (Exception ex)
{
    DBG($"Logger init FAILED: {ex.Message}");
    DBG("Continuing with console-only output");
}

DBG("");
DBG("── Starting server initialization ──");

try
{
    DBG("Step 1: Parsing INI config...");
    var ini = new IniFile(configPath);
    DBG($"  INI file loaded from: {configPath}");

    DBG("Step 2: Building server config...");
    var config = LoginServerConfig.FromIni(ini);
    DBG($"  Port: {config.Port}");
    DBG($"  AutoRegister: {config.AutoRegister}");
    DBG($"  FTP URL: {config.FtpUrl}");
    DBG($"  FTP Path: {config.FtpPath}");
    DBG($"  DB Host: {config.DbHost}");
    DBG($"  DB Port: {config.DbPort}");
    DBG($"  DB User: {config.DbUser}");
    DBG($"  DB Name: {config.DbName}");
    DBG($"  DB Pooling: {config.DbPooling}");
    DBG($"  Server count: {config.Servers.Count}");
    foreach (var s in config.Servers)
    {
        DBG($"  Server[{s.ServerId}]: {s.Name} @ {s.Ip}:{config.Port}");
        DBG($"    PlayerCap={s.PlayerCap}, FreeCap={s.FreePlayerCap}");
    }
    DBG($"  News entries: {config.News.Count}");
    foreach (var n in config.News)
    {
        DBG($"    News: \"{n.Title}\" = \"{n.Message}\"");
    }

    DBG("Step 3: Creating LoginServer instance...");
    var server = new LoginServer(config);
    DBG("  LoginServer instance created");

    DBG("Step 4: Calling Startup()...");
    bool startupResult = server.Startup();
    DBG($"  Startup() returned: {startupResult}");

    if (!startupResult)
    {
        DBG("ERROR: Startup failed! Exiting.");
        Environment.Exit(1);
    }

    DBG("Step 5: Startup complete, server is running");
    DBG("");
    DBG("═══════════════════════════════════════════════════════════");
    DBG("  Server is RUNNING — waiting for connections...");
    DBG("  Press Ctrl+C to stop.");
    DBG("═══════════════════════════════════════════════════════════");
    DBG("");

    // Handle Ctrl+C / Ctrl+Break for graceful shutdown
    using var cts = new CancellationTokenSource();
    Console.CancelKeyPress += (_, e) =>
    {
        DBG("Shutdown signal received (Ctrl+C).");
        e.Cancel = true;
        cts.Cancel();
        server.Shutdown();
    };

    await server.RunAsync();
}
catch (Exception ex)
{
    DBG("");
    DBG("═══════════════════════════════════════════════════════════");
    DBG("  CRITICAL ERROR — unhandled exception!");
    DBG("═══════════════════════════════════════════════════════════");
    DBG($"Exception type: {ex.GetType().FullName}");
    DBG($"Exception message: {ex.Message}");
    DBG($"Stack trace:");
    foreach (var line in ex.StackTrace?.Split('\n').Select(l => l.Trim()) ?? Array.Empty<string>())
    {
        DBG($"  {line}");
    }
    Console.WriteLine($"FATAL: {ex}");
}

DBG("");
DBG("LoginServer stopped.");
