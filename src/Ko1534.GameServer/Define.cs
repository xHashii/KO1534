namespace Ko1534.GameServer;

/// <summary>
/// Constants from GameServer/Define.h and shared/globals.h.
/// </summary>
public static class GSConstants
{
    // Configuration
    public const string GameServerIni = "./GameServer.ini";

    // Sockets
    public const int UdpPort = 8888;
    public const int ClientSockSize = 100;

    // Max items
    public const int MaxNpcSize = 30;
    public const int MaxType3Repeat = 40;
    public const int MaxType4Buff = 50;
    public const int MaxItem = 28;
    public const int NpcHaveItemList = 6;

    // Player
    public const int MaxClass = 26;
    public const int MaxLevel = 83;
    public const int MaxPlayerHp = 14000;
    public const int MaxDamage = 32000;

    // Messages
    public const int MaxMessageEvent = 12;
    public const int MaxTempleEventRoom = 50;

    // BBS
    public const int MaxBbsPage = 22;
    public const int MaxBbsMessage = 40;
    public const int MaxBbsTitle = 20;
    public const int MaxBbsPost = 500;

    // Zones
    public const int ZoneKarus = 1;
    public const int ZoneElmorad = 2;
    public const int ZoneKarusEslant = 11;
    public const int ZoneElmoradEslant = 12;
    public const int ZoneMoradon = 21;
    public const int ZoneDelos = 30;
    public const int ZoneBifrost = 31;
    public const int ZoneDesperationAbyss = 32;
    public const int ZoneHellAbyss = 33;
    public const int ZoneDragonCave = 34;
    public const int ZoneDelosCastellan = 35;
    public const int ZoneArena = 48;
    public const int ZoneForgottenTemple = 55;
    public const int ZoneLostTemple = 56;

    public const int ZoneBattleBase = 60;
    public const int ZoneBattle1 = 61;
    public const int ZoneBattle2 = 62;
    public const int ZoneBattle3 = 63;
    public const int ZoneBattle4 = 64;
    public const int ZoneBattle5 = 65;
    public const int ZoneBattle6 = 66;
    public const int ZoneSnowBattle = 69;
    public const int ZoneRonarckLand = 71;
    public const int ZoneAdream = 72;
    public const int ZoneKrowazDominion = 75;
    public const int ZoneStone1 = 81;
    public const int ZoneStone2 = 82;
    public const int ZoneStone3 = 83;
    public const int ZoneBorderDefenseWar = 84;
    public const int ZoneChaosDungeon = 85;
    public const int ZoneJuraidMountain = 87;
    public const int ZonePrison = 92;
    public const int ZoneWinnerCastle = 97;
    public const int ZoneWinnerCastle2 = 98;

    // Zone levels
    public const int MinLevelBorderDefense = 20;
    public const int MinLevelNationBase = 35;
    public const int MinLevelEslant = 60;
    public const int MinLevelBifrost = 70;
    public const int MinLevelWarZone = 35;
    public const int MinLevelJuraidMountain = 70;
    public const int MinLevelKrowazDominion = 70;

    // Battle zones
    public const int MaxBattleZoneUsers = 150;
    public const int WarTimeCount = 3;
    public const int WarZoneCount = 3;
    public const int WarDayCount = 7;

    // Battle types
    public const int NoBattle = 0;
    public const int NationBattle = 1;
    public const int SnowBattle = 2;
    public const int SiegeBattle = 3;
    public const int ClanBattle = 4;

    // Battle zone announcements
    public const byte BattleZoneOpen = 0x00;
    public const byte BattleZoneClose = 0x01;
    public const byte DeclareWinner = 0x02;
    public const byte DeclareLoser = 0x03;
    public const byte DeclareBan = 0x04;
    public const byte KarusCaptainNotify = 0x05;
    public const byte ElmoradCaptainNotify = 0x06;
    public const byte KarusCaptainDepriveNotify = 0x07;
    public const byte ElmoradCaptainDepriveNotify = 0x08;
    public const byte SnowBattleZoneOpen = 0x09;
    public const byte UnderAttackNotify = 0x10;
    public const byte DeclareBattleZoneStatus = 0x11;
    public const byte DeclareBattleMonumentStatus = 0x12;
    public const byte DeclareNationMonumentStatus = 0x13;
    public const byte DeclareNationRewardStatus = 0x14;
    public const byte SnowBattleZoneClose = 0x15;
    public const byte SnowBan = 0x16;

    // Item slots
    public const byte RightEar = 0;
    public const byte Head = 1;
    public const byte LeftEar = 2;
    public const byte Neck = 3;
    public const byte Breast = 4;
    public const byte Shoulder = 5;
    public const byte RightHand = 6;
    public const byte Waist = 7;
    public const byte LeftHand = 8;
    public const byte RightRing = 9;
    public const byte Leg = 10;
    public const byte LeftRing = 11;
    public const byte Glove = 12;
    public const byte Foot = 13;
    public const byte Reserved = 14;
    public const byte SlotMax = 14;
    public const byte HaveMax = 28;
    public const byte CospMax = 8;
    public const byte MbagMax = 12;
    public const int MbagTotal = 24;

    // Inventory offsets
    public const int InventoryInvent = 14;
    public const int InventoryCosp = 42;
    public const int InventoryMbag = 50;
    public const int InventoryMbag1 = 50;
    public const int InventoryMbag2 = 62;
    public const int InventoryTotal = 74;

    // Warehouse
    public const int WarehouseMax = 192;
    public const int VipWarehouseMax = 48;
    public const int MaxMerchItems = 12;

    // Items
    public const uint ItemContRecovery = 800370000;
    public const uint ItemScrollOfIdentity = 800032000;
    public const uint ItemClanNameScroll = 800086000;
    public const uint ItemNationTransfer = 800360000;
    public const uint ItemGenderChange = 810594000;
    public const uint ItemJobChange = 800570000;
    public const uint ItemMakeOver = 810340000;
    public const uint ItemMeatDumbling = 508216000;
    public const uint ItemEventPartici = 930046000;

    // Monument NPC IDs
    public const int MonumentKarusSpid = 14003;
    public const int MonumentElmoradSpid = 14004;
    public const int MonumentEnemySpid = 14005;

    // Quest
    public const int StarterSeedQuest = 500;
    public const int QuestArraySize = 3888;
    public const int QuestLimit = 1296;

    // Speed hack
    public const int HackShieldGuardTimeSecond = 180;

    // Concurrent users
    public const int PlayTimeIdle = 300;
    public const int BlinkTime = 10;
    public const int ClanSummonTime = 180;

    // Reload intervals
    public const int ReloadKnightsAndUserRating = 30; // minutes
    public const int ReloadGameUpdate = 10; // seconds

    // AI Server opcodes
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

    // Default ports
    public const int DefaultPort = 15001;
    public const int DefaultGameMaxLevel = 80;

    // View distance for region-based packet distribution
    public const int ViewDistance = 48;

    // Max sockets
    public const int MaxUser = 3000;
    public const int MaxSocket = 3000;
}

public enum Nation : byte
{
    All = 0,
    Karus = 1,
    Elmorad = 2,
    None = 3
}

public enum UserStatus : byte
{
    Dot = 1,
    Poison = 2,
    Speed = 3,
    Blind = 4,
    Black = 5
}

public enum AttributeType : byte
{
    None = 0,
    Fire = 1,
    Ice = 2,
    Lightning = 3,
    LightMagic = 4,
    Curse = 5,
    Posion = 6
}

public enum NpcState : byte
{
    Dead = 0,
    Live = 1,
    Attacking = 2,
    Attacked = 3,
    Sleeping = 4,
    Tracing = 5,
    Moving = 6,
    Standing = 7,
    Fighting = 8,
    Strategy = 9,
    Back = 10,
    Escape = 11,
    Fainting = 12,
    Healing = 13,
    Casting = 14
}

public enum UnitType : byte
{
    Player = 0,
    Npc = 1,
    Pet = 2
}

public enum TransformationType : byte
{
    None = 0,
    Monster = 1,
    Npc = 2,
    Siege = 3
}

public enum AuthorityType : byte
{
    GameMaster = 0,
    Player = 1,
    Muted = 11,
    AttackDisabled = 12,
    LimitedGameMaster = 250,
    Banned = 255
}

public enum StatType : byte
{
    Str = 0,
    Sta = 1,
    Dex = 2,
    Int = 3,
    Cha = 4
}

public enum InOutType : byte
{
    In = 1,
    Out = 2,
    Respawn = 3,
    Warp = 4,
    Summon = 5
}

public enum AttackType : byte
{
    None = 0,
    Physical = 1,
    Magic = 2
}

public enum ZoneAbilityType : byte
{
    Neutral = 0,
    PvP = 1,
    Spectator = 2,
    Siege1 = 3,
    Siege2 = 4,
    Siege3 = 5,
    SiegeDisabled = 6,
    CaitharosArena = 7,
    PvpNeutralNpcs = 8,
    PvpStoneNpcs = 9
}

[Flags]
public enum ZoneFlags : byte
{
    TradeOtherNation = 1 << 0,
    TalkOtherNation = 1 << 1,
    AttackOtherNation = 1 << 2,
    AttackSameNation = 1 << 3,
    FriendlyNpcs = 1 << 4,
    WarZone = 1 << 5,
    ClanUpdate = 1 << 6
}

public enum ItemFlag : byte
{
    None = 0,
    Rented = 1,
    CharSeal = 2,
    Duplicate = 3,
    Sealed = 4,
    NotBound = 7,
    Bound = 8
}

public enum NpcType : byte
{
    Monster = 0,
    General = 1,
    Tree = 2,
    Boss = 3,
    DungeonMonster = 4,
    TrapMonster = 5,
    Guard = 11,
    Merchant = 21,
    Tinker = 22,
    Anvil = 24,
    Healer = 40,
    Gate = 50,
    Artifact = 60,
    ChaosStone = 200,
}

public static class ItemSlots
{
    public const byte RightEar = 0;
    public const byte Head = 1;
    public const byte LeftEar = 2;
    public const byte Neck = 3;
    public const byte Breast = 4;
    public const byte Shoulder = 5;
    public const byte RightHand = 6;
    public const byte Waist = 7;
    public const byte LeftHand = 8;
    public const byte RightRing = 9;
    public const byte Leg = 10;
    public const byte LeftRing = 11;
    public const byte Glove = 12;
    public const byte Foot = 13;
    public const byte Reserved = 14;
    public const byte CWing = 42;
    public const byte CHelmet = 43;
    public const byte CLeft = 44;
    public const byte CRight = 45;
    public const byte CTop = 46;
    public const byte CFairy = 47;
    public const byte Bag1 = 48;
    public const byte Bag2 = 49;
}
