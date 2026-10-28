-- KİMSE PAYLAŞILMAZ KİRAAMORA61 --
local NPC = 29056;
local Ret = 0;

if (EVENT == 100) then
	SelectMsg(UID, 3, -1, 3018, NPC, 8611, 115, 40102, 106, 7796, 107, 8229, 108, 7202, 110, 7214, 104, 7219, 105, 7242, 547, 2002, 103);
end

if (EVENT == 101) then
	Ret = 1;
end

if (EVENT == 115) then -- Alencia Wing
	SelectMsg(UID, 2, -1, 12056, NPC, 8629, 116, 8628, 1160);
end
if (EVENT == 116) then -- Alencia Wing Blue
	ITEMDRGN = HowmuchItem(UID, 810511000);
	if (ITEMDRGN > 0) then
		SelectMsg(UID, 3, -1, 10592, NPC, 7680, 1030, 7681, 1031, 7682, 1032, 7683, 1033);
	else
		SelectMsg(UID, 2, -1, 10593, NPC, 18, 1000);
	end
end

if (EVENT == 1030) then
	NATION = CheckNation(UID);
	if (NATION == 1) then
		Check = isRoomForItem(UID, 900767866);
		if (Check == -1) then
			SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
		else
			RobItem(UID, 810511000, 1)
			GiveItem(UID, 900767866, 1,30)
		end
	else
		Check = isRoomForItem(UID, 900767866);
		if (Check == -1) then
			SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
		else
			RobItem(UID, 810511000, 1)
			GiveItem(UID, 900767866, 1,30)
		end
	end
end

if (EVENT == 1031) then
	NATION = CheckNation(UID);
	if (NATION == 1) then
		Check = isRoomForItem(UID, 900767867);
		if (Check == -1) then
			SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
		else
			RobItem(UID, 810511000, 1)
			GiveItem(UID, 900767867, 1,30)
		end
	else
		Check = isRoomForItem(UID, 900767867);
		if (Check == -1) then
			SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
		else
			RobItem(UID, 810511000, 1)
			GiveItem(UID, 900767867, 1,30)
		end
	end
end

if (EVENT == 1032) then
	NATION = CheckNation(UID);
	if (NATION == 1) then
		Check = isRoomForItem(UID, 900767868);
		if (Check == -1) then
			SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
		else
			RobItem(UID, 810511000, 1)
			GiveItem(UID, 900767869, 1,30)
		end
	else
		Check = isRoomForItem(UID, 900767868);
		if (Check == -1) then
			SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
		else
			RobItem(UID, 810511000, 1)
			GiveItem(UID, 900767869, 1,30)
		end
	end
end

if (EVENT == 1033) then
	NATION = CheckNation(UID);
	if (NATION == 1) then
		Check = isRoomForItem(UID, 900767869);
		if (Check == -1) then
			SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
		else
			RobItem(UID, 810511000, 1)
			GiveItem(UID, 900767868, 1,30)
		end
	else
		Check = isRoomForItem(UID, 900767869);
		if (Check == -1) then
			SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
		else
			RobItem(UID, 810511000, 1)
			GiveItem(UID, 900767868, 1,30)
		end
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------
if (EVENT == 1160) then -- Alencia Wing Red
	ITEMDRGN = HowmuchItem(UID, 810507000);
	if (ITEMDRGN > 0) then
		SelectMsg(UID, 3, -1, 10592, NPC, 7680, 1042, 7681, 1043, 7682, 1040, 7683, 1041);
	else
		SelectMsg(UID, 2, -1, 10593, NPC, 18, 1000);
	end
end

if (EVENT == 1042) then
	NATION = CheckNation(UID);
	if (NATION == 1) then
		Check = isRoomForItem(UID, 900768870);
		if (Check == -1) then
			SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
		else
			RobItem(UID, 810507000, 1)
			GiveItem(UID, 900768870, 1,30)
		end
	else
		Check = isRoomForItem(UID, 900768870);
		if (Check == -1) then
			SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
		else
			RobItem(UID, 810507000, 1)
			GiveItem(UID, 900768870, 1,30)
		end
	end
end

if (EVENT == 1043) then
	NATION = CheckNation(UID);
	if (NATION == 1) then
		Check = isRoomForItem(UID, 900768871);
		if (Check == -1) then
			SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
		else
			RobItem(UID, 810507000, 1)
			GiveItem(UID, 900768871, 1,30)
		end
	else
		Check = isRoomForItem(UID, 900768871);
		if (Check == -1) then
			SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
		else
			RobItem(UID, 810507000, 1)
			GiveItem(UID, 900768871, 1,30)
		end
	end
end

if (EVENT == 1040) then
	NATION = CheckNation(UID);
	if (NATION == 1) then
		Check = isRoomForItem(UID, 900768872);
		if (Check == -1) then
			SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
		else
			RobItem(UID, 810507000, 1)
			GiveItem(UID, 900768873, 1,30)
		end
	else
		Check = isRoomForItem(UID, 900768872);
		if (Check == -1) then
			SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
		else
			RobItem(UID, 810507000, 1)
			GiveItem(UID, 900768873, 1,30)
		end
	end
end

if (EVENT == 1041) then
	NATION = CheckNation(UID);
	if (NATION == 1) then
		Check = isRoomForItem(UID, 810178838);
		if (Check == -1) then
			SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
		else
			RobItem(UID, 810507000, 1)
			GiveItem(UID, 900768872, 1,30)
		end
	else
		Check = isRoomForItem(UID, 810179842);
		if (Check == -1) then
			SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
		else
			RobItem(UID, 810507000, 1)
			GiveItem(UID, 900768872, 1,30)
		end
	end
end




-------------------------------------------------------------------------------------------------------------------------------------------------------
if (EVENT == 1000) then
	ShowMap(UID, 450);
end

if (EVENT == 117) then
SLOTKONTROL = CheckGiveSlot(UID, 1)
     if SLOTKONTROL == false then
       SelectMsg(UID,2,-1,8898,NPC,10)
         else
	ALENCIA = HowmuchItem(UID, 900387000); 
	--if (ALENCIA > 0) then
	RobItem(UID, 900767000, 1)
	GiveItem(UID, 800032000, 1,30)
	end
end

if (EVENT == 106) then -- Exchanging Items
	SelectMsg(UID, 3, -1, 3018, NPC, 7247, 118, 7248, 119, 7250, 120, 7251, 121, 8210, 122, 7258, 123);
end

if (EVENT == 118) then -- Golden Pickax
	DCPRE = HowmuchItem(UID, 508122000);
	if (DCPRE < 1) then
		SelectMsg(UID, 2, -1, 9943, NPC, 18, 1000);
	else
		SelectMsg(UID, 2, -1, 9944, NPC, 4006, 124, 4005, 101);
	end
end

if (EVENT == 124) then
	DCPRE = HowmuchItem(UID, 508122000);
	if (DCPRE > 0) then
	RobItem(UID, 508122000, 1)
	GiveItem(UID, 389135000, 1,30)
	end
end

if (EVENT == 119) then -- Golden Fishing
	EXPPRE = HowmuchItem(UID, 508121000);
	if (EXPPRE < 1) then
		SelectMsg(UID, 2, -1, 9945, NPC, 18, 1000);
	elseif (EXPPRE > 0) then
		SelectMsg(UID, 2, -1, 9946, NPC, 4006, 125, 4005, 101);
	end
end

if (EVENT == 125) then
	EXPPRE = HowmuchItem(UID, 508121000);
	if (EXPPRE > 0) then
	RobItem(UID, 508121000, 1)
	GiveItem(UID, 191347000, 1,30)
	end
end

if (EVENT == 120) then -- War Pre Map of Chaos
	WARPRE = HowmuchItem(UID, 810150000);
	if (WARPRE < 1) then
		SelectMsg(UID, 2, -1, 9951, NPC, 18, 1000);
	else
		SelectMsg(UID, 2, -1, 9949, NPC, 4006, 128, 4005, 101);
	end
end

if (EVENT == 128) then
	RobItem(UID, 810150000, 1)
	GiveItem(UID, 910247000, 1,30)
end

if (EVENT == 121) then -- War Pre Ancient Text
	WARPRE = HowmuchItem(UID, 810160000);
	if (WARPRE < 1) then
		SelectMsg(UID, 2, -1, 9951, NPC, 18, 1000);
	else
		SelectMsg(UID, 2, -1, 9953, NPC, 4006, 129, 4005, 101);
	end
end

if (EVENT == 129) then
	WARPRE = HowmuchItem(UID, 399292764);
	if (WARPRE > 0) then
	RobItem(UID, 810160000, 1)
	GiveItem(UID, 810161000, 1,30)
	end
end

if (EVENT == 122) then -- Under Castle Weapons Box
	UNDER = HowmuchItem(UID, 0); -- ITEM KONTROL EDILMELI
	if (UNDER < 1) then
		SelectMsg(UID, 2, -1, 11061, NPC, 18, 1000);
	else
		SelectMsg(UID, 2, -1, 11062, NPC, 4006, 130, 4005, 101);
	end
end

if (EVENT == 130) then
	UNDER = HowmuchItem(UID, 0); -- ITEM KONTROL EDILMELI
	if (UNDER > 0) then
	RobItem(UID, 0, 1) -- ITEM KONTROL EDILMELI
	GiveItem(UID, 0, 1,30) -- ITEM KONTROL EDILMELI
	end
end

if (EVENT == 123) then -- Spirit's Help
	SelectMsg(UID, 3, -1, 9989, NPC, 7259, 131, 7260, 132, 7314, 133, 7261, 137);
end

if (EVENT == 131) then -- Spirit Dryads
	SelectMsg(UID, 2, -1, 9990, NPC, 3000, 134, 3005, 101);
end

if (EVENT == 134) then
	DRYADS = HowmuchItem(UID, 900385000); -- ITEM KONTROL EDILMELI
	if (DRYADS < 1) then
		SelectMsg(UID, 2, -1, 9991, NPC, 18, 1000);
	else
		RobItem(UID, 900385000, 1) -- ITEM KONTROL EDILMELI
		GiveItem(UID, 700038767, 1, 30) -- ITEM KONTROL EDILMELI
	end
end

if (EVENT == 132) then -- Spirit Oreads
	SelectMsg(UID, 2, -1, 9990, NPC, 3000, 135, 3005, 101);
end

if (EVENT == 135) then
	OREADS = HowmuchItem(UID, 900386000); -- ITEM KONTROL EDILMELI
	if (OREADS < 1) then
		SelectMsg(UID, 2, -1, 9991, NPC, 18, 1000);
	else
		RobItem(UID, 900386000, 1) -- ITEM KONTROL EDILMELI
		GiveItem(UID, 700039768, 1, 30) -- ITEM KONTROL EDILMELI
	end
end

if (EVENT == 133) then -- Spirit Alseids
	SelectMsg(UID, 2, -1, 9990, NPC, 3000, 136, 3005, 101);
end

if (EVENT == 136) then
	ALSEIDS = HowmuchItem(UID, 900387000); -- ITEM KONTROL EDILMELI
	if (ALSEIDS < 1) then
		SelectMsg(UID, 2, -1, 9992, NPC, 18, 1000);
	else
		RobItem(UID, 900387000, 1) -- ITEM KONTROL EDILMELI
		GiveItem(UID, 700042769,1,30) -- ITEM KONTROL EDILMELI
	end
end


if (EVENT == 137) then -- Spirit Nereids
	SelectMsg(UID, 2, -1, 9990, NPC, 3000, 138, 3005, 101);
end

if (EVENT == 138) then
	NEREIDS = HowmuchItem(UID, 814661000); -- ITEM KONTROL EDILMELI
	if (NEREIDS < 1) then
		SelectMsg(UID, 2, -1, 9991, NPC, 18, 1000);
	else
		RobItem(UID, 814661000, 1) -- ITEM KONTROL EDILMELI
		GiveItem(UID, 700047795,1,30) -- ITEM KONTROL EDILMELI
	end
end

----------------------------------------------------------------------------
if (EVENT == 110) then -- Premium Item Use
	SelectMsg(UID, 3, -1, 9527, NPC, 7197, 176, 40372, 181, 7252, 182,7198,975, 50060, 190);
end



if (EVENT == 176) then -- DISC Premium
	SelectMsg(UID, 2, -1, 9527, NPC, 4006, 183, 4005, 101);
end

if (EVENT == 183) then
SlotControl = CheckGiveSlot(UID,1);
if (SlotControl == true) then -- slotta yer var 
	DCPREM = HowmuchItem(UID, 399281685);
	if (DCPREM < 1) then
		SelectMsg(UID, 2, -1, 9528, NPC, 18, 1000);
	else
RobItem(UID, 399281685, 1)
GivePremium(UID, 10, 720)
GiveItem(UID, 900030684,1, 30)

end 
end
end

if (EVENT == 181) then -- Exp Premium 30 Days
	SelectMsg(UID, 2, -1, 9527, NPC, 4006, 184, 4005, 101);
end

if (EVENT == 184) then
SlotControl = CheckGiveSlot(UID,1);
if (SlotControl == true) then -- slotta yer var 
EXPPREM = HowmuchItem(UID, 399282686); 
if (EXPPREM < 1) then 
SelectMsg(UID, 2, -1, 9528, NPC, 18, 101);
else
RobItem(UID, 399282686, 1) 
GivePremium(UID, 11, 720)
GiveItem(UID, 900030684,1, 30)
end 
end
end



if (EVENT == 182) then -- WAR Premium
	SelectMsg(UID, 2, -1, 9527, NPC, 4006, 185, 4005, 101);
end

if (EVENT == 185) then
SlotControl = CheckGiveSlot(UID,1);
if (SlotControl == true) then -- slotta yer var 
	WARPREM = HowmuchItem(UID, 399292764);
	if (WARPREM < 1) then
		SelectMsg(UID, 2, -1, 9528, NPC, 18, 1000);
	else
		RobItem(UID, 399292764, 1)
        GivePremium(UID, 12, 720)
		GiveItem(UID, 900030684,1, 30)
		
             end 
      end
end

if (EVENT == 975) then -- switch Premium
SelectMsg(UID, 2, -1, 9527, NPC, 4006, 976, 4005, 101); 
end

if (EVENT == 976) then 
SlotControl = CheckGiveSlot(UID,1);
if (SlotControl == true) then -- slotta yer var 
EXPPREM = HowmuchItem(UID, 399295859); 
if (EXPPREM < 1) then 

SelectMsg(UID, 2, -1, 9528, NPC, 18, 101);
else
RobItem(UID, 399295859, 1) 
GivePremium(UID, 10, 720) 
GivePremium(UID, 11, 720)
GivePremium(UID, 12, 720)
GiveItem(UID, 900183679, 1,30)
GiveItem(UID, 900702863, 1,30)
end 
end
end


if (EVENT == 190) then --Clan Premium 
	SelectMsg(UID, 3, -1, 9527, NPC, 4006, 195, 4005, -1); 
	--SelectMsg(UID, 2, -1, 9527, NPC, 4006, 183, 4005, 195);
end


if (EVENT == 195) then
	
	
	CheckLeader = isClanLeader(UID)
	
	if (CheckLeader == false) then
	SelectMsg(UID, 3, -1, 54418, NPC, 10, -1);
	else
	CLANPREM = HowmuchItem(UID, 399300000);
	
	if (CLANPREM < 1) then
	SelectMsg(UID, 3, -1, 54419, NPC, 18, -1);
	else
	UpdateClanPre(UID, 2, 720);
	end
	end
end

if (EVENT == 111) then -- Seal Coupon
	SelectMsg(UID, 2, -1, 9706, NPC, 7229, 177, 7230, 178);
end

if (EVENT == 177) then -- Seal 10x
	SelectMsg(UID, 2, -1, 9708, NPC, 4161, 179, 4162, 101);
end

if (EVENT == 179) then -- Seal 10x Yes
	
end

if (EVENT == 178) then -- Seal 50x
	SelectMsg(UID, 2, -1, 9709, NPC, 4161, 180, 4162, 101);
end

if (EVENT == 180) then -- Seal 50x Yes
	
end

if (EVENT == 104) then --Minevra Package
	MINEVRA = HowmuchItem(UID, 508112000);
	if (MINEVRA < 1) then
		SelectMsg(UID, 2, -1, 9622, NPC, 18, 1000);
	else
		SelectMsg(UID, 2, -1, 9621, NPC, 4006, 114, 4005, 101);
	end
end

if (EVENT == 114) then
	RobItem(UID, 508112000, 1)
  GiveItem(UID , 508059000, 1)
  GiveItem(UID , 508058000, 1)
end

if (EVENT == 105) then -- Pathos Glove Package
	PATHOS = HowmuchItem(UID, 508114000);
	if (PATHOS < 1) then
		SelectMsg(UID, 2, -1, 9629, NPC, 18, 1000);
	else
		SelectMsg(UID, 2, -1, 9628, NPC, 4006, 113, 4005, 101);
	end
end

if (EVENT == 113) then
	RobItem(UID, 508114000, 1)
	GiveItem(UID, 508060000,1)
        GiveItem(UID, 508060000,1)
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
	GiveItem(UID, 900058761, 1,30)
end

if (EVENT == 103) then -- 2.Sayfa
	SelectMsg(UID, 3, -1, 3018, NPC, 2003, 100, 7228, 111, 7496, 102, 7679, 542, 50052, 50006, 50053, 50020);
end

---------------------------------------------------------------------------------------------------------------
---Menicia's official list coupon
---------------------------------------------------------------------------------------------------------------
if (EVENT == 50020) then -- Menicia's official list coupon
	KURU = HowmuchItem(UID, 810163000);
	if (KURU < 1) then
		SelectMsg(UID, 2, -1, 44761, NPC, 18, 1000);
	else
		SelectMsg(UID, 2, -1, 44762, NPC, 4006, 50021, 4005, 101);
	end
end

if (EVENT == 50021) then
	RobItem(UID, 810163000, 1)
	GiveItem(UID, 810166000, 1,30)
end


---------------------------------------------------------------------------------------------------------------
---Hellfire Dragon Wings
---------------------------------------------------------------------------------------------------------------
if (EVENT == 50006) then -- Hellfire Dragon Wings
	ITEMDRGN = HowmuchItem(UID, 814044000);
	if (ITEMDRGN > 0) then
		SelectMsg(UID, 3, -1, 44759, NPC, 7680, 50007, 7681, 50008, 7682, 50009, 7683, 50010);
	else
		SelectMsg(UID, 2, -1, 44760, NPC, 18, 1000);
	end
end

--National point
if (EVENT == 50007) then
	NATION = CheckNation(UID);
	if (NATION == 1) then
		Check = isRoomForItem(UID, 810638711);
		if (Check == -1) then
			SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
		else
			RobItem(UID, 814044000, 1)
			GiveItem(UID, 810638711, 1,30)
		end
	else
		Check = isRoomForItem(UID, 810638711);
		if (Check == -1) then
			SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
		else
			RobItem(UID, 814044000, 1)
			GiveItem(UID, 810638711, 1,30)
		end
	end
end

--Defence
if (EVENT == 50008) then
	NATION = CheckNation(UID);
	if (NATION == 1) then
		Check = isRoomForItem(UID, 810638712);
		if (Check == -1) then
			SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
		else
			RobItem(UID, 814044000, 1)
			GiveItem(UID, 810638712, 1,30)
		end
	else
		Check = isRoomForItem(UID, 810638712);
		if (Check == -1) then
			SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
		else
			RobItem(UID, 814044000, 1)
			GiveItem(UID, 810638712, 1,30)
		end
	end
end

--Healt Bonus
if (EVENT == 50009) then
	NATION = CheckNation(UID);
	if (NATION == 1) then
		Check = isRoomForItem(UID, 810638730);
		if (Check == -1) then
			SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
		else
			RobItem(UID, 814044000, 1)
			GiveItem(UID, 810638730, 1,30)
		end
	else
		Check = isRoomForItem(UID, 810638730);
		if (Check == -1) then
			SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
		else
			RobItem(UID, 814044000, 1)
			GiveItem(UID, 810638730, 1,30)
		end
	end
end

--Exp Point
if (EVENT == 50010) then
	NATION = CheckNation(UID);
	if (NATION == 1) then
		Check = isRoomForItem(UID, 810638731);
		if (Check == -1) then
			SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
		else
			RobItem(UID, 814044000, 1)
			GiveItem(UID, 810638731, 1,30)
		end
	else
		Check = isRoomForItem(UID, 810638731);
		if (Check == -1) then
			SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
		else
			RobItem(UID, 814044000, 1)
			GiveItem(UID, 810638731, 1,30)
		end
	end
end
----------------------------------------------------------------------------------------------------------------------------
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
			GiveItem(UID, 810178835, 1,30)
		end
	else
		Check = isRoomForItem(UID, 810179839);
		if (Check == -1) then
			SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
		else
			RobItem(UID, 810164000, 1)
			GiveItem(UID, 810179839, 1,30)
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
			GiveItem(UID, 810178836, 1,30)
		end
	else
		Check = isRoomForItem(UID, 810179840);
		if (Check == -1) then
			SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
		else
			RobItem(UID, 810164000, 1)
			GiveItem(UID, 810179840, 1,30)
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
			GiveItem(UID, 810178837, 1,30)
		end
	else
		Check = isRoomForItem(UID, 810179841);
		if (Check == -1) then
			SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
		else
			RobItem(UID, 810164000, 1)
			GiveItem(UID, 810179841, 1,30)
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
			GiveItem(UID, 810178838, 1,30)
		end
	else
		Check = isRoomForItem(UID, 810179842);
		if (Check == -1) then
			SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
		else
			RobItem(UID, 810164000, 1)
			GiveItem(UID, 810179842, 1,30)
		end
	end
end

if (EVENT == 547) then -- Yeniceri Minevra
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
		GiveItem(UID, 518001636, 1,30)
	end
end

if (EVENT == 551) then
	Check = isRoomForItem(UID, 518001637);
	if (Check == -1) then
		SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
	else
		RobItem(UID, 508117000, 1)
		GiveItem(UID, 518001637,1,30)
	end
end

if (EVENT == 552) then
	Check = isRoomForItem(UID, 518001638);
	if (Check == -1) then
		SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
	else
		RobItem(UID, 508117000, 1)
		GiveItem(UID, 518001638, 1,30)
	end
end

if (EVENT == 553) then
	Check = isRoomForItem(UID, 518001639);
	if (Check == -1) then
		SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
	else
		RobItem(UID, 508117000, 1)
		GiveItem(UID, 518001639, 1,30)
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
	Check = isRoomForItem(UID, 518003636,30);
	if (Check == -1) then
		SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
	else
		RobItem(UID, 508116000, 1)
		GiveItem(UID, 518003636, 1,30)
	end
end

if (EVENT == 555) then
	Check = isRoomForItem(UID, 518003637);
	if (Check == -1) then
		SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
	else
		RobItem(UID, 508116000, 1)
		GiveItem(UID, 518003637, 1,30)
	end
end

if (EVENT == 556) then
	Check = isRoomForItem(UID, 518003638);
	if (Check == -1) then
		SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
	else
		RobItem(UID, 508116000, 1)
		GiveItem(UID, 518003638, 1,30)
	end
end

if (EVENT == 557) then
	Check = isRoomForItem(UID, 518003639);
	if (Check == -1) then
		SelectMsg(UID, 2, -1, 832, NPC, 27, 101);
	else
		RobItem(UID, 508116000, 1)
		GiveItem(UID, 518003639, 1,30)
	end
end