local Ret = -1;
local NPC = 25066;

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

if(EVENT == 112) then 
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1262, 43928, NPC, 22, 113, 23, -1);
	else
		SelectMsg(UID, 2, 1262, 43928, NPC, 10, -1);
	end
end

if(EVENT == 113) then
	SaveEvent(UID, 7680)
end

if(EVENT == 114) then
	SaveEvent(UID, 7683)
end

if(EVENT == 117) then
	SaveEvent(UID, 7682)
end

if(EVENT == 115) then
	BRACE = HowmuchItem(UID, 900654000)
	if( BRACE < 1) then
		SelectMsg(UID, 2, 1262, 43928, NPC, 18, 116);
	else
		SelectMsg(UID, 4, 1262, 43928, NPC, 10, 118, 27, -1);
	end
end

if(EVENT == 116) then
	ShowMap(UID, 1337);
end

if(EVENT == 118) then
SaveEvent(UID, 7681)
RunExchange(UID,6058)
end

if (EVENT == 152) then
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1289, 44139, NPC, 10, 153, 23, -1);
	else
		SelectMsg(UID, 2, 1289, 44139, NPC, 10, -1);
	end
end



if(EVENT == 153) then
    SaveEvent(UID, 7880)
	SaveEvent(UID, 7882)
	SaveEvent(UID, 7881)
    RunExchange(UID,6085)
end

if (EVENT == 182) then
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1292, 44140, NPC, 10, 183, 23, -1);
	else
		SelectMsg(UID, 2, 1292, 44140, NPC, 10, -1);
	end
end

if(EVENT == 183) then
	SaveEvent(UID, 7898)
end

if(EVENT == 184) then
	SaveEvent(UID, 7901)
end

if(EVENT == 187) then
	SaveEvent(UID, 7900)
end

	if (EVENT == 185) then
	MonsterCount = QuestMonsterCount(UID, 1292, 1);
	if (MonsterCount < 0) then
		SelectMsg(UID, 2, 1292, 44140, NPC, 10, 186);
	else
		SelectMsg(UID, 4, 1292, 44140, NPC, 10, 188, 27, -1);
	end
end

if(EVENT == 186) then
ShowMap(UID, 488);
end

if(EVENT == 188) then
SaveEvent(UID, 7899)
RunExchange(UID,6088)
end

if (EVENT == 192) then
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1293, 44141, NPC, 10, 193, 23, -1);
	else
		SelectMsg(UID, 2, 1293, 44141, NPC, 10, -1);
	end
end

if(EVENT == 193) then
	SaveEvent(UID, 7904)
end

if(EVENT == 194) then
	SaveEvent(UID, 7907)
end

if(EVENT == 197) then
	SaveEvent(UID, 7906)
end

if(EVENT == 195) then
	GHOST = HowmuchItem(UID, 900638000)
	if( GHOST < 1) then
		SelectMsg(UID, 2, 1293, 44141, NPC, 18, 196);
	else
		SelectMsg(UID, 4, 1293, 44141, NPC, 10, 198, 27, -1);
	end
end

if(EVENT == 196) then
ShowMap(UID, 1284);
end

if(EVENT == 198) then
SaveEvent(UID, 7905)
RunExchange(UID,6089)
end