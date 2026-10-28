using System.Text;

namespace Ko1534.Shared.Packets;

/// <summary>
/// Byte-level read/write buffer matching the C++ ByteBuffer semantics.
/// Little-endian for all multi-byte primitives (matches x86/x64 native order).
/// Strings use a length prefix: 2 bytes by default (DByte), 1 byte when SByte is called.
/// </summary>
public class ByteBuffer
{
    private byte[] _storage = new byte[32];
    private int _rpos = 0;
    private int _wpos = 0;
    private bool _doubleByte = true;

    public bool DoubleByte
    {
        get => _doubleByte;
        set => _doubleByte = value;
    }

    public int Rpos
    {
        get => _rpos;
        set => _rpos = value;
    }

    public int Wpos
    {
        get => _wpos;
        set => _wpos = value;
    }

    /// <summary>Total allocated capacity (matches C++ size()).</summary>
    public int Size => _storage.Length;

    /// <summary>Bytes written so far (matches C++ wpos()).</summary>
    public int UsedSize => _wpos;

    public ByteBuffer() { }

    public ByteBuffer(int reserve)
    {
        if (reserve > 0 && reserve > _storage.Length)
        {
            Array.Resize(ref _storage, reserve);
        }
    }

    public void Clear()
    {
        _rpos = 0;
        _wpos = 0;
    }

    public void SByte() => _doubleByte = false;
    public void DByte() => _doubleByte = true;

    private void EnsureCapacity(int additional)
    {
        int needed = _wpos + additional;
        if (needed <= _storage.Length) return;
        int newSize = Math.Max(_storage.Length * 2, needed);
        Array.Resize(ref _storage, newSize);
    }

    // ---- Write methods ----

    public void AppendByte(byte value)
    {
        EnsureCapacity(1);
        _storage[_wpos++] = value;
    }

    public void AppendSByte(sbyte value) => AppendByte((byte)value);

    public void AppendUInt16(ushort value)
    {
        EnsureCapacity(2);
        _storage[_wpos++] = (byte)(value & 0xFF);
        _storage[_wpos++] = (byte)((value >> 8) & 0xFF);
    }

    public void AppendInt16(short value) => AppendUInt16((ushort)value);

    public void AppendUInt32(uint value)
    {
        EnsureCapacity(4);
        _storage[_wpos++] = (byte)(value & 0xFF);
        _storage[_wpos++] = (byte)((value >> 8) & 0xFF);
        _storage[_wpos++] = (byte)((value >> 16) & 0xFF);
        _storage[_wpos++] = (byte)((value >> 24) & 0xFF);
    }

    public void AppendInt32(int value) => AppendUInt32((uint)value);

    public void AppendUInt64(ulong value)
    {
        EnsureCapacity(8);
        for (int i = 0; i < 8; i++)
        {
            _storage[_wpos++] = (byte)((value >> (i * 8)) & 0xFF);
        }
    }

    public void AppendInt64(long value) => AppendUInt64((ulong)value);

    public void AppendFloat(float value)
    {
        uint bits = BitConverter.SingleToUInt32Bits(value);
        AppendUInt32(bits);
    }

    public void AppendBool(bool value) => AppendByte(value ? (byte)1 : (byte)0);

    public void AppendString(string value)
    {
        if (value is null) value = string.Empty;
        byte[] bytes = Encoding.Latin1.GetBytes(value);
        int len = bytes.Length;
        if (_doubleByte)
        {
            AppendUInt16((ushort)len);
        }
        else
        {
            AppendByte((byte)len);
        }
        AppendRaw(bytes, len);
    }

    public void AppendRaw(byte[] data, int length)
    {
        if (length <= 0) return;
        EnsureCapacity(length);
        Array.Copy(data, 0, _storage, _wpos, length);
        _wpos += length;
    }

    // ---- Read methods ----

    public byte ReadByte()
    {
        if (_rpos + 1 > _wpos) return 0;
        return _storage[_rpos++];
    }

    public sbyte ReadSByte() => (sbyte)ReadByte();

    public ushort ReadUInt16()
    {
        if (_rpos + 2 > _wpos) return 0;
        ushort value = (ushort)(_storage[_rpos] | (_storage[_rpos + 1] << 8));
        _rpos += 2;
        return value;
    }

    public short ReadInt16() => (short)ReadUInt16();

    public uint ReadUInt32()
    {
        if (_rpos + 4 > _wpos) return 0;
        uint value = (uint)_storage[_rpos]
            | ((uint)_storage[_rpos + 1] << 8)
            | ((uint)_storage[_rpos + 2] << 16)
            | ((uint)_storage[_rpos + 3] << 24);
        _rpos += 4;
        return value;
    }

    public int ReadInt32() => (int)ReadUInt32();

    public ulong ReadUInt64()
    {
        if (_rpos + 8 > _wpos) return 0;
        ulong value = 0;
        for (int i = 0; i < 8; i++)
        {
            value |= ((ulong)_storage[_rpos + i] << (i * 8));
        }
        _rpos += 8;
        return value;
    }

    public long ReadInt64() => (long)ReadUInt64();

    public float ReadFloat()
    {
        uint bits = ReadUInt32();
        return BitConverter.UInt32BitsToSingle(bits);
    }

    public bool ReadBool() => ReadByte() > 0;

    public string ReadString()
    {
        int len = _doubleByte ? (int)ReadUInt16() : ReadByte();
        if (len < 0 || _rpos + len > _wpos)
        {
            _rpos += len;
            return string.Empty;
        }
        byte[] bytes = new byte[len];
        Array.Copy(_storage, _rpos, bytes, 0, len);
        _rpos += len;
        return Encoding.Latin1.GetString(bytes);
    }

    public void ReadRaw(byte[] dest, int length)
    {
        if (_rpos + length > _wpos)
        {
            Array.Clear(dest, 0, length);
            _rpos += length;
            return;
        }
        Array.Copy(_storage, _rpos, dest, 0, length);
        _rpos += length;
    }

    // ---- Buffer access ----

    public byte[] GetContents()
    {
        if (_wpos == 0) return Array.Empty<byte>();
        var result = new byte[_wpos];
        Array.Copy(_storage, 0, result, 0, _wpos);
        return result;
    }

    public void SetContents(byte[] data, int length)
    {
        if (length > _storage.Length)
        {
            Array.Resize(ref _storage, length);
        }
        Array.Copy(data, 0, _storage, 0, length);
        _rpos = 0;
        _wpos = length;
    }

    public void Resize(int newSize)
    {
        if (newSize > _storage.Length)
        {
            Array.Resize(ref _storage, newSize);
        }
        _rpos = 0;
        _wpos = Math.Min(newSize, _storage.Length);
    }

    // ---- Raw buffer access (for framing) ----

    public byte[] Storage => _storage;
    public int StorageLength => _storage.Length;
}
