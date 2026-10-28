#pragma once

class CKnightsUserSet : public MySqlRecordset
{
public:
	CKnightsUserSet(MySqlConnection * dbConnection, void * dummy) 
		: MySqlRecordset(dbConnection) {}

	virtual tstring GetTableName() { return _T("KNIGHTS_USER"); }
	virtual tstring GetColumns() { return _T("sIDNum, strUserID, nDonatedNP"); }

	virtual bool Fetch()
	{
		uint16 sIDNum;
		std::string strUserID;
		uint32 nDonatedNP;

		_dbCommand->FetchUInt16(1, sIDNum);
		_dbCommand->FetchString(2, strUserID);
		_dbCommand->FetchUInt32(3, nDonatedNP);

		CKnightsManager::AddKnightsUser(sIDNum, strUserID);
		CKnightsManager::AddUserDonatedNP(sIDNum, strUserID, nDonatedNP);
		return true;
	}
};