if(EVENT == 1000)then
SelectMsg(UID, 4, 914, 10192, 29171, 22, 1001, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
SaveEvent(UID, 6658);
end
if(EVENT == 1001)then
SaveEvent(UID, 6656);
end
if(EVENT == 1002)then
MonsterCount0 = QuestMonsterCount(UID,914,1);
if(MonsterCount0 < 1)then
SelectMsg(UID, 2, 914, 192, 29171, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 914, 10192, 29171, 10, 1004, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1004)then
Check = CheckGiveSlot(UID, 5000);
if(Check ==1)then
--RunExchange(UID, 5000);
SaveEvent(UID, 6657);
end
end
