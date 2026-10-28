local NPC = 25257;

if (EVENT == 100) then
	SelectMsg(UID, 2, -1, 12401, NPC, 65, 501);
end

if (EVENT == 501) then
	SendDrakisInit(UID, 1, 4, 5);
end