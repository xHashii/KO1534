local NPC = 29056;
local Ret = 0;

if (EVENT == 100) then
	SelectMsg(UID, 3, -1, 3018, NPC, 8611, 115, 40102, 106, 7202, 110, 7214, 104,7219, 105, 7496, 102, 7679, 542);
end

if (EVENT == 101) then
	Ret = 1;
end

if (EVENT == 1000) then
	ShowMap(UID, 450);
end

if (EVENT == 115) then -- Alencia Wing
	SelectMsg(UID, 2, -1, 12056, NPC, 8629, 116);
end

if (EVENT == 116) then -- Alencia Wing Blue
	ALENCIA = HowmuchItem(UID, 900387000);
	if (ALENCIA < 1) then
		SelectMsg(UID, 2, -1, 12061, NPC, 18, 1000);
	else
		SelectMsg(UID, 2, -1, 12060, NPC, 4006, 117, 4005, 101);
	end
end

if (EVENT == 1000) then
	ShowMap(UID, 450);
end

if (EVENT == 117) then
	RobItem(UID, 900387000, 1)
	GiveItem(UID, 900767869, 1)
end

if (EVENT == 106) then -- Exchanging Items
	SelectMsg(UID, 3, -1, 3018, NPC, 7247, 118, 7248, 119, 7250, 120, 7251, 121);
end

if (EVENT == 118) then -- Golden Pickax
	GoldVoucher = HowmuchItem(UID, 508122000);
	if (GoldVoucher < 1) then
		SelectMsg(UID, 2, -1, 9943, NPC, 18, 1000);
	elseif (GoldVoucher > 0) then
		SelectMsg(UID, 2, -1, 9944, NPC, 4006, 124, 4005, 101);
	end
end

if (EVENT == 124) then
	RobItem(UID, 508122000, 1)
	GiveItem(UID, 389135000, 1)
end

if (EVENT == 119) then -- Golden Fishing
	FishVoucher = HowmuchItem(UID, 508121000);
		if (FishVoucher < 1) then
		SelectMsg(UID, 2, -1, 9945, NPC, 18, 1000);
	elseif (FishVoucher > 0) then
		SelectMsg(UID, 2, -1, 9946, NPC, 4006, 125, 4005, 101);
	end
end

if (EVENT == 125) then
RobItem(UID, 508121000, 1)
GiveItem(UID, 191347000, 1)
end

if (EVENT == 120) then -- War Pre Map of Chaos
	WARPRE = HowmuchItem(UID, 399292764);
	if (WARPRE < 1) then
		SelectMsg(UID, 2, -1, 9951, NPC, 18, 1000);
	elseif (WARPRE >0 ) then
		SelectMsg(UID, 2, -1, 9949, NPC, 4006, 128, 4005, 101);
	end
end

if (EVENT == 128) then
	GiveItem(UID, 910247000, 1)
end

if (EVENT == 121) then -- War Pre Ancient Text
	WARPRE = HowmuchItem(UID, 399292764);
	if (WARPRE < 1) then
		SelectMsg(UID, 2, -1, 9951, NPC, 18, 1000);
	elseif (WARPRE >0 ) then
		SelectMsg(UID, 2, -1, 9953, NPC, 4006, 129, 4005, 101);
	end
end

if (EVENT == 129) then
	GiveItem(UID, 810161000, 1)
end



if (EVENT == 110) then -- Premium Item Use
	SelectMsg(UID, 3, -1, 9527, NPC, 7197, 176, 7198, 181, 7252, 182);
end

if (EVENT == 176) then -- DISC Premium
	SelectMsg(UID, 2, -1, 9527, NPC, 4006, 183, 4005, 101);
end

if (EVENT == 183) then
	DCPREM = HowmuchItem(UID, 399281685);
	if (DCPREM < 1) then
		SelectMsg(UID, 2, -1, 9528, NPC, 18, 1000);
	else
RobItem(UID, 399281685, 1)
GivePremium(UID, 10, 30)

	end
end

if (EVENT == 181) then -- EXP Premium
	SelectMsg(UID, 2, -1, 9527, NPC, 4006, 184, 4005, 101);
end

if (EVENT == 184) then
	EXPPREM = HowmuchItem(UID, 399282686);
	if (EXPPREM < 1) then
		SelectMsg(UID, 2, -1, 9528, NPC, 18, 1000);
	else
		RobItem(UID, 399282686, 1)
		GivePremium(UID, 11, 30)
	end
end



if (EVENT == 182) then -- WAR Premium
	SelectMsg(UID, 2, -1, 9527, NPC, 4006, 185, 4005, 101);
end

if (EVENT == 185) then
	WARPREM = HowmuchItem(UID, 399292764);
	if (WARPREM < 1) then
		SelectMsg(UID, 2, -1, 9528, NPC, 18, 1000);
	else
		RobItem(UID, 399292764, 1)
		GivePremium(UID, 12, 30)
			end
end

if (EVENT == 104) then --Minevra Package
	MINEVRA = HowmuchItem(UID, 508073000);
	if (MINEVRA < 1) then
		SelectMsg(UID, 2, -1, 9622, NPC, 18, 1000);
	else
		SelectMsg(UID, 2, -1, 9621, NPC, 4006, 114, 4005, 101);
	end
end

if (EVENT == 114) then
	RobItem(UID, 508073000, 1)
	GiveItem(UID, 508116000, 1)
	GiveItem(UID, 508117000, 1)
end

if (EVENT == 105) then -- Pathos Glove Package
	PATHOS = HowmuchItem(UID, 508074000);
	if (PATHOS < 1) then
		SelectMsg(UID, 2, -1, 9629, NPC, 18, 1000);
	else
		SelectMsg(UID, 2, -1, 9628, NPC, 4006, 113, 4005, 101);
	end
end

if (EVENT == 113) then
	RobItem(UID, 508074000, 1)
	GiveItem(UID, 800250000, 1)
	GiveItem(UID, 800250000, 1)
end

if (EVENT == 102) then -- Helmet of Wrath Use
	KURU = HowmuchItem(UID, 800451000);
	if (KURU < 1) then
		SelectMsg(UID, 2, -1, 43604, NPC, 18, 1000);
	else
		SelectMsg(UID, 2, -1, 43605, NPC, 4006, 112, 4005, 101);
	end
end

if (EVENT == 112) then
	RobItem(UID, 800451000, 1)
	GiveItem(UID, 518006774, 1)
end


if (EVENT == 542) then -- Dragon Wings
	ITEMDRGN = HowmuchItem(UID, 810164000);
	if (ITEMDRGN > 0) then
		SelectMsg(UID, 3, -1, 10592, NPC, 7680, 543, 7681, 544, 7682, 545, 7683, 546);
	else
		SelectMsg(UID, 2, -1, 10593, NPC, 18, 1000);
	end
end

if (EVENT == 543) then
	NATION = CheckNation(UID);
	if (NATION == 1) then
		Check = isRoomForItem(UID, 810178835);
		if (Check == -1) then
			SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
		else
			RobItem(UID, 810164000, 1)
			GiveItem(UID, 810178835, 1)
		end
	elseif (NATION == 2) then
		Check = isRoomForItem(UID, 810179839);
		if (Check == -1) then
			SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
		else
			RobItem(UID, 810164000, 1)
			GiveItem(UID, 810179839, 1)
		end
	end
end

if (EVENT == 544) then
	NATION = CheckNation(UID);
	if (NATION == 1) then
		Check = isRoomForItem(UID, 810178836);
		if (Check == -1) then
			SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
		else
			RobItem(UID, 810164000, 1)
			GiveItem(UID, 810178836, 1)
		end
	elseif (NATION == 2) then
		Check = isRoomForItem(UID, 810179840);
		if (Check == -1) then
			SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
		else
			RobItem(UID, 810164000, 1)
			GiveItem(UID, 810179840, 1)
		end
	end
end

if (EVENT == 545) then
	NATION = CheckNation(UID);
	if (NATION == 1) then
		Check = isRoomForItem(UID, 810178837);
		if (Check == -1) then
			SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
		else
			RobItem(UID, 810164000, 1)
			GiveItem(UID, 810178837, 1)
		end
	elseif (NATION == 2) then
		Check = isRoomForItem(UID, 810179841);
		if (Check == -1) then
			SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
		else
			RobItem(UID, 810164000, 1)
			GiveItem(UID, 810179841, 1)
		end
	end
end

if (EVENT == 546) then
	NATION = CheckNation(UID);
	if (NATION == 1) then
		Check = isRoomForItem(UID, 810178838);
		if (Check == -1) then
			SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
		else
			RobItem(UID, 810164000, 1)
			GiveItem(UID, 810178838, 1)
		end
	elseif (NATION == 2) then
		Check = isRoomForItem(UID, 810179842);
		if (Check == -1) then
			SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
		else
			RobItem(UID, 810164000, 1)
			GiveItem(UID, 810179842, 1)
		end
	end
end

if (EVENT == 547) then -- Yeniceri Minerva
	SelectMsg(UID, 2, -1, 9938, NPC, 7244, 548, 7243, 549);
end

if (EVENT == 548) then
	ITEMYENIA = HowmuchItem(UID, 508117000);
	if (ITEMYENIA > 0) then
		SelectMsg(UID, 3, -1, 9941, NPC, 4288, 550, 4289, 551, 4290, 552, 4291, 553);
	else
		SelectMsg(UID, 2, -1, 9942, NPC, 18, 1000);
	end
end

if (EVENT == 550) then
	Check = isRoomForItem(UID, 518001636);
	if (Check == -1) then
		SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
	else
		RobItem(UID, 508117000, 1)
		GiveItem(UID, 518001636, 1)
	end
end

if (EVENT == 551) then
	Check = isRoomForItem(UID, 518001637);
	if (Check == -1) then
		SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
	else
		RobItem(UID, 508117000, 1)
		GiveItem(UID, 518001637, 1)
	end
end

if (EVENT == 552) then
	Check = isRoomForItem(UID, 518001638);
	if (Check == -1) then
		SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
	else
		RobItem(UID, 508117000, 1)
		GiveItem(UID, 518001638, 1)
	end
end

if (EVENT == 553) then
	Check = isRoomForItem(UID, 518001639);
	if (Check == -1) then
		SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
	else
		RobItem(UID, 508117000, 1)
		GiveItem(UID, 518001639, 1)
	end
end

if (EVENT == 549) then
	ITEMYENIH = HowmuchItem(UID, 508116000);
	if (ITEMYENIH > 0) then
		SelectMsg(UID, 3, -1, 9941, NPC, 4292, 554, 4293, 555, 4294, 556, 4295, 557);
	else
		SelectMsg(UID, 2, -1, 9940, NPC, 18, 1000);
	end
end

if (EVENT == 554) then
	Check = isRoomForItem(UID, 518003636);
	if (Check == -1) then
		SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
	else
		RobItem(UID, 508116000, 1)
		GiveItem(UID, 518003636, 1)
	end
end

if (EVENT == 555) then
	Check = isRoomForItem(UID, 518003637);
	if (Check == -1) then
		SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
	else
		RobItem(UID, 508116000, 1)
		GiveItem(UID, 518003637, 1)
	end
end

if (EVENT == 556) then
	Check = isRoomForItem(UID, 518003638);
	if (Check == -1) then
		SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
	else
		RobItem(UID, 508116000, 1)
		GiveItem(UID, 518003638, 1)
	end
end

if (EVENT == 557) then
	Check = isRoomForItem(UID, 518003639);
	if (Check == -1) then
		SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
	else
		RobItem(UID, 508116000, 1)
		GiveItem(UID, 518003639, 1)
	end
end