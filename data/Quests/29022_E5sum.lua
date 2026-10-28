if (EVENT == 100)then
	QuestStatus = SearchQuest(UID, 746)	 
	if(QuestStatus == 1) then
		EVENT = 101
		else
SelectMsg(UID, 2, -1, 22279, NPC,10,-1);
end
end

if (EVENT == 101)then
SelectMsg(UID, 2, -1, 22279, NPC, 3000,102,3005,-1);
end


if(EVENT == 102) then
ZONE = GetZoneID(UID);
if(ZONE == 12) then
SpawnEventSystem(UID,9195,0,12,144,0,914);
ShowEffect(UID, 300391)
RobItem(UID, 900266000, 1)
elseif(ZONE == 15) then
SpawnEventSystem(UID,9195,0,15,144,0,914);
ShowEffect(UID, 300391)
RobItem(UID, 900266000, 1)
elseif(ZONE == 16) then
SpawnEventSystem(UID,9195,0,16,144,0,914);
ShowEffect(UID, 300391)
RobItem(UID, 900266000, 1)
end
end