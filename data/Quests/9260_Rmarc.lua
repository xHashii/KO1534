local Ret = 0;
local NPC = 9260;

if (EVENT == 100) then
	QuestNum = SearchQuest(UID, NPC);
	if (QuestNum == 0) then
		SelectMsg(UID, 2, -1, 23004, NPC, 10, -1);
	elseif (QuestNum > 1 and  QuestNum < 100) then
		NpcMsg(UID, 23004,NPC)
	else
		EVENT = QuestNum
	end
end


if(EVENT == 1001) then
	SelectMsg(UID, 4, 789, 23004, NPC, 3000, 1002,3005,-1);
end

if(EVENT == 1002) then
	SaveEvent(UID, 13820);
end

if(EVENT == 1006) then
	SaveEvent(UID, 13822);
end

if(EVENT == 1005 ) then
	COUNTA = HowmuchItem(UID, 900327000)	
	if(COUNTA > 0) then
		SelectMsg(UID, 4, 789, 23004, NPC, 41, 1007, 27, -1);
	else
		SelectMsg(UID, 2, 789, 23004, NPC, 18, -1);
	end
end

if(EVENT == 1007 ) then
SelectMsg(UID, 2, -1, 23176, NPC, 10, -1);
		RunExchange(UID, 3237,2)
		SaveEvent(UID, 13821)
		SaveEvent(UID, 13827)
end

if(EVENT == 1101) then
	SelectMsg(UID, 4, 790, 23005, NPC, 3000, 1102,3005,-1);
end

if(EVENT == 1102) then
	SaveEvent(UID, 13827);
end

if(EVENT == 1106) then
	SaveEvent(UID, 13829);
end

if(EVENT == 1105 ) then
	COUNTA = HowmuchItem(UID, 900328000)	
	COUNTB = HowmuchItem(UID, 900329000)	
	if(COUNTA > 4 and COUNTA > 0) then
		SelectMsg(UID, 4, 790, 23005, NPC, 41, 1107, 27, -1);
	else
		SelectMsg(UID, 2, 790, 23005, NPC, 18, -1);
	end
end

if(EVENT == 1107 ) then
SelectMsg(UID, 2, -1, 23180, NPC, 10, -1);
		RunExchange(UID, 3238,2)
		SaveEvent(UID, 13828)
		SaveEvent(UID, 13833)
end
