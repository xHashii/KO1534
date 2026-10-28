using Ko1534.AIServer;
using Ko1534.Shared.Logging;

void DBG(string msg) => Logger.Debug(msg);

Console.WriteLine("=== Ko1534 AI Server v1534 ===");
Console.WriteLine($"Starting on {DateTime.Now:yyyy-MM-dd HH:mm:ss}");
Console.WriteLine();

try
{
    Logger.Init("./Logs", "AIServer.log");
    DBG("Logger initialized successfully (file + console)");
}
catch (Exception ex)
{
    DBG($"Logger init FAILED: {ex.Message}");
}

var server = new AIServerDlg();

if (!server.Startup())
{
    Console.WriteLine("Failed to start server!");
    Console.WriteLine("Press any key to exit...");
    Console.ReadKey();
    return 1;
}

Console.WriteLine("Server started successfully!");
Console.WriteLine("Press Ctrl+C to stop...");
Console.WriteLine();

// Wait for Ctrl+C
var cts = new CancellationTokenSource();
Console.CancelKeyPress += (s, e) =>
{
    e.Cancel = true;
    cts.Cancel();
    server.Shutdown();
};

try
{
    await server.RunAsync();
}
catch (Exception ex)
{
    Console.WriteLine($"Server error: {ex.Message}");
}

Console.WriteLine("Server shutting down...");
return 0;
