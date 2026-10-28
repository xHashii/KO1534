using System.Security.Cryptography;

namespace Ko1534.Shared.Crypto;

/// <summary>
/// JvCryption — the KO XOR-based stream cipher from shared/JvCryption.cpp.
/// Encryption and decryption are the same operation (XOR is symmetric).
/// </summary>
public class JvCryption
{
    private ulong _publicKey;
    private ulong _tkey;

    // Version 1534 uses the "else" branch: 0x1257091582190465
    private const ulong PrivateKey = 0x1257091582190465UL;

    public ulong GetPublicKey() => _publicKey;

    /// <summary>
    /// Generate a random non-zero public key.
    /// Returns the public key to send to the client.
    /// </summary>
    public ulong GenerateKey()
    {
        do
        {
            byte[] bytes = RandomNumberGenerator.GetBytes(8);
            _publicKey = BitConverter.ToUInt64(bytes, 0);
        } while (_publicKey == 0);

        return _publicKey;
    }

    /// <summary>
    /// Derive the session key from the public key. Must be called after GenerateKey.
    /// </summary>
    public void Init()
    {
        _tkey = _publicKey ^ PrivateKey;
    }

    /// <summary>
    /// Encrypt/decrypt <paramref name="len"/> bytes in-place.
    /// </summary>
    public void JvEncryptionFast(int len, byte[] dataIn, byte[] dataOut)
    {
        byte[] pkey = BitConverter.GetBytes(_tkey);
        byte lkey = (byte)((len * 157) & 0xFF);
        int rkey = 2157;

        for (int i = 0; i < len; i++)
        {
            byte rsk = (byte)((rkey >> 8) & 0xFF);
            dataOut[i] = (byte)(((dataIn[i] ^ rsk) ^ pkey[i % 8]) ^ lkey);
            rkey *= 2171;
        }
    }

    /// <summary>
    /// Decrypt and verify CRC32. The last 4 bytes of the data must be the CRC32
    /// of the preceding bytes (computed with startVal = -1 = 0xFFFFFFFF).
    /// Returns the data length minus 4 if valid, -1 otherwise.
    /// </summary>
    public int JvDecryptionWithCRC32(int len, byte[] dataIn, byte[] dataOut)
    {
        JvEncryptionFast(len, dataIn, dataOut);

        uint crc = Crc32.Compute(dataOut, len - 4, 0xFFFFFFFF);
        uint expectedCrc = BitConverter.ToUInt32(dataOut, len - 4);

        if (crc == expectedCrc)
            return len - 4;
        else
            return -1;
    }
}
