using Ko1534.Shared.Packets;

namespace Ko1534.AIServer;

/// <summary>
/// AI Server NPC class.
/// Matches the C++ CNpc class behavior on the AI server side.
/// </summary>
public class AiNpc
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

    // Position
    private float _curX, _curY, _curZ;

    // AI-related
    private float _targetX, _targetZ;
    private ushort _targetId;
    private int _attackTargetId;
    private byte _nation;
    private ushort _monsterId;

    // Movement
    private float _moveSpeed;
    private int _detectRange;
    private int _attackRange;
    private int _minDamage;
    private int _maxDamage;
    private int _exp;

    // Event-related
    private bool _isEventNpc;
    private byte _eventRoom;
    private int _duration;
    private int _spawnTime;

    // Map reference
    private AIMap? _map;
    private NpcThread? _npcThread;

    // Item drops
    private readonly List<(uint itemId, int count)> _dropItems = new();

    // Target HP
    private int _targetHp;

    public AiNpc(ushort npcId, byte npcType)
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

    public ushort NpcId => _npcId;
    public string NpcName => _name;
    public byte NpcType => _npcType;
    public short Sid => _sid;
    public byte Direction => _direction;
    public bool IsDead => _isDead;
    public NpcState State => _npcState;
    public bool IsEventNpc => _isEventNpc;
    public byte EventRoom => _eventRoom;
    public bool IsMonster => _npcType == (byte)Ko1534.AIServer.NpcType.Monster || _npcType == (byte)Ko1534.AIServer.NpcType.Boss;
    public ushort MonsterId => _monsterId;
    public int Exp => _exp;
    public int Hp => _hp;
    public int MaxHp => _maxHp;
    public float X => _curX;
    public float Y => _curY;
    public float Z => _curZ;
    public AIMap? Map => _map;
    public int RespawnTime { get; set; }
    public int TargetHp => _targetHp;

    public void Initialize()
    {
        _hp = _maxHp;
        _isDead = false;
        _npcState = NpcState.Live;
        _targetHp = _maxHp;
    }

    public void SetName(string name) => _name = name;
    public void SetSid(short sid) => _sid = sid;
    public void SetMap(AIMap map) => _map = map;

    public void SetPosition(float x, float y, float z)
    {
        _curX = x;
        _curY = y;
        _curZ = z;
    }

    public void SetDirection(byte dir) => _direction = dir;

    public void SetEventNpc(bool isEvent, byte eventRoom, int duration)
    {
        _isEventNpc = isEvent;
        _eventRoom = eventRoom;
        _duration = duration;
        _spawnTime = Environment.TickCount;
    }

    public void SetMonsterData(ushort monsterId, byte nation, int exp, int minDmg, int maxDmg,
        int attackRange, int detectRange, float moveSpeed)
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

    public void SetItemDrop(uint itemId, int count)
    {
        _dropItems.Add((itemId, count));
    }

    public int GetDamage()
    {
        return _minDamage + Random.Shared.Next(_maxDamage - _minDamage + 1);
    }

    public bool IsInAttackRange(AiUser user)
    {
        float dx = _curX - user.X;
        float dz = _curZ - user.Z;
        float dist = dx * dx + dz * dz;
        return dist <= (float)(_attackRange * _attackRange);
    }

    public bool IsInDetectRange(AiUser user)
    {
        float dx = _curX - user.X;
        float dz = _curZ - user.Z;
        float dist = dx * dx + dz * dz;
        return dist <= (float)(_detectRange * _detectRange);
    }

    public void SetState(NpcState state) => _npcState = state;

    public void Die(AiUser? killer)
    {
        _isDead = true;
        _npcState = NpcState.Dead;
        _hp = 0;

        Console.WriteLine($"[DBG] AI NPC {_npcId} ({_name}) died");

        if (killer != null)
        {
            // Award exp
            killer.AddExp(_exp);
        }

        // Schedule respawn (60 seconds)
        _respawnTime = 60;

        // Notify game server
        SendNpcDead();
    }

    public void Respawn()
    {
        _isDead = false;
        _npcState = NpcState.Live;
        _hp = _maxHp;
        _targetHp = _maxHp;
        Console.WriteLine($"[DBG] AI NPC {_npcId} ({_name}) respawned");
    }

    private void SendNpcDead()
    {
        if (_map == null) return;

        Packet pkt = new Packet(0x0E); // AG_NPC_DEAD
        pkt.AppendUInt16(_npcId);
        pkt.AppendByte((byte)_nation);
        pkt.AppendFloat(_curX);
        pkt.AppendFloat(_curZ);
        pkt.AppendFloat(_curY);
        _map.SendToGameServers(pkt);
    }

    public void HpChange(int amount, AiUser? attacker = null)
    {
        _hp += amount;
        if (_hp > _maxHp) _hp = _maxHp;
        if (_hp < 0) _hp = 0;
        _targetHp = _hp;

        if (_hp <= 0)
        {
            Die(attacker);
        }
    }

    public void MsPChange(int amount)
    {
        _mp += amount;
        if (_mp > _maxMp) _mp = _maxMp;
        if (_mp < 0) _mp = 0;
    }

    // AI processing
    public void ProcessAI(float deltaTime)
    {
        if (_isDead) return;

        // Find nearest player in detect range
        var nearest = _map?.GetNearestUser(_curX, _curZ, _detectRange);

        if (nearest != null)
        {
            if (IsInAttackRange(nearest))
            {
                // Attack
                Attack(nearest);
            }
            else
            {
                // Move toward target
                MoveToward(nearest.X, nearest.Z, deltaTime);
            }
        }
        else
        {
            // Idle/wander
            if (_npcState == NpcState.Live)
            {
                _npcState = NpcState.Standing;
            }
        }
    }

    private void Attack(AiUser target)
    {
        _npcState = NpcState.Attacking;
        _targetId = target.GetID();

        int damage = GetDamage();
        target.HpChange(-damage, this);

        // Notify game server of attack
        Packet pkt = new Packet(0x06); // AG_NPC_ATTACK
        pkt.AppendUInt16(_npcId);
        pkt.AppendUInt16(target.GetID());
        pkt.AppendInt16((short)(-damage));
        _map?.SendToGameServers(pkt);

        // Check if target died
        if (target.Hp <= 0)
        {
            Console.WriteLine($"[DBG] AI NPC {_npcId} killed user {target.Name}");
        }
    }

    private void MoveToward(float targetX, float targetZ, float deltaTime)
    {
        _npcState = NpcState.Moving;

        float dx = targetX - _curX;
        float dz = targetZ - _curZ;
        float dist = MathF.Sqrt(dx * dx + dz * dz);

        if (dist > 0.1f)
        {
            float moveX = (dx / dist) * _moveSpeed * deltaTime;
            float moveZ = (dz / dist) * _moveSpeed * deltaTime;

            _curX += moveX;
            _curZ += moveZ;

            // Update direction
            _direction = (byte)(Math.Atan2(dx, dz) * (180.0 / Math.PI));

            // Notify game server of movement
            Packet pkt = new Packet(0x05); // AG_NPC_MOVE_RESULT
            pkt.AppendUInt16(_npcId);
            pkt.AppendFloat(_curX);
            pkt.AppendFloat(_curZ);
            pkt.AppendFloat(_curY);
            _map?.SendToGameServers(pkt);
        }
    }

    public void GetInOut(Packet result, byte type)
    {
        result.AppendUInt16(_npcId);
        result.AppendByte(_nation);
        result.AppendByte((byte)(_maxHp > 0 ? (_hp * 100 / _maxHp) : 0)); // HP percentage
        result.AppendFloat(_curX);
        result.AppendFloat(_curZ);
        result.AppendFloat(_curY);
        result.AppendByte(_direction);
    }
}

/// <summary>
/// AI Server User class (player data copy for AI processing).
/// Matches the C++ CUser class on AI server side.
/// </summary>
public class AiUser
{
    private ushort _userId;
    private string _name;
    private byte _nation;
    private byte _level;
    private int _hp;
    private int _maxHp;
    private int _mp;
    private int _maxMp;
    private int _exp;
    private int _maxExp;
    private int _gold;
    private int _np;
    private int _loyalty;

    private float _curX, _curY, _curZ;
    private bool _isDead;
    private byte _direction;

    public AiUser(ushort userId, string name)
    {
        _userId = userId;
        _name = name;
        _isDead = false;
        _hp = 100;
        _maxHp = 100;
    }

    public ushort GetID() => _userId;
    public string Name => _name;
    public byte Nation => _nation;
    public byte Level => _level;
    public int Hp => _hp;
    public int MaxHp => _maxHp;
    public int Mp => _mp;
    public int MaxMp => _maxMp;
    public int Gold => _gold;
    public int Np => _np;
    public int Loyalty => _loyalty;
    public float X => _curX;
    public float Y => _curY;
    public float Z => _curZ;
    public bool IsDead => _isDead;
    public byte Direction => _direction;

    public void SetPosition(float x, float y, float z)
    {
        _curX = x;
        _curY = y;
        _curZ = z;
    }

    public void SetNation(byte nation) => _nation = nation;
    public void SetLevel(byte level) => _level = level;
    public void SetHp(int hp) => _hp = hp;
    public void SetMaxHp(int maxHp) => _maxHp = maxHp;
    public void SetDirection(byte dir) => _direction = dir;

    public void HpChange(int amount, AiNpc? attacker = null)
    {
        _hp += amount;
        if (_hp > _maxHp) _hp = _maxHp;

        if (_hp <= 0)
        {
            _hp = 0;
            _isDead = true;
        }
    }

    public void MsPChange(int amount)
    {
        _mp += amount;
        if (_mp > _maxMp) _mp = _maxMp;
        if (_mp < 0) _mp = 0;
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
    }
}
