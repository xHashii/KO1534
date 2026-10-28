namespace Ko1534.Shared.Crypto;

/// <summary>
/// Standard CRC32 (polynomial 0xEDB88320) matching the C++ crc32.c implementation.
/// </summary>
public static class Crc32
{
    private static readonly uint[] Table = BuildTable();

    private static uint[] BuildTable()
    {
        var table = new uint[256];
        for (uint i = 0; i < 256; i++)
        {
            uint crc = i;
            for (int j = 0; j < 8; j++)
            {
                crc = (crc & 1) != 0 ? 0xEDB88320 ^ (crc >> 1) : crc >> 1;
            }
            table[i] = crc;
        }
        return table;
    }

    /// <summary>
    /// Compute CRC32 of the first <paramref name="length"/> bytes of <paramref name="data"/>.
    /// <paramref name="startVal"> is the initial value (use 0xFFFFFFFF for standard CRC32).
    /// </summary>
    public static uint Compute(byte[] data, int length, uint startVal)
    {
        uint crc = startVal;
        for (int i = 0; i < length; i++)
        {
            crc = Table[(crc ^ data[i]) & 0xFF] ^ (crc >> 8);
        }
        return crc;
    }
}
