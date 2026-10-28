--Created by TheThyke-- %100 Usko Style.Özel Kanat Görevleri.
-----------------------
local NPC = 15725;
local Ret = 0;
-----------------------------------------------------
if (EVENT == 100) then
	QuestNum = SearchQuest(UID, NPC);
	if (QuestNum == 0) then
		SelectMsg(UID, 2, -1, 723, NPC, 10, 0);
	elseif (QuestNum > 1 and  QuestNum < 100) then
		NpcMsg(UID, 723, NPC)
	else
		EVENT = QuestNum
	end
end
-----------------------------------------------------
if (EVENT == 0) then
	Ret = 1;
end
-----------------------------------------------------
if (EVENT == 110) then
	SaveEvent(UID, 20055);
end
-----------------------------------------------------
if (EVENT == 112) then
	SelectMsg(UID, 4, 1601, 723, NPC, 22, 113, 23, -1);
end
-----------------------------------------------------
if (EVENT == 113) then
	SaveEvent(UID, 20056);
end
-----------------------------------------------------
if (EVENT == 120) then
	SaveEvent(UID, 20058);
end
-----------------------------------------------------
if (EVENT == 116) then
	MonsterCount = QuestMonsterCount(UID, 1601, 1);
	if (MonsterCount < 0) then
		SelectMsg(UID, 2, 1601, 723, NPC, 18, 117);
	else
		SelectMsg(UID, 4, 1601, 723, NPC, 4172, 118, 4173, -1);
	end
end
-----------------------------------------------------
if (EVENT == 117) then
	ShowMap(UID, 488);
end

if (EVENT == 118) then
    RunExchange(UID,22045)
	SaveEvent(UID, 20057);
end
-----------------------------------------------------
--2.Wing Görevi 1000 Kills
-----------------------------------------------------
if (EVENT == 130) then
	SaveEvent(UID, 20061);
end
-----------------------------------------------------
if (EVENT == 132) then
	SelectMsg(UID, 4, 1602, 723, NPC, 22, 133, 23, 8274);
end
-----------------------------------------------------
if (EVENT == 133) then
	SaveEvent(UID, 20062);
end
-----------------------------------------------------
if (EVENT == 140) then
	SaveEvent(UID, 20064);
end
-----------------------------------------------------
if (EVENT == 136) then
	MonsterCount = QuestMonsterCount(UID, 1602, 1);
	if (MonsterCount < 0) then
		SelectMsg(UID, 2, 1602, 723, NPC, 18, 137);
	else
		SelectMsg(UID, 4, 1602, 723, NPC, 4172, 138, 4173, 193);
	end
end
-----------------------------------------------------
if (EVENT == 137) then
	ShowMap(UID, 488);
end

if (EVENT == 138) then
    RunExchange(UID,22046)
	SaveEvent(UID, 20063);
end
-----------------------------------------------------
--3.Wing ve Pathos Görevi 3000 Kills
-----------------------------------------------------
if (EVENT == 150) then
	SaveEvent(UID, 20067);
end
-----------------------------------------------------
if (EVENT == 152) then
	SelectMsg(UID, 4, 1603, 723, NPC, 22, 153, 23, 8274);
end
-----------------------------------------------------
if (EVENT == 153) then
	SaveEvent(UID, 20068);
end
-----------------------------------------------------
if (EVENT == 160) then
	SaveEvent(UID, 20070);
end
-----------------------------------------------------
if (EVENT == 156) then
	MonsterCount = QuestMonsterCount(UID, 1603, 1);
	if (MonsterCount < 0) then
		SelectMsg(UID, 2, 1603, 723, NPC, 18, 157);
	else
		SelectMsg(UID, 4, 1603, 723, NPC, 4172, 158, 4173, 193);
	end
end
-----------------------------------------------------
if (EVENT == 157) then
	ShowMap(UID, 488);
end

if (EVENT == 158) then
    RunExchange(UID,22047)
	SaveEvent(UID, 20069);
end
-----------------------------------------------------