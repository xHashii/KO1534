local NPC = 25263;

if (EVENT == 100) then
	SelectMsg(UID, 2, -1, 44361, NPC, 65, 501, 13, 502);
end

if (EVENT == 501) then
	ZoneChange(UID, 95, 294, 271);
	DrakiRiftChange(UID, 4, 1, 25);
end

if (EVENT == 502) then
	RENT = 1;
end