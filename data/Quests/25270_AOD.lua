local NPC = 32609;
local Ret = 0;

if (EVENT == 100) then
	--CastSkill(UID,500332);
	--SpawnNewNpc(21,784,429,9850,0,4,-1,0);
	SelectMsg(UID, 2, -1, 12479, NPC, 9040, 101, 9041, -1);	
	
end


if( EVENT == 101) then
	if(HowmuchItem(UID,998010000) == 0)then
		SelectMsg(UID, 2, -1, 12480, NPC, 27);		
	else
		SelectMsg(UID, 2, -1, 12481, NPC, 8419, 102);
		
	end
end
if( EVENT == 102)then
	RobItem(UID,998010000,1);
	--SpawnNewNpc(uint16 zoneid, uint16 x, uint16 z, uint16 sSid, uint8 group, uint8 movetype, int16 uid, uint8 npc)
	SpawnNewNpc(21,784,429,9850,0,4,-1,0);
	
	
end