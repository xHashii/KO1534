local Ret = 0;
local NPC = 25017;


if (EVENT == 100) then
	QuestNum = SearchQuest(UID, NPC);
	if (QuestNum == 0) then
		SelectMsg(UID, 2, -1, 43796, NPC, 3001, 193);
	elseif (QuestNum > 1 and  QuestNum < 100) then
		NpcMsg(UID, 43803, NPC)
	else
		EVENT = QuestNum
	end
end

if (EVENT == 193) then
	Ret = 1;
end

if (EVENT == 122) then
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1238, 43803, NPC, 22, 124, 23, 0);
	else
		SelectMsg(UID, 2, 1238, 43803, NPC, 10, 0);
	end
end

if (EVENT == 123) then
	SaveEvent(UID, 7535);
end


if (EVENT == 124) then
	SaveEvent(UID, 7536);
end

if (EVENT == 127) then
	SaveEvent(UID, 7538);
end


if (EVENT == 125) then
	MonsterCount01 = QuestMonsterCount(UID, 1238, 1);
	MonsterCount02 = QuestMonsterCount(UID, 1238, 2);
	if (MonsterCount01 > 29 and MonsterCount02 > 29 ) then
		SelectMsg(UID, 4, 1238, 43803, NPC, 10, 126, 27, 0);
	else
	if (MonsterCount01 < 30) then
		SelectMsg(UID, 2, 1238, 43803, NPC, 4440, 128);
	elseif (MonsterCount02 < 30) then
		SelectMsg(UID, 2, 1238, 43803, NPC, 4440, 129);
	end
end
end

if (EVENT == 128) then
	ShowMap(UID, 1318);
end

if (EVENT == 129) then
	ShowMap(UID, 1317);
end

if (EVENT == 126) then
	SaveEvent(UID, 7537);
	RunExchange(UID,6034)
end

if (EVENT == 132) then
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1239, 43806, NPC, 22, 133, 23, 0);
	else
		SelectMsg(UID, 2, 1239, 43806, NPC, 10, 0);
	end
end

if (EVENT == 133) then
	SaveEvent(UID, 7542);
end

if (EVENT == 134) then
	SaveEvent(UID, 7545);
end

if (EVENT == 137) then
	SaveEvent(UID, 7544);
end

if (EVENT == 135) then
	SAVAGEMEAT = HowmuchItem(UID, 900651000);
	if (SAVAGEMEAT < 20) then
		SelectMsg(UID, 2, 1239, 43806, NPC, 19, 138);
	else
		SelectMsg(UID, 4, 1239, 43806, NPC, 22, 136, 23, 0);
	end
end

if (EVENT == 138) then
	ShowMap(UID, 1317);
end

if (EVENT == 136) then
RunExchange(UID,6035)
	SaveEvent(UID, 7543);
end

if (EVENT == 112) then
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1237, 43800, NPC, 22, 113, 23, 0);
	else
		SelectMsg(UID, 2, 1237, 43800, NPC, 10, 0);
	end
end

if (EVENT == 113) then
	SaveEvent(UID, 7530);
end

if (EVENT == 117) then
	SaveEvent(UID, 7532);
end

if (EVENT == 115) then
SelectMsg(UID, 4, 1237, 43800, NPC, 22, 116, 23, 0);
end

if (EVENT == 116) then
RunExchange(UID,6033)
	SaveEvent(UID, 7531);
end