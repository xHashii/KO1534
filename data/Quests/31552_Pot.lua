-- =============================================
-- LUA NEDİR ? .LUA UZANTILARI OYUN İÇİ GÖREVLERİN ÇALIŞMASINI SAĞLAYAN DOSYALARDIR.
-- GM KARAKTER İLE NPC YE TIKLADIĞINIZDA LUA İSMİ ALTTA YAZAR,DEĞİŞTİRMEK İSTEDİĞİNİZ GÖREVİ TIKLADIĞINIZDA EVENT NUMARASI AYNI ŞEKİLDE ALTTA YAZAR.
-- DEĞİŞİKLİK YAPMADAN ÖNCE YEDEĞİNİ ALINIZ.BU ALANI YETKİLİ DIŞINDA KURCAMALAYANIZ.
-- DÜZENLEMEK İSTEDİĞİNİZ LUAYI SEÇİN VE KOD SATIRINA YAPMAK İSTEDİĞİNİZ DEĞİŞİKLİĞİ EKLİYEREK KAYDEDİN.
-- =============================================
local NPC = 31552;

if (EVENT == 100) then
	QuestStatusCheck = GetQuestStatus(UID, 633)	
		if(QuestStatusCheck == 1) then
			EVENT = 101
		else
	QuestStatusCheck = GetQuestStatus(UID, 635)	
		if(QuestStatusCheck == 1) then
			EVENT = 102
		else
	QuestStatusCheck = GetQuestStatus(UID, 637)	
		if(QuestStatusCheck == 1) then
			EVENT = 103
		else
	QuestStatusCheck = GetQuestStatus(UID, 639)	
		if(QuestStatusCheck == 1) then
			EVENT = 104
				end
			end
		end
	end
end

if(EVENT == 101) then
SlotCheck = CheckGiveSlot(UID, 3)
     if SlotCheck == false then
       
         else
	COUNTA = HowmuchItem(UID, 900151000) 
	if(COUNTA < 1) then
		GiveItem(UID, 900151000);
		RobItem(UID, 900200000);
		SelectMsg(UID, 2, -1, 21582, NPC, 22,-1);
	end
end
end

if(EVENT == 102) then
SlotCheck = CheckGiveSlot(UID, 3)
     if SlotCheck == false then
       
         else
	COUNTA = HowmuchItem(UID, 900149000) 
	if(COUNTA < 1) then
		GiveItem(UID, 900149000);
		RobItem(UID, 900203000);
		SelectMsg(UID, 2, -1, 21582, NPC, 22,-1);
	end
end
end

if(EVENT == 103) then
SlotCheck = CheckGiveSlot(UID, 3)
     if SlotCheck == false then
       
         else
	COUNTA = HowmuchItem(UID, 900150000) 
	if(COUNTA < 1) then
		GiveItem(UID, 900150000);
		RobItem(UID, 900206000);
		SelectMsg(UID, 2, -1, 21582, NPC, 22,-1);
	end
end
end

if(EVENT == 104) then
SlotCheck = CheckGiveSlot(UID, 3)
     if SlotCheck == false then
       
         else
	COUNTA = HowmuchItem(UID, 900148000) 
	if(COUNTA < 1) then
		GiveItem(UID, 900148000);
		RobItem(UID, 900209000);
		SelectMsg(UID, 2, -1, 21582, NPC, 22,-1);
	end
end
end