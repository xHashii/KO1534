local Ret = 0;
local NPC = 25067;

if (EVENT == 100) then
	QuestNum = SearchQuest(UID, NPC);
	if (QuestNum == 0) then
		SelectMsg(UID, 2, -1, 43929, NPC, 10, -1);
	elseif (QuestNum > 1 and  QuestNum < 100) then
		NpcMsg(UID, 43929, NPC)
	else
		EVENT = QuestNum
	end
end

if(EVENT == 112) then 
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1263, 43929, NPC, 22, 113, 23, -1);
	else
		SelectMsg(UID, 2, 1263, 43929, NPC, 10, -1);
	end
end

if(EVENT == 113) then
	SaveEvent(UID, 7686)
end

if(EVENT == 114) then
	SaveEvent(UID, 7689)
end

if(EVENT == 117) then
	SaveEvent(UID, 7688)
end

if(EVENT == 115) then
	ASIANT = HowmuchItem(UID, 900655000)
	if( ASIANT < 1) then
		SelectMsg(UID, 2, 1263, 43929, NPC, 18, 116);
	else
		SelectMsg(UID, 4, 1263, 43929, NPC, 10, 118, 27, -1);
	end
end

if(EVENT == 116) then
	ShowMap(UID, 1316);
end

if(EVENT == 118) then
SaveEvent(UID, 7687)
RunExchange(UID,6059)
end