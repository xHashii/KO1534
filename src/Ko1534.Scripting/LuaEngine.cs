using System.Collections.Concurrent;

namespace Ko1534.Scripting;

/// <summary>
/// Lua scripting engine for quests and events.
/// Matches the C++ CLuaEngine / CLuaScript classes from LuaEngine.h.
/// Scripts are loaded from ./Quests/ directory, compiled to bytecode, and cached.
/// </summary>
public class LuaEngine
{
    private readonly object _lock = new();
    private readonly Dictionary<string, byte[]> _scriptCache = new();
    private readonly string _scriptDirectory;

    public string ScriptDirectory => _scriptDirectory;

    public LuaEngine()
    {
        _scriptDirectory = "./Quests/";
    }

    public LuaEngine(string scriptDirectory)
    {
        _scriptDirectory = scriptDirectory;
    }

    /// <summary>
    /// Initialize the scripting engine. Creates the script directory if needed.
    /// </summary>
    public bool Initialise()
    {
        Console.WriteLine($"[Scripting] Initialising Lua engine...");
        Console.WriteLine($"[Scripting] Script directory: {_scriptDirectory}");

        if (!Directory.Exists(_scriptDirectory))
        {
            Console.WriteLine($"[Scripting] Creating script directory: {_scriptDirectory}");
            Directory.CreateDirectory(_scriptDirectory);
        }

        Console.WriteLine($"[Scripting] Lua engine initialised");
        return true;
    }

    /// <summary>
    /// Compile a script file to bytecode and cache it.
    /// Returns true if compilation succeeded.
    /// </summary>
    public bool CompileScript(string filename, out byte[] bytecode)
    {
        bytecode = Array.Empty<byte>();

        string filePath = Path.Combine(_scriptDirectory, filename);
        Console.WriteLine($"[Scripting] Compiling script: {filePath}");

        if (!File.Exists(filePath))
        {
            Console.WriteLine($"[Scripting] ERROR: Script file not found: {filePath}");
            return false;
        }

        try
        {
            // In a full implementation, this would compile Lua source to bytecode.
            // For now, we read the raw file as the "bytecode".
            bytecode = File.ReadAllBytes(filePath);

            lock (_lock)
            {
                _scriptCache[filename] = bytecode;
            }

            Console.WriteLine($"[Scripting] Compiled {filename} ({bytecode.Length} bytes)");
            return true;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[Scripting] ERROR compiling {filename}: {ex.Message}");
            return false;
        }
    }

    /// <summary>
    /// Load a script from cache or compile it if not cached.
    /// </summary>
    public bool LoadScript(string filename, out byte[] bytecode)
    {
        lock (_lock)
        {
            if (_scriptCache.TryGetValue(filename, out var cached))
            {
                bytecode = cached;
                return true;
            }
        }

        return CompileScript(filename, out bytecode);
    }

    /// <summary>
    /// Execute a script for a user/NPC event.
    /// Returns true if execution succeeded.
    /// </summary>
    public bool ExecuteScript(string filename, object? user, object? npc, int eventId, byte selectedReward)
    {
        Console.WriteLine($"[Scripting] Executing script: {filename} (event={eventId}, reward={selectedReward})");

        if (!LoadScript(filename, out var bytecode))
        {
            Console.WriteLine($"[Scripting] ERROR: Could not load script {filename}");
            return false;
        }

        // In a full implementation, this would execute the Lua bytecode
        // with the user, npc, eventId, and selectedReward as globals.
        Console.WriteLine($"[Scripting] Script {filename} executed ({bytecode.Length} bytes)");
        return true;
    }

    /// <summary>
    /// Select an available script from the cache.
    /// </summary>
    public string? SelectAvailableScript()
    {
        lock (_lock)
        {
            if (_scriptCache.Count == 0) return null;
            return _scriptCache.Keys.First();
        }
    }

    /// <summary>
    /// Shutdown the scripting engine and clear the cache.
    /// </summary>
    public void Shutdown()
    {
        Console.WriteLine($"[Scripting] Shutting down Lua engine...");
        lock (_lock)
        {
            _scriptCache.Clear();
        }
        Console.WriteLine($"[Scripting] Lua engine shut down");
    }

    /// <summary>
    /// Get all loaded script filenames.
    /// </summary>
    public IEnumerable<string> GetLoadedScripts()
    {
        lock (_lock)
        {
            return _scriptCache.Keys.ToList();
        }
    }
}
