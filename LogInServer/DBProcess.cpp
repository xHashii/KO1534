#include "stdafx.h"

bool CDBProcess::Connect(const MySqlConfig & config)
{
	if (!m_dbConnection.Connect(config))
	{
		g_pMain->ReportSQLError(m_dbConnection.GetError());
		return false;
	}

	return true;
}

bool CDBProcess::LoadVersionList()
{
	unique_ptr<MySqlCommand> dbCommand(m_dbConnection.CreateCommand());
	if (dbCommand.get() == nullptr)
		return false;

	if (!dbCommand->Execute(_T("SELECT sVersion, sHistoryVersion, strFilename FROM VERSION")))
	{
		g_pMain->ReportSQLError(m_dbConnection.GetError());
		return false;
	}

	if (dbCommand->hasData())
	{
		g_pMain->m_sLastVersion = 0;
		do
		{
			_VERSION_INFO *pVersion = new _VERSION_INFO;

			dbCommand->FetchUInt16(1, pVersion->sVersion);
			dbCommand->FetchUInt16(2, pVersion->sHistoryVersion);
			dbCommand->FetchString(3, pVersion->strFilename);

			g_pMain->m_VersionList.insert(make_pair(pVersion->strFilename, pVersion));

			if (g_pMain->m_sLastVersion < pVersion->sVersion)
				g_pMain->m_sLastVersion = pVersion->sVersion;

		} while (dbCommand->MoveNext());
	}

	return true;
}

bool CDBProcess::LoadUserCountList()
{
	unique_ptr<MySqlCommand> dbCommand(m_dbConnection.CreateCommand());
	if (dbCommand.get() == nullptr)
		return false;

	if (!dbCommand->Execute(_T("SELECT serverid, zone1_count, zone2_count, zone3_count FROM CONCURRENT")))
	{
		g_pMain->ReportSQLError(m_dbConnection.GetError());
		return false;
	}

	if (dbCommand->hasData())
	{
		do
		{
			uint16 zone_1 = 0, zone_2 = 0, zone_3 = 0; uint8 serverID;
			dbCommand->FetchByte(1, serverID);
			dbCommand->FetchUInt16(2, zone_1);
			dbCommand->FetchUInt16(3, zone_2);
			dbCommand->FetchUInt16(4, zone_3);

			if ((uint8)(serverID - 1) < g_pMain->m_ServerList.size())
				g_pMain->m_ServerList[serverID - 1]->sUserCount = zone_1 + zone_2 + zone_3;
		} while (dbCommand->MoveNext());
	}

	return true;
}

uint16 CDBProcess::AccountLogin(string & strAccountID, string & strPasswd)
{
	uint16 result = 2;
	unique_ptr<MySqlCommand> dbCommand(m_dbConnection.CreateCommand());
	if (dbCommand.get() == nullptr)
		return 6;

	dbCommand->AddParameter(SQL_PARAM_OUTPUT, &result);
	dbCommand->AddParameter(SQL_PARAM_INPUT, strAccountID.c_str(), strAccountID.length());
	dbCommand->AddParameter(SQL_PARAM_INPUT, strPasswd.c_str(), strPasswd.length());

	const bool executed = dbCommand->Execute(_T("{? = CALL ACCOUNT_LOGIN(?, ?)}"));

	if (!executed)
	{
		g_pMain->ReportSQLError(m_dbConnection.GetError());
		printf("[ ACCOUNT_LOGIN ] '%s' could not be run - the SQL error is above\n",
			strAccountID.c_str());
		return result;      // 2 (AUTH_NOT_FOUND), and now the log says why
	}

	// ACCOUNT_LOGIN sets 1 (ok) or 3 (wrong password) and nothing else, so the
	// initial value 2 means the procedure ran without producing a value.
	if (result == 2)
	{
		printf("[ ACCOUNT_LOGIN ] '%s' returned no value - the procedure body did not run\n",
			strAccountID.c_str());
	}
	else
	{
		printf("[ ACCOUNT_LOGIN ] '%s' -> %u (1 = ok/registered, 3 = wrong password)\n",
			strAccountID.c_str(), (unsigned) result);
	}

	return result;
}

int16 CDBProcess::AccountPremium(string & strAccountID)
{
	int16 sHours = -1;
	unique_ptr<MySqlCommand> dbCommand(m_dbConnection.CreateCommand());
	if (dbCommand.get() == nullptr)
		return sHours;
	
	dbCommand->AddParameter(SQL_PARAM_OUTPUT, &sHours);
	dbCommand->AddParameter(SQL_PARAM_INPUT, strAccountID.c_str(), strAccountID.length());

	if (!dbCommand->Execute(_T("{? = CALL ACCOUNT_PREMIUM(?)}")))
		g_pMain->ReportSQLError(m_dbConnection.GetError());

	return sHours;
}