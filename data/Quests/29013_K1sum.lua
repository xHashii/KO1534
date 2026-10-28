if (EVENT == 100)then
	QuestStatus = SearchQuest(UID, 769)	 
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
SpawnEventSystem(UID,9146,0,71,1579,0,540);
ShowEffect(UID, 300391)
RobItem(UID, 900290000, 1)
end