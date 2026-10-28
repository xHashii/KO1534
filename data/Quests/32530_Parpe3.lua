--Event NPC From KoprimeWorld Code By Melanor


local UserClass;
local QuestNum;
local Ret = 0;
local NPC = 27100;


if EVENT == 100 then
    SelectMsg(UID, 3, -1, 6038, NPC, 48012 ,706, 48028, 707, 48035, 708, 48046, 709); ---7203,152,7234,154,7235,155,7238,156);---
end


local ITEMA = 0;


-----scroll-----
if (EVENT == 706) then
	SelectMsg(UID, 2, -1, 44665, NPC, 48013, 806, 48014, 807, 48015, 808, 48022, 815, 48023, 816, 48018, 811, 48016, 809, 48017, 810, 48021, 814, 48020, 813);
end

--undy
if (EVENT == 806) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 100000) then
		GiveItem(UID, 800079000,1)
		RobLoyalty(UID,100000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end
--ac
if (EVENT == 807) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 50000) then
		GiveItem(UID, 800077000,1)
		RobLoyalty(UID,50000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--pathos
if (EVENT == 808) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 50000) then
		GiveItem(UID, 800250000,1)
		RobLoyalty(UID,50000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--valkirre helmet
if (EVENT == 815) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 50000) then
		GiveItem(UID, 800170000,1)
		RobLoyalty(UID,50000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end
--valkirre armor
if (EVENT == 816) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 50000) then
		GiveItem(UID, 800180000,1)
		RobLoyalty(UID,50000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--wing
if (EVENT == 811) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 50000) then
		GiveItem(UID, 810164000,1)
		RobLoyalty(UID,50000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--prem mp
if (EVENT == 809) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 30000) then
		GiveItem(UID, 389400000,1)
		RobLoyalty(UID,30000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--prem hp
if (EVENT == 810) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 30000) then
		GiveItem(UID, 389390000,1)
		RobLoyalty(UID,30000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Nps Transfer
if (EVENT == 813) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 20000) then
		GiveItem(UID, 800360000,1)
		RobLoyalty(UID,20000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end
--Name changed
if (EVENT == 814) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 50000) then
		GiveItem(UID, 800032000,1)
		RobLoyalty(UID,50000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end




-----personal armas-----
if (EVENT == 707) then
	SelectMsg(UID, 2, -1, 44665, NPC, 48029, 820, 48030, 821, 48031, 822, 48032, 823, 48033, 824, 48034, 825); -- 48018, 811, 48016, 809, 48017, 810, 48021, 814, 48020, 813);--
end

--Two-handed Sword of <selfname>(+11)---
if (EVENT == 820) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 10000) then
		GiveItem(UID, 910145071,1,1)
		RobLoyalty(UID,10000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Dagger of <selfname>(+11)---
if (EVENT == 821) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 10000) then
		GiveItem(UID, 910144071,1,1)
		RobLoyalty(UID,10000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Shield of <selfname>(+11)---
if (EVENT == 822) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 10000) then
		GiveItem(UID, 910151311,1,1)
		RobLoyalty(UID,10000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Staff of <selfname>(+11)----
if (EVENT == 823) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 10000) then
		GiveItem(UID, 910148221,1,1)
		RobLoyalty(UID,10000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Bow of <selfname>(+11)---
if (EVENT == 824) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 10000) then
		GiveItem(UID, 910147131,1,1)
		RobLoyalty(UID,10000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Mace of <selfname>(+11)---
if (EVENT == 825) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 10000) then
		GiveItem(UID, 910150221,1,1)
		RobLoyalty(UID,10000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end



-----armas Basicas-----
if (EVENT == 708) then
	SelectMsg(UID, 2, -1, 44665, NPC, 48036, 830,48037, 831, 48038, 832, 48039, 833, 48040, 834, 48041, 835, 48042, 836, 48043, 837, 48044, 838, 48045, 839);--48020, 813);--
end

--Hell Breaker(+11)---
if (EVENT == 830) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 10000) then
		GiveItem(UID, 149111071,1,1)
		RobLoyalty(UID,10000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Avedon(+11) ---
if (EVENT == 831) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 10000) then
		GiveItem(UID, 139311131,1,1)
		RobLoyalty(UID,10000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Cold-Hearted Dagger(+11)---
if (EVENT == 832) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 10000) then
		GiveItem(UID, 119112221,1,1)
		RobLoyalty(UID,10000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end


--Eagle's Eye(+11)---
if (EVENT == 833) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 10000) then
		GiveItem(UID, 169312381,1,1)
		RobLoyalty(UID,10000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end


--Wreath of Erenion(+11)---
if (EVENT == 834) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 10000) then
		GiveItem(UID, 189111281,1,1)
		RobLoyalty(UID,10000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Lightning Erenion(+11)---
if (EVENT == 835) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 10000) then
		GiveItem(UID, 189311341,1,1)
		RobLoyalty(UID,10000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Glacier Erenion(+11)---
if (EVENT == 836) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 10000) then
		GiveItem(UID, 189211311,1,1)
		RobLoyalty(UID,10000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end


--Dread Shield(+11)---
if (EVENT == 837) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 10000) then
		GiveItem(UID, 179112441,1,1)
		RobLoyalty(UID,10000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Scorpion Shield(+11)---
if (EVENT == 838) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 10000) then
		GiveItem(UID, 170211281,1,1)
		RobLoyalty(UID,10000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Lobo hammer(+11)---
if (EVENT == 839) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 10000) then
		GiveItem(UID, 190251071,1,1)
		RobLoyalty(UID,10000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end


-----wings differents-----
if (EVENT == 709) then
	SelectMsg(UID, 2, -1, 44665, NPC, 48047, 840, 48048, 841); --48038, 832, 48039, 833, 48040, 834, 48041, 835, 48042, 836, 48043, 837, 48044, 838, 48045, 839);--48020, 813);--
end

--Wings of Hellfire Dragon (HP)-----
if (EVENT == 840) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 4000) then
		GiveItem(UID, 810638730,1,1)
		RobLoyalty(UID,4000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--War Wing-----
if (EVENT == 841) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 4000) then
		GiveItem(UID, 910248763,1,1)
		RobLoyalty(UID,4000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end



--Exper 


if EVENT == 152 then
   ITEMA = HowmuchItem(UID, 900132000);
   if ITEMA < 1 then
      GoldLose(UID, 50000)

--- Lvl Upper
ExpChange(UID, 1)

     
   end
end





-- Event Item Exchange


 if EVENT == 154 then
   ITEMA = HowmuchItem(UID, 379118000);
   if ITEMA < 1 then
     
     

      GiveItem(UID, 800132780, 1)





      


  end
end




-- scroll  (old clan match)


 if EVENT == 155 then
 ITEMA = HowmuchItem(UID, 379117000);
if ITEMA < 1 then
    
GoldLose(UID, 50000)
GiveItem(UID, 910139000, 30)
GiveItem(UID, 910140000, 30)
GiveItem(UID, 191600881, 30)
GiveItem(UID, 910141000, 30)
     


 end
end




-- Beginner Suprise


 if EVENT == 156 then
   ITEMA = HowmuchItem(UID, 379120000);
   if ITEMA < 1 then
     
      GoldLose(UID, 50000)
      GiveItem(UID, 389400000, 1)
      GiveItem(UID, 800014000, 1)
      GiveItem(UID, 800015000, 1)

      GiveItem(UID, 800013000, 1)
      GiveItem(UID, 800010000, 1)
     




   end
end


if EVENT == 155 then
   ITEMA = HowmuchItem(UID, 379117000);
   if ITEMA < 1 then
     GiveItem(UID, 910141000, 30)





   end
end