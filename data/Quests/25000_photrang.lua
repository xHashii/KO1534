local Ret = 0;
local NPC = 25000;

if (EVENT == 200) then
	QuestNum = SearchQuest(UID, NPC);
	if (QuestNum == 0) then
		SelectMsg(UID, 2, -1, 43647, NPC, 10, 158);
	elseif (QuestNum > 1 and  QuestNum < 100) then
		NpcMsg(UID, 43647, NPC)
	else
		EVENT = QuestNum
	end
end

local savenum = 1200
if(EVENT == 102) then 
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, savenum, 8244, NPC, 22, 106, 23, 158);
	else
		SelectMsg(UID, 2, savenum, 8265, NPC, 10, 158);
	end
end

if(EVENT == 106) then
	SaveEvent(UID, 7310)
end

if(EVENT == 107) then
	CountA  = HowmuchItem(UID, 810418000);
	if(CountA > 2) then
	SaveEvent(UID, 7312)
end
end

if(EVENT == 105) then
	CountA = HowmuchItem(UID, 810418000)
	if( CountA < 2) then
		SelectMsg(UID, 2, savenum, 8267, NPC, 18, 108);
	else
		SelectMsg(UID, 5, savenum, 8268, NPC, 41, 110, 27, 158);
	end
end

if(EVENT == 108) then
	ShowMap(UID, 1)
end

if(EVENT == 110) then
	RunExchange(UID, 6000);
	SaveEvent(UID, 7311)
end

local savenum = 1201

if(EVENT == 112) then
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, savenum, 8244, NPC, 22, 114, 23, 158);
	else
		SelectMsg(UID, 2, savenum, 8265, NPC, 10, 158);
	end
end

if(EVENT == 114) then
	SaveEvent(UID, 7317)
end

if(EVENT == 117) then
	CountA  = HowmuchItem(UID, 810418000);
	if(CountA > 2) then
	SaveEvent(UID, 7319)
end
end

if(EVENT == 115) then
	CountA = HowmuchItem(UID, 810418000)
	
	if( CountA < 2) then
		SelectMsg(UID, 2, savenum, 8267, NPC, 18, 118);
	else
		SelectMsg(UID, 5, savenum, 8268, NPC, 41, 120, 27, 158);
	end
end

if (EVENT == 118 ) then
	ShowMap(UID, 2)
end

if(EVENT == 120) then
	RunExchange(UID, 6001);
	SaveEvent(UID, 7318)
end


local savenum = 1202


if(EVENT == 122) then
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, savenum, 8244, NPC, 22, 124, 23, 158);
	else
		SelectMsg(UID, 2, savenum, 8265, NPC, 10, 158);
	end
end

if(EVENT == 124) then
	SaveEvent(UID, 7324)
end

if(EVENT == 128) then
	SaveEvent(UID, 7326)
end

if(EVENT == 125) then
	MonsterCount  = QuestMonsterCount(UID, savenum, 1);
	if (MonsterCount < 0) then
		SelectMsg(UID, 2, savenum, 8267, NPC, 18, 129);
	else
		SelectMsg(UID, 5, savenum, 8268, NPC, 41, 130, 27, 158);
	end
end

if(EVENT == 129) then
	ShowMap(UID, 2)
end

if(EVENT == 130) then
	RunExchange(UID, 6002);
	SaveEvent(UID, 7325)
end

------------------------


if(EVENT == 132) then
SelectMsg(UID, 2, 1203, 43627, NPC, 40147, 133);
end


if(EVENT == 133) then
	MonsterSub = ExistMonsterQuestSub(UID);
	if (MonsterSub == 0) then
		SelectMsg(UID, 4, 1203, 43627, NPC, 22, 134, 23, 158);
	else
		SelectMsg(UID, 2, 1203, 43627, NPC, 10, 158);
	end
end

if(EVENT == 134) then	
SaveEvent(UID, 7330)
--------------------
SaveEvent(UID, 7335)
--------------------
SaveEvent(UID, 7340)
--------------------
end

if(EVENT == 137) then
SaveEvent(UID, 7332)
end


if (EVENT == 135) then
	ITEM1_COUNT = HowmuchItem(UID, 900600000);  --patric
    ITEM2_COUNT = HowmuchItem(UID, 900601000);  --menissah
    ITEM3_COUNT = HowmuchItem(UID, 900603000);  --bilbor
    ITEM4_COUNT = HowmuchItem(UID, 900604000);	--kaishan
	if (ITEM1_COUNT > 0 and ITEM2_COUNT > 0 and ITEM3_COUNT > 0 and ITEM4_COUNT > 0) then
	SelectMsg(UID, 4, 1203, 43627, NPC, 41, 141, 27, -1);
	else
			if (ITEM1_COUNT < 1) then
			SelectMsg(UID, 2, 1203, 43627, NPC, 18, 136);
		elseif (ITEM2_COUNT < 1) then
			SelectMsg(UID, 2, 1203, 43627, NPC, 18, 138);
		elseif (ITEM3_COUNT < 1) then
			SelectMsg(UID, 2, 1203, 43627, NPC, 18, 139);
		elseif (ITEM4_COUNT < 1) then
			SelectMsg(UID, 2, 1203, 43627, NPC, 18, 140);
		end
	end
end

if (EVENT == 136) then
	ShowMap(UID, 4);
end
if (EVENT == 138) then
	ShowMap(UID, 5);
end
if (EVENT == 139) then
	ShowMap(UID, 2);
end
if (EVENT == 140) then
	ShowMap(UID, 3);
end

if(EVENT == 141) then
	RunExchange(UID, 6003);
	SaveEvent(UID, 7331)
end

if(EVENT == 142) then
		SelectMsg(UID, 2, 1209, 43647, NPC, 40150, 143);
end

if(EVENT == 143) then
		SelectMsg(UID, 2, 1209, 43648, NPC, 22, 144,23,-1);
end

if(EVENT == 144) then
SLOTKONTROL = CheckGiveSlot(UID, 3)
     if SLOTKONTROL == false then
       SelectMsg(UID,2,-1,8898,NPC,10)
         else
		 GiveItem(UID, 900599000, 1)
		    SaveEvent(UID, 7364)
		 	SaveEvent(UID, 7368)
		SelectMsg(UID, 2, 1209, 43675, NPC, 10, 113);
end
end