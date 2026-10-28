namespace Ko1534.GameServer;

/// <summary>
/// Constants from GameServer/GameDefine.h.
/// </summary>
public static class GameDefineConstants
{
    // Classes - Karus (101-112)
    public const short KaruWarrior = 101;
    public const short KaruRogue = 102;
    public const short KaruWizard = 103;
    public const short KaruPriest = 104;
    public const short Berserker = 105;
    public const short Guardian = 106;
    public const short Hunter = 107;
    public const short Penetrator = 108;
    public const short Sorcerer = 109;
    public const short Necromancer = 110;
    public const short Shaman = 111;
    public const short DarkPriest = 112;

    // Classes - El Morad (201-212)
    public const short ElmorWarrior = 201;
    public const short ElmorRogue = 202;
    public const short ElmorWizard = 203;
    public const short ElmorPriest = 204;
    public const short Blade = 205;
    public const short Protector = 206;
    public const short Ranger = 207;
    public const short Assassin = 208;
    public const short Mage = 209;
    public const short Enchanter = 210;
    public const short Cleric = 211;
    public const short Druid = 212;

    // Races
    public const short KarusBig = 1;
    public const short KarusMiddle = 2;
    public const short KarusSmall = 3;
    public const short KarusWoman = 4;
    public const short Babarian = 11;
    public const short ElmoradMan = 12;
    public const short ElmoradWoman = 13;

    // Upgrade results
    public const byte GreatSuccess = 0x01;
    public const byte Success = 0x02;
    public const byte Normal = 0x03;
    public const byte Fail = 0x04;

    // Weapon types
    public const int WeaponDagger = 1;
    public const int WeaponSword = 2;
    public const int Weapon2HSword = 22;
    public const int WeaponAxe = 3;
    public const int Weapon2HAxe = 32;
    public const int WeaponMace = 4;
    public const int Weapon2HMace = 42;
    public const int WeaponSpear = 5;
    public const int Weapon2HSpear = 52;
    public const int WeaponShield = 6;
    public const int WeaponBow = 7;
    public const int WeaponLongbow = 8;
    public const int WeaponLauncher = 10;

    // Weather
    public const byte WeatherFine = 0x01;
    public const byte WeatherRain = 0x02;
    public const byte WeatherSnow = 0x03;

    // Chat types
    public const byte GeneralChat = 1;
    public const byte PrivateChat = 2;
    public const byte PartyChat = 3;
    public const byte ForceChat = 4;
    public const byte ShoutChat = 5;
    public const byte KnightsChat = 6;
    public const byte PublicChat = 7;
    public const byte WarSystemChat = 8;
    public const byte AnnouncementChat = 17;

    // Item upgrade rates
    public const int KarivdisRate = 0;
    public const int TrinaRate = 0;
}

public enum ItemMovementType : byte
{
    InvenSlot = 1,
    SlotInven = 2,
    InvenInven = 3,
    SlotSlot = 4,
    InvenZone = 5,
    ZoneInven = 6,
    InvenToCosp = 7,
    CospToInven = 8,
    InvenToMbag = 9,
    MbagToInven = 10,
    MbagToMbag = 11,
    InvenToPet = 12
}

public enum ItemSlotType : byte
{
    EitherHand = 0,
    RightHand = 1,
    LeftHand = 2,
    RightHand2H = 3,
    LeftHand2H = 4,
    Pauldron = 5,
    Pads = 6,
    Helmet = 7,
    Gloves = 8,
    Boots = 9,
    Earring = 10,
    Necklace = 11,
    Ring = 12,
    Shoulder = 13,
    Belt = 14,
    Kaul = 20,
    Bag = 25,
}

/// <summary>
/// Item data structure matching _ITEM_DATA from globals.h.
/// </summary>
public struct ItemData
{
    public uint Num;
    public short Duration;
    public ushort Count;
    public byte Flag;
    public ushort RemainingRentalTime;
    public uint ExpirationTime;
    public ulong SerialNum;
    public uint UserSeal;
    public bool IsSelling;

    public bool IsSealed => Flag == (byte)ItemFlag.Sealed;
    public bool IsBound => Flag == (byte)ItemFlag.Bound;
    public bool IsRented => Flag == (byte)ItemFlag.Rented;
    public bool IsDuplicate => Flag == (byte)ItemFlag.Duplicate;
    public bool IsUserSeal => UserSeal > 0;
}

/// <summary>
/// Magic table structure matching _MAGIC_TABLE from the C++ source.
/// </summary>
public class MagicTable
{
    public uint SkillId;
    public byte SkillType;
    public short Range;
    public byte Attribute;
    public int Power;
    public short Duration;
    public byte Radius;
    public uint CastTime;
    public byte SubType;
    public byte BindTarget;
    public byte BindType;
    public byte BindSuccess;
    public byte SkillLevel;
}

/// <summary>
/// Buff info structure.
/// </summary>
public class BuffInfo
{
    public int SkillId;
    public short Duration;
    public byte BuffType;
    public byte Attribute;
    public int Value;
    public bool IsBuff;
    public bool IsDebuff;
    public ushort SourceId;
}
