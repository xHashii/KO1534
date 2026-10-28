local NPC = 31718;


if EVENT == 100 then
    SelectMsg(UID, 2, -1, 44595, NPC, 40644, 101,27,-1);
end

if EVENT == 101 then
    SelectMsg(UID, 3, -1, 44595, NPC, 40636,102,40637,112,40638,122,40639,132,40640,142,40641,152,40642,162,40643,172);
end

if (EVENT == 102) then
	ITEMA = HowmuchItem(UID, 810977000);
	if (ITEMA < 10) then
		SelectMsg(UID, 2, -1, 44595, NPC, 18, 500);
	else
		SelectMsg(UID, 2, -1, 44595, NPC, 8518, 103);
	end
end

if (EVENT == 103) then
SLOTKONTROL = CheckGiveSlot(UID, 1)
     if SLOTKONTROL == false then
       SelectMsg(UID,2,-1,8898,NPC,10)
         else
RobItem(UID, 810977000,10)
GiveItem(UID,910004000,100);
SelectMsg(UID, 2, -1, 9110, NPC, 10, -1);
end
end

if (EVENT == 112) then
	ITEMA = HowmuchItem(UID, 810977000);
	if (ITEMA < 10) then
		SelectMsg(UID, 2, -1, 44595, NPC, 18, 500);
	else
		SelectMsg(UID, 2, -1, 44595, NPC, 8518, 113);
	end
end

if (EVENT == 113) then
SLOTKONTROL = CheckGiveSlot(UID, 1)
     if SLOTKONTROL == false then
       SelectMsg(UID,2,-1,8898,NPC,10)
         else
RobItem(UID, 810977000,10)
GiveItem(UID,910010000,70);
SelectMsg(UID, 2, -1, 9110, NPC, 10, -1);
end
end

if (EVENT == 122) then
	ITEMA = HowmuchItem(UID, 810977000);
	if (ITEMA < 30) then
		SelectMsg(UID, 2, -1, 44595, NPC, 18, 500);
	else
		SelectMsg(UID, 2, -1, 44595, NPC, 8518, 123);
	end
end

if (EVENT == 123) then
SLOTKONTROL = CheckGiveSlot(UID, 5)
     if SLOTKONTROL == false then
       SelectMsg(UID,2,-1,8898,NPC,10)
         else
RobItem(UID, 810977000,30)
GiveItem(UID,900144023,1);
GiveItem(UID,900144023,1);
GiveItem(UID,900144023,1);
GiveItem(UID,900144023,1);
GiveItem(UID,900144023,1);
SelectMsg(UID, 2, -1, 9110, NPC, 10, -1);
end
end

if (EVENT == 132) then
	ITEMA = HowmuchItem(UID, 810977000);
	if (ITEMA < 70) then
		SelectMsg(UID, 2, -1, 44595, NPC, 18, 500);
	else
		SelectMsg(UID, 2, -1, 44595, NPC, 8518, 133);
	end
end

if (EVENT == 133) then
SLOTKONTROL = CheckGiveSlot(UID, 1)
     if SLOTKONTROL == false then
       SelectMsg(UID,2,-1,8898,NPC,10)
         else
RobItem(UID, 810977000,70)
GiveItem(UID,379154000,5);
SelectMsg(UID, 2, -1, 9110, NPC, 10, -1);
end
end

if (EVENT == 142) then
	ITEMA = HowmuchItem(UID, 810977000);
	if (ITEMA < 100) then
		SelectMsg(UID, 2, -1, 44595, NPC, 18, 500);
	else
		SelectMsg(UID, 2, -1, 44595, NPC, 8518, 143);
	end
end

if (EVENT == 143) then
SLOTKONTROL = CheckGiveSlot(UID, 1)
     if SLOTKONTROL == false then
       SelectMsg(UID,2,-1,8898,NPC,10)
         else
RobItem(UID, 810977000,100)
GiveItem(UID,379156000,5);
SelectMsg(UID, 2, -1, 9110, NPC, 10, -1);
end
end

if (EVENT == 152) then
	ITEMA = HowmuchItem(UID, 810977000);
	if (ITEMA < 150) then
		SelectMsg(UID, 2, -1, 44595, NPC, 18, 500);
	else
		SelectMsg(UID, 2, -1, 44595, NPC, 4509, 153, 4510, 154);
	end
end

if (EVENT == 153) then
	SelectMsg(UID, 3, -1, 44595, NPC, 4505, 200, 4506, 210, 4507, 220, 4508, 230);
end

if (EVENT == 200) then
SLOTKONTROL = CheckGiveSlot(UID, 2)
     if SLOTKONTROL == false then
       SelectMsg(UID,2,-1,8898,NPC,10)
         else
		RobItem(UID, 810977000, 150)
		GiveItem(UID, 502573462, 1,7)
		SelectMsg(UID, 2, -1, 9110, NPC, 10, -1);
end
end

if (EVENT == 210) then
SLOTKONTROL = CheckGiveSlot(UID, 2)
     if SLOTKONTROL == false then
       SelectMsg(UID,2,-1,8898,NPC,10)
         else
		RobItem(UID, 810977000, 150)
		GiveItem(UID, 503573463, 1,7)
		SelectMsg(UID, 2, -1, 9110, NPC, 10, -1);
end
end

if (EVENT == 220) then
SLOTKONTROL = CheckGiveSlot(UID, 2)
     if SLOTKONTROL == false then
       SelectMsg(UID,2,-1,8898,NPC,10)
         else
		RobItem(UID, 810977000, 150)
		GiveItem(UID, 504573464, 1,7)
		SelectMsg(UID, 2, -1, 9110, NPC, 10, -1);
end
end

if (EVENT == 230) then
SLOTKONTROL = CheckGiveSlot(UID, 2)
     if SLOTKONTROL == false then
       SelectMsg(UID,2,-1,8898,NPC,10)
         else
		RobItem(UID, 810977000, 150)
		GiveItem(UID, 505573465, 1,7)
		SelectMsg(UID, 2, -1, 9110, NPC, 10, -1);
end
end


if (EVENT == 154) then
	SelectMsg(UID, 3, -1, 44595, NPC, 4514, 240, 4515, 250, 4516, 260, 4517, 270);
end

if (EVENT == 240) then
SLOTKONTROL = CheckGiveSlot(UID, 2)
     if SLOTKONTROL == false then
       SelectMsg(UID,2,-1,8898,NPC,10)
         else
		RobItem(UID, 810977000, 150)
		GiveItem(UID, 511573471, 1,15)
		GiveItem(UID, 511573471, 1,15)
		SelectMsg(UID, 2, -1, 9110, NPC, 10, -1);
end
end

if (EVENT == 250) then
SLOTKONTROL = CheckGiveSlot(UID, 2)
     if SLOTKONTROL == false then
       SelectMsg(UID,2,-1,8898,NPC,10)
         else
		RobItem(UID, 810977000, 150)
		GiveItem(UID, 512573472, 1,15)
		GiveItem(UID, 512573472, 1,15)
		SelectMsg(UID, 2, -1, 9110, NPC, 10, -1);
end
end

if (EVENT == 260) then
SLOTKONTROL = CheckGiveSlot(UID, 2)
     if SLOTKONTROL == false then
       SelectMsg(UID,2,-1,8898,NPC,10)
         else
		RobItem(UID, 810977000, 150)
		GiveItem(UID, 513573473, 1,15)
		GiveItem(UID, 513573473, 1,15)
		SelectMsg(UID, 2, -1, 9110, NPC, 10, -1);
end
end

if (EVENT == 270) then
SLOTKONTROL = CheckGiveSlot(UID, 2)
     if SLOTKONTROL == false then
       SelectMsg(UID,2,-1,8898,NPC,10)
         else
		RobItem(UID, 810977000, 150)
		GiveItem(UID, 514573474, 1,15)
		GiveItem(UID, 514573474, 1,15)
		SelectMsg(UID, 2, -1, 9110, NPC, 10, -1);
end
end

if (EVENT == 162) then
	ITEMA = HowmuchItem(UID, 810977000);
	if (ITEMA < 200) then
		SelectMsg(UID, 2, -1, 44595, NPC, 18, 500);
	else
		SelectMsg(UID, 2, -1, 44595, NPC, 8518, 163);
	end
end

if (EVENT == 163) then
SLOTKONTROL = CheckGiveSlot(UID, 1)
     if SLOTKONTROL == false then
       SelectMsg(UID,2,-1,8898,NPC,10)
         else
RobItem(UID, 810977000,200)
GiveItem(UID,900136000,1);
SelectMsg(UID, 2, -1, 9110, NPC, 10, -1);
end
end

if (EVENT == 172) then
	ITEMA = HowmuchItem(UID, 810977000);
	if (ITEMA < 300) then
		SelectMsg(UID, 2, -1, 44595, NPC, 18, 500);
	else
		SelectMsg(UID, 2, -1, 44595, NPC, 8518, 173);
	end
end

if (EVENT == 173) then
SLOTKONTROL = CheckGiveSlot(UID, 1)
     if SLOTKONTROL == false then
       SelectMsg(UID,2,-1,8898,NPC,10)
         else
    GiveItem(UID,910507000,1);
	RobItem(UID, 810977000,300)
	SelectMsg(UID, 2, -1, 9110, NPC, 10, -1);
end
end