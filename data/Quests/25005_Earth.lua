-------%100 Usko Still by Created TheThyke--------
local Ret = 0;
local NPC = 25005;

if (EVENT == 100) then
	QuestNum = SearchQuest(UID, NPC);
	if (QuestNum == 0) then 
		SelectMsg(UID, 2, -1, 43943, NPC, 10, 0);
	elseif (QuestNum > 1 and  QuestNum < 100) then 
		NpcMsg(UID, 43943, NPC)
	else
		EVENT = QuestNum
	end
end

if (EVENT == 112) then 
		SelectMsg(UID, 2, 1274, 44124, NPC, 40307, 113);
end

if (EVENT == 113) then 
		SelectMsg(UID, 2, 1274, 44124, NPC, 40308, 114);
end

if (EVENT == 114) then 
		SelectMsg(UID, 2, 1274, 44124, NPC, 40309, 115);
end

if (EVENT == 115) then 
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1274, 44124, NPC, 65, 116, 27, 0);
	else
		SelectMsg(UID, 2, 1274, 44124, NPC, 27, 0);
	end
end

if (EVENT == 116) then
    SaveEvent(UID, 7790);
	SaveEvent(UID, 7792);
	SaveEvent(UID, 7791);
	RunExchange(UID,6070) 
end


if (EVENT == 122) then 
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1275, 44125, NPC, 22, 123, 23, 0);
	else
		SelectMsg(UID, 2, 1275, 44125, NPC, 27, 0);
	end
end


if (EVENT == 123) then
	SaveEvent(UID, 7796);
end

if (EVENT == 124) then
	SaveEvent(UID, 7799);
end

if (EVENT == 127) then
	SaveEvent(UID, 7798);
end

if (EVENT == 125) then
	MARCILTOKEN = HowmuchItem(UID, 900683000);
	if (MARCILTOKEN < 10) then
		SelectMsg(UID, 2, 1275, 44125, NPC, 19, 126);
	else
		SelectMsg(UID, 4, 1275, 44125, NPC, 22, 128, 23, 0);
	end
end

--if (EVENT == 126) then
	--ShowMap(UID, 95);
--end


if (EVENT == 128) then
RunExchange(UID,6071) 
	SaveEvent(UID, 7797);
end

if (EVENT == 132) then 
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1276, 44126, NPC, 22, 133, 23, 0);
	else
		SelectMsg(UID, 2, 1276, 44126, NPC, 27, 0);
	end
end

if (EVENT == 133) then
	SaveEvent(UID, 7802);
end

if (EVENT == 137) then
	SaveEvent(UID, 7804);
end

if (EVENT == 135) then
	MonsterCount = QuestMonsterCount(UID, 1276, 1);
	if (MonsterCount < 0) then
		SelectMsg(UID, 2, 1276, 44126, NPC, 18, 134);
	else
		SelectMsg(UID, 4, 1276, 44126, NPC, 22, 136, 23, 0);
	end
end

if (EVENT == 134) then
	ShowMap(UID, 1240);
end

if (EVENT == 136) then
RunExchange(UID,6072) 
	SaveEvent(UID, 7803);
end

if (EVENT == 142) then 
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1277, 44127, NPC, 22, 143, 23, 0);
	else
		SelectMsg(UID, 2, 1277, 44127, NPC, 27, 0);
	end
end

if (EVENT == 143) then
	SaveEvent(UID, 7808);
end

if (EVENT == 144) then
	SaveEvent(UID, 7811);
end

if (EVENT == 145) then
	BADINTOKEN = HowmuchItem(UID, 900684000);
	if (BADINTOKEN < 10) then
		SelectMsg(UID, 2, 1277, 44127, NPC, 19, 146);
	else
		SelectMsg(UID, 4, 1277, 44127, NPC, 22, 148, 23, 0);
	end
end

--if (EVENT == 146) then
	--ShowMap(UID, 1325);
--end

if (EVENT == 147) then
	SaveEvent(UID, 7810);
end

if (EVENT == 148) then
RunExchange(UID,6073) 
	SaveEvent(UID, 7809);
end

if (EVENT == 152) then 
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1278, 44128, NPC, 22, 153, 23, 0);
	else
		SelectMsg(UID, 2, 1278, 44128, NPC, 27, 0);
	end
end

if (EVENT == 153) then
	SaveEvent(UID, 7814);
end

if (EVENT == 154) then
	SaveEvent(UID, 7817);
end

if (EVENT == 157) then
	SaveEvent(UID, 7816);
end

if (EVENT == 155) then
	MonsterCount = QuestMonsterCount(UID, 1278, 1);
	if (MonsterCount < 0) then
		SelectMsg(UID, 2, 1278, 44128, NPC, 18, 156);
	else
		SelectMsg(UID, 4, 1278, 44128, NPC, 22, 158, 23, 0);
	end
end

--if (EVENT == 156) then
	--ShowMap(UID, 1325);
--end

if (EVENT == 158) then
RunExchange(UID,6074) 
	SaveEvent(UID, 7815);
end

if (EVENT == 162) then 
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1279, 44129, NPC, 22, 163, 23, 0);
	else
		SelectMsg(UID, 2, 1279, 44129, NPC, 27, 0);
	end
end

if (EVENT == 163) then
	SaveEvent(UID, 7820);
end

if (EVENT == 164) then
	SaveEvent(UID, 7823);
end

if (EVENT == 167) then
	SaveEvent(UID, 7822);
end

if (EVENT == 165) then
	GARLONGTOKEN = HowmuchItem(UID, 900685000);
	if (GARLONGTOKEN < 10) then
		SelectMsg(UID, 2, 1279, 44129, NPC, 19, 166);
	else
		SelectMsg(UID, 4, 1279, 44129, NPC, 22, 168, 23, 0);
	end
end

--if (EVENT == 166) then
	--ShowMap(UID, 1325);
--end

if (EVENT == 168) then
RunExchange(UID,6075) 
	SaveEvent(UID, 7821);
end

if (EVENT == 172) then 
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1280, 44130, NPC, 22, 173, 23, 0);
	else
		SelectMsg(UID, 2, 1280, 44130, NPC, 27, 0);
	end
end

if (EVENT == 173) then
	SaveEvent(UID, 7826);
end

if (EVENT == 174) then
	SaveEvent(UID, 7829);
end

if (EVENT == 177) then
	SaveEvent(UID, 7828);
end

if (EVENT == 175) then
	MonsterCount = QuestMonsterCount(UID, 1280, 1);
	if (MonsterCount < 0) then
		SelectMsg(UID, 2, 1280, 44130, NPC, 18, 176);
	else
		SelectMsg(UID, 4, 1280, 44130, NPC, 22, 178, 23, 0);
	end
end

--if (EVENT == 1176) then
	--ShowMap(UID, 1325);
--end

if (EVENT == 178) then
RunExchange(UID,6076) 
	SaveEvent(UID, 7827);
end

if (EVENT == 182) then 
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1281, 44131, NPC, 22, 183, 23, 0);
	else
		SelectMsg(UID, 2, 1281, 44131, NPC, 27, 0);
	end
end

if (EVENT == 183) then
	SaveEvent(UID, 7832);
end

if (EVENT == 184) then
	SaveEvent(UID, 7835);
end

if (EVENT == 187) then
	SaveEvent(UID, 7834);
end

if (EVENT == 185) then
	TheThykeMonster01 = QuestMonsterCount(UID, 1281, 1);
	TheThykeMonster02 = QuestMonsterCount(UID, 1281, 2);
	TheThykeMonster03 = QuestMonsterCount(UID, 1281, 3);
	if (TheThykeMonster01 > 0 and TheThykeMonster02 > 0 and TheThykeMonster03 > 0) then 
	SelectMsg(UID, 4, 1281, 44131, NPC, 22,186,27, 0);
	else
	         if (TheThykeMonster01 < 1) then
			SelectMsg(UID, 2, 1281, 44131, NPC, 18, 188);
		elseif ( TheThykeMonster02 < 1) then
			SelectMsg(UID, 2, 1281, 44131, NPC, 18, 189);
		elseif ( TheThykeMonster03 < 1) then
			SelectMsg(UID, 2, 1281, 44131, NPC, 18, 190);
end
end
end

if (EVENT == 188) then
	ShowMap(UID, 737);
end

if (EVENT == 189) then
	ShowMap(UID, 966);
end

if (EVENT == 190) then
	ShowMap(UID, 739);
end

if (EVENT == 186) then
RunExchange(UID,6077) 
	SaveEvent(UID, 7833);
end

if (EVENT == 192) then 
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1282, 44132, NPC, 22, 193, 23, 0);
	else
		SelectMsg(UID, 2, 1282, 44132, NPC, 27, 0);
	end
end

if (EVENT == 193) then
	SaveEvent(UID, 7838);
end

if (EVENT == 194) then
	SaveEvent(UID, 7841);
end

if (EVENT == 197) then
	SaveEvent(UID, 7840);
end

if (EVENT == 195) then
	TheThykeESC = HowmuchItem(UID, 900634000);
	TheThykeJER = HowmuchItem(UID, 900635000);
	TheThykeESP = HowmuchItem(UID, 900633000);
	if (TheThykeESC > 0 and TheThykeJER > 0 and TheThykeESP > 0) then
		SelectMsg(UID, 4, 1282, 44132, NPC, 22, 198, 23, 0);
    else
			if (TheThykeESC < 1) then
			SelectMsg(UID, 2, 1282, 44132, NPC, 18, 199);
		elseif ( TheThykeJER < 1) then
			SelectMsg(UID, 2, 1282, 44132, NPC, 18, 200);
		elseif ( TheThykeESP < 1) then
			SelectMsg(UID, 2, 1282, 44132, NPC, 18, 201);
end
end
end

--if (EVENT == 199) then
	--ShowMap(UID, 736);
--end

--if (EVENT == 200) then
--	ShowMap(UID, 894);
--end

--if (EVENT == 201) then
--	ShowMap(UID, 738);
--end

if (EVENT == 198) then
RunExchange(UID,6078) 
SaveEvent(UID, 7839);
end

if (EVENT == 202) then 
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1283, 44133, NPC, 22, 203, 23, 0);
	else
		SelectMsg(UID, 2, 1283, 44133, NPC, 27, 0);
	end
end

if (EVENT == 203) then
SaveEvent(UID, 7844);
end

if (EVENT == 204) then
SaveEvent(UID, 7847);
end

if (EVENT == 207) then
SaveEvent(UID, 7846);
end

if (EVENT == 205) then
	MonsterCount = QuestMonsterCount(UID, 1283, 1);
	if (MonsterCount < 0) then
		SelectMsg(UID, 2, 1283, 44133, NPC, 18, 206);
	else
		SelectMsg(UID, 4, 1283, 44133, NPC, 22, 208, 23, 0);
	end
end

if (EVENT == 206) then
	ShowMap(UID, 1243);
end

if (EVENT == 208) then
RunExchange(UID,6079) 
SaveEvent(UID, 7845);
end

if (EVENT == 212) then 
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1284, 44134, NPC, 22, 213, 23, 0);
	else
		SelectMsg(UID, 2, 1284, 44134, NPC, 27, 0);
	end
end

if (EVENT == 213) then
SaveEvent(UID, 7850);
SaveEvent(UID, 7852);
SaveEvent(UID, 7851);
RunExchange(UID,6080) 
end

if (EVENT == 0) then
	Ret = 1;
end