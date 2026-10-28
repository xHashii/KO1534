namespace Ko1534.Shared.Packets;

/// <summary>
/// Wire protocol opcodes from shared/packets.h and LogInServer/LoginSession.h.
/// </summary>

// Login server opcodes
public static class LogonOpcodes
{
    public const byte LS_VERSION_REQ       = 0x01;
    public const byte LS_DOWNLOADINFO_REQ  = 0x02;
    public const byte LS_CRYPTION          = 0xF2;
    public const byte LS_LOGIN_REQ         = 0xF3;
    public const byte LS_MGAME_LOGIN       = 0xF4;
    public const byte LS_SERVERLIST        = 0xF5;
    public const byte LS_NEWS               = 0xF6;
    public const byte LS_UNKF7              = 0xF7;
    public const int  NUM_LS_OPCODES       = 0xF8;
}

// Game server opcodes
public static class WizOpcodes
{
    public const byte WIZ_LOGIN            = 0x01;
    public const byte WIZ_NEW_CHAR         = 0x02;
    public const byte WIZ_DEL_CHAR         = 0x03;
    public const byte WIZ_SEL_CHAR         = 0x04;
    public const byte WIZ_SEL_NATION       = 0x05;
    public const byte WIZ_MOVE             = 0x06;
    public const byte WIZ_USER_INOUT       = 0x07;
    public const byte WIZ_ATTACK           = 0x08;
    public const byte WIZ_ROTATE           = 0x09;
    public const byte WIZ_NPC_INOUT        = 0x0A;
    public const byte WIZ_NPC_MOVE         = 0x0B;
    public const byte WIZ_ALLCHAR_INFO_REQ = 0x0C;
    public const byte WIZ_GAMESTART        = 0x0D;
    public const byte WIZ_MYINFO           = 0x0E;
    public const byte WIZ_LOGOUT           = 0x0F;
    public const byte WIZ_CHAT             = 0x10;
    public const byte WIZ_VERSION_CHECK    = 0x2B;
    public const byte WIZ_CRYPTION         = 0x2C;
    public const byte WIZ_WEATHER          = 0x40;
    public const byte WIZ_TIME             = 0x41;
    public const byte WIZ_COMPRESS_PACKET  = 0x42;
    public const byte WIZ_SERVER_CHANGE    = 0x46;
    public const byte WIZ_KICKOUT          = 0x51;
}

// Login auth result codes
public static class LoginAuthResult
{
    public const byte AUTH_SUCCESS    = 0x01;
    public const byte AUTH_NOT_FOUND  = 0x02;
    public const byte AUTH_INVALID    = 0x03;
    public const byte AUTH_BANNED     = 0x04;
    public const byte AUTH_IN_GAME    = 0x05;
    public const byte AUTH_ERROR      = 0x06;
    public const byte AUTH_AGREEMENT  = 0x0F;
    public const byte AUTH_FAILED     = 0xFF;
}

// Shared constants from globals.h
public static class KOConstants
{
    public const int MAX_USER      = 3000;
    public const int MAX_ID_SIZE   = 20;
    public const int MAX_PW_SIZE   = 28;
    public const int __VERSION     = 1534;
}
