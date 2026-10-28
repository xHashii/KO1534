if(EVENT == 110)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 7691);
end
end
if(EVENT == 113)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 7692);
end
end
if(EVENT == 112)then
NATION = CheckNation(UID);
if(NATION == 2)then
SelectMsg(UID, 4, 1264, 44114, 25004, 22, 113, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 115)then
ItemCount0 = HowmuchItem(UID,900012000);
NATION = CheckNation(UID);
if(NATION == 2)then
if(ItemCount0 < 0)then
SelectMsg(UID, 2, 1264, 192, 25004, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 1264, 44114, 25004, 10, 121, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 121)then
ItemCount0 = HowmuchItem(UID,900012000);
if(ItemCount0 < 0)then
else
NATION = CheckNation(UID);
if(NATION == 2)then
Check = CheckGiveSlot(UID, 6060);
if(Check == 1)then
RunExchange(UID, 6060);
SaveEvent(UID, 7693);
end
end
end
end
if(EVENT == 117)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 7694);
end
end
if(EVENT == 120)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 7697);
end
end
if(EVENT == 123)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 7698);
end
end
if(EVENT == 122)then
NATION = CheckNation(UID);
if(NATION == 2)then
SelectMsg(UID, 4, 1265, 44115, 25004, 22, 123, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 125)then
ItemCount0 = HowmuchItem(UID,900679000);
ItemCount1 = HowmuchItem(UID,900680000);
ItemCount2 = HowmuchItem(UID,900681000);
ItemCount3 = HowmuchItem(UID,900682000);
NATION = CheckNation(UID);
if(NATION == 2)then
if(ItemCount0 < 1 and ItemCount1 < 1 and ItemCount2 < 1 and ItemCount3 < 1)then
SelectMsg(UID, 2, 1265, 192, 25004, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 1265, 44115, 25004, 10, 131, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 131)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
ItemCount0 = HowmuchItem(UID,900679000);
ItemCount1 = HowmuchItem(UID,900680000);
ItemCount2 = HowmuchItem(UID,900681000);
ItemCount3 = HowmuchItem(UID,900682000);
if(ItemCount0 < 1 and ItemCount1 < 1 and ItemCount2 < 1 and ItemCount3 < 1)then
else
NATION = CheckNation(UID);
if(NATION == 2)then
Check = CheckGiveSlot(UID, 6061);
if(Check == 1)then
RunExchange(UID, 6061);
SaveEvent(UID, 7699);
end
end
end
end
end
if(EVENT == 127)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 7700);
end
end
if(EVENT == 130)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 7703);
end
end
if(EVENT == 133)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 7704);
end
end
if(EVENT == 132)then
NATION = CheckNation(UID);
if(NATION == 2)then
SelectMsg(UID, 4, 1266, 44116, 25004, 22, 133, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 135)then
MonsterCount0 = QuestMonsterCount(UID,1266,1);
MonsterCount1 = QuestMonsterCount(UID,1266,2);
MonsterCount2 = QuestMonsterCount(UID,1266,3);
NATION = CheckNation(UID);
if(NATION == 2)then
if(MonsterCount0 < 10 and MonsterCount1 < 10 and MonsterCount2 < 10)then
SelectMsg(UID, 2, 1266, 192, 25004, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 1266, 44116, 25004, 10, 141, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 141)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
NATION = CheckNation(UID);
if(NATION == 2)then
Check = CheckGiveSlot(UID, 6062);
if(Check == 1)then
RunExchange(UID, 6062);
SaveEvent(UID, 7705);
end
end
end
end
if(EVENT == 137)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 7706);
end
end
if(EVENT == 140)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 7709);
end
end
if(EVENT == 143)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 7710);
end
end
if(EVENT == 142)then
NATION = CheckNation(UID);
if(NATION == 2)then
SelectMsg(UID, 4, 1267, 44117, 25004, 22, 143, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 145)then
ItemCount0 = HowmuchItem(UID,900691000);
NATION = CheckNation(UID);
if(NATION == 2)then
if(ItemCount0 < 10)then
SelectMsg(UID, 2, 1267, 192, 25004, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 1267, 44117, 25004, 10, 151, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 151)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
ItemCount0 = HowmuchItem(UID,900691000);
if(ItemCount0 < 10)then
else
NATION = CheckNation(UID);
if(NATION == 2)then
Check = CheckGiveSlot(UID, 6063);
if(Check == 1)then
RunExchange(UID, 6063);
SaveEvent(UID, 7711);
end
end
end
end
end
if(EVENT == 147)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 7712);
end
end
if(EVENT == 150)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 7715);
end
end
if(EVENT == 153)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 7716);
end
end
if(EVENT == 152)then
NATION = CheckNation(UID);
if(NATION == 2)then
SelectMsg(UID, 4, 1268, 44118, 25004, 22, 153, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 155)then
MonsterCount0 = QuestMonsterCount(UID,1268,1);
NATION = CheckNation(UID);
if(NATION == 2)then
if(MonsterCount0 < 1)then
SelectMsg(UID, 2, 1268, 192, 25004, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 1268, 44118, 25004, 10, 161, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 161)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
NATION = CheckNation(UID);
if(NATION == 2)then
Check = CheckGiveSlot(UID, 6064);
if(Check == 1)then
RunExchange(UID, 6064);
SaveEvent(UID, 7717);
end
end
end
end
if(EVENT == 157)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 7718);
end
end
if(EVENT == 160)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 7721);
end
end
if(EVENT == 163)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 7722);
end
end
if(EVENT == 162)then
NATION = CheckNation(UID);
if(NATION == 2)then
SelectMsg(UID, 4, 1269, 44119, 25004, 22, 163, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 165)then
MonsterCount0 = QuestMonsterCount(UID,1269,1);
NATION = CheckNation(UID);
if(NATION == 2)then
if(MonsterCount0 < 20)then
SelectMsg(UID, 2, 1269, 192, 25004, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 1269, 44119, 25004, 10, 171, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 171)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
NATION = CheckNation(UID);
if(NATION == 2)then
Check = CheckGiveSlot(UID, 6065);
if(Check == 1)then
RunExchange(UID, 6065);
SaveEvent(UID, 7723);
end
end
end
end
if(EVENT == 167)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 7724);
end
end
if(EVENT == 170)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 7727);
end
end
if(EVENT == 173)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 7728);
end
end
if(EVENT == 172)then
NATION = CheckNation(UID);
if(NATION == 2)then
SelectMsg(UID, 4, 1270, 44120, 25004, 22, 173, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 175)then
MonsterCount0 = QuestMonsterCount(UID,1270,1);
NATION = CheckNation(UID);
if(NATION == 2)then
if(MonsterCount0 < 20)then
SelectMsg(UID, 2, 1270, 192, 25004, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 1270, 44120, 25004, 10, 181, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 181)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
NATION = CheckNation(UID);
if(NATION == 2)then
Check = CheckGiveSlot(UID, 6066);
if(Check == 1)then
RunExchange(UID, 6066);
SaveEvent(UID, 7729);
end
end
end
end
if(EVENT == 177)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 7730);
end
end
if(EVENT == 180)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 7771);
end
end
if(EVENT == 183)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 7772);
end
end
if(EVENT == 182)then
NATION = CheckNation(UID);
if(NATION == 2)then
SelectMsg(UID, 4, 1271, 44121, 25004, 22, 183, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 185)then
MonsterCount0 = QuestMonsterCount(UID,1271,1);
NATION = CheckNation(UID);
if(NATION == 2)then
if(MonsterCount0 < 20)then
SelectMsg(UID, 2, 1271, 192, 25004, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 1271, 44121, 25004, 10, 191, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 191)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
NATION = CheckNation(UID);
if(NATION == 2)then
Check = CheckGiveSlot(UID, 6067);
if(Check == 1)then
RunExchange(UID, 6067);
SaveEvent(UID, 7773);
end
end
end
end
if(EVENT == 187)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 7774);
end
end
if(EVENT == 190)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 7777);
end
end
if(EVENT == 193)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 7778);
end
end
if(EVENT == 192)then
NATION = CheckNation(UID);
if(NATION == 2)then
SelectMsg(UID, 4, 1272, 44122, 25004, 22, 193, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 195)then
MonsterCount0 = QuestMonsterCount(UID,1272,1);
NATION = CheckNation(UID);
if(NATION == 2)then
if(MonsterCount0 < 20)then
SelectMsg(UID, 2, 1272, 192, 25004, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 1272, 44122, 25004, 10, 201, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 201)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
NATION = CheckNation(UID);
if(NATION == 2)then
Check = CheckGiveSlot(UID, 6068);
if(Check == 1)then
RunExchange(UID, 6068);
SaveEvent(UID, 7779);
end
end
end
end
if(EVENT == 197)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 7780);
end
end
if(EVENT == 200)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 7783);
end
end
if(EVENT == 203)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 7784);
end
end
if(EVENT == 202)then
NATION = CheckNation(UID);
if(NATION == 2)then
SelectMsg(UID, 4, 1273, 44123, 25004, 22, 203, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 205)then
ItemCount0 = HowmuchItem(UID,900012000);
NATION = CheckNation(UID);
if(NATION == 2)then
if(ItemCount0 < 0)then
SelectMsg(UID, 2, 1273, 192, 25004, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 1273, 44123, 25004, 10, 211, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 211)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
NATION = CheckNation(UID);
if(NATION == 2)then
Check = CheckGiveSlot(UID, 6069);
if(Check == 1)then
RunExchange(UID, 6069);
SaveEvent(UID, 7785);
end
end
end
end
if(EVENT == 207)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 7786);
end
end
