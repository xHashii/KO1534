if(EVENT == 1000)then
SelectMsg(UID, 4, 939, 10392, 29195, 22, 1001, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
SelectMsg(UID, 4, 940, 10393, 29195, 22, 1001, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
SelectMsg(UID, 4, 941, 10394, 29195, 22, 1001, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
ItemCount0 = HowmuchItem(UID,508147000);
ItemCount1 = HowmuchItem(UID,508149000);
ItemCount2 = HowmuchItem(UID,508151000);
ItemCount3 = HowmuchItem(UID,508152000);
if(ItemCount0 < 1 and ItemCount1 < 1 and ItemCount2 < 1 and ItemCount3 < 1)then
SelectMsg(UID, 2, 941, 192, 29195, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 941, 10394, 29195, 10, 4009, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1001)then
SaveEvent(UID, 6781);
ItemCount0 = HowmuchItem(UID,508137000);
if(ItemCount0 < 3)then
SelectMsg(UID, 2, 939, 192, 29195, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 939, 10392, 29195, 10, 1009, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
SaveEvent(UID, 6786);
SaveEvent(UID, 6791);
end
if(EVENT == 1009)then
Check = CheckGiveSlot(UID, 2530);
if(Check ==1)then
RunExchange(UID, 2530);
SaveEvent(UID, 6782);
end
end
if(EVENT == 1005)then
SaveEvent(UID, 6783);
end
if(EVENT == 2001)then
ItemCount0 = HowmuchItem(UID,508138000);
if(ItemCount0 < 3)then
SelectMsg(UID, 2, 940, 192, 29195, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 940, 10393, 29195, 10, 2009, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 2009)then
Check = CheckGiveSlot(UID, 2531);
if(Check ==1)then
RunExchange(UID, 2531);
SaveEvent(UID, 6787);
end
end
if(EVENT == 2005)then
SaveEvent(UID, 6788);
end
if(EVENT == 4009)then
Check = CheckGiveSlot(UID, 2532);
if(Check ==1)then
RunExchange(UID, 2532);
SaveEvent(UID, 6792);
end
end
if(EVENT == 4005)then
SaveEvent(UID, 6793);
end
