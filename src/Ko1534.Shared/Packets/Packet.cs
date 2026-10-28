namespace Ko1534.Shared.Packets;

/// <summary>
/// Packet = opcode (separate field) + body (in ByteBuffer).
/// Matches the C++ Packet class: opcode is NOT stored in the buffer.
/// When sending, the frame is: AA 55 | len(u16 LE) | opcode+body | 55 AA
/// </summary>
public class Packet : ByteBuffer
{
    private byte _opcode;
    private short _ownerID = -1;

    public byte Opcode
    {
        get => _opcode;
        set => _opcode = value;
    }

    public short OwnerID
    {
        get => _ownerID;
        set => _ownerID = value;
    }

    public Packet() { }

    public Packet(byte opcode) : base(4096)
    {
        _opcode = opcode;
    }

    public Packet(byte opcode, int reserve) : base(reserve)
    {
        _opcode = opcode;
    }

    public void Initialize(byte opcode)
    {
        Clear();
        _opcode = opcode;
    }
}
