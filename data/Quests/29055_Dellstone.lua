local NPC = 29055;

if (EVENT == 100) then
	SelectMsg(UID, 2, -1, 9496, NPC, 10, 102);
end

if (EVENT == 101) then
	Ret = 1;
end

if (EVENT == 102) then
	CanMsg = isOwner(UID);
	if(CanMsg) then
		SelectMsg(UID, 2, -1, 9498, NPC, 3000 , 103, 3005, 101);
	else
		SelectMsg(UID, 2, -1, 9497, NPC, 10 , 101);
	end
end

if (EVENT == 103) then
	SendSiegeKickOut(UID)
end

