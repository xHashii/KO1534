#pragma once

class CIUserSealItem : public MySqlRecordset
{
public:
	CIUserSealItem(MySqlConnection * dbConnection, UserSealItemArray * pMap)
		: MySqlRecordset(dbConnection), m_pMap(pMap) {}

	virtual tstring GetTableName() { return _T("USER_SEAL"); }
	virtual tstring GetColumns() { return _T("strUserID, strSerial, SealSerial, bRaceSatis, sClass, bLevel, lExp, Stat_STR, Stat_STA, Stat_DEX, Stat_INT, Stat_CHA, bGold, bSkillPoints, strItem"); }

	virtual bool Fetch()
	{
		_USER_SEAL * pData = new _USER_SEAL;
		
		char stritem[INVENTORY_COSP * 9] = { 0 };
		char strSkill[10] = { 0 };

		int i = 1;
		_dbCommand->FetchString(i++, pData->sCharID);
		_dbCommand->FetchUInt64(i++, pData->iSerial);
		_dbCommand->FetchUInt32(i++, pData->SealSerial);
		_dbCommand->FetchByte(i++, pData->bRaceSatis);
		_dbCommand->FetchUInt16(i++, pData->sClass);
		_dbCommand->FetchByte(i++, pData->bLevel);
		_dbCommand->FetchUInt16(i++, pData->sExpPercent);
		_dbCommand->FetchByte(i++, pData->Stat_STR);
		_dbCommand->FetchByte(i++, pData->Stat_STA);
		_dbCommand->FetchByte(i++, pData->Stat_DEX);
		_dbCommand->FetchByte(i++, pData->Stat_INT);
		_dbCommand->FetchByte(i++, pData->Stat_CHA);
		_dbCommand->FetchUInt32(i++, pData->sGold);
		_dbCommand->FetchBinary(i++, strSkill, sizeof(strSkill));
		_dbCommand->FetchBinary(i++, stritem, sizeof(stritem));

		ByteBuffer SkillBuffer, ItemBuffer;
		SkillBuffer.append(strSkill, sizeof(strSkill));
		ItemBuffer.append(stritem, sizeof(stritem));

		memset(pData->Skill_Points, 0x00, sizeof(pData->Skill_Points));

		for (int i = 0; i < 9; i++)
			pData->Skill_Points[i] = SkillBuffer[i];

		for (int i = 0; i < INVENTORY_COSP; i++)
		{
			uint32 nNum;
			uint16 nDuration, nCount;

			ItemBuffer >> nNum >> nDuration >> nCount;

			_ITEM_TABLE *pTable = g_pMain->GetItemPtr(nNum);
			if (pTable == nullptr || nCount <= 0)
				continue;

			if (!pTable->m_bCountable && nCount > 1)
				nCount = 1;
			else if (nCount > ITEMCOUNT_MAX)
				nCount = ITEMCOUNT_MAX;

			pData->Item_Num[i] = nNum;
			pData->Item_Duration[i] = nDuration;
			pData->Item_Count[i] = nCount;
			pData->Item_Flag[i] = ITEM_FLAG_CHAR_SEAL;
		}

		if (!m_pMap->PutData(pData->SealSerial, pData))
			delete pData;

		return true;
	}

	UserSealItemArray *m_pMap;
};