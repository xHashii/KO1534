local UserClass;
local QuestNum;
local Ret = 0;
local NPC = 14431;


if EVENT == 155 then
	QuestNum = SearchQuest(UID, NPC);
	print("QuestNum"..QuestNum)
		if QuestNum == 0 then 
			 SelectMsg(UID, 2, -1, 8256, NPC, 10, 158, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
			 Ret = 1;
		elseif QuestNum > 1 and  QuestNum < 100 then
          NpcMsg(UID, 8258, NPC)
      else 
          EVENT = QuestNum
		end
end

if EVENT == 158 then
    Ret = 1;
end
