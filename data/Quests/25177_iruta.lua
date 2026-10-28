local NPC = 25177;

if (EVENT == 100) then
	SelectMsg(UID, 3, -1, 11793, NPC,7247, 155, 7248, 160,4478,200,8612,1000,40620,700);
end

if (EVENT == 155) then
	PICKAX = HowmuchItem(UID, 900660000);
	if (PICKAX < 1) then
		SelectMsg(UID, 2, -1, 9943, NPC, 18, 5000);
	else
		SelectMsg(UID, 2, -1, 9944, NPC, 4297, 156, 4005, -1);
	end
end

if (EVENT == 156) then
SLOTKONTROL = CheckGiveSlot(UID, 1)
     if SLOTKONTROL == false then
       SelectMsg(UID,2,-1,8898,NPC,10)
         else
	RobItem(UID, 900660000, 1)
	GiveItem(UID, 810934956, 1,30)
end
end


if (EVENT == 160) then
	FISHING = HowmuchItem(UID, 399119000);
	if (FISHING < 1) then
		SelectMsg(UID, 2, -1, 9945, NPC, 18, 5000);
	else
		SelectMsg(UID, 2, -1, 9946, NPC, 4297, 161, 4005, -1);

	end
end

if (EVENT == 161) then
SLOTKONTROL = CheckGiveSlot(UID, 1)
     if SLOTKONTROL == false then
       SelectMsg(UID,2,-1,8898,NPC,10)
         else
	RobItem(UID, 399119000, 1)
	GiveItem(UID, 930540724, 1,30)
end
end

if (EVENT == 5000) then
	ShowMap(UID, 450);
end

if (EVENT == 200) then
	PREMIUM = GetPremium(UID);
	if (PREMIUM == 0) then
		SelectMsg(UID, 3, -1, 9527, NPC,8525,201,8526,202,8528,203,8529,204,8531,205,8532,206,8808,207);
	else
		SelectMsg(UID, 2, -1, 9526, NPC, 10, -1);
	end
end

if (EVENT == 201) then -- DISC Premium 3
	SelectMsg(UID, 2, -1, 9529, NPC, 3000, 210, 3005, -1);
end

if (EVENT == 202) then -- DISC Premium 7
	SelectMsg(UID, 2, -1, 9529, NPC, 3000, 211, 3005, -1);
end

if (EVENT == 203) then -- EXP Premium 3
	SelectMsg(UID, 2, -1, 9544, NPC, 3000, 212, 3005, -1);
end

if (EVENT == 204) then -- EXP Premium 7
	SelectMsg(UID, 2, -1, 9544, NPC, 3000, 213, 3005, -1);
end

if (EVENT == 205) then -- WAR Premium 3
	SelectMsg(UID, 2, -1, 9954, NPC, 3000, 214, 3005, -1);
end

if (EVENT == 206) then -- WAR Premium 7
	SelectMsg(UID, 2, -1, 9954, NPC, 3000, 215, 3005, -1);
end

if (EVENT == 207) then -- Bronze Premium 3
	SelectMsg(UID, 2, -1, 12068, NPC, 3000, 216, 3005, -1);
end


if (EVENT == 210) then -- DISC Premium 3
	DCPREM = HowmuchItem(UID, 900044000);
	if (DCPREM < 1) then
		SelectMsg(UID, 2, -1, 9530, NPC, 18, 5000);
	else
    EVENT = 219
	end
end

if (EVENT == 219) then
		RobItem(UID, 900044000, 1)
		GivePremium(UID, 10, 3)
end		

if (EVENT == 211) then -- DISC Premium 7
	DCPREM = HowmuchItem(UID, 900045000);
	if (DCPREM < 1) then
		SelectMsg(UID, 2, -1, 9530, NPC, 18, 5000);
	else
    EVENT = 220
	end
end

if (EVENT == 220) then
		RobItem(UID, 900045000, 1)
		GivePremium(UID, 10, 7)
end	

if (EVENT == 212) then -- EXP Premium 3
	EXPPREM = HowmuchItem(UID, 998020000);
	if (EXPPREM < 1) then
		SelectMsg(UID, 2, -1, 9531, NPC, 18, 5000);
	else
    EVENT = 221
	end
end

if (EVENT == 221) then
	RobItem(UID, 998020000, 1)
	GivePremium(UID, 11, 3)
end

if (EVENT == 213) then -- EXP Premium 7
	EXPPREM = HowmuchItem(UID, 911800000);
	if (EXPPREM < 1) then
		SelectMsg(UID, 2, -1, 9531, NPC, 18, 5000);
	else
    EVENT = 222
	end
end

if (EVENT == 222) then
	RobItem(UID, 911800000, 1)
	GivePremium(UID, 11, 7)
end

if (EVENT == 214) then -- WAR Premium 3
	WARPREM = HowmuchItem(UID, 914012000);
	if (WARPREM < 1) then
		SelectMsg(UID, 2, -1, 9955, NPC, 18, 5000);
	else
    EVENT = 223
	end
end

if (EVENT == 223) then
	RobItem(UID, 914012000, 1)
	GivePremium(UID, 12, 3)
end

if (EVENT == 215) then -- WAR Premium 7
	WARPREM = HowmuchItem(UID, 910936000);
	if (WARPREM < 1) then
		SelectMsg(UID, 2, -1, 9955, NPC, 18, 5000);
	else
    EVENT = 224
	end
end

if (EVENT == 224) then
	RobItem(UID, 910936000, 1)
	GivePremium(UID, 12, 7)
end

if (EVENT == 216) then -- Bronze Premium 3
	BRONZEPRE = HowmuchItem(UID, 900828000);
	if (BRONZEPRE < 1) then
		SelectMsg(UID, 2, -1, 12069, NPC, 18, 5000);
	else
    EVENT = 225
	end
end

if (EVENT == 225) then	
	RobItem(UID, 900828000, 1)
	GivePremium(UID, 3, 3)
end

if (EVENT ==  1000) then
	SelectMsg(UID, 2, -1, 12056, NPC, 8632,1010,8694,1020);
end

if (EVENT == 1010) then --Alencia Wing Blue
	BLUEWING = HowmuchItem(UID, 810507000);
	if (BLUEWING < 1) then
		SelectMsg(UID, 2, -1, 12061, NPC, 10, -1);
	else
		SelectMsg(UID, 3, -1, 12060, NPC, 7786,1011,7787,1012,7788,1013,7789,1014);
	end
end

if (EVENT == 1020) then --Alencia Wing Red
	REDWING = HowmuchItem(UID, 810507000);
	if (REDWING < 1) then
		SelectMsg(UID, 2, -1, 12058, NPC, 10, -1);
	else
		SelectMsg(UID, 3, -1, 12057, NPC, 7786,1015,7787,1016,7788,1017,7789,1018);
	end
end

if (EVENT == 1011) then
SLOTKONTROL = CheckGiveSlot(UID, 1)
     if SLOTKONTROL == false then
       SelectMsg(UID,2,-1,8898,NPC,10)
         else
	RobItem(UID, 810507000, 1)
	GiveItem(UID, 900767866, 1,7)
    end
end

if (EVENT == 1012) then
SLOTKONTROL = CheckGiveSlot(UID, 1)
     if SLOTKONTROL == false then
       SelectMsg(UID,2,-1,8898,NPC,10)
         else
	RobItem(UID, 810507000, 1)
	GiveItem(UID, 900767867, 1,7)
    end
end

if (EVENT == 1013) then
SLOTKONTROL = CheckGiveSlot(UID, 1)
     if SLOTKONTROL == false then
       SelectMsg(UID,2,-1,8898,NPC,10)
         else
	RobItem(UID, 810507000, 1)
	GiveItem(UID, 900767869, 1,7)
    end
end

if (EVENT == 1014) then
SLOTKONTROL = CheckGiveSlot(UID, 1)
     if SLOTKONTROL == false then
       SelectMsg(UID,2,-1,8898,NPC,10)
         else
	RobItem(UID, 810507000, 1)
	GiveItem(UID, 900767868, 1,7)
    end
end

if (EVENT == 1015) then
SLOTKONTROL = CheckGiveSlot(UID, 1)
     if SLOTKONTROL == false then
       SelectMsg(UID,2,-1,8898,NPC,10)
         else
	RobItem(UID, 810507000, 1)
	GiveItem(UID, 900768870, 1,7)
    end
end

if (EVENT == 1016) then
SLOTKONTROL = CheckGiveSlot(UID, 1)
     if SLOTKONTROL == false then
       SelectMsg(UID,2,-1,8898,NPC,10)
         else
	RobItem(UID, 810507000, 1)
	GiveItem(UID, 900768871, 1,7)
    end
end

if (EVENT == 1017) then
SLOTKONTROL = CheckGiveSlot(UID, 1)
     if SLOTKONTROL == false then
       SelectMsg(UID,2,-1,8898,NPC,10)
         else
	RobItem(UID, 810507000, 1)
	GiveItem(UID, 900768873, 1,7)
    end
end

if (EVENT == 1018) then
SLOTKONTROL = CheckGiveSlot(UID, 1)
     if SLOTKONTROL == false then
       SelectMsg(UID,2,-1,8898,NPC,10)
         else
	RobItem(UID, 810507000, 1)
	GiveItem(UID, 900768872, 1,7)
    end
end

if (EVENT == 700) then --Wing of Hell Fire
	HELL = HowmuchItem(UID, 810672000);
	if (HELL < 1) then
		SelectMsg(UID, 2, -1, 12462, NPC, 10, -1);
	else
		SelectMsg(UID, 3, -1, 12460, NPC, 7786,701,7787,702,7788,703,7789,704);
	end
end

if (EVENT == 701) then
SLOTKONTROL = CheckGiveSlot(UID, 1)
     if SLOTKONTROL == false then
       SelectMsg(UID,2,-1,8898,NPC,10)
         else
	RobItem(UID, 810672000, 1)
	GiveItem(UID, 810638711, 1,7)
    end
end

if (EVENT == 702) then
SLOTKONTROL = CheckGiveSlot(UID, 1)
     if SLOTKONTROL == false then
       SelectMsg(UID,2,-1,8898,NPC,10)
         else
	RobItem(UID, 810672000, 1)
	GiveItem(UID, 810638712, 1,7)
    end
end

if (EVENT == 703) then
SLOTKONTROL = CheckGiveSlot(UID, 1)
     if SLOTKONTROL == false then
       SelectMsg(UID,2,-1,8898,NPC,10)
         else
	RobItem(UID, 810672000, 1)
	GiveItem(UID, 810638730, 1,7)
    end
end

if (EVENT == 704) then
SLOTKONTROL = CheckGiveSlot(UID, 1)
     if SLOTKONTROL == false then
       SelectMsg(UID,2,-1,8898,NPC,10)
         else
	RobItem(UID, 810672000, 1)
	GiveItem(UID, 810638731, 1,7)
    end
end