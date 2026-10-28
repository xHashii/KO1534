#pragma once

class CMakeItemGroupSet : public OdbcRecordset
{
public:
	CMakeItemGroupSet(OdbcConnection * dbConnection, MakeItemGroupArray * pMap) 
		: OdbcRecordset(dbConnection), m_pMap(pMap) {}

	virtual tstring GetTableName() { return _T("MAKE_ITEM_GROUP"); }
	virtual tstring GetColumns() { return _T("iItemGroupNum, iItem_1, iItem_2, iItem_3, iItem_4, iItem_5, iItem_6, iItem_7, iItem_8, iItem_9, iItem_10, iItem_11, iItem_12, iItem_13, iItem_14, iItem_15, iItem_16, iItem_17, iItem_18, iItem_19, iItem_20, iItem_21, iItem_22, iItem_23, iItem_24, iItem_25, iItem_26, iItem_27, iItem_28, iItem_29, iItem_30, iItem_31, iItem_32, iItem_33, iItem_34, iItem_35, iItem_36, iItem_37, iItem_38, iItem_39, iItem_40, iItem_41, iItem_42, iItem_43, iItem_44, iItem_45, iItem_46, iItem_47, iItem_48, iItem_49, iItem_50, iItem_51, iItem_52, iItem_53, iItem_54, iItem_55, iItem_56, iItem_57, iItem_58, iItem_59, iItem_60, iItem_61, iItem_62, iItem_63, iItem_64, iItem_65, iItem_66, iItem_67, iItem_68, iItem_69, iItem_70, iItem_71, iItem_72, iItem_73, iItem_74, iItem_75, iItem_76, iItem_77, iItem_78, iItem_79, iItem_80, iItem_81, iItem_82, iItem_83, iItem_84, iItem_85, iItem_86, iItem_87, iItem_88, iItem_89, iItem_90, iItem_91, iItem_92, iItem_93, iItem_94, iItem_95, iItem_96, iItem_97, iItem_98, iItem_99, iItem_100"); }
	
	virtual bool Fetch()
	{
		_MAKE_ITEM_GROUP *pData = new _MAKE_ITEM_GROUP;

		_dbCommand->FetchUInt32(1, pData->iItemGroupNum);
		for (int i = 1; i <= 100; i++)
		{
			uint32 iItem;
			_dbCommand->FetchUInt32(i + 1, iItem);

			// Insert regardless of whether it's set or not. This is official behaviour.
			pData->iItems.push_back(iItem);
		}

		if (!m_pMap->PutData(pData->iItemGroupNum, pData))
			delete pData;

		return true;
	}

	MakeItemGroupArray *m_pMap;
};