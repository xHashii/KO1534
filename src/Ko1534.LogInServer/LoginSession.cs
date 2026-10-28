using System.Net.Sockets;
using System.Security.Cryptography;
using System.Text;
using Ko1534.Shared.Crypto;
using Ko1534.Shared.Logging;
using Ko1534.Shared.Packets;

namespace Ko1534.LogInServer;

/// <summary>
/// Handles a single client session on the login server.
/// Matches the C++ LoginSession class behavior.
///
/// Opcodes (from C++ LoginSession.h):
///   0x01 = LS_VERSION_REQ
///   0x02 = LS_DOWNLOADINFO_REQ
///   0xF2 = LS_CRYPTION
///   0xF3 = LS_LOGIN_REQ
///   0xF5 = LS_SERVERLIST
///   0xF6 = LS_NEWS
///   0xF7 = LS_UNKF7
///
/// Crypto flow (from C++ KOSocket.cpp / JvCryption.cpp):
///   1. Client sends CRYPTION (0xF2) — unencrypted
///   2. Server generates key, sends key response (uint64) — unencrypted
///   3. Server calls EnableCrypto() — all subsequent packets are encrypted
///   4. Client → Server encrypted format: seq(u32) + opcode+body + crc32(u32)
///   5. Server → Client encrypted format: 0x1efc(u16) + seq(u16) + 0(1) + opcode+body
///   6. Encryption: JvEncryptionFast — XOR with (rkey>>8) ^ pkey[i%8] ^ lkey
///   7. Decryption: JvDecryptionWithCRC32 — decrypt + verify CRC32 of first len-4 bytes
/// </summary>
public class LoginSession
{
    private readonly LoginServer _server;
    private readonly TcpClient _client;
    private readonly NetworkStream _stream;
    private bool _disposed = false;

    // ── Crypto state (from C++ KOSocket) ───────────────────────────────
    private readonly JvCryption _crypto = new();
    private uint _sequence = 0;
    private bool _usingCrypto = false;

    public LoginSession(TcpClient client, LoginServer server)
    {
        Logger.Debug($"LoginSession constructor: client={client.Client.RemoteEndPoint}");
        Logger.Debug("LoginSession: creating NetworkStream...");
        _client = client;
        _server = server;
        _stream = client.GetStream();
        Logger.Debug("LoginSession constructor: complete");
    }

    public void Start()
    {
        Logger.Debug($"Session.Start() called from {_client.Client.RemoteEndPoint}");
        Logger.Debug("Session.Start(): launching read loop...");
        _ = ReadLoopAsync();
        Logger.Debug("Session.Start(): read loop launched (fire-and-forget)");
    }

    private async Task ReadLoopAsync()
    {
        Logger.Debug("── ReadLoopAsync() begin ──");
        try
        {
            while (true)
            {
                // 1. Read frame header: 0xAA 0x55
                Logger.Debug("  ReadLoop: reading frame header...");
                var header = new byte[2];
                await ReadExactAsync(header, 0, 2);
                Logger.Debug($"  ReadLoop: header bytes = 0x{Convert.ToHexString(header)}");

                if (header[0] != 0xAA || header[1] != 0x55)
                {
                    Logger.Debug($"  ERROR: Invalid frame header: 0x{Convert.ToHexString(header)} (expected 0xAA55)");
                    Disconnect();
                    break;
                }

                // 2. Read length (uint16 LE)
                Logger.Debug("  ReadLoop: reading packet length...");
                var lenBytes = new byte[2];
                await ReadExactAsync(lenBytes, 0, 2);
                ushort packetLen = BitConverter.ToUInt16(lenBytes, 0);
                Logger.Debug($"  ReadLoop: packet length = {packetLen}");

                // 3. Read payload
                Logger.Debug($"  ReadLoop: reading payload ({packetLen} bytes)...");
                var payload = new byte[packetLen];
                await ReadExactAsync(payload, 0, packetLen);
                Logger.Debug("  ReadLoop: payload hex:");
                DumpHex(payload);

                // 4. Read frame footer: 0x55 0xAA
                Logger.Debug("  ReadLoop: reading frame footer...");
                var footer = new byte[2];
                await ReadExactAsync(footer, 0, 2);
                Logger.Debug($"  ReadLoop: footer bytes = 0x{Convert.ToHexString(footer)}");
                if (footer[0] != 0x55 || footer[1] != 0xAA)
                {
                    Logger.Debug($"  ERROR: Invalid frame footer: 0x{Convert.ToHexString(footer)} (expected 0x55AA)");
                    Disconnect();
                    break;
                }

                // 5. Parse opcode and body
                Logger.Debug($"  ReadLoop: parsing opcode and body (crypto={_usingCrypto})...");
                if (payload.Length < 1)
                {
                    Logger.Debug("  ERROR: Payload too short (no opcode)");
                    Disconnect();
                    break;
                }

                byte opcode;
                byte[] body;

                if (_usingCrypto)
                {
                    // ── Decrypt incoming packet ───────────────────────────
                    // C++ DecryptPacket: checks m_remaining >= 4, then
                    // JvDecryptionWithCRC32, then ++m_sequence == seq(u32)
                    // Decrypted format: seq(4) + opcode+body + crc32(4)

                    if (payload.Length < 4)
                    {
                        Logger.Debug($"  ERROR: Encrypted payload too short ({payload.Length} < 4)");
                        Disconnect();
                        break;
                    }

                    Logger.Debug($"  ReadLoop: decrypting ({payload.Length} bytes)...");
                    int decryptedLen = _crypto.JvDecryptionWithCRC32(payload.Length, payload, payload);
                    Logger.Debug($"  ReadLoop: decryption result = {decryptedLen}");

                    if (decryptedLen < 0)
                    {
                        Logger.Debug("  ERROR: CRC32 check failed");
                        Disconnect();
                        break;
                    }

                    // Check sequence ID (only if CRC32 passed)
                    uint expectedSeq = ++_sequence;
                    uint actualSeq = BitConverter.ToUInt32(payload, 0);
                    Logger.Debug($"  ReadLoop: seq check: expected={expectedSeq}, actual={actualSeq}");
                    if (expectedSeq != actualSeq)
                    {
                        Logger.Debug("  ERROR: Sequence ID mismatch");
                        Disconnect();
                        break;
                    }

                    // Extract opcode and body
                    // Format: seq(4) + opcode(1) + body(bodySize) + crc32(4)
                    // Minimum: 4 + 1 + 0 + 4 = 9 bytes
                    if (payload.Length < 9)
                    {
                        Logger.Debug($"  ERROR: Encrypted payload too short for valid packet ({payload.Length} < 9)");
                        Disconnect();
                        break;
                    }

                    int bodyLen = payload.Length - 9;
                    opcode = payload[4];
                    body = new byte[bodyLen];
                    Array.Copy(payload, 5, body, 0, bodyLen);

                    Logger.Debug($"  ReadLoop: decrypted opcode = 0x{opcode:X2}");
                }
                else
                {
                    // ── Unencrypted packet ─────────────────────────────────
                    opcode = payload[0];
                    body = new byte[payload.Length - 1];
                    Array.Copy(payload, 1, body, 0, body.Length);

                    Logger.Debug($"  ReadLoop: opcode = 0x{opcode:X2}");
                }

                Logger.Debug($"  ReadLoop: body length = {body.Length}");
                Logger.Debug("  ReadLoop: body hex:");
                DumpHex(body);

                // 6. Dispatch
                Logger.Debug("  ReadLoop: dispatching to HandlePacketAsync...");
                await HandlePacketAsync(opcode, body);
                Logger.Debug("  ReadLoop: HandlePacketAsync complete");
            }
        }
        catch (IOException ex)
        {
            Logger.Debug($"  IO error in read loop: {ex.Message}");
            Disconnect();
        }
        catch (ObjectDisposedException)
        {
            Logger.Debug("  Stream was disposed (client disconnected).");
        }
        catch (Exception ex)
        {
            Logger.Debug($"  UNEXPECTED ERROR in read loop: {ex.GetType().Name}: {ex.Message}");
            Logger.Debug($"  Stack trace: {ex.StackTrace}");
            Disconnect();
        }

        Logger.Debug("── ReadLoopAsync() end ──");
    }

    private async Task ReadExactAsync(byte[] buffer, int offset, int count)
    {
        int totalRead = 0;
        while (totalRead < count)
        {
            Logger.Debug($"    ReadExactAsync: reading {count - totalRead} more bytes (offset={offset + totalRead})...");
            int read = await _stream.ReadAsync(buffer, offset + totalRead, count - totalRead);
            Logger.Debug($"    ReadExactAsync: read {read} bytes");
            if (read == 0)
            {
                Logger.Debug("    ReadExactAsync: connection closed by remote");
                throw new IOException("Connection closed by remote");
            }
            totalRead += read;
        }
        Logger.Debug($"    ReadExactAsync: {totalRead} bytes total read");
    }

    private async Task HandlePacketAsync(byte opcode, byte[] body)
    {
        try
        {
            switch (opcode)
            {
                case 0x01: // LS_VERSION_REQ
                    Logger.Debug("  HandlePacketAsync: VERSION_REQ (0x01)");
                    await HandleVersionAsync(body);
                    break;
                case 0x02: // LS_DOWNLOADINFO_REQ
                    Logger.Debug("  HandlePacketAsync: DOWNLOADINFO_REQ (0x02)");
                    await HandlePatchesAsync(body);
                    break;
                case 0xF3: // LS_LOGIN_REQ
                    Logger.Debug("  HandlePacketAsync: LOGIN_REQ (0xF3)");
                    await HandleLoginAsync(body);
                    break;
                case 0xF5: // LS_SERVERLIST
                    Logger.Debug("  HandlePacketAsync: SERVERLIST (0xF5)");
                    await HandleServerlistAsync(body);
                    break;
                case 0xF6: // LS_NEWS
                    Logger.Debug("  HandlePacketAsync: NEWS (0xF6)");
                    await HandleNewsAsync(body);
                    break;
                case 0xF2: // LS_CRYPTION
                    Logger.Debug("  HandlePacketAsync: CRYPTION (0xF2)");
                    await HandleSetEncryptionPublicKeyAsync(body);
                    break;
                case 0xF7: // LS_UNKF7
                    Logger.Debug("  HandlePacketAsync: UNKF7 (0xF7)");
                    await HandleUnkF7Async(body);
                    break;
                default:
                    Logger.Debug($"  HandlePacketAsync: UNKNOWN opcode 0x{opcode:X2} — ignoring");
                    break;
            }
        }
        catch (Exception ex)
        {
            Logger.Debug($"  ERROR handling packet 0x{opcode:X2}: {ex.GetType().Name}: {ex.Message}");
            Logger.Debug($"  Stack trace: {ex.StackTrace}");
            Disconnect();
        }
    }

    // ── VERSION (0x01) ──────────────────────────────────────────────────
    // C++: Packet result(pkt.GetOpcode()); result << g_pMain->GetVersion();

    private async Task HandleVersionAsync(byte[] body)
    {
        Logger.Debug($"  HandleVersionAsync: body={BitConverter.ToString(body)}");
        Logger.Debug("  HandleVersionAsync: sending version response...");
        Logger.Debug($"  HandleVersionAsync: server version = {_server.LastVersion}");
        var result = new Packet(0x01); // LS_VERSION_REQ
        result.AppendInt16(_server.LastVersion);
        await SendAsync(result);
    }

    // ── PATCHES (0x02) ──────────────────────────────────────────────────
    // C++: Packet result(pkt.GetOpcode());
    //      result << FTPUrl << FTPPath;
    //      result << uint16(downloadset.size());
    //      foreach: result << filename;
    // NOTE: NO server version in response! NO version/history per patch!

    private async Task HandlePatchesAsync(byte[] body)
    {
        Logger.Debug($"  HandlePatchesAsync: body={BitConverter.ToString(body)}");

        // Read client's current version (first 2 bytes of body)
        short clientVersion = BitConverter.ToInt16(body, 0);
        Logger.Debug($"  HandlePatchesAsync: client version = {clientVersion}");
        Logger.Debug($"  HandlePatchesAsync: server latest version = {_server.LastVersion}");

        // Filter patches — only include versions the client doesn't have
        var neededPatches = new List<string>();
        foreach (var (filename, (version, historyVersion)) in _server.PatchList)
        {
            if (version > clientVersion)
            {
                Logger.Debug($"    Patch needed: {filename} v={version} (client has {clientVersion})");
                neededPatches.Add(filename);
            }
            else
            {
                Logger.Debug($"    Patch not needed: {filename} v={version} (client already has {clientVersion})");
            }
        }

        Logger.Debug("  HandlePatchesAsync: sending patches response...");
        Logger.Debug($"  HandlePatchesAsync: FTP URL = {_server.FtpUrl}");
        Logger.Debug($"  HandlePatchesAsync: FTP Path = {_server.FtpPath}");
        Logger.Debug($"  HandlePatchesAsync: needed patch count = {neededPatches.Count}");

        var result = new Packet(0x02); // LS_DOWNLOADINFO_REQ
        result.AppendString(_server.FtpUrl);
        result.AppendString(_server.FtpPath);
        result.AppendUInt16((ushort)neededPatches.Count);

        foreach (var filename in neededPatches)
        {
            Logger.Debug($"    Patch: {filename}");
            result.AppendString(filename);
        }

        await SendAsync(result);
    }

    // ── SERVERLIST (0xF5) ───────────────────────────────────────────────
    // C++: Packet result(pkt.GetOpcode());
    //      uint16 echo; pkt >> echo; result << echo;
    //      g_pMain->GetServerList(result);

    private async Task HandleServerlistAsync(byte[] body)
    {
        Logger.Debug($"  HandleServerlistAsync: body={BitConverter.ToString(body)}");

        // Read echo (uint16) from request
        short echo = BitConverter.ToInt16(body, 0);
        Logger.Debug($"  HandleServerlistAsync: echo = {echo}");

        Logger.Debug("  HandleServerlistAsync: sending server list response...");
        var result = new Packet(0xF5); // LS_SERVERLIST
        result.AppendInt16(echo);
        _server.GetServerList(result);
        Logger.Debug($"  HandleServerlistAsync: response size={result.UsedSize} bytes");
        Logger.Debug("  HandleServerlistAsync: response hex:");
        DumpHex(result.Storage[..result.UsedSize]);
        await SendAsync(result);
    }

    // ── NEWS (0xF6) ─────────────────────────────────────────────────────
    // C++: Packet result(pkt.GetOpcode());
    //      if (pNews->Size) { result << "Login Notice" << uint16(pNews->Size); result.append(pNews->Content, pNews->Size); }
    //      else { result << "Login Notice" << "<empty>"; }

    private async Task HandleNewsAsync(byte[] body)
    {
        Logger.Debug($"  HandleNewsAsync: body={BitConverter.ToString(body)}");

        var result = new Packet(0xF6); // LS_NEWS
        result.AppendString("Login Notice");

        var newsBytes = _server.GetNewsBytes();
        if (newsBytes != null && newsBytes.Length > 0)
        {
            Logger.Debug($"  HandleNewsAsync: news size = {newsBytes.Length} bytes");
            Logger.Debug($"  HandleNewsAsync: news content: \"{Encoding.Latin1.GetString(newsBytes)}\"");
            result.AppendUInt16((ushort)newsBytes.Length);
            result.AppendRaw(newsBytes, newsBytes.Length);
        }
        else
        {
            Logger.Debug("  HandleNewsAsync: no news — sending <empty>");
            result.AppendString("<empty>");
        }

        await SendAsync(result);
    }

    // ── LOGIN (0xF3) ─────────────────────────────────────────────────────
    // C++: Packet result(pkt.GetOpcode());
    //      pkt >> account >> password;  (NO serial!)
    //      resultCode = AccountLogin(account, password);
    //      result << uint8(resultCode);
    //      if (resultCode == AUTH_SUCCESS) { result << AccountPremium(account); result << account; }
    //
    // Result codes:
    //   AUTH_SUCCESS    = 0x01
    //   AUTH_NOT_FOUND  = 0x02
    //   AUTH_INVALID    = 0x03
    //   AUTH_BANNED     = 0x04
    //   AUTH_IN_GAME    = 0x05
    //   AUTH_ERROR      = 0x06

    private async Task HandleLoginAsync(byte[] body)
    {
        Logger.Debug($"  HandleLoginAsync: body length = {body.Length}");
        Logger.Debug("  HandleLoginAsync: body hex:");
        DumpHex(body);

        // C++ reads: pkt >> account >> password (NO serial!)
        var reader = new PacketReader(body);
        string acc = reader.ReadString();
        string password = reader.ReadString();
        Logger.Debug($"  HandleLoginAsync: account = \"{acc}\"");
        Logger.Debug($"  HandleLoginAsync: password = \"{password}\"");

        var repo = _server.GetRepository();
        byte resultCode = await repo.AccountLoginAsync(acc, password);

        Logger.Debug($"  HandleLoginAsync: result code = 0x{resultCode:X2}");

        var result = new Packet(0xF3); // LS_LOGIN_REQ
        result.AppendByte(resultCode);

        if (resultCode == 0x01) // AUTH_SUCCESS
        {
            Logger.Debug("  HandleLoginAsync: SUCCESS — loading premium info...");
            short premiumHours = await repo.AccountPremiumAsync(acc);
            Logger.Debug($"  HandleLoginAsync: premium hours = {premiumHours}");
            result.AppendInt16(premiumHours);
            result.AppendString(acc);
        }

        Logger.Debug("  HandleLoginAsync: response hex:");
        DumpHex(result.Storage[..result.UsedSize]);
        await SendAsync(result);
    }

    // ── CRYPTION (0xF2) ──────────────────────────────────────────────────
    // C++: Packet result(pkt.GetOpcode()); result << m_crypto.GenerateKey();
    //      Send(&result); EnableCrypto();
    // Key response is UNENCRYPTED — crypto is enabled AFTER sending.

    private async Task HandleSetEncryptionPublicKeyAsync(byte[] body)
    {
        Logger.Debug($"  HandleSetEncryptionPublicKeyAsync: body={BitConverter.ToString(body)}");
        Logger.Debug("  HandleSetEncryptionPublicKeyAsync: generating crypto key...");

        ulong key = _crypto.GenerateKey();
        Logger.Debug($"  HandleSetEncryptionPublicKeyAsync: generated key = 0x{key:X16}");

        _crypto.Init();
        Logger.Debug("  HandleSetEncryptionPublicKeyAsync: tkey derived (m_tkey = public_key ^ private_key)");

        var result = new Packet(0xF2); // LS_CRYPTION
        result.AppendUInt64(key);
        await SendAsync(result);

        Logger.Debug("  HandleSetEncryptionPublicKeyAsync: key sent, enabling crypto...");
        EnableCrypto();
    }

    private void EnableCrypto()
    {
        _usingCrypto = true;
        Logger.Debug("  EnableCrypto: crypto now enabled for all subsequent packets");
    }

    // ── UNKF7 (0xF7) ──────────────────────────────────────────────────────
    // C++: Packet result(pkt.GetOpcode()); result << uint16(0);

    private async Task HandleUnkF7Async(byte[] body)
    {
        Logger.Debug($"  HandleUnkF7Async: body={BitConverter.ToString(body)}");
        Logger.Debug("  HandleUnkF7Async: sending uint16(0) response...");
        var result = new Packet(0xF7); // LS_UNKF7
        result.AppendUInt16(0);
        await SendAsync(result);
    }

    // ── SEND ────────────────────────────────────────────────────────────
    // C++ Send (KOSocket.cpp):
    //   if crypto disabled:
    //     len = bodySize + 1
    //     out_stream = opcode(1) + body(bodySize)
    //   if crypto enabled:
    //     len = bodySize + 1 + 5 = bodySize + 6
    //     out_stream = 0x1efc(u16) + seq(u16) + 0(1) + opcode(1) + body(bodySize)
    //     JvEncryptionFast(len, out_stream, out_stream)
    //   Frame: AA 55 | len(u16 LE) | out_stream | 55 AA

    private async Task SendAsync(Packet packet)
    {
        Logger.Debug("  SendAsync: building frame...");
        Logger.Debug($"  SendAsync: opcode=0x{packet.Opcode:X2}, bodyLen={packet.UsedSize}, crypto={_usingCrypto}");

        byte[] payload;
        int payloadLen;

        if (_usingCrypto)
        {
            // Encrypted outgoing packet
            // Format: 0x1efc(2) + seq(u16,2) + 0(1) + opcode(1) + body(bodySize)
            payloadLen = packet.UsedSize + 1 + 5; // bodySize + 6
            payload = new byte[payloadLen];

            // 0x1efc as uint16 LE
            payload[0] = 0xFC;
            payload[1] = 0x1E;

            // sequence as uint16 LE (lower 16 bits of _sequence)
            payload[2] = (byte)(_sequence & 0xFF);
            payload[3] = (byte)((_sequence >> 8) & 0xFF);

            // 0
            payload[4] = 0;

            // opcode
            payload[5] = packet.Opcode;

            // body
            if (packet.UsedSize > 0)
            {
                Array.Copy(packet.Storage, 0, payload, 6, packet.UsedSize);
            }

            Logger.Debug($"  SendAsync: pre-encrypt payload hex ({payloadLen} bytes):");
            DumpHex(payload);

            _crypto.JvEncryptionFast(payloadLen, payload, payload);

            Logger.Debug("  SendAsync: post-encrypt payload hex:");
            DumpHex(payload);
        }
        else
        {
            // Unencrypted packet
            payloadLen = packet.UsedSize + 1;
            payload = new byte[payloadLen];
            payload[0] = packet.Opcode;
            if (packet.UsedSize > 0)
            {
                Array.Copy(packet.Storage, 0, payload, 1, packet.UsedSize);
            }

            Logger.Debug($"  SendAsync: payload hex ({payloadLen} bytes):");
            DumpHex(payload);
        }

        var frame = new List<byte>();
        frame.Add(0xAA);
        frame.Add(0x55);
        frame.AddRange(BitConverter.GetBytes((ushort)payloadLen));
        frame.AddRange(payload);
        frame.Add(0x55);
        frame.Add(0xAA);

        Logger.Debug($"  SendAsync: frame hex ({frame.Count} bytes):");
        DumpHex(frame.ToArray());
        Logger.Debug($"  SendAsync: writing {frame.Count} bytes to stream...");

        await _stream.WriteAsync(frame.ToArray(), 0, frame.Count);
        Logger.Debug($"  SendAsync: write complete ({frame.Count} bytes)");
    }

    // ── DISCONNECT ──────────────────────────────────────────────────────

    private void Disconnect()
    {
        Logger.Debug($"  DISCONNECT: closing session to {_client.Client.RemoteEndPoint}");
        if (!_disposed)
        {
            _disposed = true;
            try
            {
                Logger.Debug("  DISCONNECT: shutting down socket...");
                _stream.Close();
                _client.Close();
                Logger.Debug("  DISCONNECT: socket closed");
            }
            catch (Exception ex)
            {
                Logger.Debug($"  DISCONNECT: error closing socket: {ex.Message}");
            }
        }
        Logger.Debug("  DISCONNECT: done");
    }

    // ── HEX DUMP ────────────────────────────────────────────────────────

    private static void DumpHex(byte[] data)
    {
        for (int i = 0; i < data.Length; i += 16)
        {
            var hex = new char[32];
            var ascii = new char[16];
            for (int j = 0; j < 16; j++)
            {
                if (i + j < data.Length)
                {
                    byte b = data[i + j];
                    hex[j * 2] = (char)(((b >> 4) < 10 ? '0' + (b >> 4) : 'A' + (b >> 4) - 10));
                    hex[j * 2 + 1] = (char)(((b & 0x0F) < 10 ? '0' + (b & 0x0F) : 'A' + (b & 0x0F) - 10));
                    ascii[j] = (b >= 32 && b < 127) ? (char)b : '.';
                }
                else
                {
                    hex[j * 2] = ' ';
                    hex[j * 2 + 1] = ' ';
                    ascii[j] = ' ';
                }
            }
            Logger.Debug($"    {i:D4}: {new string(hex)}  {new string(ascii)}");
        }
    }
}
