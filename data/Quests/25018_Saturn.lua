if(EVENT == 1170)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 3701);
end
end
if(EVENT == 1173)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 3702);
end
end
if(EVENT == 1172)then
NATION = CheckNation(UID);
if(NATION == 1)then
SelectMsg(UID, 4, 1332, 44120, 25018, 22, 1173, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1175)then
MonsterCount0 = QuestMonsterCount(UID,1332,1);
NATION = CheckNation(UID);
if(NATION == 1)then
if(MonsterCount0 < 20)then
SelectMsg(UID, 2, 1332, 192, 25018, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 1332, 44120, 25018, 10, 1181, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1181)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
NATION = CheckNation(UID);
if(NATION == 1)then
Check = CheckGiveSlot(UID, 6126);
if(Check == 1)then
RunExchange(UID, 6126);
SaveEvent(UID, 3703);
end
end
end
end
if(EVENT == 1177)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 3704);
end
end
if(EVENT == 1110)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 3665);
end
end
if(EVENT == 1113)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 3666);
end
end
if(EVENT == 1112)then
NATION = CheckNation(UID);
if(NATION == 1)then
SelectMsg(UID, 4, 1326, 44114, 25018, 22, 1113, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1115)then
ItemCount0 = HowmuchItem(UID,900012000);
NATION = CheckNation(UID);
if(NATION == 1)then
if(ItemCount0 < 0)then
SelectMsg(UID, 2, 1326, 192, 25018, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 1326, 44114, 25018, 10, 1121, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1121)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
ItemCount0 = HowmuchItem(UID,900012000);
if(ItemCount0 < 0)then
else
NATION = CheckNation(UID);
if(NATION == 1)then
Check = CheckGiveSlot(UID, 6120);
if(Check == 1)then
RunExchange(UID, 6120);
SaveEvent(UID, 3667);
end
end
end
end
end
if(EVENT == 1117)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 3668);
end
end
if(EVENT == 1120)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 3671);
end
end
if(EVENT == 1123)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 3672);
end
end
if(EVENT == 1122)then
NATION = CheckNation(UID);
if(NATION == 1)then
SelectMsg(UID, 4, 1327, 44115, 25018, 22, 1123, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1125)then
ItemCount0 = HowmuchItem(UID,900679000);
ItemCount1 = HowmuchItem(UID,900680000);
ItemCount2 = HowmuchItem(UID,900681000);
ItemCount3 = HowmuchItem(UID,900682000);
NATION = CheckNation(UID);
if(NATION == 1)then
if(ItemCount0 < 1 and ItemCount1 < 1 and ItemCount2 < 1 and ItemCount3 < 1)then
SelectMsg(UID, 2, 1327, 192, 25018, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 1327, 44115, 25018, 10, 1131, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1131)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
ItemCount0 = HowmuchItem(UID,900679000);
ItemCount1 = HowmuchItem(UID,900680000);
ItemCount2 = HowmuchItem(UID,900681000);
ItemCount3 = HowmuchItem(UID,900682000);
if(ItemCount0 < 1 and ItemCount1 < 1 and ItemCount2 < 1 and ItemCount3 < 1)then
else
NATION = CheckNation(UID);
if(NATION == 1)then
Check = CheckGiveSlot(UID, 6121);
if(Check == 1)then
RunExchange(UID, 6121);
SaveEvent(UID, 3673);
end
end
end
end
end
if(EVENT == 1127)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 3674);
end
end
if(EVENT == 1130)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 3677);
end
end
if(EVENT == 1133)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 3678);
end
end
if(EVENT == 1132)then
NATION = CheckNation(UID);
if(NATION == 1)then
SelectMsg(UID, 4, 1328, 44116, 25018, 22, 1133, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1135)then
MonsterCount0 = QuestMonsterCount(UID,1328,1);
MonsterCount1 = QuestMonsterCount(UID,1328,2);
MonsterCount2 = QuestMonsterCount(UID,1328,3);
NATION = CheckNation(UID);
if(NATION == 1)then
if(MonsterCount0 < 10 and MonsterCount1 < 10 and MonsterCount2 < 10)then
SelectMsg(UID, 2, 1328, 192, 25018, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 1328, 44116, 25018, 10, 1141, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1141)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
NATION = CheckNation(UID);
if(NATION == 1)then
Check = CheckGiveSlot(UID, 6122);
if(Check == 1)then
RunExchange(UID, 6122);
SaveEvent(UID, 3679);
end
end
end
end
if(EVENT == 1137)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 3680);
end
end
if(EVENT == 1140)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 3683);
end
end
if(EVENT == 1143)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 3684);
end
end
if(EVENT == 1142)then
NATION = CheckNation(UID);
if(NATION == 1)then
SelectMsg(UID, 4, 1329, 44117, 25018, 22, 1143, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1145)then
ItemCount0 = HowmuchItem(UID,900691000);
NATION = CheckNation(UID);
if(NATION == 1)then
if(ItemCount0 < 10)then
SelectMsg(UID, 2, 1329, 192, 25018, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 1329, 44117, 25018, 10, 1151, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1151)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
ItemCount0 = HowmuchItem(UID,900691000);
if(ItemCount0 < 10)then
else
NATION = CheckNation(UID);
if(NATION == 1)then
Check = CheckGiveSlot(UID, 6123);
if(Check == 1)then
RunExchange(UID, 6123);
SaveEvent(UID, 3685);
end
end
end
end
end
if(EVENT == 1147)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 3686);
end
end
if(EVENT == 1150)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 3689);
end
end
if(EVENT == 1153)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 3690);
end
end
if(EVENT == 1152)then
NATION = CheckNation(UID);
if(NATION == 1)then
SelectMsg(UID, 4, 1330, 44118, 25018, 22, 1153, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1155)then
MonsterCount0 = QuestMonsterCount(UID,1330,1);
NATION = CheckNation(UID);
if(NATION == 1)then
if(MonsterCount0 < 1)then
SelectMsg(UID, 2, 1330, 192, 25018, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 1330, 44118, 25018, 10, 1161, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1161)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
NATION = CheckNation(UID);
if(NATION == 1)then
Check = CheckGiveSlot(UID, 6124);
if(Check == 1)then
RunExchange(UID, 6124);
SaveEvent(UID, 3691);
end
end
end
end
if(EVENT == 1157)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 3692);
end
end
if(EVENT == 1160)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 3695);
end
end
if(EVENT == 1163)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 3696);
end
end
if(EVENT == 1162)then
NATION = CheckNation(UID);
if(NATION == 1)then
SelectMsg(UID, 4, 1331, 44119, 25018, 22, 1163, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1165)then
MonsterCount0 = QuestMonsterCount(UID,1331,1);
NATION = CheckNation(UID);
if(NATION == 1)then
if(MonsterCount0 < 20)then
SelectMsg(UID, 2, 1331, 192, 25018, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 1331, 44119, 25018, 10, 1171, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1171)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
NATION = CheckNation(UID);
if(NATION == 1)then
Check = CheckGiveSlot(UID, 6125);
if(Check == 1)then
RunExchange(UID, 6125);
SaveEvent(UID, 3697);
end
end
end
end
if(EVENT == 1167)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 3698);
end
end
if(EVENT == 1180)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 3707);
end
end
if(EVENT == 1183)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 3708);
end
end
if(EVENT == 1182)then
NATION = CheckNation(UID);
if(NATION == 1)then
SelectMsg(UID, 4, 1333, 44121, 25018, 22, 1183, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1185)then
MonsterCount0 = QuestMonsterCount(UID,1333,1);
NATION = CheckNation(UID);
if(NATION == 1)then
if(MonsterCount0 < 20)then
SelectMsg(UID, 2, 1333, 192, 25018, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 1333, 44121, 25018, 10, 1191, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1191)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
NATION = CheckNation(UID);
if(NATION == 1)then
Check = CheckGiveSlot(UID, 6127);
if(Check == 1)then
RunExchange(UID, 6127);
SaveEvent(UID, 3709);
end
end
end
end
if(EVENT == 1187)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 3710);
end
end
if(EVENT == 1190)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 3713);
end
end
if(EVENT == 1193)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 3714);
end
end
if(EVENT == 1192)then
NATION = CheckNation(UID);
if(NATION == 1)then
SelectMsg(UID, 4, 1334, 44122, 25018, 22, 1193, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1195)then
MonsterCount0 = QuestMonsterCount(UID,1334,1);
NATION = CheckNation(UID);
if(NATION == 1)then
if(MonsterCount0 < 20)then
SelectMsg(UID, 2, 1334, 192, 25018, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 1334, 44122, 25018, 10, 1201, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1201)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
NATION = CheckNation(UID);
if(NATION == 1)then
Check = CheckGiveSlot(UID, 6128);
if(Check == 1)then
RunExchange(UID, 6128);
SaveEvent(UID, 3715);
end
end
end
end
if(EVENT == 1197)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 3716);
end
end
if(EVENT == 1200)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 3719);
end
end
if(EVENT == 1203)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 3720);
end
end
if(EVENT == 1202)then
NATION = CheckNation(UID);
if(NATION == 1)then
SelectMsg(UID, 4, 1335, 44123, 25018, 22, 1203, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1205)then
ItemCount0 = HowmuchItem(UID,900012000);
NATION = CheckNation(UID);
if(NATION == 1)then
if(ItemCount0 < 0)then
SelectMsg(UID, 2, 1335, 192, 25018, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 1335, 44123, 25018, 10, 1211, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1211)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
ItemCount0 = HowmuchItem(UID,900012000);
if(ItemCount0 < 0)then
else
NATION = CheckNation(UID);
if(NATION == 1)then
Check = CheckGiveSlot(UID, 6129);
if(Check == 1)then
RunExchange(UID, 6129);
SaveEvent(UID, 3721);
end
end
end
end
end
if(EVENT == 1207)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 3722);
end
end
