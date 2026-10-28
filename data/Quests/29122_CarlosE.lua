if(EVENT == 1602)then
SelectMsg(UID, 4, 840, 9819, 29122, 22, 1603, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
if(EVENT == 1603)then
SaveEvent(UID, 6315);
end
if(EVENT == 1606)then
ItemCount0 = HowmuchItem(UID,900371000);
if(ItemCount0 < 1)then
SelectMsg(UID, 2, 840, 192, 29122, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 840, 9819, 29122, 10, 1609, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
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
SaveEvent(UID, 6316);
end
end
end
end
if(EVENT == 1605)then
SaveEvent(UID, 6317);
end
if(EVENT == 1702)then
SelectMsg(UID, 4, 842, 9820, 29122, 22, 1703, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
if(EVENT == 1703)then
SaveEvent(UID, 6325);
end
if(EVENT == 1706)then
ItemCount0 = HowmuchItem(UID,900375000);
if(ItemCount0 < 1)then
SelectMsg(UID, 2, 842, 192, 29122, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 842, 9820, 29122, 10, 1709, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
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
SaveEvent(UID, 6326);
end
end
end
end
if(EVENT == 1705)then
SaveEvent(UID, 6327);
end
if(EVENT == 2102)then
SelectMsg(UID, 4, 848, 9822, 29122, 22, 2103, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
if(EVENT == 2103)then
SaveEvent(UID, 6383);
end
if(EVENT == 2106)then
ItemCount0 = HowmuchItem(UID,900369000);
if(ItemCount0 < 1)then
SelectMsg(UID, 2, 848, 192, 29122, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 848, 9822, 29122, 10, 2109, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
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
SaveEvent(UID, 6384);
end
end
end
end
if(EVENT == 2105)then
SaveEvent(UID, 6385);
end
if(EVENT == 2202)then
SelectMsg(UID, 4, 850, 9822, 29122, 22, 2203, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
end
if(EVENT == 2203)then
SaveEvent(UID, 6393);
end
if(EVENT == 2206)then
ItemCount0 = HowmuchItem(UID,900370000);
if(ItemCount0 < 1)then
SelectMsg(UID, 2, 850, 192, 29122, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
else
SelectMsg(UID, 4, 850, 9822, 29122, 10, 2209, 27, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
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
SaveEvent(UID, 6394);
end
end
end
end
if(EVENT == 2205)then
SaveEvent(UID, 6395);
end
