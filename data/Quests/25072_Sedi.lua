local Ret = 0;
local NPC = 25072;

if (EVENT == 100) then
	QuestNum = SearchQuest(UID, NPC);
	if (QuestNum == 0) then
		SelectMsg(UID, 2, -1, 43812, NPC, 10, -1);
	elseif (QuestNum > 1 and  QuestNum < 100) then
		NpcMsg(UID, 43812, NPC)
	else
		EVENT = QuestNum
	end
end

if(EVENT == 112) then 
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1240, 43812, NPC, 22, 113, 23, -1);
	else
		SelectMsg(UID, 2, 1240, 43812, NPC, 10, -1);
	end
end

if(EVENT == 113) then
	SaveEvent(UID, 7548)
end

if(EVENT == 114) then
	SaveEvent(UID, 7551)
end

if(EVENT == 117) then
	SaveEvent(UID, 7550)
end

if(EVENT == 115) then
	WOLFDOG = HowmuchItem(UID, 900652000)
	if( WOLFDOG < 20) then
		SelectMsg(UID, 2, 1240, 43812, NPC, 18, 116);
	else
		SelectMsg(UID, 4, 1240, 43812, NPC, 10, 118, 27, -1);
	end
end

if(EVENT == 116) then
ShowMap(UID, 1318);
end

if(EVENT == 118) then
SaveEvent(UID, 7549)
RunExchange(UID,6036)
end


if(EVENT == 122) then 
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1241, 43815, NPC, 10, 123, 23, -1);
	else
		SelectMsg(UID, 2, 1241, 43815, NPC, 10, -1);
	end
end

if(EVENT == 123) then
	SaveEvent(UID, 7554)
end

if(EVENT == 124) then
	SaveEvent(UID, 7557)
end

if(EVENT == 127) then
	SaveEvent(UID, 7556)
end
	
if(EVENT == 125) then
	SADDY = HowmuchItem(UID, 900659000)
	if( SADDY < 1) then
		SelectMsg(UID, 2, 1241, 43815, NPC, 18, 126);
	else
		SelectMsg(UID, 4, 1241, 43815, NPC, 10, 128, 27, -1);
	end
end

if(EVENT == 126) then
	ShowMap(UID, 1334);
end

if(EVENT == 128) then
SaveEvent(UID, 7555)
RunExchange(UID,6037)
end