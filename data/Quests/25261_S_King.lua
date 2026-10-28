local NPC = 25261;

if (EVENT == 100) then
	SelectMsg(UID, 2, -1, 44358, NPC, 40483, 501);
end

if (EVENT == 501) then
	SendDrakisInit(UID, 3, 4, 21);
end
