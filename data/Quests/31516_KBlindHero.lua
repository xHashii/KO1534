if(EVENT == 1000)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 11403);
end
end
if(EVENT == 1003)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 11404);
end
ItemCount0 = HowmuchItem(UID,900012000);
if(NATION == 1)then
if(ItemCount0 < 0)then
SelectMsg(UID, 2, 547, 192, 31516, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 547, 20062, 31516, 10, 4, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1002)then
NATION = CheckNation(UID);
if(NATION == 1)then
SelectMsg(UID, 4, 547, 20062, 31516, 22, 1003, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1100)then
NATION = CheckNation(UID);
ClassCheck = JobGroupCheck( UID, 1 )
if(NATION == 1 and ClassCheck == 1)then
SaveEvent(UID, 11415);
end
ClassCheck = JobGroupCheck( UID, 2 )
if(NATION == 1 and ClassCheck == 1)then
SaveEvent(UID, 11420);
end
ClassCheck = JobGroupCheck( UID, 3 )
if(NATION == 1 and ClassCheck == 1)then
SaveEvent(UID, 11425);
end
ClassCheck = JobGroupCheck( UID, 4 )
if(NATION == 1 and ClassCheck == 1)then
SaveEvent(UID, 11430);
end
end
if(EVENT == 1102)then
NATION = CheckNation(UID);
ClassCheck = JobGroupCheck (UID,1);
if(NATION == 1 and ClassCheck == 1)then
SaveEvent(UID, 11416);
end
ClassCheck = JobGroupCheck (UID,2);
if(NATION == 1 and ClassCheck == 1)then
SaveEvent(UID, 11421);
end
ClassCheck = JobGroupCheck (UID,3);
if(NATION == 1 and ClassCheck == 1)then
SaveEvent(UID, 11426);
end
ClassCheck = JobGroupCheck (UID,4);
if(NATION == 1 and ClassCheck == 1)then
SaveEvent(UID, 11431);
end
end
if(EVENT == 1101)then
NATION = CheckNation(UID);
ClassCheck = JobGroupCheck (UID,1);
if(NATION == 1 and ClassCheck == 1)then
SelectMsg(UID, 4, 548, 20064, 31516, 22, 1102, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
ClassCheck = JobGroupCheck (UID,2);
if(NATION == 1 and ClassCheck == 1)then
SelectMsg(UID, 4, 548, 20064, 31516, 22, 1102, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
ClassCheck = JobGroupCheck (UID,3);
if(NATION == 1 and ClassCheck == 1)then
SelectMsg(UID, 4, 548, 20064, 31516, 22, 1102, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
ClassCheck = JobGroupCheck (UID,4);
if(NATION == 1 and ClassCheck == 1)then
SelectMsg(UID, 4, 548, 20064, 31516, 22, 1102, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1105)then
ItemCount0 = HowmuchItem(UID,508108000);
NATION = CheckNation(UID);
if(NATION == 1)then
if(ItemCount0 < 5)then
SelectMsg(UID, 2, 548, 192, 31516, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 548, 20064, 31516, 10, 1108, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1108)then
ItemCount0 = HowmuchItem(UID,508108000);
if(ItemCount0 < 5)then
else
NATION = CheckNation(UID);
ClassCheck = JobGroupCheck (UID,1);
if(NATION == 1 and ClassCheck == 1)then
Check = CheckGiveSlot(UID, 3035);
if(Check == 1)then
RunExchange(UID, 3035);
SaveEvent(UID, 11417);
end

end
ClassCheck = JobGroupCheck (UID,2);
if(NATION == 1 and ClassCheck == 1)then
Check = CheckGiveSlot(UID, 3036);
if(Check == 1)then
RunExchange(UID, 3036);
SaveEvent(UID, 11422);
end

end
ClassCheck = JobGroupCheck (UID,3);
if(NATION == 1 and ClassCheck == 1)then
Check = CheckGiveSlot(UID, 3037);
if(Check == 1)then
RunExchange(UID, 3037);
SaveEvent(UID, 11427);
end

end
ClassCheck = JobGroupCheck (UID,4);
if(NATION == 1 and ClassCheck == 1)then
Check = CheckGiveSlot(UID, 3038);
if(Check == 1)then
RunExchange(UID, 3038);
SaveEvent(UID, 11432);
end
end
end
end
if(EVENT == 1104)then
NATION = CheckNation(UID);
ClassCheck = JobGroupCheck (UID,1);
if(NATION == 1 and ClassCheck == 1)then
SaveEvent(UID, 11418);
end
ClassCheck = JobGroupCheck (UID,2);
if(NATION == 1 and ClassCheck == 1)then
SaveEvent(UID, 11423);
end
ClassCheck = JobGroupCheck (UID,3);
if(NATION == 1 and ClassCheck == 1)then
SaveEvent(UID, 11428);
end
ClassCheck = JobGroupCheck (UID,4);
if(NATION == 1 and ClassCheck == 1)then
SaveEvent(UID, 11433);
end
end
if(EVENT == 1200)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 11457);
end
end
if(EVENT == 1202)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 11458);
end
end
if(EVENT == 1201)then
NATION = CheckNation(UID);
if(NATION == 1)then
SelectMsg(UID, 4, 549, 20066, 31516, 22, 1202, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1205)then
ItemCount0 = HowmuchItem(UID,910228000);
NATION = CheckNation(UID);
if(NATION == 1)then
if(ItemCount0 < 1)then
SelectMsg(UID, 2, 549, 192, 31516, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 549, 20066, 31516, 10, 1208, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1208)then
ItemCount0 = HowmuchItem(UID,910228000);
if(ItemCount0 < 1)then
else
NATION = CheckNation(UID);
if(NATION == 1)then
Check = CheckGiveSlot(UID, 3039);
if(Check == 1)then
RunExchange(UID, 3039);
SaveEvent(UID, 11459);
end
end
end
end
if(EVENT == 1204)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 11460);
end
end
if(EVENT == 1300)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 11517);
end
end
if(EVENT == 1303)then
NATION = CheckNation(UID);
if(NATION == 1)then
SaveEvent(UID, 11518);
end
ItemCount0 = HowmuchItem(UID,900012000);
if(NATION == 1)then
if(ItemCount0 < 0)then
SelectMsg(UID, 2, 554, 192, 31516, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 554, 20076, 31516, 10, 4, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1302)then
NATION = CheckNation(UID);
if(NATION == 1)then
SelectMsg(UID, 4, 554, 20076, 31516, 22, 1303, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
