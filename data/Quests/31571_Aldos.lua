if(EVENT == 1002)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 12913);
end
end
if(EVENT == 1001)then
NATION = CheckNation(UID);
if(NATION == 2)then
SelectMsg(UID, 4, 686, 21332, 31571, 22, 1002, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1003)then
ItemCount0 = HowmuchItem(UID,900012000);
NATION = CheckNation(UID);
if(NATION == 2)then
if(ItemCount0 < 0)then
SelectMsg(UID, 2, 686, 192, 31571, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 686, 21332, 31571, 10, 1010, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1010)then
ItemCount0 = HowmuchItem(UID,900012000);
if(ItemCount0 < 0)then
else
NATION = CheckNation(UID);
if(NATION == 2)then
Check = CheckGiveSlot(UID, 3161);
if(Check == 1)then
RunExchange(UID, 3161);
SaveEvent(UID, 12914);
end
end
end
end
if(EVENT == 1006)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 12915);
end
end
if(EVENT == 1102)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 12925);
end
end
if(EVENT == 1101)then
NATION = CheckNation(UID);
if(NATION == 2)then
SelectMsg(UID, 4, 687, 21334, 31571, 22, 1102, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1105)then
ItemCount0 = HowmuchItem(UID,379061000);
ItemCount1 = HowmuchItem(UID,389020000);
NATION = CheckNation(UID);
if(NATION == 2)then
if(ItemCount0 < 50 and ItemCount1 < 20)then
SelectMsg(UID, 2, 687, 192, 31571, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 687, 21334, 31571, 10, 1110, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1110)then
ItemCount0 = HowmuchItem(UID,379061000);
ItemCount1 = HowmuchItem(UID,389020000);
if(ItemCount0 < 50 and ItemCount1 < 20)then
else
NATION = CheckNation(UID);
if(NATION == 2)then
Check = CheckGiveSlot(UID, 3162);
if(Check == 1)then
RunExchange(UID, 3162);
SaveEvent(UID, 12926);
end
end
end
end
if(EVENT == 1106)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 12927);
end
end
if(EVENT == 1202)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 12937);
end
end
if(EVENT == 1201)then
NATION = CheckNation(UID);
if(NATION == 2)then
SelectMsg(UID, 4, 688, 21336, 31571, 22, 1202, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1205)then
ItemCount0 = HowmuchItem(UID,389480000);
NATION = CheckNation(UID);
if(NATION == 2)then
if(ItemCount0 < 5)then
SelectMsg(UID, 2, 688, 192, 31571, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 688, 21336, 31571, 10, 1210, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1210)then
ItemCount0 = HowmuchItem(UID,389480000);
if(ItemCount0 < 5)then
else
NATION = CheckNation(UID);
if(NATION == 2)then
Check = CheckGiveSlot(UID, 3163);
if(Check == 1)then
RunExchange(UID, 3163);
SaveEvent(UID, 12938);
end
end
end
end
if(EVENT == 1206)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 12939);
end
end
if(EVENT == 1302)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 12949);
end
end
if(EVENT == 1301)then
NATION = CheckNation(UID);
if(NATION == 2)then
SelectMsg(UID, 4, 689, 21338, 31571, 22, 1302, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1305)then
ItemCount0 = HowmuchItem(UID,389470000);
NATION = CheckNation(UID);
if(NATION == 2)then
if(ItemCount0 < 5)then
SelectMsg(UID, 2, 689, 192, 31571, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 689, 21338, 31571, 10, 1310, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1310)then
ItemCount0 = HowmuchItem(UID,389470000);
if(ItemCount0 < 5)then
else
NATION = CheckNation(UID);
if(NATION == 2)then
Check = CheckGiveSlot(UID, 3164);
if(Check == 1)then
RunExchange(UID, 3164);
SaveEvent(UID, 12950);
end
end
end
end
if(EVENT == 1306)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 12951);
end
end
if(EVENT == 1402)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 12961);
end
end
if(EVENT == 1401)then
NATION = CheckNation(UID);
if(NATION == 2)then
SelectMsg(UID, 4, 690, 21340, 31571, 22, 1402, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1405)then
ItemCount0 = HowmuchItem(UID,389750000);
NATION = CheckNation(UID);
if(NATION == 2)then
if(ItemCount0 < 5)then
SelectMsg(UID, 2, 690, 192, 31571, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 690, 21340, 31571, 10, 1410, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1410)then
ItemCount0 = HowmuchItem(UID,389750000);
if(ItemCount0 < 5)then
else
NATION = CheckNation(UID);
if(NATION == 2)then
Check = CheckGiveSlot(UID, 3165);
if(Check == 1)then
RunExchange(UID, 3165);
SaveEvent(UID, 12962);
end
end
end
end
if(EVENT == 1406)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 12963);
end
end
if(EVENT == 1502)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 12973);
end
end
if(EVENT == 1501)then
NATION = CheckNation(UID);
if(NATION == 2)then
SelectMsg(UID, 4, 691, 21342, 31571, 22, 1502, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1505)then
ItemCount0 = HowmuchItem(UID,389560000);
NATION = CheckNation(UID);
if(NATION == 2)then
if(ItemCount0 < 5)then
SelectMsg(UID, 2, 691, 192, 31571, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 691, 21342, 31571, 10, 1510, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1510)then
ItemCount0 = HowmuchItem(UID,389560000);
if(ItemCount0 < 5)then
else
NATION = CheckNation(UID);
if(NATION == 2)then
Check = CheckGiveSlot(UID, 3166);
if(Check == 1)then
RunExchange(UID, 3166);
SaveEvent(UID, 12974);
end
end
end
end
if(EVENT == 1506)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 12975);
end
end
