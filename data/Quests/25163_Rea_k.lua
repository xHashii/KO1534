local Ret = -1;
local NPC = 25163;

if (EVENT == 100) then
	QuestNum = SearchQuest(UID, NPC);
	if (QuestNum == 0) then
		SelectMsg(UID, 2, -1, 43829, NPC, 10, -1);
	elseif (QuestNum > 1 and  QuestNum < 100) then
		NpcMsg(UID, 43829, NPC)
	else
		EVENT = QuestNum
	end
end

if (EVENT == -1) then
	Ret = 1;
end

if(EVENT == 1112) then 
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1312, 43829, NPC, 22, 1113, 23, -1);
	else
		SelectMsg(UID, 2, 1312, 43829, NPC, 10, -1);
	end
end

if(EVENT == 1113) then
	SaveEvent(UID, 3582)
end

if(EVENT == 1114) then
	SaveEvent(UID, 3585)
end

if(EVENT == 1117) then
	SaveEvent(UID, 3584)
end

if (EVENT == 1115) then
	MonsterCount = QuestMonsterCount(UID, 1312, 1);
	if (MonsterCount < 0) then
		SelectMsg(UID, 2, 1312, 43829, NPC, 10, 1116);
	else
		SelectMsg(UID, 4, 1312, 43829, NPC, 10, 1118, 27, -1);
	end
end

if(EVENT == 1116) then
	ShowMap(UID, 1337);
end

if(EVENT == 1118) then
SaveEvent(UID, 3583)
RunExchange(UID,6105)
end

if(EVENT == 1122) then 
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1313, 43826, NPC, 10, 1123, 23, -1);
	else
		SelectMsg(UID, 2, 1313, 43826, NPC, 10, -1);
	end
end

if(EVENT == 1123) then
	SaveEvent(UID, 3588)
end

if(EVENT == 1124) then
	SaveEvent(UID, 3591)
end

if(EVENT == 1127) then
	SaveEvent(UID, 3590)
end
	
	if (EVENT == 1125) then
	MonsterCount = QuestMonsterCount(UID, 1313, 1);
	if (MonsterCount < 0) then
		SelectMsg(UID, 2, 1313, 43826, NPC, 10, 1126);
	else
		SelectMsg(UID, 4, 1313, 43826, NPC, 10, 1128, 27, -1);
	end
end

if(EVENT == 1126) then
	ShowMap(UID, 113);
end

if(EVENT == 1128) then
SaveEvent(UID, 3589)
RunExchange(UID,6106)
end

if (EVENT == 1132) then
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1314, 43833, NPC, 10, 1133, 23, -1);
	else
		SelectMsg(UID, 2, 1314, 43833, NPC, 10, -1);
	end
end

if(EVENT == 1133) then
	SaveEvent(UID, 3594)
end

if(EVENT == 1134) then
	SaveEvent(UID, 3597)
end

if(EVENT == 1137) then
	SaveEvent(UID, 3596)
end
	
if(EVENT == 1135) then
	KINGAIF = HowmuchItem(UID, 900653000)
	if( KINGAIF < 1) then
		SelectMsg(UID, 2, 1314, 43833, NPC, 18, 1136);
	else
		SelectMsg(UID, 4, 1314, 43833, NPC, 10, 1138, 27, -1);
	end
end

if(EVENT == 1136) then
	ShowMap(UID, 1337);
end

if(EVENT == 1138) then
SaveEvent(UID, 3595)
RunExchange(UID,6107)
end


if (EVENT == 1152) then
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1315, 43835, NPC, 10, 1153, 23, -1);
	else
		SelectMsg(UID, 2, 1315, 43835, NPC, 10, -1);
	end
end

if(EVENT == 1153) then
	SaveEvent(UID, 3600)
end

if(EVENT == 1154) then
	SaveEvent(UID, 3603)
end

if(EVENT == 1157) then
	SaveEvent(UID, 3602)
end

if(EVENT == 1155) then
	BRACE = HowmuchItem(UID, 900654000)
	EARRIN = HowmuchItem(UID, 900655000)
	if (BRACE > 0 and EARRIN > 0) then 
		SelectMsg(UID, 4, 1315, 43833, NPC, 10, 1158, 27, -1);
	else
		if (BRACE < 1) then
			SelectMsg(UID, 2, 1315, 43833, NPC, 18, 1156);
		elseif (EARRIN < 1) then
			SelectMsg(UID, 2, 1315, 43833, NPC, 18, 1156);
			end
			end
			end
			
			
	if(EVENT == 1156) then
	ShowMap(UID, 1336);
    end		
			

if(EVENT == 1158) then
SaveEvent(UID, 3601)
RunExchange(UID,6109)
end

if (EVENT == 1162) then
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1316, 43839, NPC, 10, 1163, 23, -1);
	else
		SelectMsg(UID, 2, 1316, 43839, NPC, 10, -1);
	end
end

if(EVENT == 1163) then
	SaveEvent(UID, 3606)
end

if(EVENT == 1164) then
	SaveEvent(UID, 3609)
end

if(EVENT == 1167) then
	SaveEvent(UID, 3608)
end

	if (EVENT == 1165) then
	MonsterCount = QuestMonsterCount(UID, 1316, 1);
	if (MonsterCount < 0) then
		SelectMsg(UID, 2, 1316, 43839, NPC, 10, 1166);
	else
		SelectMsg(UID, 4, 1316, 43839, NPC, 10, 1168, 27, -1);
	end
end

if(EVENT == 1166) then
ShowMap(UID, 1336);
end

if(EVENT == 1168) then
SaveEvent(UID, 3607)
RunExchange(UID,6110)
end

if (EVENT == 1172) then
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1317, 43842, NPC, 10, 1173, 23, -1);
	else
		SelectMsg(UID, 2, 1317, 43842, NPC, 10, -1);
	end
end

if(EVENT == 1173) then
	SaveEvent(UID, 3612)
end

if(EVENT == 1174) then
	SaveEvent(UID, 3615)
end

if(EVENT == 1177) then
	SaveEvent(UID, 3614)
end

	if (EVENT == 1175) then
	MonsterCount = QuestMonsterCount(UID, 1317, 1);
	if (MonsterCount < 0) then
		SelectMsg(UID, 2, 1317, 43842, NPC, 10, 1176);
	else
		SelectMsg(UID, 4, 1317, 43842, NPC, 10, 1178, 27, -1);
	end
end

if(EVENT == 1176) then
ShowMap(UID, 1319);
end

if(EVENT == 1178) then
SaveEvent(UID, 3613)
RunExchange(UID,6111)
end

if (EVENT == 1182) then
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1318, 43845, NPC, 10, 1183, 23, -1);
	else
		SelectMsg(UID, 2, 1318, 43845, NPC, 10, -1);
	end
end

if(EVENT == 1183) then
	SaveEvent(UID, 3618)
end

if(EVENT == 1184) then
	SaveEvent(UID, 3621)
end

if(EVENT == 1187) then
	SaveEvent(UID, 3620)
end

	if (EVENT == 1185) then
	MonsterCount = QuestMonsterCount(UID, 1318, 1);
	if (MonsterCount < 0) then
		SelectMsg(UID, 2, 1318, 43845, NPC, 10, 1186);
	else
		SelectMsg(UID, 4, 1318, 43845, NPC, 10, 1188, 27, -1);
	end
end

if(EVENT == 1186) then
ShowMap(UID, 1338);
end

if(EVENT == 1188) then
SaveEvent(UID, 3619)
RunExchange(UID,6112)
end

if (EVENT == 1192) then
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1319, 43848, NPC, 10, 1193, 23, -1);
	else
		SelectMsg(UID, 2, 1319, 43848, NPC, 10, -1);
	end
end

if(EVENT == 1193) then
	SaveEvent(UID, 3624)
end

if(EVENT == 1194) then
	SaveEvent(UID, 3627)
end

if(EVENT == 1197) then
	SaveEvent(UID, 3626)
end

	if (EVENT == 1195) then
	MonsterCount = QuestMonsterCount(UID, 1319, 1);
	if (MonsterCount < 0) then
		SelectMsg(UID, 2, 1319, 43848, NPC, 10, 1196);
	else
		SelectMsg(UID, 4, 1319, 43848, NPC, 10, 1198, 27, -1);
	end
end

if(EVENT == 1196) then
ShowMap(UID, 547);
end

if(EVENT == 1198) then
SaveEvent(UID, 3625)
RunExchange(UID,6113)
end

if (EVENT == 1202) then
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1320, 43851, NPC, 10, 1203, 23, -1);
	else
		SelectMsg(UID, 2, 1320, 43851, NPC, 10, -1);
	end
end

if(EVENT == 1203) then
	SaveEvent(UID, 3630)
	SaveEvent(UID, 3632)
end

if(EVENT == 1205) then
	SaveEvent(UID, 3631)
    RunExchange(UID,6114)
end