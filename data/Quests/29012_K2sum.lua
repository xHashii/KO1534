if (EVENT == 100)then
	QuestStatus = SearchQuest(UID, 763)	 
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
SpawnEventSystem(UID,9145,0,71,1895,0,1716);
ShowEffect(UID, 300391)
RobItem(UID, 900284000, 1)
end