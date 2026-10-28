local NPC = 25264;

if (EVENT == 100) then
	SelectMsg(UID, 2, -1, 44366, NPC, 65, 501, 13, 502);
end

if (EVENT == 501) then
	SendDrakisInit(UID, 4, 4, 29);
end

if (EVENT == 502) then
	RENT = 1;
end