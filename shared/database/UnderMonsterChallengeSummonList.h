#pragma once
 
class CUnderMonsterChallengeSummonList : public MySqlRecordset
{
public:
	CUnderMonsterChallengeSummonList(MySqlConnection * dbConnection, UnderMonsterChallengeSummonListArray * pMap) 
    : MySqlRecordset(dbConnection), m_pMap(pMap) {}
	
	virtual tstring GetTableName() { return _T("UNDER_MONSTER_CHALLENGE_SUMMON_LIST"); }
	virtual tstring GetColumns() { return _T("sIndex, bLevel, bStage, bStageLevel, sTime, sSid, sCount, sPosX, sPosZ, bRange"); }
 
	virtual bool Fetch()
	{
		_UNDER_MONSTER_CHALLENGE_SUMMON_LIST * pData = new _UNDER_MONSTER_CHALLENGE_SUMMON_LIST;
		
		int i = 1;
		_dbCommand->FetchUInt16(i++, pData->sIndex);
		_dbCommand->FetchByte(i++, pData->bLevel);
		_dbCommand->FetchByte(i++, pData->bStage);
		_dbCommand->FetchByte(i++, pData->bStageLevel);
		_dbCommand->FetchUInt16(i++, pData->sTime);
		_dbCommand->FetchUInt16(i++, pData->sSid);
		_dbCommand->FetchUInt16(i++, pData->sCount);
		_dbCommand->FetchUInt16(i++, pData->sPosX);
		_dbCommand->FetchUInt16(i++, pData->sPosZ);
		_dbCommand->FetchByte(i++, pData->bRange);
 
     if (!m_pMap->PutData(pData->sIndex, pData))
       delete pData;
 
     return true;
   }
 
   UnderMonsterChallengeSummonListArray *m_pMap;
 };