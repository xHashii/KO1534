if(EVENT == 1000)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 11565);
end
end
if(EVENT == 1003)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 11566);
end
ItemCount0 = HowmuchItem(UID,900012000);
if(NATION == 1)then
if(ItemCount0 < 0)then
SelectMsg(UID, 2, 558, 192, 31518, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 558, 20084, 31518, 10, 4, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1002)then
NATION = CheckNation(UID);
if(NATION == 1)then
SelectMsg(UID, 4, 558, 20084, 31518, 22, 1003, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1100)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 11577);
end
end
if(EVENT == 1103)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 11578);
end
end
if(EVENT == 1102)then
NATION = CheckNation(UID);
if(NATION == 1)then
SelectMsg(UID, 4, 559, 20086, 31518, 22, 1103, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1105)then
MonsterCount0 = QuestMonsterCount(UID,559,1);
NATION = CheckNation(UID);
if(NATION == 1)then
if(MonsterCount0 < 40)then
SelectMsg(UID, 2, 559, 192, 31518, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 559, 20086, 31518, 10, 1110, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1110)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
NATION = CheckNation(UID);
if(NATION == 1)then
Check = CheckGiveSlot(UID, 3049);
if(Check == 1)then
RunExchange(UID, 3049);
SaveEvent(UID, 11579);
end
end
end
end
if(EVENT == 1106)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 11580);
end
end
if(EVENT == 1200)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 11589);
end
end
if(EVENT == 1203)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 11590);
end
end
if(EVENT == 1202)then
NATION = CheckNation(UID);
if(NATION == 1)then
SelectMsg(UID, 4, 560, 20088, 31518, 22, 1203, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1205)then
MonsterCount0 = QuestMonsterCount(UID,560,1);
MonsterCount1 = QuestMonsterCount(UID,560,2);
NATION = CheckNation(UID);
if(NATION == 1)then
if(MonsterCount0 < 30 and MonsterCount1 < 30)then
SelectMsg(UID, 2, 560, 192, 31518, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 560, 20088, 31518, 10, 1210, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1210)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
NATION = CheckNation(UID);
if(NATION == 1)then
Check = CheckGiveSlot(UID, 3050);
if(Check == 1)then
RunExchange(UID, 3050);
SaveEvent(UID, 11591);
end
end
end
end
if(EVENT == 1206)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 11592);
end
end
if(EVENT == 1300)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 11601);
end
end
if(EVENT == 1303)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 11602);
end
end
if(EVENT == 1302)then
NATION = CheckNation(UID);
if(NATION == 1)then
SelectMsg(UID, 4, 561, 20090, 31518, 22, 1303, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1305)then
MonsterCount0 = QuestMonsterCount(UID,561,1);
NATION = CheckNation(UID);
if(NATION == 1)then
if(MonsterCount0 < 30)then
SelectMsg(UID, 2, 561, 192, 31518, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 561, 20090, 31518, 10, 1310, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1310)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
NATION = CheckNation(UID);
if(NATION == 1)then
Check = CheckGiveSlot(UID, 3051);
if(Check == 1)then
RunExchange(UID, 3051);
SaveEvent(UID, 11603);
end
end
end
end
if(EVENT == 1306)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 11604);
end
end
