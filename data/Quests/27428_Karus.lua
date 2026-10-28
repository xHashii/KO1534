--Created by Equity -- %100 Usko Style.Special Quests
local Ret = 0;
local NPC = 27428;

if (EVENT == 190) then
 QuestNum = SearchQuest(UID, NPC);
 if (QuestNum == 0) then
  SelectMsg(UID, 2, -1, 4597, NPC, 10, 193);
 elseif (QuestNum > 1 and  QuestNum < 100) then
  NpcMsg(UID, 4598, NPC)
 else
  EVENT = QuestNum
 end
end

if (EVENT == 193) then
 Ret = 1;
end

local savenum = 2340;

if (EVENT == 530) then -- 83 Level 1000 Kill 
 SaveEvent(UID, 35005);
 SelectMsg(UID, 2, savenum, 45002, NPC, 4080, 193);
end

if (EVENT == 532) then
 MonsterSub = ExistMonsterQuestSub(UID);
 if (MonsterSub == 0) then
  SelectMsg(UID, 4, savenum, 45002, NPC, 22, 533, 23, 534);
 else
  SelectMsg(UID, 2, savenum, 45002, NPC, 10, 193);
 end
end

if (EVENT == 533) then
 SaveEvent(UID, 35004);
end

if (EVENT == 534) then
 SaveEvent(UID, 35001);
end

if (EVENT == 535) then
 SaveEvent(UID, 35002);  
 SelectMsg(UID, 2, savenum, 45002, NPC, 14, 193);
end

if (EVENT == 536) then
 MonsterCount = QuestMonsterCount(UID, 340, 1);
 if (MonsterCount < 0) then
  SelectMsg(UID, 2, savenum, 45002, NPC, 18, 538);
 else
  SelectMsg(UID, 4, savenum, 45002, NPC, 4172, 537, 4173, 193);
 end
end

if (EVENT == 538) then
 ShowMap(UID, 489);
end

if (EVENT == 537) then
 RunExchange(UID,8933)
 SaveEvent(UID, 35003);   
end

local savenum = 2350;

if (EVENT == 630) then -- 83 Level 2500 Kill 
 SaveEvent(UID, 35014);
 SelectMsg(UID, 2, savenum, 45003, NPC, 4080, 193);
end

if (EVENT == 632) then
 MonsterSub = ExistMonsterQuestSub(UID);
 if (MonsterSub == 0) then
  SelectMsg(UID, 4, savenum, 45003, NPC, 22, 533, 23, 534);
 else
  SelectMsg(UID, 2, savenum, 45003, NPC, 10, 193);
 end
end

if (EVENT == 633) then
 SaveEvent(UID, 35013);
end

if (EVENT == 634) then
 SaveEvent(UID, 35010);
end

if (EVENT == 635) then
 SaveEvent(UID, 35011);  
 SelectMsg(UID, 2, savenum, 45003, NPC, 14, 193);
end

if (EVENT == 636) then
 MonsterCount = QuestMonsterCount(UID, 340, 1);
 if (MonsterCount < 0) then
  SelectMsg(UID, 2, savenum, 45003, NPC, 18, 538);
 else
  SelectMsg(UID, 4, savenum, 45003, NPC, 4172, 537, 4173, 193);
 end
end

if (EVENT == 638) then
 ShowMap(UID, 489);
end

if (EVENT == 637) then
 RunExchange(UID,8934)
 SaveEvent(UID, 35012);   
end

local savenum = 2360;

if (EVENT == 730) then -- 83 Level 2500 Kill 
 SaveEvent(UID, 35019);
 SelectMsg(UID, 2, savenum, 45003, NPC, 4080, 193);
end

if (EVENT == 732) then
 MonsterSub = ExistMonsterQuestSub(UID);
 if (MonsterSub == 0) then
  SelectMsg(UID, 4, savenum, 45003, NPC, 22, 533, 23, 534);
 else
  SelectMsg(UID, 2, savenum, 45003, NPC, 10, 193);
 end
end

if (EVENT == 733) then
 SaveEvent(UID, 35018);
end

if (EVENT == 734) then
 SaveEvent(UID, 35015);
end

if (EVENT == 735) then
 SaveEvent(UID, 35016);  
 SelectMsg(UID, 2, savenum, 45003, NPC, 14, 193);
end

if (EVENT == 736) then
 MonsterCount = QuestMonsterCount(UID, 340, 1);
 if (MonsterCount < 0) then
  SelectMsg(UID, 2, savenum, 45003, NPC, 18, 538);
 else
  SelectMsg(UID, 4, savenum, 45003, NPC, 4172, 537, 4173, 193);
 end
end

if (EVENT == 738) then
 ShowMap(UID, 489);
end

if (EVENT == 737) then
 RunExchange(UID,8935)
 SaveEvent(UID, 35017);   
end

local savenum = 2370;

if (EVENT == 830) then -- 83 Level 5000 Kill 
 SaveEvent(UID, 35024);
 SelectMsg(UID, 2, savenum, 45004, NPC, 4080, 193);
end

if (EVENT == 832) then
 MonsterSub = ExistMonsterQuestSub(UID);
 if (MonsterSub == 0) then
  SelectMsg(UID, 4, savenum, 45004, NPC, 22, 533, 23, 534);
 else
  SelectMsg(UID, 2, savenum, 45004, NPC, 10, 193);
 end
end

if (EVENT == 833) then
 SaveEvent(UID, 35023);
end

if (EVENT == 834) then
 SaveEvent(UID, 35021);
end

if (EVENT == 835) then
 SaveEvent(UID, 35022);  
 SelectMsg(UID, 2, savenum, 45004, NPC, 14, 193);
end

if (EVENT == 836) then
 MonsterCount = QuestMonsterCount(UID, 340, 1);
 if (MonsterCount < 0) then
  SelectMsg(UID, 2, savenum, 45004, NPC, 18, 538);
 else
  SelectMsg(UID, 4, savenum, 45004, NPC, 4172, 537, 4173, 193);
 end
end

if (EVENT == 838) then
 ShowMap(UID, 489);
end

if (EVENT == 837) then
 RunExchange(UID,8936)
 SaveEvent(UID, 35022);   
end