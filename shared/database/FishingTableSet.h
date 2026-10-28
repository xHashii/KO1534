#pragma once

class CFishingTableSet : public OdbcRecordset
{
public:
	CFishingTableSet(OdbcConnection * dbConnection, FishingItemArray * pMap) 
		: OdbcRecordset(dbConnection), m_pMap(pMap) {}

	virtual tstring GetTableName() { return _T("FISHING_ITEM"); }
	virtual tstring GetColumns() { return _T("nRate,nItemID,nCount"); }

	virtual bool Fetch()
	{
		_FISHING_ITEM *pData = new _FISHING_ITEM;

		_dbCommand->FetchUInt16(1, pData->nRate);
		_dbCommand->FetchUInt32(2, pData->nItemID);
		_dbCommand->FetchUInt32(3, pData->nCount);
		if (!m_pMap->PutData(pData->nRate, pData))
			delete pData;
		
		return true;
	}

	FishingItemArray * m_pMap;
};