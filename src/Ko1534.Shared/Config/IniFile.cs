using System.Globalization;

namespace Ko1534.Shared.Config;

/// <summary>
/// Simple INI file reader matching the C++ CIni class semantics.
/// Sections are [SECTION], keys are key = value. Comments start with # or ;.
/// </summary>
public class IniFile
{
    private readonly Dictionary<string, Dictionary<string, string>> _sections = new();

    public IniFile(string path)
    {
        Load(path);
    }

    /// <summary>
    /// Find an INI file by name, searching common locations.
    /// Checks: ./name, ./config/name, then walks up parent directories looking for config/name.
    /// </summary>
    public static string FindIni(string fileName)
    {
        // Check current directory
        if (File.Exists(fileName)) return fileName;
        if (File.Exists($"./config/{fileName}")) return $"./config/{fileName}";

        // Walk up parent directories looking for config/name
        var dir = new DirectoryInfo(Directory.GetCurrentDirectory());
        while (dir != null)
        {
            string candidate = Path.Combine(dir.FullName, "config", fileName);
            if (File.Exists(candidate)) return candidate;
            dir = dir.Parent;
        }

        return fileName; // fallback — IniFile will silently load empty
    }

    private void Load(string path)
    {
        if (!File.Exists(path)) return;

        string? currentSection = null;
        foreach (var rawLine in File.ReadLines(path))
        {
            string line = rawLine.Trim();
            if (line.Length == 0 || line.StartsWith('#') || line.StartsWith(';')) continue;

            if (line.StartsWith('[') && line.EndsWith(']'))
            {
                currentSection = line[1..^1];
                if (!_sections.ContainsKey(currentSection))
                {
                    _sections[currentSection] = new Dictionary<string, string>();
                }
            }
            else
            {
                int eq = line.IndexOf('=');
                if (eq < 0) continue;

                string key = line[..eq].Trim();
                string value = line[(eq + 1)..].Trim();

                if (currentSection is not null)
                {
                    _sections[currentSection][key] = value;
                }
            }
        }
    }

    public string GetString(string section, string key, string defaultValue = "")
    {
        if (_sections.TryGetValue(section, out var kv) && kv.TryGetValue(key, out var value))
        {
            return value;
        }
        return defaultValue;
    }

    public int GetInt(string section, string key, int defaultValue = 0)
    {
        string value = GetString(section, key);
        return int.TryParse(value, NumberStyles.Integer, CultureInfo.InvariantCulture, out int result)
            ? result
            : defaultValue;
    }

    public bool GetBool(string section, string key, bool defaultValue = false)
    {
        string value = GetString(section, key);
        return bool.TryParse(value, out bool result) ? result : defaultValue;
    }
}
