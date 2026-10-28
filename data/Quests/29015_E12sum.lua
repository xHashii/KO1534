-- =============================================
-- LUA NEDİR ? .LUA UZANTILARI OYUN İÇİ GÖREVLERİN ÇALIŞMASINI SAĞLAYAN DOSYALARDIR.
-- GM KARAKTER İLE NPC YE TIKLADIĞINIZDA LUA İSMİ ALTTA YAZAR,DEĞİŞTİRMEK İSTEDİĞİNİZ GÖREVİ TIKLADIĞINIZDA EVENT NUMARASI AYNI ŞEKİLDE ALTTA YAZAR.
-- DEĞİŞİKLİK YAPMADAN ÖNCE YEDEĞİNİ ALINIZ.BU ALANI YETKİLİ DIŞINDA KURCAMALAYANIZ.
-- DÜZENLEMEK İSTEDİĞİNİZ LUAYI SEÇİN VE KOD SATIRINA YAPMAK İSTEDİĞİNİZ DEĞİŞİKLİĞİ EKLİYEREK KAYDEDİN.
-- =============================================
local NPC = 29015;

if (EVENT == 100)then
	QuestStatusCheck = GetQuestStatus(UID, 704)	 
	ITEM = HowmuchItem(UID, 900224000)
		if(QuestStatusCheck == 1 and ITEM > 0) then
			EVENT = 101
		else
			SelectMsg(UID, 2, -1, 22279, NPC,10,-1);
	end
end

if (EVENT == 101)then
	SelectMsg(UID, 2, -1, 22279, NPC, 3000,102,3005,-1);
end

if(EVENT == 102) then
	QuestStatusCheck = GetQuestStatus(UID, 704)	 
	ITEM = HowmuchItem(UID, 900224000)
		if(QuestStatusCheck == 1 and ITEM > 0) then
	ZONE = GetZoneID(UID);
		if(ZONE == 2) then
			SpawnEventNpc(UID,9158,0,2,1287,0,545);
			ShowEffect(UID, 300391);
			RobItem(UID, 900224000, 1);
	elseif(ZONE == 7) then
			SpawnEventNpc(UID,9158,0,7,1287,0,545);
			ShowEffect(UID, 300391);
			RobItem(UID, 900224000, 1);
	elseif(ZONE == 8) then
			SpawnEventNpc(UID,9158,0,8,1287,0,545);
			ShowEffect(UID, 300391);
			RobItem(UID, 900224000, 1);
		else
			SelectMsg(UID, 2, -1, 22279, NPC,10,-1);
		end
	end
end