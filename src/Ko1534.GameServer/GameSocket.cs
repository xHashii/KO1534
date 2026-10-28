using System.Net;
using System.Net.Sockets;
using Ko1534.Shared.Crypto;
using Ko1534.Shared.Packets;

namespace Ko1534.GameServer;

/// <summary>
/// Represents a connected game client socket.
/// Handles packet framing (AA 55 | len | opcode+body | 55 AA) and dispatch to handlers.
/// Matches the C++ CGameSocket class behavior.
/// </summary>
public class GameSocket
{
    private readonly TcpClient _client;
    private readonly GameServerDlg _server;
    private readonly NetworkStream _stream;
    private readonly BufferStream _readBuffer;
    private readonly BufferStream _writeBuffer;
    private readonly byte[] _readChunk = new byte[65536];
    private bool _connected = true;
    private bool _cryptoEnabled = false;
    private readonly JvCryption _crypto = new();
    private uint _sequence = 0;
    private int _readTries = 0;
    private int _remaining = 0;

    public short SocketId { get; private set; }
    public string RemoteIP { get; private set; } = "";
    public User? User { get; set; }

    public GameSocket(TcpClient client, short socketId, GameServerDlg server)
    {
        _client = client;
        _server = server;
        _stream = client.GetStream();
        SocketId = socketId;
        RemoteIP = ((IPEndPoint)client.Client.RemoteEndPoint!).Address.ToString();

        _readBuffer = new BufferStream(662144);
        _writeBuffer = new BufferStream(331072);
    }

    public async Task StartReadLoop()
    {
        try
        {
            while (_connected)
            {
                int bytesRead = await _stream.ReadAsync(_readChunk, 0, _readChunk.Length);
                if (bytesRead <= 0)
                {
                    Disconnect();
                    break;
                }

                _readBuffer.Write(_readChunk, 0, bytesRead);
                await ProcessReadBuffer();
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[GameSocket] Read error from {RemoteIP}: {ex.Message}");
            Disconnect();
        }
    }

    private async Task ProcessReadBuffer()
    {
        while (_connected)
        {
            if (_remaining == 0)
            {
                if (_readBuffer.Length < 5)
                    return;

                byte[] headerBytes = new byte[2];
                _readBuffer.Read(headerBytes, 0, 2);
                ushort header = (ushort)(headerBytes[0] | (headerBytes[1] << 8));

                if (header != 0x55AA)
                {
                    Console.WriteLine($"[GameSocket] Bad header 0x{header:X} from {RemoteIP}");
                    Disconnect();
                    return;
                }

                byte[] lenBytes = new byte[2];
                _readBuffer.Read(lenBytes, 0, 2);
                _remaining = lenBytes[0] | (lenBytes[1] << 8);

                if (_remaining == 0)
                {
                    Disconnect();
                    return;
                }
            }

            if (_remaining > _readBuffer.Length)
            {
                _readTries++;
                if (_readTries > 4)
                {
                    Console.WriteLine($"[GameSocket] Fragmentation count > 4 from {RemoteIP}");
                    Disconnect();
                    return;
                }
                return;
            }

            _readTries = 0;
            byte[] inStream = new byte[_remaining];
            _readBuffer.Read(inStream, 0, _remaining);

            byte[] footerBytes = new byte[2];
            _readBuffer.Read(footerBytes, 0, 2);
            ushort footer = (ushort)(footerBytes[0] | (footerBytes[1] << 8));

            if (footer != 0xAA55 || !DecryptPacket(inStream, out Packet pkt))
            {
                Console.WriteLine($"[GameSocket] Footer invalid (0x{footer:X}) or decrypt failed from {RemoteIP}");
                Disconnect();
                return;
            }

            _remaining = 0;
            HandlePacket(pkt);
        }
    }

    private bool DecryptPacket(byte[] inStream, out Packet pkt)
    {
        pkt = new Packet();

        byte[] finalPacket;
        int finalLen;

        if (_cryptoEnabled)
        {
            if (_remaining < 8) // need at least seq(4) + crc(4)
                return false;

            int decrypted = _crypto.JvDecryptionWithCRC32(_remaining, inStream, inStream);
            if (decrypted < 0)
                return false;

            uint sequence = BitConverter.ToUInt32(inStream, 0);
            _sequence++;
            if (_sequence != sequence)
                return false;

            _remaining -= 8; // remove sequence ID (4) + CRC (4)
            finalPacket = inStream;
            finalLen = _remaining;
        }
        else
        {
            finalPacket = inStream;
            finalLen = _remaining;
        }

        // C++: m_remaining--; pkt.opcode = final_packet[0];
        //      memcpy(pkt.contents(), &final_packet[1], m_remaining);
        // Opcode is at finalPacket[0], body is at finalPacket[1..]
        pkt.Opcode = finalPacket[0];
        int bodyLen = finalLen - 1;
        if (bodyLen > 0)
        {
            byte[] body = new byte[bodyLen];
            Array.Copy(finalPacket, 1, body, 0, bodyLen);
            pkt.SetContents(body, body.Length);
        }
        _remaining = bodyLen;
        return true;
    }

    public ulong GenerateCryptoKey()
    {
        return _crypto.GenerateKey();
    }

    public void EnableCrypto()
    {
        _crypto.Init();
        _cryptoEnabled = true;
    }

    public void Send(Packet pkt)
    {
        if (!_connected) return;

        byte[] body = pkt.GetContents();
        byte opcode = pkt.Opcode;

        byte[] outStream;
        int outLen;

        if (_cryptoEnabled)
        {
            outLen = body.Length + 1 + 5; // opcode + body + 5 byte header
            outStream = new byte[outLen];
            // 0x1efc (u16 LE)
            outStream[0] = 0xFC;
            outStream[1] = 0x1E;
            // sequence (u16 LE)
            outStream[2] = (byte)(_sequence & 0xFF);
            outStream[3] = (byte)((_sequence >> 8) & 0xFF);
            // 0
            outStream[4] = 0;
            // opcode
            outStream[5] = opcode;
            // body
            if (body.Length > 0)
                Array.Copy(body, 0, outStream, 6, body.Length);

            _crypto.JvEncryptionFast(outLen, outStream, outStream);
        }
        else
        {
            outLen = body.Length + 1;
            outStream = new byte[outLen];
            outStream[0] = opcode;
            if (body.Length > 0)
                Array.Copy(body, 0, outStream, 1, body.Length);
        }

        byte[] frame = new byte[outLen + 6];
        frame[0] = 0xAA;
        frame[1] = 0x55;
        frame[2] = (byte)(outLen & 0xFF);
        frame[3] = (byte)((outLen >> 8) & 0xFF);
        Array.Copy(outStream, 0, frame, 4, outLen);
        frame[4 + outLen] = 0x55;
        frame[5 + outLen] = 0xAA;

        _stream.Write(frame, 0, frame.Length);
    }

    public void Disconnect()
    {
        if (!_connected) return;
        _connected = false;

        if (User != null)
        {
            User.OnDisconnect();
        }

        _server.DisconnectSocket(SocketId);
        _client.Close();
    }

    public void HandlePacket(Packet pkt)
    {
        _server.HandleGamePacket(this, pkt);
    }

    public async Task SendAsync(Packet pkt)
    {
        Send(pkt);
    }
}

/// <summary>
/// Simple buffer stream that accumulates bytes for packet framing.
/// </summary>
public class BufferStream
{
    private byte[] _buffer;
    private int _readPos = 0;
    private int _writePos = 0;

    public BufferStream(int initialSize = 65536)
    {
        _buffer = new byte[initialSize];
    }

    public int Length => _writePos - _readPos;

    public void Write(byte[] data, int offset, int count)
    {
        if (_writePos + count > _buffer.Length)
        {
            Array.Resize(ref _buffer, Math.Max(_buffer.Length * 2, _writePos + count));
        }
        Array.Copy(data, offset, _buffer, _writePos, count);
        _writePos += count;
    }

    public int Read(byte[] dest, int offset, int count)
    {
        int toRead = Math.Min(count, Length);
        Array.Copy(_buffer, _readPos, dest, offset, toRead);
        _readPos += toRead;

        if (_readPos >= _writePos)
        {
            _readPos = 0;
            _writePos = 0;
        }

        return toRead;
    }
}
