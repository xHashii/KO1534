-------%100 Usko Still by Created TheThyke--------
local Ret = 0;
local NPC = 25019;

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

if (EVENT == 1112) then 
		SelectMsg(UID, 2, 1336, 43944, NPC, 40307, 1113);
end

if (EVENT == 1113) then 
		SelectMsg(UID, 2, 1336, 43945, NPC, 40308, 1114);
end

if (EVENT == 1114) then 
		SelectMsg(UID, 2, 1336, 43946, NPC, 40309, 1115);
end

if (EVENT == 1115) then 
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1336, 43947, NPC, 65, 1116, 27, 0);
	else
		SelectMsg(UID, 2, 1336, 43947, NPC, 27, 0);
	end
end

if (EVENT == 1116) then
    SaveEvent(UID, 3726);
	SaveEvent(UID, 3728);
	SaveEvent(UID, 3727);
	RunExchange(UID,6130) 
end


if (EVENT == 1122) then 
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1337, 43948, NPC, 22, 1123, 23, 0);
	else
		SelectMsg(UID, 2, 1337, 43948, NPC, 27, 0);
	end
end


if (EVENT == 1123) then
	SaveEvent(UID, 3732);
end

if (EVENT == 1124) then
	SaveEvent(UID, 3735);
end

if (EVENT == 1127) then
	SaveEvent(UID, 3734);
end

if (EVENT == 1125) then
	MARCILTOKEN = HowmuchItem(UID, 900683000);
	if (MARCILTOKEN < 10) then
		SelectMsg(UID, 2, 1337, 43948, NPC, 19, 1126);
	else
		SelectMsg(UID, 4, 1337, 43948, NPC, 22, 1128, 23, 0);
	end
end

--if (EVENT == 1126) then
	--ShowMap(UID, 95);
--end


if (EVENT == 1128) then
RunExchange(UID,6131) 
	SaveEvent(UID, 3733);
end

if (EVENT == 1132) then 
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1338, 44126, NPC, 22, 1133, 23, 0);
	else
		SelectMsg(UID, 2, 1338, 44126, NPC, 27, 0);
	end
end

if (EVENT == 1133) then
	SaveEvent(UID, 3738);
end

if (EVENT == 1137) then
	SaveEvent(UID, 3740);
end

if (EVENT == 1135) then
	MonsterCount = QuestMonsterCount(UID, 1338, 1);
	if (MonsterCount < 0) then
		SelectMsg(UID, 2, 1338, 44126, NPC, 18, 1134);
	else
		SelectMsg(UID, 4, 1338, 44126, NPC, 22, 1136, 23, 0);
	end
end

if (EVENT == 1134) then
	ShowMap(UID, 1325);
end

if (EVENT == 1136) then
RunExchange(UID,6132) 
	SaveEvent(UID, 3739);
end

if (EVENT == 1142) then 
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1339, 44127, NPC, 22, 1143, 23, 0);
	else
		SelectMsg(UID, 2, 1339, 44127, NPC, 27, 0);
	end
end

if (EVENT == 1143) then
	SaveEvent(UID, 3744);
end

if (EVENT == 1144) then
	SaveEvent(UID, 3747);
end

if (EVENT == 1145) then
	BADINTOKEN = HowmuchItem(UID, 900684000);
	if (BADINTOKEN < 20) then
		SelectMsg(UID, 2, 1339, 44127, NPC, 19, 1146);
	else
		SelectMsg(UID, 4, 1339, 44127, NPC, 22, 1148, 23, 0);
	end
end

--if (EVENT == 1146) then
	--ShowMap(UID, 1325);
--end

if (EVENT == 1147) then
	SaveEvent(UID, 3746);
end

if (EVENT == 1148) then
RunExchange(UID,6133) 
	SaveEvent(UID, 3745);
end

if (EVENT == 1152) then 
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1340, 44128, NPC, 22, 1153, 23, 0);
	else
		SelectMsg(UID, 2, 1340, 44128, NPC, 27, 0);
	end
end

if (EVENT == 1153) then
	SaveEvent(UID, 3750);
end

if (EVENT == 1154) then
	SaveEvent(UID, 3753);
end

if (EVENT == 1157) then
	SaveEvent(UID, 3752);
end

if (EVENT == 1155) then
	MonsterCount = QuestMonsterCount(UID, 1340, 1);
	if (MonsterCount < 0) then
		SelectMsg(UID, 2, 1340, 44128, NPC, 18, 1156);
	else
		SelectMsg(UID, 4, 1340, 44128, NPC, 22, 1158, 23, 0);
	end
end

--if (EVENT == 1156) then
	--ShowMap(UID, 1325);
--end

if (EVENT == 1158) then
RunExchange(UID,6134) 
	SaveEvent(UID, 3751);
end

if (EVENT == 1162) then 
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1341, 44129, NPC, 22, 1163, 23, 0);
	else
		SelectMsg(UID, 2, 1341, 44129, NPC, 27, 0);
	end
end

if (EVENT == 1163) then
	SaveEvent(UID, 3756);
end

if (EVENT == 1164) then
	SaveEvent(UID, 3759);
end

if (EVENT == 1167) then
	SaveEvent(UID, 3758);
end

if (EVENT == 1165) then
	GARLONGTOKEN = HowmuchItem(UID, 900685000);
	if (GARLONGTOKEN < 10) then
		SelectMsg(UID, 2, 1341, 44129, NPC, 19, 1166);
	else
		SelectMsg(UID, 4, 1341, 44129, NPC, 22, 1168, 23, 0);
	end
end

--if (EVENT == 1166) then
	--ShowMap(UID, 1325);
--end

if (EVENT == 1168) then
RunExchange(UID,6135) 
	SaveEvent(UID, 3757);
end

if (EVENT == 1172) then 
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1342, 44130, NPC, 22, 1173, 23, 0);
	else
		SelectMsg(UID, 2, 1342, 44130, NPC, 27, 0);
	end
end

if (EVENT == 1173) then
	SaveEvent(UID, 3762);
end

if (EVENT == 1174) then
	SaveEvent(UID, 3765);
end

if (EVENT == 1177) then
	SaveEvent(UID, 3764);
end

if (EVENT == 1175) then
	MonsterCount = QuestMonsterCount(UID, 1342, 1);
	if (MonsterCount < 0) then
		SelectMsg(UID, 2, 1342, 44130, NPC, 18, 1176);
	else
		SelectMsg(UID, 4, 1342, 44130, NPC, 22, 1178, 23, 0);
	end
end

--if (EVENT == 1176) then
	--ShowMap(UID, 1325);
--end

if (EVENT == 1178) then
RunExchange(UID,6136) 
	SaveEvent(UID, 3763);
end

if (EVENT == 1182) then 
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1343, 44131, NPC, 22, 1183, 23, 0);
	else
		SelectMsg(UID, 2, 1343, 44131, NPC, 27, 0);
	end
end

if (EVENT == 1183) then
	SaveEvent(UID, 3768);
end

if (EVENT == 1184) then
	SaveEvent(UID, 3771);
end

if (EVENT == 1187) then
	SaveEvent(UID, 3770);
end

if (EVENT == 1185) then
	TheThykeMonster01 = QuestMonsterCount(UID, 1343, 1);
	TheThykeMonster02 = QuestMonsterCount(UID, 1343, 2);
	TheThykeMonster03 = QuestMonsterCount(UID, 1343, 3);
	if (TheThykeMonster01 > 0 and TheThykeMonster02 > 0 and TheThykeMonster03 > 0) then 
	SelectMsg(UID, 4, 1343, 44131, NPC, 22,1186,27, 0);
	else
	         if (TheThykeMonster01 < 1) then
			SelectMsg(UID, 2, 1343, 44131, NPC, 18, 1188);
		elseif ( TheThykeMonster02 < 1) then
			SelectMsg(UID, 2, 1343, 44131, NPC, 18, 1189);
		elseif ( TheThykeMonster03 < 1) then
			SelectMsg(UID, 2, 1343, 44131, NPC, 18, 1190);
end
end
end

if (EVENT == 1188) then
	ShowMap(UID, 736);
end

if (EVENT == 1189) then
	ShowMap(UID, 894);
end

if (EVENT == 1190) then
	ShowMap(UID, 738);
end

if (EVENT == 1186) then
RunExchange(UID,6137) 
	SaveEvent(UID, 3769);
end

if (EVENT == 1192) then 
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1344, 44132, NPC, 22, 1193, 23, 0);
	else
		SelectMsg(UID, 2, 1344, 44132, NPC, 27, 0);
	end
end

if (EVENT == 1193) then
	SaveEvent(UID, 3774);
end

if (EVENT == 1194) then
	SaveEvent(UID, 3777);
end

if (EVENT == 1197) then
	SaveEvent(UID, 3776);
end

if (EVENT == 1195) then
	TheThykeESC = HowmuchItem(UID, 900634000);
	TheThykeJER = HowmuchItem(UID, 900635000);
	TheThykeESP = HowmuchItem(UID, 900633000);
	if (TheThykeESC > 0 and TheThykeJER > 0 and TheThykeESP > 0) then
		SelectMsg(UID, 4, 1344, 44132, NPC, 22, 1198, 23, 0);
    else
			if (TheThykeESC < 1) then
			SelectMsg(UID, 2, 1344, 44132, NPC, 18, 1199);
		elseif ( TheThykeJER < 1) then
			SelectMsg(UID, 2, 1344, 44132, NPC, 18, 1200);
		elseif ( TheThykeESP < 1) then
			SelectMsg(UID, 2, 1344, 44132, NPC, 18, 1201);
end
end
end

--if (EVENT == 1199) then
	--ShowMap(UID, 736);
--end

--if (EVENT == 1200) then
--	ShowMap(UID, 894);
--end

--if (EVENT == 1201) then
--	ShowMap(UID, 738);
--end

if (EVENT == 1198) then
RunExchange(UID,6138) 
SaveEvent(UID, 3775);
end

if (EVENT == 1202) then 
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1345, 44133, NPC, 22, 1203, 23, 0);
	else
		SelectMsg(UID, 2, 1345, 44133, NPC, 27, 0);
	end
end

if (EVENT == 1203) then
SaveEvent(UID, 3780);
end

if (EVENT == 1204) then
SaveEvent(UID, 3783);
end

if (EVENT == 1207) then
SaveEvent(UID, 3782);
end

if (EVENT == 1205) then
	MonsterCount = QuestMonsterCount(UID, 1345, 1);
	if (MonsterCount < 0) then
		SelectMsg(UID, 2, 1345, 44133, NPC, 18, 1206);
	else
		SelectMsg(UID, 4, 1345, 44133, NPC, 22, 1208, 23, 0);
	end
end

if (EVENT == 1206) then
	ShowMap(UID, 1328);
end

if (EVENT == 1208) then
RunExchange(UID,6139) 
SaveEvent(UID, 3781);
end

if (EVENT == 1212) then 
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1346, 44134, NPC, 22, 1213, 23, 0);
	else
		SelectMsg(UID, 2, 1346, 44134, NPC, 27, 0);
	end
end

if (EVENT == 1213) then
SaveEvent(UID, 3786);
SaveEvent(UID, 3788);
SaveEvent(UID, 3787);
RunExchange(UID,6140) 
end

if (EVENT == 0) then
	Ret = 1;
end