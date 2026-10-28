local NPC = 25260;

if (EVENT == 100) then
	SelectMsg(UID, 2, -1, 44352, NPC, 65, 501, 13, 502);
end

if (EVENT == 501) then
	ZoneChange(UID, 95, 302, 440)
	DrakiRiftChange(UID, 3, 1, 17);
end

if (EVENT == 502) then
	Ret = 1;
end