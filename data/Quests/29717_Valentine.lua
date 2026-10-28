---Author:Terry---
local Ret = 0;
local NPC = 29717;

if (EVENT == 100) then
	SelectMsg(UID, 3, -1, 29015, NPC, 29017, 101, 29018, 102, 29019,103,	29020,104,	29021,105);		   
end


if (EVENT == 101) then ---OLD MORADON
	ZoneChange(UID, 22, 306, 352)
end

if (EVENT == 102) then ---OLD BRETH
Nation = CheckNation(UID);
if (Nation == 2) then 
SelectMsg(UID,3,-1,29022,NPC,10);
else
ZoneChange(UID, 18, 315, 1672)
end
end


if (EVENT == 103) then ---OLD PIANA
Nation = CheckNation(UID);
if (Nation == 1) then 
SelectMsg(UID,3,-1,29022,NPC,10);
else
ZoneChange(UID, 28, 1660, 382)
end
end


if (EVENT == 104) then ---NEW RONARK EVENT
	Level = CheckLevel (UID);
	if Level >69 then
		Nation = CheckNation(UID);
		if (Nation == 2) then
		ZoneChange(UID, 78, 622, 898)
		else
		ZoneChange(UID, 78, 1375, 1098)
		end
	end
end


if (EVENT == 105) then ---UNDER THE CASTLE
Level = CheckLevel (UID);
if Level > 79 then
ZoneChange(UID, 86, 75, 65)
end
end

