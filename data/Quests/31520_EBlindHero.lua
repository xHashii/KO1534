if(EVENT == 1000)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 11409);
end
end
if(EVENT == 1003)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 11410);
end
ItemCount0 = HowmuchItem(UID,900012000);
if(NATION == 2)then
if(ItemCount0 < 0)then
SelectMsg(UID, 2, 547, 192, 31520, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 547, 20063, 31520, 10, 4, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1002)then
NATION = CheckNation(UID);
if(NATION == 2)then
SelectMsg(UID, 4, 547, 20063, 31520, 22, 1003, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1100)then
NATION = CheckNation(UID);
ClassCheck = JobGroupCheck( UID, 1 )
if(NATION == 2 and ClassCheck == 1)then
SaveEvent(UID, 11436);
end
ClassCheck = JobGroupCheck( UID, 2 )
if(NATION == 2 and ClassCheck == 1)then
SaveEvent(UID, 11441);
end
ClassCheck = JobGroupCheck( UID, 3 )
if(NATION == 2 and ClassCheck == 1)then
SaveEvent(UID, 11446);
end
ClassCheck = JobGroupCheck( UID, 4 )
if(NATION == 2 and ClassCheck == 1)then
SaveEvent(UID, 11451);
end
end
if(EVENT == 1102)then
NATION = CheckNation(UID);
ClassCheck = JobGroupCheck (UID,1);
if(NATION == 2 and ClassCheck == 1)then
SaveEvent(UID, 11437);
end
ClassCheck = JobGroupCheck (UID,2);
if(NATION == 2 and ClassCheck == 1)then
SaveEvent(UID, 11442);
end
ClassCheck = JobGroupCheck (UID,3);
if(NATION == 2 and ClassCheck == 1)then
SaveEvent(UID, 11447);
end
ClassCheck = JobGroupCheck (UID,4);
if(NATION == 2 and ClassCheck == 1)then
SaveEvent(UID, 11452);
end
end
if(EVENT == 1101)then
NATION = CheckNation(UID);
ClassCheck = JobGroupCheck (UID,1);
if(NATION == 2 and ClassCheck == 1)then
SelectMsg(UID, 4, 548, 20065, 31520, 22, 1102, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
ClassCheck = JobGroupCheck (UID,2);
if(NATION == 2 and ClassCheck == 1)then
SelectMsg(UID, 4, 548, 20065, 31520, 22, 1102, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
ClassCheck = JobGroupCheck (UID,3);
if(NATION == 2 and ClassCheck == 1)then
SelectMsg(UID, 4, 548, 20065, 31520, 22, 1102, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
ClassCheck = JobGroupCheck (UID,4);
if(NATION == 2 and ClassCheck == 1)then
SelectMsg(UID, 4, 548, 20065, 31520, 22, 1102, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1105)then
ItemCount0 = HowmuchItem(UID,508108000);
NATION = CheckNation(UID);
if(NATION == 2)then
if(ItemCount0 < 5)then
SelectMsg(UID, 2, 548, 192, 31520, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 548, 20065, 31520, 10, 1108, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1108)then
ItemCount0 = HowmuchItem(UID,508108000);
if(ItemCount0 < 5)then
else
NATION = CheckNation(UID);
ClassCheck = JobGroupCheck (UID,1);
if(NATION == 2 and ClassCheck == 1)then
Check = CheckGiveSlot(UID, 3035);
if(Check == 1)then
RunExchange(UID, 3035);
SaveEvent(UID, 11438);
end
end
end
ClassCheck = JobGroupCheck (UID,2);
if(NATION == 2 and ClassCheck == 1)then
Check = CheckGiveSlot(UID, 3036);
if(Check == 1)then
RunExchange(UID, 3036);
SaveEvent(UID, 11443);
end

end
ClassCheck = JobGroupCheck (UID,3);
if(NATION == 2 and ClassCheck == 1)then
Check = CheckGiveSlot(UID, 3037);
if(Check == 1)then
RunExchange(UID, 3037);
SaveEvent(UID, 11448);
end

end
ClassCheck = JobGroupCheck (UID,4);
if(NATION == 2 and ClassCheck == 1)then
Check = CheckGiveSlot(UID, 3038);
if(Check == 1)then
RunExchange(UID, 3038);
SaveEvent(UID, 11453);
end

end
end
if(EVENT == 1104)then
NATION = CheckNation(UID);
ClassCheck = JobGroupCheck (UID,1);
if(NATION == 2 and ClassCheck == 1)then
SaveEvent(UID, 11439);
end
ClassCheck = JobGroupCheck (UID,2);
if(NATION == 2 and ClassCheck == 1)then
SaveEvent(UID, 11444);
end
ClassCheck = JobGroupCheck (UID,3);
if(NATION == 2 and ClassCheck == 1)then
SaveEvent(UID, 11449);
end
ClassCheck = JobGroupCheck (UID,4);
if(NATION == 2 and ClassCheck == 1)then
SaveEvent(UID, 11454);
end
end
if(EVENT == 1200)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 11463);
end
end
if(EVENT == 1202)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 11464);
end
end
if(EVENT == 1201)then
NATION = CheckNation(UID);
if(NATION == 2)then
SelectMsg(UID, 4, 549, 20067, 31520, 22, 1202, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1205)then
ItemCount0 = HowmuchItem(UID,910228000);
NATION = CheckNation(UID);
if(NATION == 2)then
if(ItemCount0 < 1)then
SelectMsg(UID, 2, 549, 192, 31520, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 549, 20067, 31520, 10, 1208, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1208)then
ItemCount0 = HowmuchItem(UID,910228000);
if(ItemCount0 < 1)then
else
NATION = CheckNation(UID);
if(NATION == 2)then
Check = CheckGiveSlot(UID, 3039);
if(Check == 1)then
RunExchange(UID, 3039);
SaveEvent(UID, 11465);
end
end
end
end
if(EVENT == 1204)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 11466);
end
end
if(EVENT == 1300)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 11523);
end
end
if(EVENT == 1303)then
NATION = CheckNation(UID);
if(NATION == 2)then
SaveEvent(UID, 11524);
end
ItemCount0 = HowmuchItem(UID,900012000);
if(NATION == 2)then
if(ItemCount0 < 0)then
SelectMsg(UID, 2, 554, 192, 31520, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 554, 20077, 31520, 10, 4, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
end
if(EVENT == 1302)then
NATION = CheckNation(UID);
if(NATION == 2)then
SelectMsg(UID, 4, 554, 20077, 31520, 22, 1303, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
