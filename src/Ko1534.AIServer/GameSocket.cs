using System.Net;
using System.Net.Sockets;
using Ko1534.Shared.Packets;

namespace Ko1534.AIServer;

/// <summary>
/// AI Server socket for communication with Game Servers.
/// Matches the C++ CGameSocket class in AIServer.
/// </summary>
public class AIGameSocket
{
    private readonly TcpClient _client;
    private readonly NetworkStream _stream;
    private readonly AIServerDlg _server;
    private bool _connected = true;
    private readonly byte[] _buffer = new byte[65536];
    private int _remaining = 0;
    private int _readPos = 0;
    private bool _cryptoEnabled = false;

    public short SocketId { get; private set; }
    public string RemoteIP { get; private set; } = "";
    public ushort SessionId { get; private set; }

    public AIGameSocket(TcpClient client, short socketId, AIServerDlg server)
    {
        _client = client;
        _server = server;
        _stream = client.GetStream();
        SocketId = socketId;
        RemoteIP = ((IPEndPoint)client.Client.RemoteEndPoint!).Address.ToString();
    }

    public async Task StartReadLoop()
    {
        try
        {
            while (_connected)
            {
                int bytesRead = await _stream.ReadAsync(_buffer, _readPos, _buffer.Length - _readPos);
                if (bytesRead <= 0)
                {
                    Disconnect();
                    break;
                }

                _readPos += bytesRead;
                ProcessReadBuffer();
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[AIGameSocket] Read error from {RemoteIP}: {ex.Message}");
            Disconnect();
        }
    }

    private void ProcessReadBuffer()
    {
        while (_readPos >= 5)
        {
            if (_buffer[_readPos - _remaining - 4] != 0xAA || _buffer[_readPos - _remaining - 3] != 0x55)
            {
                // Find header
                int start = Array.IndexOf(_buffer, (byte)0xAA, Math.Max(0, _readPos - _remaining - 10), Math.Min(_buffer.Length, _readPos));
                if (start < 0) { _readPos = 0; return; }
                _readPos = start;
                continue;
            }

            // We need at least 5 bytes: header(2) + len(2) + opcode(1)
            if (_readPos < 5) return;

            ushort pktLen = (ushort)(_buffer[_readPos + 2] | (_buffer[_readPos + 3] << 8));
            if (pktLen < 1)
            {
                _readPos++;
                continue;
            }

            int totalLen = pktLen + 4; // header + len + opcode + body
            if (_readPos < totalLen + 2) return; // need footer too

            // Check footer
            ushort footer = (ushort)(_buffer[_readPos + totalLen] | (_buffer[_readPos + totalLen + 1] << 8));
            if (footer != 0xAA55)
            {
                _readPos++;
                continue;
            }

            byte opcode = _buffer[_readPos + 4];
            byte[] body = new byte[pktLen - 1];
            Array.Copy(_buffer, _readPos + 5, body, 0, pktLen - 1);

            Packet pkt = new Packet(opcode);
            pkt.SetContents(body, body.Length);

            HandlePacket(pkt);

            _readPos += totalLen + 2;
            _remaining = 0;
        }

        // Compact buffer
        if (_readPos > 0)
        {
            Array.Copy(_buffer, _readPos, _buffer, 0, _buffer.Length - _readPos);
            _readPos = 0;
        }
    }

    private void HandlePacket(Packet pkt)
    {
        _server.HandleGamePacket(this, pkt);
    }

    public void Send(Packet pkt)
    {
        if (!_connected) return;

        byte[] body = pkt.GetContents();
        int totalLen = body.Length + 1;

        byte[] frame = new byte[totalLen + 6];
        frame[0] = 0xAA;
        frame[1] = 0x55;
        frame[2] = (byte)(totalLen & 0xFF);
        frame[3] = (byte)((totalLen >> 8) & 0xFF);
        frame[4] = pkt.Opcode;
        Array.Copy(body, 0, frame, 5, body.Length);
        frame[5 + body.Length] = 0x55;
        frame[6 + body.Length] = 0xAA;

        _stream.Write(frame, 0, frame.Length);
    }

    public void Disconnect()
    {
        if (!_connected) return;
        _connected = false;
        _server.DisconnectSocket(SocketId);
        _client.Close();
    }
}
