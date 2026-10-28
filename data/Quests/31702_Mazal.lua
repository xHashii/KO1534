if(EVENT == 1000)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 11841);
end
end
if(EVENT == 1003)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 11842);
end
ItemCount0 = HowmuchItem(UID,900012000);
if(NATION == 1)then
if(ItemCount0 < 0)then
SelectMsg(UID, 2, 581, 192, 31702, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 581, 20732, 31702, 10, 4, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1002)then
NATION = CheckNation(UID);
if(NATION == 1)then
SelectMsg(UID, 4, 581, 20732, 31702, 22, 1003, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1100)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 11853);
end
end
if(EVENT == 1103)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 11854);
end
end
if(EVENT == 1102)then
NATION = CheckNation(UID);
if(NATION == 1)then
SelectMsg(UID, 4, 582, 20734, 31702, 22, 1103, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1105)then
ItemCount0 = HowmuchItem(UID,508110000);
ItemCount1 = HowmuchItem(UID,508109000);
NATION = CheckNation(UID);
if(NATION == 1)then
if(ItemCount0 < 3 and ItemCount1 < 3)then
SelectMsg(UID, 2, 582, 192, 31702, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 582, 20734, 31702, 10, 1110, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1110)then
ItemCount0 = HowmuchItem(UID,508110000);
ItemCount1 = HowmuchItem(UID,508109000);
if(ItemCount0 < 3 and ItemCount1 < 3)then
else
NATION = CheckNation(UID);
if(NATION == 1)then
Check = CheckGiveSlot(UID, 3072);
if(Check == 1)then
RunExchange(UID, 3072);
SaveEvent(UID, 11855);
end
end
end
end
if(EVENT == 1106)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 11856);
end
end
if(EVENT == 1200)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 11889);
end
end
if(EVENT == 1203)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 11890);
end
end
if(EVENT == 1202)then
NATION = CheckNation(UID);
if(NATION == 1)then
SelectMsg(UID, 4, 585, 20740, 31702, 22, 1203, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1205)then
ItemCount0 = HowmuchItem(UID,910236000);
NATION = CheckNation(UID);
if(NATION == 1)then
if(ItemCount0 < 1)then
SelectMsg(UID, 2, 585, 192, 31702, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 585, 20740, 31702, 10, 1210, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1210)then
ItemCount0 = HowmuchItem(UID,910236000);
if(ItemCount0 < 1)then
else
NATION = CheckNation(UID);
if(NATION == 1)then
Check = CheckGiveSlot(UID, 3075);
if(Check == 1)then
RunExchange(UID, 3075);
SaveEvent(UID, 11891);
end
end
end
end
if(EVENT == 1206)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 11892);
end
end
if(EVENT == 1300)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 12009);
end
end
if(EVENT == 1303)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 12010);
end
ItemCount0 = HowmuchItem(UID,900012000);
if(NATION == 1)then
if(ItemCount0 < 0)then
SelectMsg(UID, 2, 596, 192, 31702, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 596, 20760, 31702, 10, 4, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1302)then
NATION = CheckNation(UID);
if(NATION == 1)then
SelectMsg(UID, 4, 596, 20760, 31702, 22, 1303, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1400)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 12069);
end
end
if(EVENT == 1403)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 12070);
end
ItemCount0 = HowmuchItem(UID,900012000);
if(NATION == 1)then
if(ItemCount0 < 0)then
SelectMsg(UID, 2, 601, 192, 31702, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 601, 20770, 31702, 10, 4, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1402)then
NATION = CheckNation(UID);
if(NATION == 1)then
SelectMsg(UID, 4, 601, 20770, 31702, 22, 1403, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1500)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 12117);
end
end
if(EVENT == 1503)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 12118);
end
end
if(EVENT == 1502)then
NATION = CheckNation(UID);
if(NATION == 1)then
SelectMsg(UID, 4, 605, 20778, 31702, 22, 1503, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1505)then
ItemCount0 = HowmuchItem(UID,910240000);
NATION = CheckNation(UID);
if(NATION == 1)then
if(ItemCount0 < 1)then
SelectMsg(UID, 2, 605, 192, 31702, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 605, 20778, 31702, 10, 1510, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1510)then
ItemCount0 = HowmuchItem(UID,910240000);
if(ItemCount0 < 1)then
else
NATION = CheckNation(UID);
if(NATION == 1)then
Check = CheckGiveSlot(UID, 3094);
if(Check == 1)then
RunExchange(UID, 3094);
SaveEvent(UID, 12119);
end
end
end
end
if(EVENT == 1506)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 12120);
end
end
if(EVENT == 1600)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 12129);
end
end
if(EVENT == 1603)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 12130);
end
end
if(EVENT == 1602)then
NATION = CheckNation(UID);
if(NATION == 1)then
SelectMsg(UID, 4, 606, 20780, 31702, 22, 1603, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1605)then
MonsterCount0 = QuestMonsterCount(UID,606,1);
MonsterCount1 = QuestMonsterCount(UID,606,2);
NATION = CheckNation(UID);
if(NATION == 1)then
if(MonsterCount0 < 40 and MonsterCount1 < 40)then
SelectMsg(UID, 2, 606, 192, 31702, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 606, 20780, 31702, 10, 1610, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1610)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
NATION = CheckNation(UID);
if(NATION == 1)then
Check = CheckGiveSlot(UID, 3095);
if(Check == 1)then
RunExchange(UID, 3095);
SaveEvent(UID, 12131);
end
end
end
end
if(EVENT == 1606)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 12132);
end
end
if(EVENT == 1700)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 12189);
end
end
if(EVENT == 1703)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 12190);
end
ItemCount0 = HowmuchItem(UID,900012000);
if(NATION == 1)then
if(ItemCount0 < 0)then
SelectMsg(UID, 2, 611, 192, 31702, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 611, 20790, 31702, 10, 4, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1702)then
NATION = CheckNation(UID);
if(NATION == 1)then
SelectMsg(UID, 4, 611, 20790, 31702, 22, 1703, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1800)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 12201);
end
end
if(EVENT == 1803)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 12202);
end
end
if(EVENT == 1802)then
NATION = CheckNation(UID);
if(NATION == 1)then
SelectMsg(UID, 4, 612, 20792, 31702, 22, 1803, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1805)then
MonsterCount0 = QuestMonsterCount(UID,612,1);
NATION = CheckNation(UID);
if(NATION == 1)then
if(MonsterCount0 < 100)then
SelectMsg(UID, 2, 612, 192, 31702, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 612, 20792, 31702, 10, 1810, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1810)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
NATION = CheckNation(UID);
if(NATION == 1)then
Check = CheckGiveSlot(UID, 3101);
if(Check == 1)then
RunExchange(UID, 3101);
SaveEvent(UID, 12203);
end
end
end
end
if(EVENT == 1806)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 12204);
end
end
if(EVENT == 1900)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 12213);
end
end
if(EVENT == 1903)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 12214);
end
end
if(EVENT == 1902)then
NATION = CheckNation(UID);
if(NATION == 1)then
SelectMsg(UID, 4, 613, 20794, 31702, 22, 1903, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1905)then
MonsterCount0 = QuestMonsterCount(UID,613,1);
NATION = CheckNation(UID);
if(NATION == 1)then
if(MonsterCount0 < 100)then
SelectMsg(UID, 2, 613, 192, 31702, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 613, 20794, 31702, 10, 1910, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1910)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
NATION = CheckNation(UID);
if(NATION == 1)then
Check = CheckGiveSlot(UID, 3102);
if(Check == 1)then
RunExchange(UID, 3102);
SaveEvent(UID, 12215);
end
end
end
end
if(EVENT == 1906)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 12216);
end
end
