using Ko1534.Shared.Packets;

namespace Ko1534.GameServer;

/// <summary>
/// Base unit class - bridge between CUser and CNpc.
/// Matches the C++ Unit class behavior.
/// </summary>
public abstract class Unit
{
    internal C3DMap? _map;
    protected CRegion? _region;
    protected byte _zoneId;
    protected float _curX, _curY, _curZ;
    protected ushort _regionX, _regionZ;
    protected UnitType _unitType;
    protected byte _level;
    protected byte _nation;
    protected ushort _totalHit;
    protected ushort _totalAc;
    protected float _totalHitRate;
    protected float _totalEvasionRate;
    protected bool _isDead;
    protected bool _isBlinded;
    protected bool _canUseSkills;
    protected bool _canUsePotions;
    protected bool _canTeleport;
    protected bool _canStealth;
    protected bool _isInstantCast;
    protected byte _eventRoom;
    protected short _socketId;

    protected Unit(UnitType unitType)
    {
        _unitType = unitType;
        _isDead = false;
        _isBlinded = false;
        _canUseSkills = true;
        _canUsePotions = true;
        _canTeleport = true;
        _canStealth = false;
        _isInstantCast = false;
    }

    public abstract ushort GetID();
    public abstract string Name { get; }
    public abstract int GetHealth();
    public abstract int GetMaxHealth();
    public abstract int GetMana();
    public abstract int GetMaxMana();
    public abstract bool IsDead();

    public bool IsPlayer => _unitType == UnitType.Player;
    public bool IsNPC => _unitType == UnitType.Npc;

    public float X => _curX;
    public float Y => _curY;
    public float Z => _curZ;
    public byte ZoneId => _zoneId;
    public byte Level { get => _level; set => _level = value; }
    public byte Nation { get => _nation; set => _nation = value; }
    public C3DMap? Map => _map;
    public CRegion? Region => _region;
    public short SocketId => _socketId;

    public void SetPosition(float x, float y, float z)
    {
        _curX = x;
        _curY = y;
        _curZ = z;
    }

    public void SetZone(byte zoneId)
    {
        _zoneId = zoneId;
    }

    public void SetSocketId(short socketId)
    {
        _socketId = socketId;
    }

    public float GetDistance(Unit target)
    {
        float dx = _curX - target.X;
        float dz = _curZ - target.Z;
        return MathF.Sqrt(dx * dx + dz * dz);
    }

    public float GetDistanceSqrt(Unit target)
    {
        float dx = _curX - target.X;
        float dz = _curZ - target.Z;
        return dx * dx + dz * dz;
    }

    public bool IsInRange(Unit target, float squaredRange)
    {
        return GetDistanceSqrt(target) <= squaredRange;
    }

    public bool IsInRange(float fx, float fz, float squaredRange)
    {
        float dx = _curX - fx;
        float dz = _curZ - fz;
        return dx * dx + dz * dz <= squaredRange;
    }

    public void SetRegion(ushort rx, ushort rz)
    {
        _regionX = rx;
        _regionZ = rz;
    }

    public ushort GetNewRegionX() => (ushort)(_curX / GSConstants.ViewDistance);
    public ushort GetNewRegionZ() => (ushort)(_curZ / GSConstants.ViewDistance);

    public abstract void GetInOut(Packet result, byte type);
    public abstract void HpChange(int amount, Unit? attacker = null, bool sendToAi = true);
    public abstract void MsPChange(int amount);

    public void SendToRegion(Packet result)
    {
        _map?.SendToRegion(this, result);
    }

    public void Send_AIServer(Packet result)
    {
        GameServerDlg.Instance?.Send_AIServer(result);
    }
}

/// <summary>
/// Player/User class.
/// Matches the C++ CUser class behavior.
/// </summary>
public class User : Unit
{
    private string _accountId;
    private ushort _userId;
    private short _sessionId;
    private GameServerDlg _server;
    private GameSocket? _socket;
    private byte _race;
    private byte _class;
    private string _charName = "";
    private int _hp;
    private int _maxHp;
    private int _mp;
    private int _maxMp;
    private int _exp;
    private int _maxExp;
    private int _gold;
    private int _np;
    private int _loyalty;

    // Position
    private float _startX = 0;
    private float _startY = 0;
    private float _startZ = 0;

    // Status
    private bool _isInGame;
    private bool _isLoading;
    private bool _isInvisible;

    // Inventory (simplified)
    private readonly Dictionary<byte, ItemData> _equippedItems = new();
    private readonly Dictionary<byte, ItemData> _inventory = new();

    // Quests
    private readonly List<ushort> _activeQuests = new();

    // Buffs
    private readonly Dictionary<byte, BuffInfo> _buffs = new();

    public User(string accountId, short sessionId, GameServerDlg server)
        : base(UnitType.Player)
    {
        _accountId = accountId;
        _sessionId = sessionId;
        _server = server;
        _userId = (ushort)(sessionId + 1000);
        _isInGame = false;
        _isLoading = false;

        // Default values
        _hp = GSConstants.MaxPlayerHp;
        _maxHp = GSConstants.MaxPlayerHp;
        _mp = 50;
        _maxMp = 50;
        _level = 1;
    }

    public override ushort GetID() => _userId;
    public override string Name => _accountId;
    public string AccountId => _accountId;
    public short SessionId => _sessionId;
    public bool IsInGame => _isInGame;
    public bool IsLoading => _isLoading;
    public byte Race { get => _race; set => _race = value; }
    public byte Class { get => _class; set => _class = value; }
    public string CharName { get => _charName; set => _charName = value; }
    public int Gold { get => _gold; set => _gold = value; }
    public int Np { get => _np; set => _np = value; }
    public int Exp { get => _exp; set => _exp = value; }
    public int MaxExp { get => _maxExp; set => _maxExp = value; }
    public int Hp { get => _hp; set => _hp = value; }
    public int MaxHp { get => _maxHp; set => _maxHp = value; }
    public int Mp { get => _mp; set => _mp = value; }
    public int MaxMp { get => _maxMp; set => _maxMp = value; }

    public override int GetHealth() => _hp;
    public override int GetMaxHealth() => _maxHp;
    public override int GetMana() => _mp;
    public override int GetMaxMana() => _maxMp;
    public override bool IsDead() => _hp <= 0;

    public void SetSocket(GameSocket socket)
    {
        _socket = socket;
        _sessionId = socket.SocketId;
    }

    public GameSocket? GetSocket => _socket;

    public void OnConnect()
    {
        _isInGame = true;
        _isLoading = false;
        Console.WriteLine($"[DBG] User {_accountId} (ID={_userId}) connected, socketId={_sessionId}");
    }

    public void OnDisconnect()
    {
        if (_isInGame)
        {
            Console.WriteLine($"[DBG] User {_accountId} (ID={_userId}) disconnected");
            _isInGame = false;

            // Save user data
            SaveUserData();
        }
    }

    private void SaveUserData()
    {
        // Save to database
        Console.WriteLine($"[DBG] Saving user data for {_accountId}");
    }

    public void HandleMove(Packet pkt)
    {
        // Read position from packet
        // float x = pkt.ReadFloat();
        // float z = pkt.ReadFloat();
        // float y = pkt.ReadFloat();
        // SetPosition(x, y, z);
    }

    public void HandleAttack(Packet pkt)
    {
        // Read attack target and process
    }

    public override void GetInOut(Packet result, byte type)
    {
        // Send user in/out packet
        result.AppendUInt16(GetID());
        result.AppendByte((byte)Nation);
        result.AppendByte(Level);
        result.AppendFloat(X);
        result.AppendFloat(Z);
        result.AppendFloat(Y);
        result.AppendByte(0); // direction
    }

    public override void HpChange(int amount, Unit? attacker = null, bool sendToAi = true)
    {
        _hp += amount;
        if (_hp > _maxHp) _hp = _maxHp;
        if (_hp <= 0)
        {
            _hp = 0;
            OnDeath(attacker);
        }
    }

    public override void MsPChange(int amount)
    {
        _mp += amount;
        if (_mp > _maxMp) _mp = _maxMp;
        if (_mp < 0) _mp = 0;
    }

    private void OnDeath(Unit? killer)
    {
        Console.WriteLine($"[DBG] User {_accountId} died, killed by {killer?.Name ?? "environment"}");
        _isDead = true;
    }

    public void Respawn()
    {
        _hp = _maxHp;
        _mp = _maxMp;
        _isDead = false;
        SetPosition(_startX, _startY, _startZ);
    }

    public void AddExp(int exp)
    {
        _exp += exp;
        if (_exp >= _maxExp)
        {
            LevelUp();
        }
    }

    private void LevelUp()
    {
        _level++;
        _exp -= _maxExp;
        _maxExp = 1000 + (_level * _level * 50);
        _maxHp += 20;
        _maxMp += 10;
        _hp = _maxHp;
        _mp = _maxMp;
        Console.WriteLine($"[DBG] User {_accountId} leveled up to {_level}!");
    }

    public void AddGold(int gold)
    {
        _gold += gold;
    }

    public void AddItem(byte slot, ItemData item)
    {
        _inventory[slot] = item;
    }

    public GameServerDlg Server => _server;
}

/// <summary>
/// Extension methods for Unit to access socket.
/// </summary>
public static class UnitExtensions
{
    public static GameSocket? GetSocket(this Unit unit)
    {
        if (unit is User user)
        {
            return user.GetSocket;
        }
        return null;
    }
}
