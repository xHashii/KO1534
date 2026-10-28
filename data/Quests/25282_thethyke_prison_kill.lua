--Created by TheThyke-- %100 Usko Style.Special Quests
-----------------------
local NPC = 25282;
-----------------------------------------------------
if (EVENT == 100) then
	QuestNum = SearchQuest(UID, NPC);
	if (QuestNum == 0) then
		SelectMsg(UID, 2, -1, 44152, NPC, 10, -1);
	elseif (QuestNum > 1 and  QuestNum < 100) then
		NpcMsg(UID, 44152, NPC)
	else
		EVENT = QuestNum
	end
end


if (EVENT == 112) then
	SelectMsg(UID, 4, 1612, 44152, NPC, 22, 113, 23, -1);
end
-----------------------------------------------------
if (EVENT == 113) then
	SaveEvent(UID, 20127);
end
-----------------------------------------------------
if (EVENT == 120) then
	SaveEvent(UID, 20129);
end
-----------------------------------------------------
if (EVENT == 116) then
	MonsterCount = QuestMonsterCount(UID, 1612, 1);
	if (MonsterCount < 0) then
		SelectMsg(UID, 2, 1612 ,44152, NPC, 18, 117);
	else
		SelectMsg(UID, 4, 1612, 44152, NPC, 4172, 118, 23, -1);
	end
end
-----------------------------------------------------
if (EVENT == 117) then
	ShowMap(UID, 488);
end

if (EVENT == 118) then
    RunExchange(UID,16250)
	SaveEvent(UID, 20128);
end

if (EVENT == 132) then
	SelectMsg(UID, 4, 1613, 44152, NPC, 22, 133, 23, -1);
end
-----------------------------------------------------
if (EVENT == 133) then
	SaveEvent(UID, 20133);
end
-----------------------------------------------------
if (EVENT == 140) then
	SaveEvent(UID, 20135);
end
-----------------------------------------------------
if (EVENT == 136) then
	ITEM1 = HowmuchItem(UID, 0);
	ITEM2 = HowmuchItem(UID, 0);
	ITEM3 = HowmuchItem(UID, 0);
	ITEM4 = HowmuchItem(UID, 0);
	if (ITEM1 < 0 and ITEM2 < 0 and ITEM3 < 0 and ITEM4 < 0) then
		SelectMsg(UID, 2, 1613 ,44152, NPC, 18, 137);
	else
		SelectMsg(UID, 4, 1613, 44152, NPC, 4172, 138, 23, -1);
	end
end
-----------------------------------------------------
if (EVENT == 137) then
	ShowMap(UID, 488);
end

if (EVENT == 138) then
    RunExchange(UID,16251)
	SaveEvent(UID, 20134);
end


if (EVENT == 152) then
	SelectMsg(UID, 4, 1614, 44152, NPC, 22, 153, 23, -1);
end
-----------------------------------------------------
if (EVENT == 153) then
	SaveEvent(UID, 20139);
end
-----------------------------------------------------
if (EVENT == 160) then
	SaveEvent(UID, 20141);
end
-----------------------------------------------------
if (EVENT == 156) then
	MonsterCount = QuestMonsterCount(UID, 1614, 1);
	if (MonsterCount < 0) then
		SelectMsg(UID, 2, 1614 ,44152, NPC, 18, 157);
	else
		SelectMsg(UID, 4, 1614, 44152, NPC, 4172, 158, 23, -1);
	end
end
-----------------------------------------------------
if (EVENT == 157) then
	ShowMap(UID, 488);
end

if (EVENT == 158) then
    RunExchange(UID,16252)
	SaveEvent(UID, 20140);
end

-----------------------------------------------------
if (EVENT == 172) then
	SelectMsg(UID, 4, 1615, 44152, NPC, 22, 173, 23, -1);
end
-----------------------------------------------------
if (EVENT == 173) then
	SaveEvent(UID, 20145);
end
-----------------------------------------------------
if (EVENT == 180) then
	SaveEvent(UID, 20147);
end
-----------------------------------------------------
if (EVENT == 176) then
	MonsterCount1 = QuestMonsterCount(UID, 1615, 1);
	MonsterCount2 = QuestMonsterCount(UID, 1615, 2);
	if (MonsterCount1 < 0 and MonsterCount2 < 0) then
		SelectMsg(UID, 2, 1615 ,44152, NPC, 18, 177);
	else
		SelectMsg(UID, 4, 1615, 44152, NPC, 4172, 178, 23, -1);
	end
end
-----------------------------------------------------
if (EVENT == 177) then
	ShowMap(UID, 488);
end

if (EVENT == 178) then
    RunExchange(UID,16253)
	SaveEvent(UID, 20146);
end

-----------------------------------------------------
if (EVENT == 192) then
	SelectMsg(UID, 4, 1616, 44152, NPC, 22, 193, 23, -1);
end
-----------------------------------------------------
if (EVENT == 193) then
	SaveEvent(UID, 20151);
end
-----------------------------------------------------
if (EVENT == 200) then
	SaveEvent(UID, 20153);
end
-----------------------------------------------------
if (EVENT == 196) then
	MonsterCount1 = QuestMonsterCount(UID, 1616, 1);
	if (MonsterCount1 < 0) then
		SelectMsg(UID, 2, 1616 ,44152, NPC, 18, 197);
	else
		SelectMsg(UID, 4, 1616, 44152, NPC, 4172, 198, 23, -1);
	end
end
-----------------------------------------------------
if (EVENT == 197) then
	ShowMap(UID, 488);
end

if (EVENT == 198) then
    RunExchange(UID,16254)
	SaveEvent(UID, 20152);
end