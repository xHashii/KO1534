if(EVENT == 1000)then
SelectMsg(UID, 4, 942, 10395, 29196, 22, 1001, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
ItemCount0 = HowmuchItem(UID,508139000);
if(ItemCount0 < 3)then
SelectMsg(UID, 2, 942, 192, 29196, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 942, 10395, 29196, 10, 1009, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
SelectMsg(UID, 4, 943, 10396, 29196, 22, 1001, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
ItemCount0 = HowmuchItem(UID,508141000);
if(ItemCount0 < 3)then
SelectMsg(UID, 2, 943, 192, 29196, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 943, 10396, 29196, 10, 2009, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
SelectMsg(UID, 4, 944, 10397, 29196, 22, 1001, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
ItemCount0 = HowmuchItem(UID,508142000);
if(ItemCount0 < 5)then
SelectMsg(UID, 2, 944, 192, 29196, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 944, 10397, 29196, 10, 3009, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
SelectMsg(UID, 4, 945, 10398, 29196, 22, 1001, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
ItemCount0 = HowmuchItem(UID,508147000);
ItemCount1 = HowmuchItem(UID,508149000);
ItemCount2 = HowmuchItem(UID,508151000);
ItemCount3 = HowmuchItem(UID,508152000);
if(ItemCount0 < 1 and ItemCount1 < 1 and ItemCount2 < 1 and ItemCount3 < 1)then
SelectMsg(UID, 2, 945, 192, 29196, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 945, 10398, 29196, 10, 4009, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1001)then
SaveEvent(UID, 6796);
SaveEvent(UID, 6801);
SaveEvent(UID, 6806);
SaveEvent(UID, 6811);
end
if(EVENT == 1009)then
Check = CheckGiveSlot(UID, 2533);
if(Check ==1)then
RunExchange(UID, 2533);
SaveEvent(UID, 6797);
end
end
if(EVENT == 1005)then
SaveEvent(UID, 6798);
end
if(EVENT == 2009)then
Check = CheckGiveSlot(UID, 2534);
if(Check ==1)then
RunExchange(UID, 2534);
SaveEvent(UID, 6802);
end
end
if(EVENT == 2005)then
SaveEvent(UID, 6803);
end
if(EVENT == 3009)then
Check = CheckGiveSlot(UID, 2535);
if(Check ==1)then
RunExchange(UID, 2535);
SaveEvent(UID, 6807);
end
end
if(EVENT == 3005)then
SaveEvent(UID, 6808);
end
if(EVENT == 4009)then
Check = CheckGiveSlot(UID, 2536);
if(Check ==1)then
RunExchange(UID, 2536);
SaveEvent(UID, 6812);
end
end
if(EVENT == 4005)then
SaveEvent(UID, 6813);
end
