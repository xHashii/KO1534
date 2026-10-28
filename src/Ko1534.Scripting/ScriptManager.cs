namespace Ko1534.Scripting;

/// <summary>
/// Manages quest scripts and their execution.
/// Matches the C++ script management functionality.
/// </summary>
public class ScriptManager
{
    private readonly LuaEngine _engine;
    private readonly Dictionary<int, string> _eventScripts = new();

    public ScriptManager(LuaEngine engine)
    {
        _engine = engine;
    }

    /// <summary>
    /// Register a script for a specific event ID.
    /// </summary>
    public void RegisterScript(int eventId, string filename)
    {
        _eventScripts[eventId] = filename;
        Console.WriteLine($"[Scripting] Registered script '{filename}' for event {eventId}");
    }

    /// <summary>
    /// Execute a script for a given event.
    /// </summary>
    public bool ExecuteEvent(int eventId, object? user, object? npc, byte selectedReward = 0)
    {
        if (!_eventScripts.TryGetValue(eventId, out var filename))
        {
            Console.WriteLine($"[Scripting] No script registered for event {eventId}");
            return false;
        }

        return _engine.ExecuteScript(filename, user, npc, eventId, selectedReward);
    }

    /// <summary>
    /// Load all scripts from the script directory.
    /// </summary>
    public void LoadAllScripts()
    {
        Console.WriteLine($"[Scripting] Loading all scripts from {_engine.ScriptDirectory}...");

        if (!Directory.Exists(_engine.ScriptDirectory))
        {
            Console.WriteLine($"[Scripting] Script directory does not exist: {_engine.ScriptDirectory}");
            return;
        }

        var files = Directory.GetFiles(_engine.ScriptDirectory, "*.lua");
        Console.WriteLine($"[Scripting] Found {files.Length} script files");

        foreach (var file in files)
        {
            var filename = Path.GetFileName(file);
            _engine.CompileScript(filename, out _);
        }
    }
}
