local Ret = 0;
local NPC = 32585;

if (EVENT == 100) then
	QuestStatus = SearchQuest(UID, 772)	
	ITEM1_COUNT = HowmuchItem(UID, 900293000);  
	if(QuestStatus == 1 and ITEM1_COUNT < 1) then
		EVENT = 2000
end
end

if (EVENT == 2000)then
SLOTKONTROL = CheckGiveSlot(UID, 2)
     if SLOTKONTROL == false then
       SelectMsg(UID,2,-1,8898,NPC,10)
         else
SelectMsg(UID, 2, -1, 20816, NPC, 22,-1);
GiveItem(UID, 900293000,1)
end
end