using System.Text;

namespace Ko1534.Shared.Packets;

/// <summary>
/// Reads from a raw byte array — used to parse incoming packet bodies.
/// Matches the C++ packet parsing semantics (little-endian, DByte string prefix).
/// </summary>
public class PacketReader
{
    private readonly byte[] _data;
    private int _rpos = 0;

    public PacketReader(byte[] data)
    {
        _data = data;
        _rpos = 0;
    }

    public int Remaining => _data.Length - _rpos;

    public byte ReadByte()
    {
        if (_rpos >= _data.Length) return 0;
        return _data[_rpos++];
    }

    public sbyte ReadSByte() => (sbyte)ReadByte();

    public ushort ReadUInt16()
    {
        if (_rpos + 2 > _data.Length) return 0;
        ushort value = (ushort)(_data[_rpos] | (_data[_rpos + 1] << 8));
        _rpos += 2;
        return value;
    }

    public short ReadInt16() => (short)ReadUInt16();

    public uint ReadUInt32()
    {
        if (_rpos + 4 > _data.Length) return 0;
        uint value = (uint)_data[_rpos]
            | ((uint)_data[_rpos + 1] << 8)
            | ((uint)_data[_rpos + 2] << 16)
            | ((uint)_data[_rpos + 3] << 24);
        _rpos += 4;
        return value;
    }

    public int ReadInt32() => (int)ReadUInt32();

    public ulong ReadUInt64()
    {
        if (_rpos + 8 > _data.Length) return 0;
        ulong value = 0;
        for (int i = 0; i < 8; i++)
        {
            value |= ((ulong)_data[_rpos + i] << (i * 8));
        }
        _rpos += 8;
        return value;
    }

    public long ReadInt64() => (long)ReadUInt64();

    public bool ReadBool() => ReadByte() > 0;

    public string ReadString()
    {
        int len = (int)ReadUInt16();
        if (len < 0 || _rpos + len > _data.Length)
        {
            _rpos += len;
            return string.Empty;
        }
        byte[] bytes = new byte[len];
        Array.Copy(_data, _rpos, bytes, 0, len);
        _rpos += len;
        return Encoding.Latin1.GetString(bytes);
    }

    public void ReadRaw(byte[] dest, int length)
    {
        if (_rpos + length > _data.Length)
        {
            Array.Clear(dest, 0, length);
            _rpos += length;
            return;
        }
        Array.Copy(_data, _rpos, dest, 0, length);
        _rpos += length;
    }

    /// <summary>
    /// Read raw bytes into a destination array (alias for ReadRaw).
    /// </summary>
    public void ReadBytes(byte[] dest, int length) => ReadRaw(dest, length);
}
