#pragma once

#include "../shared/database/MySqlConnection.h"
#include "../shared/database/SchemaCheck.h"

class CDBProcess  
{
public:
	bool Connect(const MySqlConfig & config);
	void ResetErrors() { m_dbConnection.ResetErrors(); }
	bool IsSchemaReady() { return ::IsSchemaReady(m_dbConnection); }

	bool LoadVersionList();
	bool LoadUserCountList();

	uint16 AccountLogin(std::string & strAccountID, std::string & strPasswd);
	int16 AccountPremium(std::string & strAccountID);

private:
	MySqlConnection m_dbConnection;
};