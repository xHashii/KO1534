local UserClass;
local QuestNum;
local Ret = 0;
local NPC =29236;


if EVENT == 500 then
 SelectMsg(UID, 3, -1, 3019, NPC, 17500,1300,17501,1301,17502,1302,17503,1303,17504,1304,17505,1305,17506,1306); 
end

--EARRING
if EVENT == 1300 then
 SelectMsg(UID, 3, -1, 3019, NPC, 18000,510,18001,501,18002,502,18003,503,18004,504,18005,505,18006,506); 
end

--[Pendants & Neckless]
if EVENT == 1301 then
 SelectMsg(UID, 3, -1, 3019, NPC,19001,601,19002,602,19003,603,19004,604,19005,605,19006,606);
end

--[Belts]
if EVENT == 1302 then
 SelectMsg(UID, 3, -1, 3019, NPC, 17000,310,17001,301,17002,302,17003,303,17004,304);
end

--[Rings]
if EVENT == 1303 then
 SelectMsg(UID, 3, -1, 3019, NPC,15002,202,15003,203,15004,204,15005,205,15006,206); 
end

--WEAPON STAFFS
if EVENT == 1304 then
 SelectMsg(UID, 3, -1, 3019, NPC, 16000,410,16001,401,16002,402,16003,403,16004,404,16005,405); 
end

--[Weapons]
if EVENT == 1305 then
 SelectMsg(UID, 3, -1, 3019, NPC, 20010,810,20011,801,20012,802,20013,803,20014,804); 
end

--[Shield]
if EVENT == 1306 then
 SelectMsg(UID, 3, -1, 3019, NPC, 20015,805);--,20016,806); 
end


-- [Defender Of The Lord +9 / 70.000 NP]
if (EVENT == 805) then
	SelectMsg(UID, 3, -1, 3019, NPC, 20000,6021)
end

if (EVENT == 6021) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty > 69999)  then
	GiveItem(UID, 179101299, 1)
	RobLoyalty(UID, 70000)
	else
	SelectMsg(UID, 3, -1, 3019, NPC, 20001,144)
end
end

--[Dread Shield +9 / 120.000 NP]
if (EVENT == 806) then
	SelectMsg(UID, 3, -1, 3019, NPC, 20000,6022)
end

if (EVENT == 6022) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty > 119999)  then
	GiveItem(UID, 179102329, 1)
	RobLoyalty(UID, 120000)
	else
	SelectMsg(UID, 3, -1, 3019, NPC, 20001,144)
end
end


--------------------------------------------
-- [Mirage Dagger +9 / 100.000 NP]
if (EVENT == 810) then
	SelectMsg(UID, 3, -1, 3019, NPC, 20000,6016)
end

if (EVENT == 6016) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty > 99999)  then
	GiveItem(UID, 111110049, 1)
	RobLoyalty(UID, 100000)
	else
	SelectMsg(UID, 3, -1, 3019, NPC, 20001,144)
end
end

-- [Dark Vane +9 / 150.000 NP]
if (EVENT == 801) then
	SelectMsg(UID, 3, -1, 3019, NPC, 20000,6017)
end

if (EVENT == 6017) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty > 149999)  then
	GiveItem(UID, 119101209, 1)
	RobLoyalty(UID, 150000)
	else
	SelectMsg(UID, 3, -1, 3019, NPC, 20001,144)
end
end

-- [Iron Impact +9 / 120.000 NP]
if (EVENT == 802) then
	SelectMsg(UID, 3, -1, 3019, NPC, 20000,6018)
end

if (EVENT == 6018) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty > 119999)  then
	GiveItem(UID, 146210049, 1)
	RobLoyalty(UID, 120000)
	else
	SelectMsg(UID, 3, -1, 3019, NPC, 20001,144)
end
end

-- [Totamic Spear +9 and Hanguk Sword +9 / 150.000 NP]
if (EVENT == 803) then
	SelectMsg(UID, 3, -1, 3019, NPC, 20000,6019)
end

if (EVENT == 6019) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty > 149999)  then
	GiveItem(UID, 151310049, 1)
	GiveItem(UID, 129101219, 1)
	RobLoyalty(UID, 150000)
	else
	SelectMsg(UID, 3, -1, 3019, NPC, 20001,144)
end
end

-- [Eagle's Eye +9 / 70.000 NP]
if (EVENT == 804) then
	SelectMsg(UID, 3, -1, 3019, NPC, 20000,6020)
end

if (EVENT == 6020) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty > 69999)  then
	GiveItem(UID, 169302419, 1)
	RobLoyalty(UID, 70000)
	else
	SelectMsg(UID, 3, -1, 3019, NPC, 20001,144)
end
end



---------------------------------------------------
-- [Wreath Of Erenion +9 / 70.000 NP]
if (EVENT == 410) then
	SelectMsg(UID, 3, -1, 3019, NPC, 20000,6010)
end

if (EVENT == 6010) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty > 69999)  then
	GiveItem(UID, 189101309, 1)
	RobLoyalty(UID, 70000)
	else
	SelectMsg(UID, 3, -1, 3019, NPC, 20001,144)
end
end

-- [Glacier Erenion +9 / 70.000 NP]
if (EVENT == 401) then
	SelectMsg(UID, 3, -1, 3019, NPC, 20000,6011)
end

if (EVENT == 6011) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty > 69999)  then
	GiveItem(UID, 189201269, 1)
	RobLoyalty(UID, 70000)
	else
	SelectMsg(UID, 3, -1, 3019, NPC, 20001,144)
end
end

-- [Lightning Erenion +9 / 70.000 NP]
if (EVENT == 402) then
	SelectMsg(UID, 3, -1, 3019, NPC, 20000,6012)
end

if (EVENT == 6012) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty > 69999)  then
	GiveItem(UID, 189301279, 1)
	RobLoyalty(UID, 70000)
	else
	SelectMsg(UID, 3, -1, 3019, NPC, 20001,144)
end
end

-- [Scorching Staff +9 and Lycaon Staff +9 / 100.000 NP]
if (EVENT == 403) then
	SelectMsg(UID, 3, -1, 3019, NPC, 20000,6013)
end

if (EVENT == 6013) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty > 99999)  then
	GiveItem(UID, 189302639, 1)
	GiveItem(UID, 180110299, 1)
	RobLoyalty(UID, 100000)
	else
	SelectMsg(UID, 3, -1, 3019, NPC, 20001,144)
end
end

-- [Oasis Staff +9 and Lobo Staff +9 / 100.000 NP]
if (EVENT == 404) then
	SelectMsg(UID, 3, -1, 3019, NPC, 20000,6014)
end

if (EVENT == 6014) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty > 99999)  then
	GiveItem(UID, 189102648, 1)
	GiveItem(UID, 180110278, 1)
	RobLoyalty(UID, 100000)
	else
	SelectMsg(UID, 3, -1, 3019, NPC, 20001,144)
end
end

-- [Chaotic Staff +9 and Lupus Staff +9 / 100.000 NP]
if (EVENT == 405) then
	SelectMsg(UID, 3, -1, 3019, NPC, 20000,6015)
end

if (EVENT == 6015) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty > 99999)  then
	GiveItem(UID, 189202658, 1)
	GiveItem(UID, 180110288, 1)
	RobLoyalty(UID, 100000)
	else
	SelectMsg(UID, 3, -1, 3019, NPC, 20001,144)
end
end

-------------------------------------------------
-- [Ring Of Felankor +3 / 120.000 NP]
if (EVENT == 202) then
	SelectMsg(UID, 3, -1, 3019, NPC, 20000,6005)
end

if (EVENT == 6005) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty > 119999)  then
	GiveItem(UID, 330620433, 1)
	RobLoyalty(UID, 120000)
	else
	SelectMsg(UID, 3, -1, 3019, NPC, 20001,144)
end
end

-- [Foverin +4 / 70.000 NP]
if (EVENT == 203) then
	SelectMsg(UID, 3, -1, 3019, NPC, 20000,6006)
end

if (EVENT == 6006) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty > 69999)  then
	GiveItem(UID, 330940634, 1)
	RobLoyalty(UID, 70000)
	else
	SelectMsg(UID, 3, -1, 3019, NPC, 20001,144)
end
end

-- [Elf Ring +4 / 70.000 NP] 
if (EVENT == 204) then
	SelectMsg(UID, 3, -1, 3019, NPC, 20000,6007)
end

if (EVENT == 6007) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty > 69999)  then
	GiveItem(UID, 330610404, 1)
	RobLoyalty(UID, 70000)
	else
	SelectMsg(UID, 3, -1, 3019, NPC, 20001,144)
end
end

-- [Agate Ring +4 / 70.000 NP]
if (EVENT == 205) then
	SelectMsg(UID, 3, -1, 3019, NPC, 20000,6008)
end

if (EVENT == 6008) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty > 69999)  then
	GiveItem(UID, 330610344, 1)
	RobLoyalty(UID, 70000)
	else
	SelectMsg(UID, 3, -1, 3019, NPC, 20001,144)
end
end

-- [Diamond Ring +4 / 70.000 NP]
if (EVENT == 206) then
	SelectMsg(UID, 3, -1, 3019, NPC, 20000,6009)
end

if (EVENT == 6009) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty > 69999)  then
	GiveItem(UID, 330410364, 1)
	RobLoyalty(UID, 70000)
	else
	SelectMsg(UID, 3, -1, 3019, NPC, 20001,144)
end
end

---------------------------------------------------------------
-- [String Of Skulls +4 / 90.000 NP]
if (EVENT == 310) then
	SelectMsg(UID, 3, -1, 3019, NPC, 20000,7000)
end

if (EVENT == 7000) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty > 89999)  then
	GiveItem(UID, 340410164, 1)
	RobLoyalty(UID, 90000)
	else
	SelectMsg(UID, 3, -1, 3019, NPC, 20001,144)
end
end

--[Belt Of Strength +4 / 40.000 NP]
if (EVENT == 301) then
	SelectMsg(UID, 3, -1, 3019, NPC, 20000,6000)
end

if (EVENT == 6000) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty > 39999)  then
	GiveItem(UID, 340510404, 1)
	RobLoyalty(UID, 40000)
	else
	SelectMsg(UID, 3, -1, 3019, NPC, 20001,144)
end
end

--[Belt Of Dexterity +4 / 40.000 NP]
if (EVENT == 302) then
	SelectMsg(UID, 3, -1, 3019, NPC, 20000,6001)
end

if (EVENT == 6001) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty > 39999)  then
	GiveItem(UID, 340610414, 1)
	RobLoyalty(UID, 40000)
	else
	SelectMsg(UID, 3, -1, 3019, NPC, 20001,144)
end
end

-- [Belt Of Life +4 / 40.000 NP]
if (EVENT == 303) then
	SelectMsg(UID, 3, -1, 3019, NPC, 20000,6003)
end

if (EVENT == 6003) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty > 39999)  then
	GiveItem(UID, 340110314, 1)
	RobLoyalty(UID, 40000)
	else
	SelectMsg(UID, 3, -1, 3019, NPC, 20001,144)
end
end

-- [Light Belt Of Life +4 / 40.000 NP]
if (EVENT == 304) then
	SelectMsg(UID, 3, -1, 3019, NPC, 20000,6004)
end

if (EVENT == 6004) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty > 39999)  then
	GiveItem(UID, 340110134, 1)
	RobLoyalty(UID, 40000)
	else
	SelectMsg(UID, 3, -1, 3019, NPC, 20001,144)
end
end

--------------------------------------------
--[Amulet Of Strength +4 / 60.000 NP]
if (EVENT == 601) then
	SelectMsg(UID, 3, -1, 3019, NPC, 20000,4451)
end

if (EVENT == 4451) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty > 59999)  then
	GiveItem(UID, 320610344, 1)
	RobLoyalty(UID, 60000)
	else
	SelectMsg(UID, 3, -1, 3019, NPC, 20001,144)
end
end

--- [Amulet Of Goddess +4 / 60.000 NP]
if (EVENT == 602) then
	SelectMsg(UID, 3, -1, 3019, NPC, 20000,4452)
end

if (EVENT == 4452) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty > 59999)  then
	GiveItem(UID, 320510424, 1)
	RobLoyalty(UID, 60000)
	else
	SelectMsg(UID, 3, -1, 3019, NPC, 20001,144)
end
end

-- [Amulet Of Health +4 / 60.000 NP]
if (EVENT == 603) then
	SelectMsg(UID, 3, -1, 3019, NPC, 20000,4453)
end

if (EVENT == 4453) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty > 59999)  then
	GiveItem(UID, 320510384, 1)
	RobLoyalty(UID, 60000)
	else
	SelectMsg(UID, 3, -1, 3019, NPC, 20001,144)
end
end

--[Priest Pendant +4 / 90.000 NP]
if (EVENT == 604) then
	SelectMsg(UID, 3, -1, 3019, NPC, 20000,4454)
end

if (EVENT == 4454) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty > 89999)  then
	GiveItem(UID, 320110324, 1)
	RobLoyalty(UID, 90000)
	else
	SelectMsg(UID, 3, -1, 3019, NPC, 20001,144)
end
end

--[Warrior Pendant +4 / 90.000 NP]
if (EVENT == 605) then
	SelectMsg(UID, 3, -1, 3019, NPC, 20000,4455)
end

if (EVENT == 4455) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty > 89999)  then
	GiveItem(UID, 320110304, 1)
	RobLoyalty(UID, 90000)
	else
	SelectMsg(UID, 3, -1, 3019, NPC, 20001,144)
end
end

-- [Elemantal Pendant +4 / 90.000 NP]
if (EVENT == 606) then
	SelectMsg(UID, 3, -1, 3019, NPC, 20000,4456)
end

if (EVENT == 4456) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty > 89999)  then
	GiveItem(UID, 320110314, 1)
	RobLoyalty(UID, 90000)
	else
	SelectMsg(UID, 3, -1, 3019, NPC, 20001,144)
end
end

--------------------------------------------------------
--[Elf-Metal Earring +4 / 90.000 NP]
if (EVENT == 510) then
	SelectMsg(UID, 3, -1, 3019, NPC, 20000,8444)
end

if (EVENT == 8444) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty > 89999)  then
	GiveItem(UID, 310610254, 1)
	RobLoyalty(UID, 90000)
	else
	SelectMsg(UID, 3, -1, 3019, NPC, 20001,144)
end
end

--[Platinum Earring +4 / 90.000 NP]
if (EVENT == 501) then
	SelectMsg(UID, 3, -1, 3019, NPC, 20000,8445)
end

if (EVENT == 8445) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty > 89999)  then
	GiveItem(UID, 310410244, 1)
	RobLoyalty(UID, 90000)
	else
	SelectMsg(UID, 3, -1, 3019, NPC, 20001,144)
end
end

--[Secret-Silver Earring +4 / 90.000 NP]
if (EVENT == 502) then
	SelectMsg(UID, 3, -1, 3019, NPC, 20000,8446)
end

if (EVENT == 8446) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty > 89999)  then
	GiveItem(UID, 310410264, 1)
	RobLoyalty(UID, 90000)
	else
	SelectMsg(UID, 3, -1, 3019, NPC, 20001,144)
end
end

--[Warrior Earring +4 / 60.000 NP]
if (EVENT == 503) then
	SelectMsg(UID, 3, -1, 3019, NPC, 20000,8447)
end

if (EVENT == 8447) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty > 59999)  then
	GiveItem(UID, 310310404, 1)
	RobLoyalty(UID, 60000)
	else
	SelectMsg(UID, 3, -1, 3019, NPC, 20001,144)
end
end

--[Rogue Earring +4 / 60.000 NP]
if (EVENT == 504) then
	SelectMsg(UID, 3, -1, 3019, NPC, 20000,8448)
end

if (EVENT == 8448) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty > 59999)  then
	GiveItem(UID, 310310414, 1)
	RobLoyalty(UID, 60000)
	else
	SelectMsg(UID, 3, -1, 3019, NPC, 20001,144)
end
end

--[Cleric Earring +4 / 60.000 NP]
if (EVENT == 505) then
	SelectMsg(UID, 3, -1, 3019, NPC, 20000,8449)
end

if (EVENT == 8449) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty > 59999)  then
	GiveItem(UID, 310310424, 1)
	RobLoyalty(UID, 60000)
	else
	SelectMsg(UID, 3, -1, 3019, NPC, 20001,144)
end
end

--[Opal Earring +4 / 60.000 NP]
if (EVENT == 506) then
	SelectMsg(UID, 3, -1, 3019, NPC, 20000,8450)
end

if (EVENT == 8450) then
	Loyalty = CheckLoyalty(UID)
	if (Loyalty > 59999)  then
	GiveItem(UID, 310510294, 1)
	RobLoyalty(UID, 60000)
	else
	SelectMsg(UID, 3, -1, 3019, NPC, 20001,144)
end
end
----------------------------------------------------


