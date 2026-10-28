local Ret = 0;
local NPC = 31566;

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
SelectMsg(UID, 4, 653, 21287, NPC, 22, 1002, 23, -1);
end

if (EVENT == 1002) then
SaveEvent(UID, 12636);
end

if (EVENT == 1006) then
SaveEvent(UID, 12638);
end

if (EVENT == 1005) then
	ITEM1_COUNT = HowmuchItem(UID, 389410000);   
	if (ITEM1_COUNT < 5) then
		SelectMsg(UID, 2, 653, 21287, NPC, 18,1004);
	else
		SelectMsg(UID, 4, 653, 21287, NPC, 22, 1007, 27, -1);
end
end	

if (EVENT == 1004) then
	ShowMap(UID, 810);
end

if (EVENT == 1007)then
RunExchange(UID,3138)
	SaveEvent(UID,12637)
	SaveEvent(UID,12648)
	SelectMsg(UID, 2, 653, 21758, NPC, 10,-1);
end

if (EVENT == 1101) then
SelectMsg(UID, 4, 654, 21289, NPC, 22, 1102, 23, -1);
end

if (EVENT == 1102) then
SaveEvent(UID, 12648);
end

if (EVENT == 1106) then
SaveEvent(UID, 12650);
end

if (EVENT == 1105) then
	ITEM1_COUNT = HowmuchItem(UID, 389083000);   
	if (ITEM1_COUNT < 2) then
		SelectMsg(UID, 2, 654, 21289, NPC, 18,1104);
	else
		SelectMsg(UID, 4, 654, 21289, NPC, 22, 1107, 27, -1);
end
end	

if (EVENT == 1104) then
	ShowMap(UID, 414);
end

if (EVENT == 1107)then
RunExchange(UID,3139)
	SaveEvent(UID,12649)
	SaveEvent(UID,12660)
	SelectMsg(UID, 2, 654, 21781, NPC, 10,-1);
end

if (EVENT == 1201) then
SelectMsg(UID, 4, 655, 21291, NPC, 22, 1202, 23, -1);
end

if (EVENT == 1202) then
SaveEvent(UID, 12660);
end

if (EVENT == 1206) then
SaveEvent(UID, 12662);
end

if (EVENT == 1205) then
	ITEM1_COUNT = HowmuchItem(UID, 389490000);   
	if (ITEM1_COUNT < 5) then
		SelectMsg(UID, 2, 655, 21291, NPC, 18,1204);
	else
		SelectMsg(UID, 4, 655, 21291, NPC, 22, 1207, 27, -1);
end
end	

if (EVENT == 1204) then
	ShowMap(UID, 801);
end

if (EVENT == 1207)then
RunExchange(UID,3140)
	SaveEvent(UID,12661)
	SaveEvent(UID,12672)
	SelectMsg(UID, 2, 655, 21696, NPC, 10,-1);
end

if (EVENT == 1301) then
SelectMsg(UID, 4, 656, 21293, NPC, 22, 1302, 23, -1);
end

if (EVENT == 1302) then
SaveEvent(UID, 12672);
end

if (EVENT == 1306) then
SaveEvent(UID, 12674);
end

if (EVENT == 1305) then
	ITEM1_COUNT = HowmuchItem(UID, 389450000);   
	if (ITEM1_COUNT < 5) then
		SelectMsg(UID, 2, 656, 21293, NPC, 18,1304);
	else
		SelectMsg(UID, 4, 656, 21293, NPC, 22, 1307, 27, -1);
end
end	

if (EVENT == 1204) then
	ShowMap(UID, 811);
end

if (EVENT == 1307)then
SLOTKONTROL = CheckGiveSlot(UID, 4)
     if SLOTKONTROL == false then
       SelectMsg(UID,2,-1,8898,NPC,10)
         else
RunExchange(UID,3141)
	SaveEvent(UID,12673)
	SaveEvent(UID,12684)
end
end

if (EVENT == 1401) then
SelectMsg(UID, 4, 657, 21295, NPC, 22, 1402, 23, -1);
end

if (EVENT == 1402) then
SaveEvent(UID, 12684);
end

if (EVENT == 1406) then
SaveEvent(UID, 12686);
end

if (EVENT == 1405) then
	ITEM1_COUNT = HowmuchItem(UID, 900167000);   
	ITEM2_COUNT = HowmuchItem(UID, 900166000);   
	if (ITEM1_COUNT < 1 and ITEM2_COUNT < 1) then
		SelectMsg(UID, 2, 657, 21295, NPC, 18,-1);
	else
		SelectMsg(UID, 4, 657, 21295, NPC, 22, 1407, 27, -1);
end
end

if (EVENT == 1407)then
RunExchange(UID,3142)
	SaveEvent(UID,12685)
	SaveEvent(UID,12696)
	SelectMsg(UID, 2, 657, 21819, NPC, 10,-1);
end

if (EVENT == 1501) then
SelectMsg(UID, 4, 658, 21297, NPC, 22, 1502, 23, -1);
end

if (EVENT == 1502) then
SaveEvent(UID, 12696);
end

if (EVENT == 1506) then
SaveEvent(UID, 12698);
end

if (EVENT == 1505) then
	ITEM_COUNT = HowmuchItem(UID, 389420000);    
	if (ITEM_COUNT < 5) then
		SelectMsg(UID, 2, 658, 21297, NPC, 18,1504);
	else
		SelectMsg(UID, 4, 658, 21297, NPC, 22, 1507, 27, -1);
end
end

if (EVENT == 1504) then
	ShowMap(UID, 805);
end

if (EVENT == 1507)then
RunExchange(UID,3143)
	SaveEvent(UID,12697)
	SaveEvent(UID,12708)
	SelectMsg(UID, 2, 658, 21831, NPC, 10,-1);
end

if (EVENT == 1601) then
SelectMsg(UID, 4, 659, 21299, NPC, 22, 1602, 23, -1);
end

if (EVENT == 1602) then
SaveEvent(UID, 12708);
end

if (EVENT == 1606) then
SaveEvent(UID, 12710);
end

if (EVENT == 1605) then
	ITEM_COUNT = HowmuchItem(UID, 389530000);    
	if (ITEM_COUNT < 5) then
		SelectMsg(UID, 2, 659, 21299, NPC, 18,1604);
	else
		SelectMsg(UID, 4, 659, 21299, NPC, 22, 1607, 27, -1);
end
end

if (EVENT == 1604) then
	ShowMap(UID, 804);
end

if (EVENT == 1607)then
RunExchange(UID,3144)
	SaveEvent(UID,12709)
	SaveEvent(UID,12720)
end