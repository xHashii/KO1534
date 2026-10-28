local NPC = 32608;
local Ret = 0;

if (EVENT == 100) then
	SelectMsg(UID, 2, -1, 9846, NPC, 40365, 101,40366,201,40367,301,40368,401,40369,501,40371,601,40372,602);
end

if(EVENT == 601)then
level = CheckLevel(UID);

if(level < 59 )then
	LevelChange(UID,59)
elseif(level > 59)then
	JumpTo(UID,59);
end


end
if(EVENT == 602)then
if(level < 83)then
	LevelChange(UID,83)
end
end



local	hp200 = {508011441,508471453,508051466,508011441}

local	hp100 = {508013318,508473453,508053466,508013318}
local	ac30 =  {508011442,508471454,508051467,508011442}

local	ac20 =  {508013319,508473454,508053467,508013319}
local	hp300wing =  {900452819,900452819,900452819,900452819}
local	def50wing =  {900452818,900452818,900452818,900452818}


local rand = 0



if (EVENT == 101) then
	SelectMsg(UID, 3, -1, 4902, NPC, 4288, 102, 4289, 103);
end


if (EVENT == 102) then
 rand = Random(1,4);
	ITEMHELMET = HowmuchItem(UID, 900569000);
   if ITEMHELMET > 0 then
      RobItem(UID,900569000,1)
	  GiveItem(UID,hp200[rand],1,48);
   end
	
end

if (EVENT == 103) then
rand = Random(1,4);
	ITEMHELMET = HowmuchItem(UID, 900569000);
   if ITEMHELMET > 0 then
      RobItem(UID,900569000,1)
	  GiveItem(UID,ac30[rand],1,48);
   end
	
end


if (EVENT == 201) then
	SelectMsg(UID, 3, -1, 4902, NPC, 4292, 202, 4293, 203);
end
if (EVENT == 202) then
rand = Random(1,4);
	ITEMHELMET = HowmuchItem(UID, 900568000);
   if ITEMHELMET > 0 then
      RobItem(UID,900568000,1)
	  GiveItem(UID,hp100[rand],1,48);
   end
	
end
if (EVENT == 203) then
rand = Random(1,4);
	ITEMHELMET = HowmuchItem(UID, 900568000);
   if ITEMHELMET > 0 then
      RobItem(UID,900568000,1)
	  GiveItem(UID,ac20[rand],1,48);
   end
	
end
if (EVENT == 301) then
	SelectMsg(UID, 3, -1, 10592, NPC, 7681, 302, 7682, 303);
end

if (EVENT == 302) then --def50
rand = Random(1,4);
	ITEMHELMET = HowmuchItem(UID, 810643000);
   if ITEMHELMET > 0 then
      RobItem(UID,810643000,1)
	  GiveItem(UID,def50wing[rand],1,48);
   end
	
end
if (EVENT == 303) then --hp300
rand = Random(1,4);
	ITEMHELMET = HowmuchItem(UID, 810643000);
   if ITEMHELMET > 0 then
      RobItem(UID,810643000,1)
	  GiveItem(UID,hp300wing[rand],1,48);
   end
	
end

if (EVENT == 401) then
	--premium ekle
	
	ITEMHELMET = HowmuchItem(UID, 900828000);
   if ITEMHELMET > 0 then
      RobItem(UID,900828000,1)
	  GivePremium(UID,6,48)
   end
	
end
if(EVENT == 501 )then
   --oreads
   ITEMHELMET = HowmuchItem(UID, 900386000);
   if ITEMHELMET > 0 then
      RobItem(UID,900386000,1)
	  GiveItem(UID,700039768,1,48)
   end
   
   
end
