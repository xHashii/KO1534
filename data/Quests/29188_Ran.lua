local Ret = 0;
local NPC = 29188;

if (EVENT == 100) then
	SelectMsg(UID, 3, -1, 10502, NPC,7586,120);
end
if (EVENT == 120) then
	Time = CheckUnderTheCastle(UID)
	if (Time == 21) then
	ZoneChange(UID, 86, 69, 64)
			else
				SelectMsg(UID, 2, -1, 4136, NPC, 18, 200);		
end
end