#pragma once

class CMiningTableSet : public OdbcRecordset
{
public:
	CMiningTableSet(OdbcConnection * dbConnection, MiningItemArray * pMap) 
		: OdbcRecordset(dbConnection), m_pMap(pMap) {}

	virtual tstring GetTableName() { return _T("MINING_ITEM"); }
	virtual tstring GetColumns() { return _T("nRate,nItemID,nCount"); }

	virtual bool Fetch()
	{
		_MINING_ITEM *pData = new _MINING_ITEM;

		_dbCommand->FetchUInt16(1, pData->nRate);
		_dbCommand->FetchUInt32(2, pData->nItemID);
		_dbCommand->FetchUInt32(3, pData->nCount);
		if (!m_pMap->PutData(pData->nRate, pData))
			delete pData;
		
		return true;
	}

	MiningItemArray * m_pMap;
};