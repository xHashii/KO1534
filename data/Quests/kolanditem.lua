local UserClass;
local QuestNum;
local Ret = 0;
local NPC =29237;


if EVENT == 500 then
 SelectMsg(UID, 3, -1, 3019, NPC, 17507,800,17508,801,17509,802,17510,803,17511,804,17512,805); 
end

--mage mp paper set
if (EVENT == 800) then
GiveItem(UID, 261001538, 1)
GiveItem(UID, 261002538, 1)
GiveItem(UID, 261003538, 1)
GiveItem(UID, 261004538, 1)
GiveItem(UID, 261005538, 1)
end

--prist hp paper set
if (EVENT == 801) then
GiveItem(UID, 281001508, 1)
GiveItem(UID, 281002508, 1)
GiveItem(UID, 281003508, 1)
GiveItem(UID, 281004508, 1)
GiveItem(UID, 281005508, 1)
end
--rogue hp paper set
if (EVENT == 802) then
GiveItem(UID, 241001508, 1)
GiveItem(UID, 241002508, 1)
GiveItem(UID, 241003508, 1)
GiveItem(UID, 241004508, 1)
GiveItem(UID, 241005508, 1)
end

--warrior hp paper set
if (EVENT == 803) then
GiveItem(UID, 201001508, 1)
GiveItem(UID, 201002508, 1)
GiveItem(UID, 201003508, 1)
GiveItem(UID, 201004508, 1)
GiveItem(UID, 201005508, 1)
end

--mage linen set hp
if (EVENT == 804) then
GiveItem(UID, 262001508, 1)
GiveItem(UID, 262002508, 1)
GiveItem(UID, 262003508, 1)
GiveItem(UID, 262004508, 1)
GiveItem(UID, 262005508, 1)
end

--mage linen set MP
if (EVENT == 805) then
GiveItem(UID, 262001538, 1)
GiveItem(UID, 262002538, 1)
GiveItem(UID, 262003538, 1)
GiveItem(UID, 262004538, 1)
GiveItem(UID, 262005538, 1)
end