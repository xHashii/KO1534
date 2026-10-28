local Ret = 0;
local NPC = 15003;

if EVENT == 100 then
   SelectMsg(UID, 2, -1, 22607, NPC,29041, 101, 4074, 102);
end

if EVENT == 101 then
Nation = CheckNation(UID);
if (Nation == 1) then 
   ZoneChange(UID, 75, 53, 1974)
end
end

if EVENT == 102 then
   Ret = 1;
end
