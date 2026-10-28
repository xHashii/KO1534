local Ret = 0;
local NPC = 15006;

if EVENT == 100 then
   SelectMsg(UID, 2, -1, 22607, NPC,29041, 101, 4074, 102);
end

if EVENT == 101 then
Nation = CheckNation(UID);
if (Nation == 2) then 
   ZoneChange(UID, 75, 47, 1830)
end
end

if EVENT == 102 then
   Ret = 1;
end
