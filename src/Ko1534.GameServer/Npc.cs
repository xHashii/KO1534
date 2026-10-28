using Ko1534.Shared.Packets;

namespace Ko1534.GameServer;

/// <summary>
/// NPC class.
/// Matches the C++ CNpc class behavior.
/// </summary>
public class Npc : Unit
{
    private ushort _npcId;
    private string _name;
    private byte _npcType;
    private int _hp;
    private int _maxHp;
    private int _mp;
    private int _maxMp;
    private short _sid;
    private byte _direction;
    private bool _isDead;
    private NpcState _npcState;
    private int _respawnTime;

    // AI-related
    private CNpcThread? _npcThread;
    private float _targetX;
    private float _targetZ;
    private int _attackTargetId;

    // Event-related
    private bool _isEventNpc;
    private byte _eventRoom;
    private int _duration;
    private int _spawnTime;

    // Monster-specific
    private byte _nation;
    private ushort _monsterId;
    private int _exp;
    private int _minDamage;
    private int _maxDamage;
    private int _attackRange;
    private int _detectRange;
    private byte _moveSpeed;

    public Npc(ushort npcId, byte npcType)
        : base(UnitType.Npc)
    {
        _npcId = npcId;
        _npcType = npcType;
        _isDead = false;
        _npcState = NpcState.Standing;
        _hp = 100;
        _maxHp = 100;
        _mp = 0;
        _maxMp = 0;
    }

    public override ushort GetID() => _npcId;
    public override string Name => _name;
    public string NpcName => _name;
    public byte NpcType => _npcType;
    public short Sid => _sid;
    public NpcState State => _npcState;
    public byte Direction => _direction;
    public bool IsEventNpc => _isEventNpc;
    public byte EventRoom => _eventRoom;
    public bool IsMonster => _npcType == (byte)Ko1534.GameServer.NpcType.Monster || _npcType == (byte)Ko1534.GameServer.NpcType.Boss || _npcType == (byte)Ko1534.GameServer.NpcType.DungeonMonster;
    public ushort MonsterId => _monsterId;
    public int Exp => _exp;
    public override int GetHealth() => _hp;
    public override int GetMaxHealth() => _maxHp;
    public override int GetMana() => _mp;
    public override int GetMaxMana() => _maxMp;
    public override bool IsDead() => _isDead;

    public void Initialize()
    {
        _hp = _maxHp;
        _isDead = false;
        _npcState = NpcState.Standing;
    }

    public void SetName(string name)
    {
        _name = name;
    }

    public void SetPosition(float x, float y, float z)
    {
        base.SetPosition(x, y, z);
    }

    public void SetSid(short sid)
    {
        _sid = sid;
    }

    public void SetDirection(byte dir)
    {
        _direction = dir;
    }

    public void SetEventNpc(bool isEvent, byte eventRoom, int duration)
    {
        _isEventNpc = isEvent;
        _eventRoom = eventRoom;
        _duration = duration;
    }

    public void SetMonsterData(ushort monsterId, byte nation, int exp, int minDmg, int maxDmg,
        int attackRange, int detectRange, byte moveSpeed)
    {
        _monsterId = monsterId;
        _nation = nation;
        _exp = exp;
        _minDamage = minDmg;
        _maxDamage = maxDmg;
        _attackRange = attackRange;
        _detectRange = detectRange;
        _moveSpeed = moveSpeed;
    }

    public int GetDamage()
    {
        return _minDamage + Random.Shared.Next(_maxDamage - _minDamage + 1);
    }

    public bool IsInAttackRange(Unit target)
    {
        return GetDistanceSqrt(target) <= (float)(_attackRange * _attackRange);
    }

    public bool IsInDetectRange(Unit target)
    {
        return GetDistanceSqrt(target) <= (float)(_detectRange * _detectRange);
    }

    public void SetState(NpcState state)
    {
        _npcState = state;
    }

    public void Die(Unit? killer)
    {
        _isDead = true;
        _npcState = NpcState.Dead;
        _hp = 0;

        Console.WriteLine($"[DBG] NPC {_npcId} ({_name}) died, killed by {killer?.Name ?? "unknown"}");

        // Award exp to killer if player
        if (killer is User player)
        {
            player.AddExp(_exp);
        }

        // Schedule respawn
        _respawnTime = 60; // 60 seconds
    }

    public void Respawn()
    {
        _isDead = false;
        _npcState = NpcState.Live;
        _hp = _maxHp;
    }

    public override void GetInOut(Packet result, byte type)
    {
        result.AppendUInt16(GetID());
        result.AppendByte((byte)Nation);
        result.AppendByte(Level);
        result.AppendFloat(X);
        result.AppendFloat(Z);
        result.AppendFloat(Y);
        result.AppendByte(_direction);
    }

    public override void HpChange(int amount, Unit? attacker = null, bool sendToAi = true)
    {
        _hp += amount;
        if (_hp > _maxHp) _hp = _maxHp;

        if (_hp <= 0)
        {
            Die(attacker);
        }

        // Send HP change to AI server if this is a monster
        if (sendToAi && IsMonster && !IsDead())
        {
            var pkt = new Packet(0x14); // AG_NPC_HP_CHANGE
            pkt.AppendUInt16(GetID());
            pkt.AppendInt16((short)_hp);
            Send_AIServer(pkt);
        }
    }

    public override void MsPChange(int amount)
    {
        _mp += amount;
        if (_mp > _maxMp) _mp = _maxMp;
        if (_mp < 0) _mp = 0;
    }
}

/// <summary>
/// 3D Map class with region-based packet distribution.
/// Matches the C++ C3DMap class behavior.
/// </summary>
public class C3DMap
{
    private readonly Dictionary<ushort, User> _users = new();
    private readonly Dictionary<ushort, Npc> _npcs = new();
    private readonly Dictionary<int, CRegion> _regions = new();
    private int _zoneId;
    private string _mapName;

    public C3DMap(int zoneId, string mapName)
    {
        _zoneId = zoneId;
        _mapName = mapName;
    }

    public int ZoneId => _zoneId;
    public string MapName => _mapName;
    public int UserCount => _users.Count;
    public int NpcCount => _npcs.Count;

    public void AddUser(User user)
    {
        _users[user.GetID()] = user;
        user._map = this;
    }

    public void RemoveUser(ushort userId)
    {
        _users.Remove(userId);
    }

    public void AddNpc(Npc npc)
    {
        _npcs[npc.GetID()] = npc;
        npc._map = this;
    }

    public void RemoveNpc(ushort npcId)
    {
        _npcs.Remove(npcId);
    }

    public User? GetUser(ushort userId)
    {
        _users.TryGetValue(userId, out var user);
        return user;
    }

    public Npc? GetNpc(ushort npcId)
    {
        _npcs.TryGetValue(npcId, out var npc);
        return npc;
    }

    public void SendToRegion(Unit unit, Packet result)
    {
        // Implement region-based packet distribution
        foreach (var user in _users.Values)
        {
            if (user.IsInRange(unit, (float)(GSConstants.ViewDistance * GSConstants.ViewDistance)))
            {
                user.GetSocket?.Send(result);
            }
        }
    }

    public void SendToAll(Packet result)
    {
        foreach (var user in _users.Values)
        {
            user.GetSocket?.Send(result);
        }
    }
}

/// <summary>
/// Region class for efficient packet distribution.
/// Matches the C++ CRegion class behavior.
/// </summary>
public class CRegion
{
    private readonly List<Unit> _units = new();
    private readonly C3DMap _map;
    private ushort _regionX;
    private ushort _regionZ;

    public CRegion(C3DMap map, ushort rx, ushort rz)
    {
        _map = map;
        _regionX = rx;
        _regionZ = rz;
    }

    public ushort RegionX => _regionX;
    public ushort RegionZ => _regionZ;
    public int UnitCount => _units.Count;
    public C3DMap Map => _map;

    public void AddUnit(Unit unit)
    {
        _units.Add(unit);
    }

    public void RemoveUnit(Unit unit)
    {
        _units.Remove(unit);
    }

    public void Send(Packet result)
    {
        foreach (var unit in _units)
        {
            if (unit is User user && user.GetSocket != null)
            {
                user.GetSocket.Send(result);
            }
        }
    }
}

/// <summary>
/// NPC thread for AI processing (AI server side).
/// On the game server, this is a placeholder for NPC state management.
/// </summary>
public class CNpcThread
{
    private Npc? _npc;
    private volatile bool _running;
    private CancellationTokenSource? _cts;

    public CNpcThread()
    {
        _running = false;
    }

    public void AttachNpc(Npc npc)
    {
        _npc = npc;
    }

    public void Start()
    {
        _running = true;
        _cts = new CancellationTokenSource();
        _ = Task.Run(() => Process(_cts.Token));
    }

    public void Stop()
    {
        _running = false;
        _cts?.Cancel();
    }

    private async Task Process(CancellationToken token)
    {
        while (_running && !token.IsCancellationRequested)
        {
            try
            {
                if (_npc != null && !_npc.IsDead())
                {
                    // Process AI logic
                    // Check for nearby players
                    // Move toward target
                    // Attack if in range
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[CNpcThread] Error: {ex.Message}");
            }

            try { await Task.Delay(1000, token); }
            catch (OperationCanceledException) { break; }
        }
    }
}
