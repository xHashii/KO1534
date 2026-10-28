using Ko1534.Shared.Packets;

namespace Ko1534.AIServer;

/// <summary>
/// AI Server map class with region-based packet distribution.
/// Matches the C++ MAP class behavior.
/// </summary>
public class AIMap
{
    private readonly Dictionary<ushort, AiNpc> _npcs = new();
    private readonly Dictionary<ushort, AiUser> _users = new();
    private readonly List<AIGameSocket> _gameServers = new();
    private int _zoneId;
    private string _mapName;

    public AIMap(int zoneId, string mapName)
    {
        _zoneId = zoneId;
        _mapName = mapName;
    }

    public int ZoneId => _zoneId;
    public string MapName => _mapName;
    public int NpcCount => _npcs.Count;
    public int UserCount => _users.Count;
    public int GameServerCount => _gameServers.Count;

    public void AddGameServer(AIGameSocket socket)
    {
        if (!_gameServers.Contains(socket))
        {
            _gameServers.Add(socket);
        }
    }

    public void RemoveGameServer(AIGameSocket socket)
    {
        _gameServers.Remove(socket);
    }

    public void AddNpc(AiNpc npc)
    {
        _npcs[npc.NpcId] = npc;
        npc.SetMap(this);
    }

    public void RemoveNpc(ushort npcId)
    {
        _npcs.Remove(npcId);
    }

    public AiNpc? GetNpc(ushort npcId)
    {
        _npcs.TryGetValue(npcId, out var npc);
        return npc;
    }

    public void AddUser(AiUser user)
    {
        _users[user.GetID()] = user;
    }

    public void RemoveUser(ushort userId)
    {
        _users.Remove(userId);
    }

    public AiUser? GetUser(ushort userId)
    {
        _users.TryGetValue(userId, out var user);
        return user;
    }

    public AiUser? GetNearestUser(float x, float z, int maxRange)
    {
        float maxDist = (float)(maxRange * maxRange);
        AiUser? nearest = null;
        float nearestDist = float.MaxValue;

        foreach (var user in _users.Values)
        {
            if (user.IsDead) continue;

            float dx = user.X - x;
            float dz = user.Z - z;
            float dist = dx * dx + dz * dz;

            if (dist <= maxDist && dist < nearestDist)
            {
                nearestDist = dist;
                nearest = user;
            }
        }

        return nearest;
    }

    public void SendToGameServers(Packet pkt)
    {
        foreach (var server in _gameServers)
        {
            server.Send(pkt);
        }
    }

    public void SendToAll(Packet pkt)
    {
        foreach (var user in _users.Values)
        {
            // On AI server, we don't have direct sockets to users
            // We send to game servers which distribute to users
        }

        SendToGameServers(pkt);
    }
}

/// <summary>
/// AI Server NPC thread for AI processing.
/// Matches the C++ CNpcThread class behavior.
/// </summary>
public class NpcThread
{
    private AiNpc? _npc;
    private volatile bool _running;
    private CancellationTokenSource? _cts;
    private float _lastProcessTime;

    public NpcThread()
    {
        _running = false;
    }

    public void AttachNpc(AiNpc npc)
    {
        _npc = npc;
    }

    public void Start()
    {
        _running = true;
        _cts = new CancellationTokenSource();
        _lastProcessTime = Environment.TickCount;
        _ = Task.Run(() => Process(_cts.Token));
    }

    public void Stop()
    {
        _running = false;
        _cts?.Cancel();
    }

    private async Task Process(CancellationToken token)
    {
        const int tickInterval = 1000; // 1 second tick

        while (_running && !token.IsCancellationRequested)
        {
            try
            {
                if (_npc != null && !_npc.IsDead)
                {
                    int now = Environment.TickCount;
                    float deltaTime = (now - _lastProcessTime) / 1000.0f;
                    _lastProcessTime = now;

                    _npc.ProcessAI(deltaTime);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[NpcThread] NPC {_npc?.NpcId} error: {ex.Message}");
            }

            try { await Task.Delay(tickInterval, token); }
            catch (OperationCanceledException) { break; }
        }
    }
}
