if(EVENT == 1000)then
SelectMsg(UID, 4, 828, 0, 29094, 22, 1001, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
if(EVENT == 1001)then
SaveEvent(UID, 2880);
end
if(EVENT == 1004)then
if(true)then
SelectMsg(UID, 2, 828, 192, 29094, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 828, 0, 29094, 10, 1007, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1007)then
Check = CheckGiveSlot(UID, 0);
if(Check ==1)then
RunExchange(UID, 0);
SaveEvent(UID, 2881);
end
end
if(EVENT == 1003)then
SaveEvent(UID, 2882);
end
