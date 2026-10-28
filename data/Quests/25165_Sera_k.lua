local Ret = 0;
local NPC = 25165;

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

if(EVENT == 1112) then 
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1325, 43929, NPC, 22, 1113, 23, -1);
	else
		SelectMsg(UID, 2, 1325, 43929, NPC, 10, -1);
	end
end

if(EVENT == 1113) then
	SaveEvent(UID, 3660)
end

if(EVENT == 1114) then
	SaveEvent(UID, 3663)
end

if(EVENT == 1117) then
	SaveEvent(UID, 3662)
end

if(EVENT == 1115) then
	EAR = HowmuchItem(UID, 900655000)
	if( EAR < 1) then
		SelectMsg(UID, 2, 1325, 43929, NPC, 18, 1116);
	else
		SelectMsg(UID, 4, 1325, 43929, NPC, 10, 1118, 27, -1);
	end
end

if(EVENT == 1116) then
	ShowMap(UID, 1336);
end

if(EVENT == 1118) then
SaveEvent(UID, 3661)
RunExchange(UID,6119)
end