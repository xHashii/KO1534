#include "stdafx.h"
#include "MySqlConnection.h"
#include "MySqlRecordset.h"

MySqlRecordset::MySqlRecordset(MySqlConnection * dbConnection) : _dbConnection(dbConnection)
{
	_dbCommand = (_dbConnection != nullptr) ? _dbConnection->CreateCommand() : nullptr;
}

TCHAR * MySqlRecordset::Read(bool bAllowEmptyTable /*= false*/)
{
	static TCHAR szError[128] = {0};

	if (_dbCommand == nullptr)
	{
		_stprintf(szError, _T("No database connection for table %s."), GetTableName().c_str());
		return szError;
	}

	// Build statement
	tstring szSQL = _T("SELECT ");
	
	szSQL += GetColumns();
	szSQL += _T(" FROM ");
	szSQL += GetTableName();

	tstring szWhereClause = GetWhereClause();
	// Do we have a where clause? Include it.
	if (!szWhereClause.empty())
	{
		szSQL += _T(" WHERE ");
		szSQL += szWhereClause;
	}

	// Attempt to execute the statement.
	if (!_dbCommand->Execute(szSQL))
		return _dbCommand->GetError();

	// Does the table have any rows?
	// Make sure we allow for tables that can be empty.
	if (!_dbCommand->hasData())
	{
		if (bAllowEmptyTable)
			return nullptr;

		_stprintf(szError, _T("%s table is empty."), GetTableName().c_str());
		return szError;
	}

	do
	{
		// This extra result/check potentially slows things down. 
		// It's also not very informative, so this could really use a bit of a rewrite
		// to better allow for this scenario.
		if (!Fetch())
		{
			_stprintf(szError, _T("Could not fetch row in table %s."), GetTableName().c_str());
			return szError;
		}
	} while (_dbCommand->MoveNext());
	return nullptr;
}

MySqlRecordset::~MySqlRecordset()
{
	if (_dbCommand != nullptr)
	{
		_dbCommand->Close();
		delete _dbCommand;
	}
}