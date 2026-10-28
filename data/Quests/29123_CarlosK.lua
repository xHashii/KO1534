if(EVENT == 1602)then
SelectMsg(UID, 4, 839, 9814, 29123, 22, 1603, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
if(EVENT == 1603)then
SaveEvent(UID, 6310);
end
if(EVENT == 1606)then
ItemCount0 = HowmuchItem(UID,900371000);
if(ItemCount0 < 1)then
SelectMsg(UID, 2, 839, 192, 29123, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 839, 9814, 29123, 10, 1609, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1609)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
ItemCount0 = HowmuchItem(UID,900371000);
if(ItemCount0 < 1)then
else
Check = CheckGiveSlot(UID, 243);
if(Check ==1)then
RunExchange(UID, 243);
SaveEvent(UID, 6311);
end
end
end
end
if(EVENT == 1605)then
SaveEvent(UID, 6312);
end
if(EVENT == 1702)then
SelectMsg(UID, 4, 841, 9815, 29123, 22, 1703, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
if(EVENT == 1703)then
SaveEvent(UID, 6320);
end
if(EVENT == 1706)then
ItemCount0 = HowmuchItem(UID,900375000);
if(ItemCount0 < 1)then
SelectMsg(UID, 2, 841, 192, 29123, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 841, 9815, 29123, 10, 1709, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 1709)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
ItemCount0 = HowmuchItem(UID,900375000);
if(ItemCount0 < 1)then
else
Check = CheckGiveSlot(UID, 245);
if(Check ==1)then
RunExchange(UID, 245);
SaveEvent(UID, 6321);
end
end
end
end
if(EVENT == 1705)then
SaveEvent(UID, 6322);
end
if(EVENT == 2102)then
SelectMsg(UID, 4, 847, 9817, 29123, 22, 2103, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
if(EVENT == 2103)then
SaveEvent(UID, 6378);
end
if(EVENT == 2106)then
ItemCount0 = HowmuchItem(UID,900369000);
if(ItemCount0 < 1)then
SelectMsg(UID, 2, 847, 192, 29123, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 847, 9817, 29123, 10, 2109, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 2109)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
ItemCount0 = HowmuchItem(UID,900369000);
if(ItemCount0 < 1)then
else
Check = CheckGiveSlot(UID, 1587);
if(Check ==1)then
RunExchange(UID, 1587);
SaveEvent(UID, 6379);
end
end
end
end
if(EVENT == 2105)then
SaveEvent(UID, 6380);
end
if(EVENT == 2202)then
SelectMsg(UID, 4, 849, 9817, 29123, 22, 2203, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
if(EVENT == 2203)then
SaveEvent(UID, 6388);
end
if(EVENT == 2206)then
ItemCount0 = HowmuchItem(UID,900370000);
if(ItemCount0 < 1)then
SelectMsg(UID, 2, 849, 192, 29123, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 849, 9817, 29123, 10, 2209, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
end
if(EVENT == 2209)then
Slot = CheckGiveSlot(UID,1)
if (Slot == true) then -- slotta yer var
ItemCount0 = HowmuchItem(UID,900370000);
if(ItemCount0 < 1)then
else
Check = CheckGiveSlot(UID, 1634);
if(Check ==1)then
RunExchange(UID, 1634);
SaveEvent(UID, 6389);
end
end
end
end
if(EVENT == 2205)then
SaveEvent(UID, 6390);
end
