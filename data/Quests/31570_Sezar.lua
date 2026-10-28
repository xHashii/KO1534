if(EVENT == 1002)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 12847);
end
end
if(EVENT == 1001)then
NATION = CheckNation(UID);
if(NATION == 1)then
SelectMsg(UID, 4, 676, 21321, 31570, 22, 1002, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1005)then
MonsterCount0 = QuestMonsterCount(UID,676,1);
NATION = CheckNation(UID);
if(NATION == 1)then
if(MonsterCount0 < 25)then
SelectMsg(UID, 2, 676, 192, 31570, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 676, 21321, 31570, 10, 1010, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1010)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
NATION = CheckNation(UID);
if(NATION == 1)then
Check = CheckGiveSlot(UID, 3156);
if(Check == 1)then
RunExchange(UID, 3156);
SaveEvent(UID, 12848);
end
end
end
end
if(EVENT == 1006)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 12849);
end
end
if(EVENT == 1102)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 12859);
end
end
if(EVENT == 1101)then
NATION = CheckNation(UID);
if(NATION == 1)then
SelectMsg(UID, 4, 678, 21323, 31570, 22, 1102, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1105)then
MonsterCount0 = QuestMonsterCount(UID,678,1);
NATION = CheckNation(UID);
if(NATION == 1)then
if(MonsterCount0 < 25)then
SelectMsg(UID, 2, 678, 192, 31570, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 678, 21323, 31570, 10, 1110, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1110)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
NATION = CheckNation(UID);
if(NATION == 1)then
Check = CheckGiveSlot(UID, 3157);
if(Check == 1)then
RunExchange(UID, 3157);
SaveEvent(UID, 12860);
end
end
end
end
if(EVENT == 1106)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 12861);
end
end
if(EVENT == 1202)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 12871);
end
end
if(EVENT == 1201)then
NATION = CheckNation(UID);
if(NATION == 1)then
SelectMsg(UID, 4, 680, 21325, 31570, 22, 1202, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1205)then
MonsterCount0 = QuestMonsterCount(UID,680,1);
NATION = CheckNation(UID);
if(NATION == 1)then
if(MonsterCount0 < 25)then
SelectMsg(UID, 2, 680, 192, 31570, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 680, 21325, 31570, 10, 1210, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1210)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
NATION = CheckNation(UID);
if(NATION == 1)then
Check = CheckGiveSlot(UID, 3158);
if(Check == 1)then
RunExchange(UID, 3158);
SaveEvent(UID, 12872);
end
end
end
end
if(EVENT == 1206)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 12873);
end
end
if(EVENT == 1302)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 12883);
end
end
if(EVENT == 1301)then
NATION = CheckNation(UID);
if(NATION == 1)then
SelectMsg(UID, 4, 682, 21327, 31570, 22, 1302, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1305)then
MonsterCount0 = QuestMonsterCount(UID,682,1);
NATION = CheckNation(UID);
if(NATION == 1)then
if(MonsterCount0 < 25)then
SelectMsg(UID, 2, 682, 192, 31570, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 682, 21327, 31570, 10, 1310, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1310)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
NATION = CheckNation(UID);
if(NATION == 1)then
Check = CheckGiveSlot(UID, 3159);
if(Check == 1)then
RunExchange(UID, 3159);
SaveEvent(UID, 12884);
end
end
end
end
if(EVENT == 1306)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 12885);
end
end
if(EVENT == 1402)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 12895);
end
end
if(EVENT == 1401)then
NATION = CheckNation(UID);
if(NATION == 1)then
SelectMsg(UID, 4, 684, 21329, 31570, 22, 1402, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1405)then
MonsterCount0 = QuestMonsterCount(UID,684,1);
NATION = CheckNation(UID);
if(NATION == 1)then
if(MonsterCount0 < 25)then
SelectMsg(UID, 2, 684, 192, 31570, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 684, 21329, 31570, 10, 1410, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1410)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
NATION = CheckNation(UID);
if(NATION == 1)then
Check = CheckGiveSlot(UID, 3160);
if(Check == 1)then
RunExchange(UID, 3160);
SaveEvent(UID, 12896);
end
end
end
end
if(EVENT == 1406)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 12897);
end
end
if(EVENT == 1502)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 12979);
end
end
if(EVENT == 1501)then
NATION = CheckNation(UID);
if(NATION == 1)then
SelectMsg(UID, 4, 692, 21343, 31570, 22, 1502, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1505)then
MonsterCount0 = QuestMonsterCount(UID,692,1);
NATION = CheckNation(UID);
if(NATION == 1)then
if(MonsterCount0 < 25)then
SelectMsg(UID, 2, 692, 192, 31570, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 692, 21343, 31570, 10, 1510, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1510)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
NATION = CheckNation(UID);
if(NATION == 1)then
Check = CheckGiveSlot(UID, 3167);
if(Check == 1)then
RunExchange(UID, 3167);
SaveEvent(UID, 12980);
end
end
end
end
if(EVENT == 1506)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 12981);
end
end
if(EVENT == 1602)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 12991);
end
end
if(EVENT == 1601)then
NATION = CheckNation(UID);
if(NATION == 1)then
SelectMsg(UID, 4, 694, 21345, 31570, 22, 1602, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1605)then
MonsterCount0 = QuestMonsterCount(UID,694,1);
NATION = CheckNation(UID);
if(NATION == 1)then
if(MonsterCount0 < 25)then
SelectMsg(UID, 2, 694, 192, 31570, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 694, 21345, 31570, 10, 1610, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1610)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
NATION = CheckNation(UID);
if(NATION == 1)then
Check = CheckGiveSlot(UID, 3168);
if(Check == 1)then
RunExchange(UID, 3168);
SaveEvent(UID, 12992);
end
end
end
end
if(EVENT == 1606)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 12993);
end
end
