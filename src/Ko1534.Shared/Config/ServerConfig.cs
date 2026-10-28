namespace Ko1534.Shared.Config;

/// <summary>
/// Login server configuration parsed from LogInServer.ini.
/// </summary>
public class LoginServerConfig
{
    public int Port { get; set; } = 15100;
    public bool AutoRegister { get; set; } = true;

    public string FtpUrl { get; set; } = "ftp.yoursite.net";
    public string FtpPath { get; set; } = "/patches/";

    public string DbHost { get; set; } = "127.0.0.1";
    public int DbPort { get; set; } = 3306;
    public string DbUser { get; set; } = "ko";
    public string DbPassword { get; set; } = "";
    public string DbName { get; set; } = "KO1534";
    public bool DbPooling { get; set; } = true;
    public int DbConnectionTimeout { get; set; } = 15;
    public int DbCommandTimeout { get; set; } = 30;

    public List<ServerEntry> Servers { get; } = new();

    public List<NewsEntry> News { get; } = new();

    public static LoginServerConfig FromIni(IniFile ini)
    {
        var config = new LoginServerConfig
        {
            Port = ini.GetInt("SETTINGS", "PORT", 15100),
            AutoRegister = ini.GetBool("SETTINGS", "AUTO_REGISTER", true),

            FtpUrl = ini.GetString("DOWNLOAD", "URL", "ftp.yoursite.net"),
            FtpPath = ini.GetString("DOWNLOAD", "PATH", "/patches/"),

            DbHost = ini.GetString("ODBC", "HOST", "127.0.0.1"),
            DbPort = ini.GetInt("ODBC", "PORT", 3306),
            DbUser = ini.GetString("ODBC", "USER", "ko"),
            DbPassword = ini.GetString("ODBC", "PASSWORD", ""),
            DbName = ini.GetString("ODBC", "DATABASE", "KO1534"),
            DbPooling = ini.GetBool("ODBC", "POOLING", true),
            DbConnectionTimeout = ini.GetInt("ODBC", "CONNECTION_TIMEOUT", 15),
            DbCommandTimeout = ini.GetInt("ODBC", "COMMAND_TIMEOUT", 30),
        };

        int count = ini.GetInt("SERVER_LIST", "COUNT", 1);
        if (count <= 0) count = 1;

        for (int i = 0; i < count; i++)
        {
            string key = $"SERVER_{i:D2}";
            config.Servers.Add(new ServerEntry
            {
                Ip          = ini.GetString("SERVER_LIST", key, "127.0.0.1"),
                LanIp       = ini.GetString("SERVER_LIST", $"LANIP_{i:D2}", "127.0.0.1"),
                Name        = ini.GetString("SERVER_LIST", $"NAME_{i:D2}", "Ko1534 Server"),
                ServerId    = (short)ini.GetInt("SERVER_LIST", $"ID_{i:D2}", i + 1),
                GroupId     = (short)ini.GetInt("SERVER_LIST", $"GROUPID_{i:D2}", 1),
                PlayerCap   = (short)ini.GetInt("SERVER_LIST", $"PREMLIMIT_{i:D2}", 3000),
                FreePlayerCap = (short)ini.GetInt("SERVER_LIST", $"FREELIMIT_{i:D2}", 3000),
                KarusKingName = ini.GetString("SERVER_LIST", $"KING1_{i:D2}", ""),
                KarusNotice   = ini.GetString("SERVER_LIST", $"KINGMSG1_{i:D2}", ""),
                ElMoradKingName = ini.GetString("SERVER_LIST", $"KING2_{i:D2}", ""),
                ElMoradNotice   = ini.GetString("SERVER_LIST", $"KINGMSG2_{i:D2}", ""),
            });
        }

        for (int i = 0; i < 3; i++)
        {
            string title = ini.GetString("NEWS", $"TITLE_{i:D2}", "");
            string message = ini.GetString("NEWS", $"MESSAGE_{i:D2}", "");
            if (!string.IsNullOrEmpty(title) && !string.IsNullOrEmpty(message))
            {
                config.News.Add(new NewsEntry { Title = title, Message = message });
            }
        }

        return config;
    }
}

public class ServerEntry
{
    public string Ip { get; set; } = "127.0.0.1";
    public string LanIp { get; set; } = "127.0.0.1";
    public string Name { get; set; } = "Ko1534 Server";
    public short ServerId { get; set; }
    public short GroupId { get; set; }
    public short PlayerCap { get; set; }
    public short FreePlayerCap { get; set; }
    public short UserCount { get; set; }
    public string KarusKingName { get; set; } = "";
    public string KarusNotice { get; set; } = "";
    public string ElMoradKingName { get; set; } = "";
    public string ElMoradNotice { get; set; } = "";
}

public class NewsEntry
{
    public string Title { get; set; } = "";
    public string Message { get; set; } = "";
}
