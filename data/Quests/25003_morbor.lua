local Ret = 0;
local NPC = 25003;


if (EVENT == 100) then
	QuestNum = SearchQuest(UID, NPC);
	if (QuestNum == 0) then
		SelectMsg(UID, 2, -1, 43796, NPC, 3001, 193);
	elseif (QuestNum > 1 and  QuestNum < 100) then
		NpcMsg(UID, 43796, NPC)
	else
		EVENT = QuestNum
	end
end

if (EVENT == 193) then
	Ret = 1;
end

if (EVENT == 1122) then
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1308, 43803, NPC, 22, 1124, 23, 0);
	else
		SelectMsg(UID, 2, 1308, 43803, NPC, 10, 0);
	end
end

if (EVENT == 1123) then
	SaveEvent(UID, 3557);
end


if (EVENT == 1124) then
	SaveEvent(UID, 3558);
end

if (EVENT == 1127) then
	SaveEvent(UID, 3560);
end


if (EVENT == 1125) then
	MonsterCount01 = QuestMonsterCount(UID, 1308, 1);
	MonsterCount02 = QuestMonsterCount(UID, 1308, 2);
	if (MonsterCount01 > 29 and MonsterCount02 > 29 ) then
		SelectMsg(UID, 4, 1308, 43803, NPC, 10, 1126, 27, 0);
	else
	if (MonsterCount01 < 30) then
		SelectMsg(UID, 2, 1308, 43803, NPC, 4440, 1128);
	elseif (MonsterCount02 < 30) then
		SelectMsg(UID, 2, 1308, 43803, NPC, 4440, 1129);
	end
end
end

if (EVENT == 1128) then
	ShowMap(UID, 1323);
end

if (EVENT == 1129) then
	ShowMap(UID, 1322);
end

if (EVENT == 1126) then
	SaveEvent(UID, 3559);
	RunExchange(UID,6101)
end

if (EVENT == 1132) then
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1309, 43806, NPC, 22, 1133, 23, 0);
	else
		SelectMsg(UID, 2, 1309, 43806, NPC, 10, 0);
	end
end

if (EVENT == 1133) then
	SaveEvent(UID, 3564);
end

if (EVENT == 1134) then
	SaveEvent(UID, 3567);
end

if (EVENT == 1137) then
	SaveEvent(UID, 3566);
end

if (EVENT == 1135) then
	SAVAGEMEAT = HowmuchItem(UID, 900651000);
	if (SAVAGEMEAT < 20) then
		SelectMsg(UID, 2, 1309, 43806, NPC, 19, 1138);
	else
		SelectMsg(UID, 4, 1309, 43806, NPC, 22, 1136, 23, 158);
	end
end

if (EVENT == 1138) then
	ShowMap(UID, 1322);
end

if (EVENT == 1136) then
RunExchange(UID,6102)
	SaveEvent(UID, 3565);
end

if (EVENT == 157) then
	SaveEvent(UID, 7526);
end


if (EVENT == 1112) then
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1307, 43800, NPC, 22, 1113, 23, 0);
	else
		SelectMsg(UID, 2, 1307, 43800, NPC, 10, 0);
	end
end

if (EVENT == 1113) then
	SaveEvent(UID, 3552);
end

if (EVENT == 1117) then
	SaveEvent(UID, 3554);
end

if (EVENT == 1115) then
SelectMsg(UID, 4, 1307, 43800, NPC, 22, 1116, 23, 0);
end

if (EVENT == 1116) then
RunExchange(UID,6100)
	SaveEvent(UID, 3553);
end