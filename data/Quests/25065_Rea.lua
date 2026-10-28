local Ret = -1;
local NPC = 25065;

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

if(EVENT == 112) then 
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1242, 43829, NPC, 22, 113, 23, -1);
	else
		SelectMsg(UID, 2, 1242, 43829, NPC, 10, -1);
	end
end

if(EVENT == 113) then
	SaveEvent(UID, 7560)
end

if(EVENT == 114) then
	SaveEvent(UID, 7563)
end

if(EVENT == 117) then
	SaveEvent(UID, 7562)
end

if (EVENT == 115) then
	MonsterCount = QuestMonsterCount(UID, 1242, 1);
	if (MonsterCount < 0) then
		SelectMsg(UID, 2, 1242, 43829, NPC, 10, 116);
	else
		SelectMsg(UID, 4, 1242, 43829, NPC, 10, 118, 27, -1);
	end
end

if(EVENT == 116) then
	ShowMap(UID, 1337);
end

if(EVENT == 118) then
SaveEvent(UID, 7561)
RunExchange(UID,6038)
end

if(EVENT == 122) then 
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1243, 43826, NPC, 10, 123, 23, -1);
	else
		SelectMsg(UID, 2, 1243, 43826, NPC, 10, -1);
	end
end

if(EVENT == 123) then
	SaveEvent(UID, 7566)
end

if(EVENT == 124) then
	SaveEvent(UID, 7569)
end

if(EVENT == 127) then
	SaveEvent(UID, 7568)
end
	
	if (EVENT == 125) then
	MonsterCount = QuestMonsterCount(UID, 1243, 1);
	if (MonsterCount < 0) then
		SelectMsg(UID, 2, 1243, 43826, NPC, 10, 126);
	else
		SelectMsg(UID, 4, 1243, 43826, NPC, 10, 128, 27, -1);
	end
end

if(EVENT == 126) then
	ShowMap(UID, 114);
end

if(EVENT == 128) then
SaveEvent(UID, 7567)
RunExchange(UID,6039)
end

if (EVENT == 132) then
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1244, 43833, NPC, 10, 133, 23, -1);
	else
		SelectMsg(UID, 2, 1244, 43833, NPC, 10, -1);
	end
end

if(EVENT == 133) then
	SaveEvent(UID, 7572)
end

if(EVENT == 134) then
	SaveEvent(UID, 7571)
end

if(EVENT == 137) then
	SaveEvent(UID, 7574)
end
	
if(EVENT == 135) then
	KINGAIF = HowmuchItem(UID, 900653000)
	if( KINGAIF < 1) then
		SelectMsg(UID, 2, 1244, 43833, NPC, 18, 136);
	else
		SelectMsg(UID, 4, 1244, 43833, NPC, 10, 138, 27, -1);
	end
end

if(EVENT == 136) then
	ShowMap(UID, 1246);
end

if(EVENT == 138) then
SaveEvent(UID, 7573)
RunExchange(UID,6040)
end

if (EVENT == 152) then
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1246, 43835, NPC, 10, 153, 23, -1);
	else
		SelectMsg(UID, 2, 1246, 43835, NPC, 10, -1);
	end
end

if(EVENT == 153) then
	SaveEvent(UID, 7584)
end

if(EVENT == 154) then
	SaveEvent(UID, 7583)
end

if(EVENT == 157) then
	SaveEvent(UID, 7586)
end

if(EVENT == 155) then
	BRACE = HowmuchItem(UID, 900654000)
	EARRIN = HowmuchItem(UID, 900655000)
	if (BRACE > 0 and EARRIN > 0) then 
		SelectMsg(UID, 4, 1246, 43833, NPC, 10, 158, 27, -1);
	else
		if (BRACE < 1) then
			SelectMsg(UID, 2, 1246, 43833, NPC, 18, 156);
		elseif (EARRIN < 1) then
			SelectMsg(UID, 2, 1246, 43833, NPC, 18, 159);
			end
			end
			end
			
			
	if(EVENT == 156) then
	ShowMap(UID, 1314);
    end		
	
	if(EVENT == 159) then
	ShowMap(UID, 1316);
    end	
			

if(EVENT == 158) then
SaveEvent(UID, 7585)
RunExchange(UID,6042)
end

if (EVENT == 162) then
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1247, 43839, NPC, 10, 163, 23, -1);
	else
		SelectMsg(UID, 2, 1247, 43839, NPC, 10, -1);
	end
end

if(EVENT == 163) then
	SaveEvent(UID, 7590)
end

if(EVENT == 164) then
	SaveEvent(UID, 7593)
end

if(EVENT == 167) then
	SaveEvent(UID, 7592)
end

	if (EVENT == 165) then
	MonsterCount = QuestMonsterCount(UID, 1247, 1);
	if (MonsterCount < 0) then
		SelectMsg(UID, 2, 1247, 43839, NPC, 10, 166);
	else
		SelectMsg(UID, 4, 1247, 43839, NPC, 10, 168, 27, -1);
	end
end

if(EVENT == 166) then
ShowMap(UID, 1314);
end

if(EVENT == 168) then
SaveEvent(UID, 7591)
RunExchange(UID,6043)
end

if (EVENT == 172) then
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1248, 43842, NPC, 10, 173, 23, -1);
	else
		SelectMsg(UID, 2, 1248, 43842, NPC, 10, -1);
	end
end

if(EVENT == 173) then
	SaveEvent(UID, 7596)
end

if(EVENT == 174) then
	SaveEvent(UID, 7599)
end

if(EVENT == 177) then
	SaveEvent(UID, 7598)
end

	if (EVENT == 175) then
	MonsterCount = QuestMonsterCount(UID, 1248, 1);
	if (MonsterCount < 0) then
		SelectMsg(UID, 2, 1248, 43842, NPC, 10, 176);
	else
		SelectMsg(UID, 4, 1248, 43842, NPC, 10, 178, 27, -1);
	end
end

if(EVENT == 176) then
ShowMap(UID, 106);
end

if(EVENT == 178) then
SaveEvent(UID, 7597)
RunExchange(UID,6044)
end

if (EVENT == 182) then
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1249, 43845, NPC, 10, 183, 23, -1);
	else
		SelectMsg(UID, 2, 1249, 43845, NPC, 10, -1);
	end
end

if(EVENT == 183) then
	SaveEvent(UID, 7602)
end

if(EVENT == 184) then
	SaveEvent(UID, 7605)
end

if(EVENT == 187) then
	SaveEvent(UID, 7604)
end

	if (EVENT == 185) then
	MonsterCount = QuestMonsterCount(UID, 1249, 1);
	if (MonsterCount < 0) then
		SelectMsg(UID, 2, 1249, 43845, NPC, 10, 186);
	else
		SelectMsg(UID, 4, 1249, 43845, NPC, 10, 188, 27, -1);
	end
end

if(EVENT == 186) then
ShowMap(UID, 1316);
end

if(EVENT == 188) then
SaveEvent(UID, 7603)
RunExchange(UID,6045)
end

if (EVENT == 192) then
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1250, 43848, NPC, 10, 193, 23, -1);
	else
		SelectMsg(UID, 2, 1250, 43848, NPC, 10, -1);
	end
end

if(EVENT == 193) then
	SaveEvent(UID, 7608)
end

if(EVENT == 194) then
	SaveEvent(UID, 7611)
end

if(EVENT == 197) then
	SaveEvent(UID, 7610)
end

	if (EVENT == 195) then
	MonsterCount = QuestMonsterCount(UID, 1250, 1);
	if (MonsterCount < 0) then
		SelectMsg(UID, 2, 1250, 43848, NPC, 10, 196);
	else
		SelectMsg(UID, 4, 1250, 43848, NPC, 10, 198, 27, -1);
	end
end

if(EVENT == 196) then
ShowMap(UID, 546);
end

if(EVENT == 198) then
SaveEvent(UID, 7609)
RunExchange(UID,6046)
end

if (EVENT == 202) then
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1251, 43851, NPC, 10, 205, 23, -1);
	else
		SelectMsg(UID, 2, 1251, 43851, NPC, 10, -1);
	end
end



if(EVENT == 205) then
    SaveEvent(UID, 7614)
	SaveEvent(UID, 7616)
	SaveEvent(UID, 7615)
    RunExchange(UID,6047)
end