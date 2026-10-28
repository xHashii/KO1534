local Ret = 0;
local NPC = 31564;

if (EVENT == 100) then
	QuestNum = SearchQuest(UID, NPC);
	if (QuestNum == 0) then 
		SelectMsg(UID, 2, -1, 4703, NPC, 10, -1);
	elseif (QuestNum > 1 and  QuestNum < 100) then 
		NpcMsg(UID, 8060, NPC)
	else
		EVENT = QuestNum
	end
end

if (EVENT == 1001) then
SelectMsg(UID, 4, 651, 21283, NPC, 22, 1002, 23, -1);
end

if (EVENT == 1002) then
SaveEvent(UID, 12612);
end

if (EVENT == 1006) then
SaveEvent(UID, 12614);
end

if (EVENT == 1005) then
	ITEM1_COUNT = HowmuchItem(UID, 900191000);   
	if (ITEM1_COUNT < 1) then
		SelectMsg(UID, 2, 651, 21283, NPC, 18,-1);
	else
		SelectMsg(UID, 4, 651, 21283, NPC, 22, 1007, 27, -1);
end
end	

if (EVENT == 1007)then
RunExchange(UID,3136)
	SaveEvent(UID,12613)
	SaveEvent(UID,12624)
	SelectMsg(UID, 2, 651, 21736, NPC, 10,-1);
end

if (EVENT == 1101) then
SelectMsg(UID, 2, 652, 21285, NPC, 10,1103);
SaveEvent(UID,12624)
end

if (EVENT == 1103) then
SelectMsg(UID, 4, 652, 21285, NPC, 22, 1104, 23, -1);
SaveEvent(UID,12626)
end

if (EVENT == 1104) then
SelectMsg(UID, 2, 652, 21746, NPC, 10,-1);
SaveEvent(UID,12625)
SaveEvent(UID,12636)
end


if (EVENT == 1201) then
SelectMsg(UID, 2, 660, 21301, NPC, 10,1203);
SaveEvent(UID,12720)
end


if (EVENT == 1203) then
SelectMsg(UID, 4, 660, 21301, NPC, 22, 1204, 23, -1);
SaveEvent(UID,12722)
end

if (EVENT == 1204) then
SLOTKONTROL = CheckGiveSlot(UID, 3)
     if SLOTKONTROL == false then
       SelectMsg(UID,2,-1,8898,NPC,10)
         else
SelectMsg(UID, 2, 660, 21844, NPC, 10,-1);
SaveEvent(UID,12721)
SaveEvent(UID,12733)
RunExchange(UID,3145)
end
end

if (EVENT == 1301) then
SelectMsg(UID, 4, 662, 21304, NPC, 22, 1302, 23, -1);
end

if (EVENT == 1302) then
SaveEvent(UID, 12739);
end

if (EVENT == 1306) then
SaveEvent(UID, 12741);
end

if (EVENT == 1305) then
	ITEM1_COUNT = HowmuchItem(UID, 900168000);   
	if (ITEM1_COUNT < 1) then
		SelectMsg(UID, 2, 662, 662, NPC, 18,-1);
	else
		SelectMsg(UID, 4, 662, 662, NPC, 22, 1307, 27, -1);
end
end	

if (EVENT == 1307) then
SelectMsg(UID, 2, 662, 21862, NPC, 10,-1);
SaveEvent(UID,12740)
RunExchange(UID,3147)
end