local Ret = 0;
local NPC = 25164;

if (EVENT == 100) then
	QuestNum = SearchQuest(UID, NPC);
	if (QuestNum == 0) then
		SelectMsg(UID, 2, -1, 43928, NPC, 10, -1);
	elseif (QuestNum > 1 and  QuestNum < 100) then
		NpcMsg(UID, 43928, NPC)
	else
		EVENT = QuestNum
	end
end


if(EVENT == 1112) then 
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1324, 43928, NPC, 22, 1113, 23, -1);
	else
		SelectMsg(UID, 2, 1324, 43928, NPC, 10, -1);
	end
end

if(EVENT == 1113) then
	SaveEvent(UID, 3654)
end

if(EVENT == 1114) then
	SaveEvent(UID, 3657)
end

if(EVENT == 1117) then
	SaveEvent(UID, 3656)
end

if(EVENT == 1115) then
	BRACE1 = HowmuchItem(UID, 900654000)
	if( BRACE1 < 1) then
		SelectMsg(UID, 2, 1324, 43928, NPC, 18, 1116);
	else
		SelectMsg(UID, 4, 1324, 43928, NPC, 10, 1118, 27, -1);
	end
end

if(EVENT == 1116) then
	ShowMap(UID, 1336);
end

if(EVENT == 1118) then
SaveEvent(UID, 3655)
RunExchange(UID,6118)
end

if(EVENT == 1152) then 
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1351, 44139, NPC, 22, 1156, 23, -1);
	else
		SelectMsg(UID, 2, 1351, 44139, NPC, 10, -1);
	end
end

if(EVENT == 1156) then
SaveEvent(UID, 3816)
SaveEvent(UID, 3818)
SaveEvent(UID, 3817)
RunExchange(UID,6145)
end

if(EVENT == 1182) then 
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1352, 44140, NPC, 22, 1183, 23, -1);
	else
		SelectMsg(UID, 2, 1352, 44140, NPC, 10, -1);
	end
end

if(EVENT == 1183) then
SaveEvent(UID, 3822)
end

if(EVENT == 1184) then
SaveEvent(UID, 3825)
end

if(EVENT == 1187) then
SaveEvent(UID, 3824)
end

if (EVENT == 1185) then
	MonsterCount = QuestMonsterCount(UID, 1352, 1);
	if (MonsterCount < 0) then
		SelectMsg(UID, 2, 1352, 44140, NPC, 18, 1186);
	else
		SelectMsg(UID, 4, 1352, 44140, NPC, 22, 1188, 23, -1);
	end
end

if(EVENT == 1186) then
	ShowMap(UID, 489);
end

if(EVENT == 1188) then
SaveEvent(UID, 3823)
RunExchange(UID,6146)
end

if(EVENT == 1192) then 
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1353, 44141, NPC, 22, 1193, 23, -1);
	else
		SelectMsg(UID, 2, 1353, 44141, NPC, 10, -1);
	end
end

if(EVENT == 1193) then
SaveEvent(UID, 3828)
end

if(EVENT == 1194) then
SaveEvent(UID, 3831)
end

if(EVENT == 1197) then
SaveEvent(UID, 3830)
end

if(EVENT == 1195) then
	GHOST = HowmuchItem(UID, 900638000)
	if( GHOST < 1) then
		SelectMsg(UID, 2, 1353, 44141, NPC, 18, 1196);
	else
		SelectMsg(UID, 4, 1353, 44141, NPC, 10, 1198, 27, -1);
	end
end

if(EVENT == 1196) then
	ShowMap(UID, 1332);
end

if(EVENT == 1198) then
SaveEvent(UID, 3829)
RunExchange(UID,6147)
end