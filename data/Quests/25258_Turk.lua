local NPC = 25258;

if (EVENT == 100) then
	SelectMsg(UID, 2, -1, 44346, NPC, 65, 501, 13, 502);
end

if (EVENT == 501) then
	ZoneChange(UID, 95, 78, 58)
	DrakiRiftChange(UID, 2, 1, 9);
end

if (EVENT == 502) then
	Ret = 1;
end