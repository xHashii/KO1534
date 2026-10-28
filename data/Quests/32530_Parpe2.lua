--Event NPC From KoprimeWorld Code By Melanor


local UserClass;
local QuestNum;
local Ret = 0;
local NPC = 27100;


if EVENT == 100 then
    SelectMsg(UID, 3, -1, 6038, NPC, 48012 ,706); ---7203,152,7234,154,7235,155,7238,156);---
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