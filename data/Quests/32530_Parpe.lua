--Event NPC From KoprimeWorld Code By Melanor


local UserClass;
local QuestNum;
local Ret = 0;
local NPC = 27100;


if EVENT == 100 then
    SelectMsg(UID, 3, -1, 44670, NPC, 48046, 710, 48076, 714, 48089, 715, 49012, 720, 49013, 721, 49014, 725, 49017, 726, 49015, 727, 49016, 728, 49018, 729);  ---48065, 712,48074, 713,, 48012 ,706, 48056, 711, 48028, 707, 48012 ,706, 48076, 714, 48035, 708,7203,152,7234,154,7235,155,7238,156);---
end


local ITEMA = 0;


-----scroll-----
if (EVENT == 706) then
	SelectMsg(UID, 2, -1, 44665, NPC, 48013, 806, 48014, 807, 48016, 809, 48017, 810, 48021, 814, 48020, 813);
end

--undy
if (EVENT == 806) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 5000) then
		GiveItem(UID, 800079000,1,10)
		RobLoyalty(UID,5000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end
--ac
if (EVENT == 807) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 3000) then
		GiveItem(UID, 800077000,1,10)
		RobLoyalty(UID,3000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--pathos
if (EVENT == 808) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 30000) then
		GiveItem(UID, 800250000,1,7)
		RobLoyalty(UID,30000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--valkirre helmet
if (EVENT == 815) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 50000) then
		GiveItem(UID, 800170000,1,7)
		RobLoyalty(UID,50000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end
--valkirre armor
if (EVENT == 816) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 50000) then
		GiveItem(UID, 800180000,1,7)
		RobLoyalty(UID,50000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--wing
if (EVENT == 811) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 50000) then
		GiveItem(UID, 810164000,1,7)
		RobLoyalty(UID,50000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--prem mp
if (EVENT == 809) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 3000) then
		GiveItem(UID, 389400000,1)
		RobLoyalty(UID,3000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--prem hp
if (EVENT == 810) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 3000) then
		GiveItem(UID, 389390000,1)
		RobLoyalty(UID,3000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Nps Transfer
if (EVENT == 813) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 5000) then
		GiveItem(UID, 800360000,1,5)
		RobLoyalty(UID,5000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end
--Name changed
if (EVENT == 814) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 10000) then
		GiveItem(UID, 800032000,1,10)
		RobLoyalty(UID,10000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

-----personal armas-----
if (EVENT == 707) then
	SelectMsg(UID, 2, -1, 44666, NPC, 48029, 820, 48030, 821, 48031, 822, 48032, 823, 48033, 824, 48034, 825); -- 48018, 811, 48016, 809, 48017, 810, 48021, 814, 48020, 813);--
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
	SelectMsg(UID, 2, -1, 44666, NPC, 48036, 830,48037, 831, 48038, 832, 48039, 833, 48040, 834, 48041, 835, 48042, 836, 48043, 837, 48044, 838, 48045, 839);--48020, 813);--
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

-----alas diferentes latinko-----
if (EVENT == 710) then
	SelectMsg(UID, 2, -1, 44667, NPC, 48049, 801, 48050, 802, 48051, 803, 48052, 804, 48053, 805, 48054, 157, 48048, 841, 48047, 840, 49006, 842, 49006, 843);--, 48017, 810, 48021, 814, 48020, 813);
end

--Night chaos  wing hp--
if (EVENT == 801) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 2000) then
		GiveItem(UID, 810263913,1,7)
		RobLoyalty(UID,2000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Night chaos wing np--
if (EVENT == 802) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 2000) then
		GiveItem(UID, 810263911,1,7)
		RobLoyalty(UID,2000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Alencia Wing Blue---
if (EVENT == 803) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 2000) then
		GiveItem(UID, 900767869,1,7)
		RobLoyalty(UID,2000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Alencia Wing RED---
if (EVENT == 804) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 2000) then
		GiveItem(UID, 900768873,1,7)
		RobLoyalty(UID,2000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end
--Wing of Hero Blue--
if (EVENT == 805) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 2000) then
		GiveItem(UID, 900028683,1,7)
		RobLoyalty(UID,2000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Wing of Hero RED
if (EVENT == 157) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 2000) then
		GiveItem(UID, 900030684,1,7)
		RobLoyalty(UID,2000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--War Wing-----
if (EVENT == 841) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 2000) then
		GiveItem(UID, 910248763,1,7)
		RobLoyalty(UID,2000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Wings of Hellfire Dragon-----
if (EVENT == 840) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 500) then
		GiveItem(UID, 810638730,1,7)
		RobLoyalty(UID,500);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Wing of dragon  karus-----
if (EVENT == 842) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 2000) then
		GiveItem(UID, 810178837,1,7)
		RobLoyalty(UID,2000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Wings of dragon human-----
if (EVENT == 843) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 2000) then
		GiveItem(UID, 810179841,1,7)
		RobLoyalty(UID,2000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end


-----PATHOS ESPECIALES-----
if (EVENT == 711) then
	SelectMsg(UID, 2, -1, 44668, NPC, 48061, 163, 48062, 164, 48063, 165, 48064, 166,49002,300, 49003, 301, 49004, 302, 49005, 303);--, 48057, 159, 48058, 160, 48059, 161, 48060, 162, ----48017, 810, 48021, 814, 48020, 813);
end

--Black Attack Warrior Pathos Glove)--
if (EVENT == 159) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 5000) then
		GiveItem(UID, 506573666,1,1)
		RobLoyalty(UID,5000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Black Attack rogue Pathos Glove)--
if (EVENT == 160) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 5000) then
		GiveItem(UID, 507573667,1,1)
		RobLoyalty(UID,5000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Black Attack mage Pathos Glove)---
if (EVENT == 161) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 5000) then
		GiveItem(UID, 508573668,1,1)
		RobLoyalty(UID,5000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Black Attack priest Pathos Glove)---
if (EVENT == 162) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 5000) then
		GiveItem(UID, 509573669,1,1)
		RobLoyalty(UID,5000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end
--Attack warrior Pathos Glove--
if (EVENT == 163) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 2000) then
		GiveItem(UID, 502573462,1,7)
		RobLoyalty(UID,2000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Attack rogue Pathos Glove---
if (EVENT == 164) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 2000) then
		GiveItem(UID, 503573463,1,7)
		RobLoyalty(UID,2000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Attack mage Pathos Glove-----
if (EVENT == 165) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 2000) then
		GiveItem(UID, 504573464,1,7)
		RobLoyalty(UID,2000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Attack priest Pathos Glove-----
if (EVENT == 166) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 2000) then
		GiveItem(UID, 505573465,1,7)
		RobLoyalty(UID,2000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Defensa warrior Pathos Glove-----
if (EVENT == 300) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 2000) then
		GiveItem(UID, 511573471,1,3)
		RobLoyalty(UID,2000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Defensa rogue Pathos Glove-----
if (EVENT == 301) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 2000) then
		GiveItem(UID, 512573472,1,3)
		RobLoyalty(UID,2000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Defensa rogue Pathos Glove-----
if (EVENT == 302) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 2000) then
		GiveItem(UID, 513573473,1,3)
		RobLoyalty(UID,2000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Defensa rogue Pathos Glove-----
if (EVENT == 303) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 2000) then
		GiveItem(UID, 514573474,1,3)
		RobLoyalty(UID,2000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end


-----CUERPOS ITEM COSPRE SET-----
if (EVENT == 712) then
	SelectMsg(UID, 2, -1, 44669, NPC, 48070, 171, 48071, 172, 48072, 173, 48073, 174, 49008, 350, 49009, 351, 49010, 352, 49011, 353); ---48066, 167, 48067, 168, 48068, 169, 48069, 170,-----
end

--krowaz Armor Pauldron HP--
if (EVENT == 167) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 5000) then
		GiveItem(UID, 508311666,1,2)
		RobLoyalty(UID,5000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end
--krowaz HELMET Pauldron HP--
if (EVENT == 168) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 5000) then
		GiveItem(UID, 508313670,1,2)
		RobLoyalty(UID,5000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Ultimate Top HP--
if (EVENT == 169) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 5000) then
		GiveItem(UID, 708011741,1,2)
		RobLoyalty(UID,5000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Ultimate helmet HP--
if (EVENT == 170) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 5000) then
		GiveItem(UID, 708013718,1,2)
		RobLoyalty(UID,5000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end
--Yeniceri Pauldron HP--
if (EVENT == 171) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 2000) then
		GiveItem(UID, 518001636,1,7)
		RobLoyalty(UID,2000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Yeniceri helmet HP--
if (EVENT == 172) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 2000) then
		GiveItem(UID, 518003636,1,7)
		RobLoyalty(UID,2000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

-- Bahamut Pauldron HP--
if (EVENT == 173) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 2000) then
		GiveItem(UID, 508051466,1,7)
		RobLoyalty(UID,2000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

-- Bahamut Pauldron HP--
if (EVENT == 174) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 2000) then
		GiveItem(UID, 508471453,1,7)
		RobLoyalty(UID,2000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Grypon HP Pauldron
if (EVENT == 350) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 2000) then
		GiveItem(UID, 508053466,1,7)
		RobLoyalty(UID,2000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Grypon HP Helmet
if (EVENT == 351) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 2000) then
		GiveItem(UID, 508473453,1,7)
		RobLoyalty(UID,2000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Valkyrie HP Pauldron
if (EVENT == 352) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 2000) then
		GiveItem(UID, 508011441,1,7)
		RobLoyalty(UID,2000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Valkyrie HP helmet
if (EVENT == 353) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 2000) then
		GiveItem(UID, 508013318,1,7)
		RobLoyalty(UID,2000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

-----FULL ARMA PERSONAL-----
if (EVENT == 713) then
	SelectMsg(UID, 2, -1, 44666, NPC, 48075, 175);--, 48067, 168, 48068, 169, 48069, 170, 48070, 171, 48071, 172, 48072, 173, 48073, 174);
end

--SET PERSONAL--
if (EVENT == 175) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 100) then
		GiveItem(UID, 910126308, 1)
		 GiveItem(UID, 910120358, 1)
         GiveItem(UID, 910124588, 1)
         GiveItem(UID, 910123578, 1)
         GiveItem(UID, 910119308, 1)
	     GiveItem(UID, 910122358, 1)
	     GiveItem(UID, 910125378, 1)
		RobLoyalty(UID,100);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

-----Weapon krowaz-----
if (EVENT == 714) then
	SelectMsg(UID, 2, -1, 44665, NPC, 48077, 176, 48078, 177, 48079, 178, 48080, 179, 48081, 180, 48082, 181, 48083, 182, 48084, 183, 48085, 184, 48086, 185, 48087, 186, 48088, 187);
end

--Chaos Baal +8
if (EVENT == 176) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 50) then
		GiveItem(UID, 139430778,1,1)
		RobLoyalty(UID,50);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end
--Chaos Wirinom +8
if (EVENT == 177) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 50) then
		GiveItem(UID, 127430758,1,1)
		RobLoyalty(UID,50);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Chaos Nebiros +8
if (EVENT == 178) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 50) then
		GiveItem(UID, 159430778,1,1)
		RobLoyalty(UID,50);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Aztec Gold Molok+8
if (EVENT == 179) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 50) then
		GiveItem(UID, 183230848,1,1)
		RobLoyalty(UID,50);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end
--Aztec Gold Fulitol+8
if (EVENT == 180) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 50) then
		GiveItem(UID, 182430818,1,1)
		RobLoyalty(UID,50);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Aztec Gold Fulitol+8
if (EVENT == 181) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 50) then
		GiveItem(UID, 184430878,1,1)
		RobLoyalty(UID,50);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Gab Adamant+8
if (EVENT == 182) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 50) then
		GiveItem(UID, 197410338,1,1)
		RobLoyalty(UID,50);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Gab Blessing+8
if (EVENT == 183) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 50) then
		GiveItem(UID, 197420348,1,1)
		RobLoyalty(UID,50);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end
--Windforce Severe Diet+8
if (EVENT == 184) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 50) then
		GiveItem(UID, 180420768,1,1)
		RobLoyalty(UID,50);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Lousy Pickpocket Windforce+8
if (EVENT == 185) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 50) then
		GiveItem(UID, 180450798,1,1)
		RobLoyalty(UID,50);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Lousy Pickpocket Raum
if (EVENT == 186) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 50) then
		GiveItem(UID, 128440838,1,1)
		RobLoyalty(UID,50);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Weak Dwarf Raum+8
if (EVENT == 187) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 50) then
		GiveItem(UID, 128430828,1,1)
		RobLoyalty(UID,50);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

-----scroll-----
if (EVENT == 715) then
	SelectMsg(UID, 2, -1, 44665, NPC, 48090, 200, 48091, 201, 48092, 202, 48093, 203, 48094, 204, 48095, 205, 48096, 206, 48097,207, 49001, 208) ; ---, 815, 48023, 816, 48018, 811, 48016, 809, 48017, 810, 48021, 814, 48020, 813);
end

--Dyriads
if (EVENT == 200) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 1000) then
		GiveItem(UID, 700038767,1,7)
		RobLoyalty(UID,1000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end
--Oreads
if (EVENT == 201) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 1000) then
		GiveItem(UID, 700039768,1,7)
		RobLoyalty(UID,1000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Alseids
if (EVENT == 202) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 1000) then
		GiveItem(UID, 700042769,1,7)
		RobLoyalty(UID,1000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--Tinker War
if (EVENT == 203) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 10000) then
		GiveItem(UID, 700047920,1,7)
		RobLoyalty(UID,10000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--OTP EMBLEM
if (EVENT == 204) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 1000) then
		GiveItem(UID, 900677882,1,7)
		RobLoyalty(UID,1000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--like EMBLEM
if (EVENT == 205) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 1000) then
		GiveItem(UID, 810333856,1,7)
		RobLoyalty(UID,1000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--like GNGWN
if (EVENT == 206) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 1000) then
		GiveItem(UID, 810353858,1,7)
		RobLoyalty(UID,1000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--WAR EMBLEM
if (EVENT == 207) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 1000) then
		GiveItem(UID, 900597861,1,7)
		RobLoyalty(UID,1000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--REBORN EMBLEM
if (EVENT == 208) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 1000) then
		GiveItem(UID, 810934956,1,7)
		RobLoyalty(UID,1000);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end


--SET COSPRES--
if (EVENT == 720) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 1) then
		GiveItem(UID, 508013318, 1,1)
		 GiveItem(UID, 508011441, 1,1)
		 GiveItem(UID, 508473453, 1,1)
		 GiveItem(UID, 508053466, 1,1)
		 GiveItem(UID, 508471453, 1,1)
		 GiveItem(UID, 508051466, 1,1)
		 GiveItem(UID, 518003636, 1,1)
		 GiveItem(UID, 518001636, 1,1)
		 GiveItem(UID, 810434973, 1,30)
		 GiveItem(UID, 810333856, 1,30)

		 
		RobLoyalty(UID,1);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end


--SET SCROLL--
if (EVENT == 721) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 1) then
		GiveItem(UID, 800079000, 1,1)
		 GiveItem(UID, 800077000, 1,1)
		 GiveItem(UID, 800014000, 1)
		 GiveItem(UID, 800015000, 1)
		 GiveItem(UID, 800021000, 1)
		 GiveItem(UID, 800028000, 1)
		RobLoyalty(UID,1);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end


--SET ALAS MODERNAS--
if (EVENT == 725) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 1) then
		 GiveItem(UID, 910258750, 1,1)
		 GiveItem(UID, 910290753, 1,1)
		 GiveItem(UID, 910278752, 1,1)
		 GiveItem(UID, 910268751, 1,1)
		 GiveItem(UID, 810638730, 1,1)
		 
		RobLoyalty(UID,1);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--SET POTION HP Y MP--
if (EVENT == 726) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 1) then
		 GiveItem(UID, 389390000, 1,1)
		 GiveItem(UID, 389400000, 1,1)
				 
		RobLoyalty(UID,1);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--SET PATHOS DEFENSA--
if (EVENT == 727) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 1) then
		 GiveItem(UID, 511573471, 1,1)
		 GiveItem(UID, 512573472, 1,1)
		 GiveItem(UID, 513573473, 1,1)
		 GiveItem(UID, 514573474, 1,1)
				 
		RobLoyalty(UID,1);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end

--SET PATHOS ATACK--
if (EVENT == 728) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 1) then
		 GiveItem(UID, 505573465, 1,1)
		 GiveItem(UID, 503573463, 1,1)
		 GiveItem(UID, 502573462, 1,1)
		 GiveItem(UID, 504573464, 1,1)
				 
		RobLoyalty(UID,1);
	else
		SelectMsg(UID, 2, -1, 44664, NPC, 6002, 500);
	end
end


--SET PATHOS ATACK--
if (EVENT == 729) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty >= 1) then
		 GiveItem(UID, 910126308, 1)
	     GiveItem(UID, 910120358, 1)
         GiveItem(UID, 910124588, 1)
         GiveItem(UID, 910123578, 1)
         GiveItem(UID, 910119308, 1)
	     GiveItem(UID, 910122358, 1)
	     GiveItem(UID, 910125378, 1)
				 
		RobLoyalty(UID,1);
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