---Author:Terry---
local Ret = 0;
local NPC = 21924;

if (EVENT == 100) then
	SelectMsg(UID, 3, -1, 29040,NPC,29040,101);	   
end

if (EVENT == 101) then --- MORADON
	ZoneChange(UID, 21, 817, 530)
end


