if(EVENT == 1002)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 12853);
end
end
if(EVENT == 1001)then
NATION = CheckNation(UID);
if(NATION == 2)then
SelectMsg(UID, 4, 677, 21322, 31569, 22, 1002, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1005)then
MonsterCount0 = QuestMonsterCount(UID,677,1);
NATION = CheckNation(UID);
if(NATION == 2)then
if(MonsterCount0 < 25)then
SelectMsg(UID, 2, 677, 192, 31569, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 677, 21322, 31569, 10, 1010, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1010)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
NATION = CheckNation(UID);
if(NATION == 2)then
Check = CheckGiveSlot(UID, 13156);
if(Check == 1)then
RunExchange(UID, 13156);
SaveEvent(UID, 12854);
end
end
end
end
if(EVENT == 1006)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 12855);
end
end
if(EVENT == 1102)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 12865);
end
end
if(EVENT == 1101)then
NATION = CheckNation(UID);
if(NATION == 2)then
SelectMsg(UID, 4, 679, 21324, 31569, 22, 1102, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1105)then
MonsterCount0 = QuestMonsterCount(UID,679,1);
NATION = CheckNation(UID);
if(NATION == 2)then
if(MonsterCount0 < 25)then
SelectMsg(UID, 2, 679, 192, 31569, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 679, 21324, 31569, 10, 1110, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1110)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
NATION = CheckNation(UID);
if(NATION == 2)then
Check = CheckGiveSlot(UID, 13157);
if(Check == 1)then
RunExchange(UID, 13157);
SaveEvent(UID, 12866);
end
end
end
end
if(EVENT == 1106)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 12867);
end
end
if(EVENT == 1202)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 12877);
end
end
if(EVENT == 1201)then
NATION = CheckNation(UID);
if(NATION == 2)then
SelectMsg(UID, 4, 681, 21326, 31569, 22, 1202, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1205)then
MonsterCount0 = QuestMonsterCount(UID,681,1);
NATION = CheckNation(UID);
if(NATION == 2)then
if(MonsterCount0 < 25)then
SelectMsg(UID, 2, 681, 192, 31569, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 681, 21326, 31569, 10, 1210, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1210)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
NATION = CheckNation(UID);
if(NATION == 2)then
Check = CheckGiveSlot(UID, 13158);
if(Check == 1)then
RunExchange(UID, 13158);
SaveEvent(UID, 12878);
end
end
end
end
if(EVENT == 1206)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 12879);
end
end
if(EVENT == 1302)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 12889);
end
end
if(EVENT == 1301)then
NATION = CheckNation(UID);
if(NATION == 2)then
SelectMsg(UID, 4, 683, 21328, 31569, 22, 1302, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1305)then
MonsterCount0 = QuestMonsterCount(UID,683,1);
NATION = CheckNation(UID);
if(NATION == 2)then
if(MonsterCount0 < 25)then
SelectMsg(UID, 2, 683, 192, 31569, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 683, 21328, 31569, 10, 1310, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1310)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
NATION = CheckNation(UID);
if(NATION == 2)then
Check = CheckGiveSlot(UID, 13159);
if(Check == 1)then
RunExchange(UID, 13159);
SaveEvent(UID, 12890);
end
end
end
end
if(EVENT == 1306)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 12891);
end
end
if(EVENT == 1402)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 12901);
end
end
if(EVENT == 1401)then
NATION = CheckNation(UID);
if(NATION == 2)then
SelectMsg(UID, 4, 685, 21330, 31569, 22, 1402, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1405)then
MonsterCount0 = QuestMonsterCount(UID,685,1);
NATION = CheckNation(UID);
if(NATION == 2)then
if(MonsterCount0 < 25)then
SelectMsg(UID, 2, 685, 192, 31569, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 685, 21330, 31569, 10, 1410, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1410)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
NATION = CheckNation(UID);
if(NATION == 2)then
Check = CheckGiveSlot(UID, 13160);
if(Check == 1)then
RunExchange(UID, 13160);
SaveEvent(UID, 12902);
end
end
end
end
if(EVENT == 1406)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 12903);
end
end
if(EVENT == 1502)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 12985);
end
end
if(EVENT == 1501)then
NATION = CheckNation(UID);
if(NATION == 2)then
SelectMsg(UID, 4, 693, 21344, 31569, 22, 1502, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1505)then
MonsterCount0 = QuestMonsterCount(UID,693,1);
NATION = CheckNation(UID);
if(NATION == 2)then
if(MonsterCount0 < 25)then
SelectMsg(UID, 2, 693, 192, 31569, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 693, 21344, 31569, 10, 1510, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1510)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
NATION = CheckNation(UID);
if(NATION == 2)then
Check = CheckGiveSlot(UID, 13167);
if(Check == 1)then
RunExchange(UID, 13167);
SaveEvent(UID, 12986);
end
end
end
end
if(EVENT == 1506)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 12987);
end
end
if(EVENT == 1602)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 12997);
end
end
if(EVENT == 1601)then
NATION = CheckNation(UID);
if(NATION == 2)then
SelectMsg(UID, 4, 695, 21346, 31569, 22, 1602, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1605)then
MonsterCount0 = QuestMonsterCount(UID,695,1);
NATION = CheckNation(UID);
if(NATION == 2)then
if(MonsterCount0 < 25)then
SelectMsg(UID, 2, 695, 192, 31569, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 695, 21346, 31569, 10, 1610, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1610)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
NATION = CheckNation(UID);
if(NATION == 2)then
Check = CheckGiveSlot(UID, 13168);
if(Check == 1)then
RunExchange(UID, 13168);
SaveEvent(UID, 12998);
end
end
end
end
if(EVENT == 1606)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 12999);
end
end
