local NPC = 29083;
local Ret = 0;


if (EVENT == 100) then
	SelectMsg(UID, 2, -1, 12370, NPC, 8933, 101, 8934, -1);
end

if (EVENT == 101) then
	SelectMsg(UID, 22, -1, NPC);
end