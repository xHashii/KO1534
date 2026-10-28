#pragma once

class CUnderMonsterChallenge : public OdbcRecordset
{
public:
	CUnderMonsterChallenge(OdbcConnection * dbConnection, UnderMonsterChallengeArray * pMap) 
    : OdbcRecordset(dbConnection), m_pMap(pMap) {}
	
	virtual tstring GetTableName() { return _T("UNDER_MONSTER_CHALLENGE"); }
	virtual tstring GetColumns() { return _T("sIndex, bStartTime1, bStartTime2, bStartTime3, bLevelMin, bLevelMax"); }
 
	virtual bool Fetch()
	{
		_UNDER_MONSTER_CHALLENGE * pData = new _UNDER_MONSTER_CHALLENGE;
		
		_dbCommand->FetchUInt16(1, pData->sIndex);
		_dbCommand->FetchByte(2, pData->bStartTime1);
		_dbCommand->FetchByte(3, pData->bStartTime2);
		_dbCommand->FetchByte(4, pData->bStartTime3);
		_dbCommand->FetchByte(5, pData->bLevelMin);
		_dbCommand->FetchByte(6, pData->bLevelMax);
 
     if (!m_pMap->PutData(pData->sIndex, pData))
       delete pData;
 
     return true;
   }
 
   UnderMonsterChallengeArray *m_pMap;
 };
