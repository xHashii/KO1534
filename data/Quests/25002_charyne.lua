local Ret = 0;
local NPC = 25002;

if (EVENT == 100) then
	QuestNum = SearchQuest(UID, NPC);
	if (QuestNum == 0) then
		SelectMsg(UID, 2, -1, 43742, NPC, 10, 193);
	elseif (QuestNum > 1 and  QuestNum < 100) then
		NpcMsg(UID, 43742, NPC)
	else
		EVENT = QuestNum
	end
end

if(EVENT == 115) then
		SelectMsg(UID, 2, 1232, 43742, NPC, 40220, 116);
end

if(EVENT == 116) then
		SelectMsg(UID, 2, 1232, 43743, NPC, 40221, 118);
end

if(EVENT == 117) then
SaveEvent(UID, 7502)
end

if(EVENT == 118) then
		SelectMsg(UID, 2, 1232, 43744, NPC, 40222, 119);
end

if(EVENT == 119) then
		SelectMsg(UID, 2, 1232, 43745, NPC, 40223, 120);
end

if(EVENT == 120) then
RunExchange(UID, 6026);
SaveEvent(UID, 7501)
end

if(EVENT == 122) then
		SelectMsg(UID, 2, 1233, 43746, NPC, 40224, 123);
end

if(EVENT == 123) then
		SelectMsg(UID, 2, 1233, 43747, NPC, 40225, 124);
end

if(EVENT == 124) then
		SelectMsg(UID, 2, 1233, 43748, NPC, 65, 125);
end

if(EVENT == 125) then
RunExchange(UID, 6027);
		SaveEvent(UID, 7507)
end

if(EVENT == 132) then
		SelectMsg(UID, 4, 1234, 43750, NPC, 22, 133,23,-1);
end

if(EVENT == 133) then
SaveEvent(UID, 7512)
end

if(EVENT == 137) then
SaveEvent(UID, 7514)
end

if(EVENT == 135) then
	CountA = HowmuchItem(UID, 900649000)
	if( CountA < 1) then
		SelectMsg(UID, 2, 1234, 43750, NPC, 18, 136);
	else
		SelectMsg(UID, 4, 1234, 43750, NPC, 41, 138, 27, -1);
	end
end

if(EVENT == 136) then
ShowMap(UID, 1257);
end

if(EVENT == 138) then
RunExchange(UID, 6028);
		SaveEvent(UID, 7513)
end

if(EVENT == 142) then
		SelectMsg(UID, 4, 1235, 43753, NPC, 22, 143,23,-1);
end

if(EVENT == 143) then
SaveEvent(UID, 7518)
end

if(EVENT == 145) then
	MonsterCount  = QuestMonsterCount(UID, 1235, 1);
	if (MonsterCount < 0) then
		SelectMsg(UID, 2, 1235, 43753, NPC, 18, -1);
	else
		SelectMsg(UID, 4, 1235, 43753, NPC, 41, 146, 27, -1);
	end
end

if(EVENT == 146) then
RunExchange(UID, 6029);
		SaveEvent(UID, 7519)
end

if(EVENT == 152) then
		SelectMsg(UID, 4, 1236, 43758, NPC, 22, 153,23,-1);
end

if(EVENT == 153) then
SaveEvent(UID, 7524)
end

if(EVENT == 157) then
SaveEvent(UID, 7526)
end

if(EVENT == 155) then
SelectMsg(UID, 4, 1236, 43758, NPC, 22, 156,23,-1);
end

if(EVENT == 156) then
SelectMsg(UID, 2, 1236, 43758, NPC, 10, 158);
RunExchange(UID, 6032);
		SaveEvent(UID, 7525)
		end
		
		
if (EVENT == 158 ) then
	ShowMap(UID, 1189)
end