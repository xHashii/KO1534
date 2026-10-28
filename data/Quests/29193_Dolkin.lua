if(EVENT == 1000)then
SelectMsg(UID, 4, 946, 10399, 29193, 22, 1001, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
ItemCount0 = HowmuchItem(UID,508143000);
if(ItemCount0 < 3)then
SelectMsg(UID, 2, 946, 192, 29193, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 946, 10399, 29193, 10, 1009, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
SelectMsg(UID, 4, 947, 10400, 29193, 22, 1001, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
ItemCount0 = HowmuchItem(UID,508144000);
if(ItemCount0 < 3)then
SelectMsg(UID, 2, 947, 192, 29193, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 947, 10400, 29193, 10, 2009, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
SelectMsg(UID, 4, 948, 10401, 29193, 22, 1001, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
ItemCount0 = HowmuchItem(UID,508147000);
ItemCount1 = HowmuchItem(UID,508149000);
ItemCount2 = HowmuchItem(UID,508151000);
ItemCount3 = HowmuchItem(UID,508152000);
if(ItemCount0 < 1 and ItemCount1 < 1 and ItemCount2 < 1 and ItemCount3 < 1)then
SelectMsg(UID, 2, 948, 192, 29193, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 948, 10401, 29193, 10, 4009, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1001)then
SaveEvent(UID, 6816);
SaveEvent(UID, 6821);
SaveEvent(UID, 6826);
end
if(EVENT == 1009)then
Check = CheckGiveSlot(UID, 2537);
if(Check ==1)then
RunExchange(UID, 2537);
SaveEvent(UID, 6817);
end
end
if(EVENT == 1005)then
SaveEvent(UID, 6818);
end
if(EVENT == 2009)then
Check = CheckGiveSlot(UID, 2538);
if(Check ==1)then
RunExchange(UID, 2538);
SaveEvent(UID, 6822);
end
end
if(EVENT == 2005)then
SaveEvent(UID, 6823);
end
if(EVENT == 4009)then
Check = CheckGiveSlot(UID, 2539);
if(Check ==1)then
RunExchange(UID, 2539);
SaveEvent(UID, 6827);
end
end
if(EVENT == 4005)then
SaveEvent(UID, 6828);
end
