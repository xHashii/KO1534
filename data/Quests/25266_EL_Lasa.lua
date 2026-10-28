local NPC = 25266;

if (EVENT == 100) then
	SelectMsg(UID, 2, -1, 44398, NPC, 40497, 501);
end

if (EVENT == 501) then
	DrakiOutZone(UID);
end
