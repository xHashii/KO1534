namespace Ko1534.AIServer;

/// <summary>
/// NPC state for AI processing.
/// </summary>
public enum NpcState : byte
{
    Standing = 0,
    Live = 1,
    Dead = 2,
    Moving = 3,
    Attacking = 4,
    Fainting = 5,
    Healing = 6,
    Casting = 7,
    Back = 8,
    Sleeping = 9,
    Tracing = 10,
}

/// <summary>
/// NPC type classification.
/// </summary>
public enum NpcType : byte
{
    Monster = 0,
    Boss = 1,
    DungeonMonster = 2,
    Healer = 3,
    Guard = 4,
    Store = 5,
    Merchant = 6,
    Event = 7,
    Gate = 8,
    Object = 9,
}

/// <summary>
/// Nation affiliation.
/// </summary>
public enum Nation : byte
{
    None = 0,
    Karus = 1,
    Elmorad = 2,
}

/// <summary>
/// Constants from AIServer/Define.h.
/// </summary>
public static class AIConstants
{
    // Communication
    public const int MaxSocket = 100;
    public const int MaxPathLine = 100;

    // Map
    public const int ViewDist = 48;
    public const int TileSize = 4;
    public const int CellSize = 4;

    // NPC
    public const int NpcNum = 250;
    public const int MaxDungeonBossMonster = 250;
    public const int NpcPassive = 150;
    public const int NpcMaxMoveRange = 100;

    // Types
    public const int UserBand = 0;
    public const int NpcBand = 10000;
    public const int InvalidBand = 30000;

    // Item
    public const int TypeMoney = 0;
    public const int TypeItem = 1;

    // Durability
    public const int Attack = 0x01;
    public const int Defence = 0x02;

    // Directions
    public const int DirDown = 0;
    public const int DirDownLeft = 1;
    public const int DirLeft = 2;
    public const int DirUpLeft = 3;
    public const int DirUp = 4;
    public const int DirUpRight = 5;
    public const int DirRight = 6;
    public const int DirDownRight = 7;

    // Attack types
    public const int DirectAttack = 0;
    public const int LongAttack = 1;
    public const int MagicAttack = 2;
    public const int DurationAttack = 3;

    // Object types
    public const int NormalObject = 0;
    public const int SpecialObject = 1;

    // Battle zone
    public const byte BattleZoneOpen = 0x00;
    public const byte BattleZoneClose = 0x01;
    public const byte DeclareWinner = 0x02;

    // Upgrade results
    public const byte GreatSuccess = 0x01;
    public const byte Success = 0x02;
    public const byte Normal = 0x03;
    public const byte Fail = 0x04;

    // NPC InOut
    public const byte NpcIn = 0x01;
    public const byte NpcOut = 0x02;

    // AI User status
    public const byte AiUserDead = 0x00;
    public const byte AiUserLive = 0x01;

    // Money SID
    public const int TypeMoneySid = 900000000;

    // AI Server opcodes (from packets.h AG_* defines)
    public const byte AG_LOGIN = 0x01;
    public const byte AG_CHECK_ALIVE = 0x02;
    public const byte AG_SERVER_INFO = 0x03;
    public const byte AG_NPC_INFO_ALL = 0x04;
    public const byte AG_NPC_MOVE_RESULT = 0x05;
    public const byte AG_NPC_ATTACK = 0x06;
    public const byte AG_NPC_INFO = 0x07;
    public const byte AG_NPC_REGION_UPDATE = 0x08;
    public const byte AG_USER_EXP = 0x09;
    public const byte AG_SYSTEM_MSG = 0x0A;
    public const byte AG_NPC_GIVE_ITEM = 0x0B;
    public const byte AG_USER_FAIL = 0x0C;
    public const byte AG_GATE_DESTORY = 0x0D;
    public const byte AG_NPC_DEAD = 0x0E;
    public const byte AG_NPC_INOUT = 0x0F;
    public const byte AG_BATTLE_EVENT = 0x10;
    public const byte AG_NPC_EVENT_ITEM = 0x11;
    public const byte AG_GATE_OPEN = 0x12;
    public const byte AG_COMPRESSED = 0x13;
    public const byte AG_NPC_HP_CHANGE = 0x14;
    public const byte AG_NPC_UPDATE_INFO = 0x15;
    public const byte AG_NPC_SPAWN_REQ = 0x16;
    public const byte AG_NPC_KILL_REQ = 0x17;
    public const byte AG_NPC_UPDATE = 0x18;
    public const byte AG_USER_INFO_ALL = 0x19;
    public const byte AG_PARTY_INFO_ALL = 0x1A;
    public const byte AG_TIME_WEATHER = 0x1B;
}
