local NPC = 25265;

if (EVENT == 100) then
	SelectMsg(UID, 2, -1, 44370, NPC, 65, 501, 13, 502);
end

if (EVENT == 501) then
	ZoneChange(UID, 95, 71, 191);
	DrakiRiftChange(UID, 5, 1, 33);
end

if (EVENT == 502) then
	RENT = 1;
end