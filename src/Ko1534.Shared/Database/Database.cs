using MySqlConnector;
using System.Collections;

namespace Ko1534.Shared.Database;

/// <summary>
/// A single row from a MySQL query result.
/// </summary>
public class MySqlRow
{
    private readonly Dictionary<string, object?> _values;

    public MySqlRow(Dictionary<string, object?> values)
    {
        _values = values;
    }

    public string GetString(string column) => _values.TryGetValue(column, out var val) ? val?.ToString() ?? "" : "";
    public short GetInt16(string column) => _values.TryGetValue(column, out var val) && val is not null ? Convert.ToInt16(val) : (short)0;
    public ushort GetUInt16(string column) => _values.TryGetValue(column, out var val) && val is not null ? Convert.ToUInt16(val) : (ushort)0;
    public int GetInt32(string column) => _values.TryGetValue(column, out var val) && val is not null ? Convert.ToInt32(val) : 0;
    public uint GetUInt32(string column) => _values.TryGetValue(column, out var val) && val is not null ? Convert.ToUInt32(val) : 0u;
    public long GetInt64(string column) => _values.TryGetValue(column, out var val) && val is not null ? Convert.ToInt64(val) : 0L;
    public ulong GetUInt64(string column) => _values.TryGetValue(column, out var val) && val is not null ? Convert.ToUInt64(val) : 0UL;
    public byte GetByte(string column) => _values.TryGetValue(column, out var val) && val is not null ? Convert.ToByte(val) : (byte)0;
    public bool GetBool(string column) => _values.TryGetValue(column, out var val) && val is not null && Convert.ToBoolean(val);
}

/// <summary>
/// MySQL connection wrapper using MySqlConnector with connection pooling.
/// </summary>
public class Database
{
    private readonly string _connectionString;

    public Database(string host, int port, string user, string password, string database,
                    bool pooling = true, int connectionTimeout = 15, int commandTimeout = 30)
    {
        _connectionString = new MySqlConnectionStringBuilder
        {
            Server = host,
            Port = (uint)port,
            UserID = user,
            Password = password,
            Database = database,
            Pooling = pooling,
            ConnectionTimeout = (uint)connectionTimeout,
            DefaultCommandTimeout = (uint)commandTimeout,
        }.ToString();
    }

    /// <summary>
    /// Test the connection. Returns true if successful.
    /// </summary>
    public bool Connect(out string error)
    {
        try
        {
            using var conn = new MySqlConnection(_connectionString);
            conn.Open();
            error = string.Empty;
            return true;
        }
        catch (Exception ex)
        {
            error = ex.Message;
            return false;
        }
    }

    /// <summary>
    /// Create a new open connection (uses connection pool).
    /// </summary>
    public MySqlConnection CreateConnection()
    {
        var conn = new MySqlConnection(_connectionString);
        conn.Open();
        return conn;
    }

    /// <summary>
    /// Execute a SELECT query and return rows.
    /// </summary>
    public List<MySqlRow> Query(string sql)
    {
        var result = new List<MySqlRow>();
        using var conn = new MySqlConnection(_connectionString);
        conn.Open();
        using var cmd = new MySqlCommand(sql, conn);
        using var reader = cmd.ExecuteReader();

        while (reader.Read())
        {
            var row = new Dictionary<string, object?>();
            for (int i = 0; i < reader.FieldCount; i++)
            {
                row[reader.GetName(i)] = reader.IsDBNull(i) ? null : reader.GetValue(i);
            }
            result.Add(new MySqlRow(row));
        }
        return result;
    }

    /// <summary>
    /// Execute a non-query SQL statement (INSERT, UPDATE, DELETE, etc).
    /// </summary>
    public void Execute(string sql)
    {
        using var conn = new MySqlConnection(_connectionString);
        conn.Open();
        using var cmd = new MySqlCommand(sql, conn);
        cmd.ExecuteNonQuery();
    }

    public string ConnectionString => _connectionString;
}
