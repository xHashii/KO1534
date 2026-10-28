using System.IO;
using System.Text;

namespace Ko1534.Shared.Logging;

/// <summary>
/// Simple thread-safe logger that writes to console and a file.
/// </summary>
public static class Logger
{
    private static readonly object _lock = new();
    private static StreamWriter? _fileWriter;
    private static bool _initialized;

    public static void Init(string logDirectory, string logFileName)
    {
        lock (_lock)
        {
            if (_initialized) return;
            Directory.CreateDirectory(logDirectory);
            string fullPath = Path.Combine(logDirectory, logFileName);
            _fileWriter = new StreamWriter(fullPath, append: true, Encoding.UTF8) { AutoFlush = true };
            _initialized = true;
        }
    }

    public static void Info(string message)
    {
        Write("INFO", message);
    }

    public static void Warn(string message)
    {
        Write("WARN", message);
    }

    public static void Error(string message)
    {
        Write("ERROR", message);
    }

    public static void Debug(string message)
    {
        Write("DEBUG", message);
    }

    private static void Write(string level, string message)
    {
        string timestamp = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
        string line = $"[{timestamp}] [{level}] {message}";

        lock (_lock)
        {
            Console.WriteLine(line);
            _fileWriter?.WriteLine(line);
        }
    }
}
