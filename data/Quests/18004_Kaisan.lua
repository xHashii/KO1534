local Ret = 0;
local NPC = 18004;

if (EVENT == 101) then
	Ret = 1;
end

local savenum = -1;

if (EVENT == 100) then   
	Level = CheckLevel(UID)
	if (Level > 9) then 
		Class = CheckClass(UID);
		if (Class == 1 or Class == 2 or Class == 3 or Class == 4) then
			ITEM_COUNT = HowmuchItem(UID, 900000000);
			if (ITEM_COUNT < 3000) then
				SelectMsg(UID, 2, savenum, 4065, NPC, 10, 101);
			else
				SelectMsg(UID, 2, savenum, 4064, NPC, 4062, 404, 4063, 101);
			end
		else
			EVENT = 105
		end
	else
		SelectMsg(UID, 2, savenum, 4069, NPC, 10, 101);
	end
end

if (EVENT == 404) then
	SaveEvent(UID, 4063);
	PromoteUserNovice(UID)
	GoldLose(UID, 3000)
	NATION = CheckNation(UID);
	if (NATION == 1) then
		SelectMsg(UID, 2, savenum, 4066, NPC, 4064, 101);
	else
		SelectMsg(UID, 2, savenum, 4067, NPC, 4064, 101);
	end
end

if (EVENT == 105) then
	SelectMsg(UID, 3, savenum, 147, NPC, 4070, 106, 7772, 107);
end

if (EVENT == 107) then
	Check = NationChange(UID);
	if (Check == 0) then
		SelectMsg(UID, 2, savenum, 1524, NPC, 10, 101);
	elseif (Check == 1) then
		SelectMsg(UID, 2, savenum, 1523, NPC, 10, 101);
	elseif (Check == 2) then
		SelectMsg(UID, 2, savenum, 1526, NPC, 10, 101);
	elseif (Check == 3) then
		SelectMsg(UID, 2, savenum, 1521, NPC, 10, 101);
	end
end

if (EVENT == 106) then
	SelectMsg(UID, 2, savenum, 4070, NPC, 4070, 408, 10, 101);
end

if (EVENT == 408) then
	SendStatSkillDistribute(UID)
end
