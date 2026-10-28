local NPC = 25259;

if (EVENT == 100) then
	SelectMsg(UID, 2, -1, 44350, NPC, 4170, 501, 3005, 502);
end

if (EVENT == 501) then
	SendDrakisInit(UID, 2, 4, 13);
end

if (EVENT == 502) then
	Ret = 1;
end