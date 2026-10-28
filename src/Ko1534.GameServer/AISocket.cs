using System.Net.Sockets;
using Ko1534.Shared.Crypto;
using Ko1534.Shared.Packets;

namespace Ko1534.GameServer;

/// <summary>
/// Socket connection to the AI server (AIServer).
/// Matches the C++ CAISocket class behavior.
/// </summary>
public class AISocket
{
    private readonly TcpClient _client;
    private readonly NetworkStream _stream;
    private readonly GameServerDlg _server;
    private bool _connected = true;
    private bool _hasConnected = false;
    private readonly JvCryption _crypto = new();
    private bool _cryptoEnabled = false;

    public short SocketId { get; private set; }
    public string RemoteIP { get; private set; } = "";

    public AISocket(TcpClient client, short socketId, GameServerDlg server)
    {
        _client = client;
        _server = server;
        _stream = client.GetStream();
        SocketId = socketId;
        RemoteIP = ((System.Net.IPEndPoint)client.Client.RemoteEndPoint!).Address.ToString();
    }

    public async Task StartReadLoop()
    {
        try
        {
            byte[] buffer = new byte[65536];
            while (_connected)
            {
                int bytesRead = await _stream.ReadAsync(buffer, 0, buffer.Length);
                if (bytesRead <= 0)
                {
                    Disconnect();
                    break;
                }

                _hasConnected = true;
                ProcessData(buffer, bytesRead);
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[AISocket] Read error: {ex.Message}");
            Disconnect();
        }
    }

    private void ProcessData(byte[] buffer, int length)
    {
        int pos = 0;
        while (pos + 4 <= length)
        {
            if (buffer[pos] != 0xAA || buffer[pos + 1] != 0x55)
            {
                pos++;
                continue;
            }

            if (pos + 4 > length) return;
            ushort pktLen = (ushort)(buffer[pos + 2] | (buffer[pos + 3] << 8));
            if (pktLen < 1) return;

            int totalLen = pktLen + 4;
            if (pos + totalLen + 2 > length) return;

            byte opcode = buffer[pos + 4];
            byte[] body = new byte[pktLen - 1];
            Array.Copy(buffer, pos + 5, body, 0, pktLen - 1);

            ushort footer = (ushort)(buffer[pos + 4 + pktLen] | (buffer[pos + 4 + pktLen + 1] << 8));
            if (footer != 0xAA55)
            {
                pos += totalLen + 2;
                continue;
            }

            Packet pkt = new Packet(opcode);
            pkt.SetContents(body, body.Length);
            HandlePacket(pkt);

            pos += totalLen + 2;
        }
    }

    private void HandlePacket(Packet pkt)
    {
        _server.HandleAIPacket(this, pkt);
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

    public bool IsReconnecting => _hasConnected;

    public void Disconnect()
    {
        if (!_connected) return;
        _connected = false;
        _server.DisconnectAISocket(SocketId);
        _client.Close();
    }
}
