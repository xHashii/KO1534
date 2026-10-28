#include "stdafx.h"
#include "MySqlConnection.h"
#include "MySqlRecordset.h"
#include "SqlIdentifiers.h"

MySqlRecordset::MySqlRecordset(MySqlConnection * dbConnection) : _dbConnection(dbConnection)
{
	_dbCommand = (_dbConnection != nullptr) ? _dbConnection->CreateCommand() : nullptr;
}

TCHAR * MySqlRecordset::Read(bool bAllowEmptyTable /*= false*/)
{
	static TCHAR szError[2048] = {0};

	if (_dbCommand == nullptr)
	{
		_stprintf(szError, _T("No database connection for table %s."), GetTableName().c_str());
		return szError;
	}

	// Build statement
	tstring szSQL = _T("SELECT ");
	
	// MySQL 8 reserves RANGE, so an unquoted column list fails with a syntax
	// error on the table name that follows it.
	szSQL += ko_sql::QuoteIdentifierList(GetColumns());
	szSQL += _T(" FROM ");
	szSQL += ko_sql::QuoteIdentifier(GetTableName());

	tstring szWhereClause = GetWhereClause();
	// Do we have a where clause? Include it.
	if (!szWhereClause.empty())
	{
		szSQL += _T(" WHERE ");
		szSQL += szWhereClause;
	}

	// Attempt to execute the statement.
	if (!_dbCommand->Execute(szSQL))
	{
		// The client's message only quotes the fragment it choked on, which is
		// not enough to tell a stale binary from a bad statement - so the whole
		// statement goes into the error.  Seeing `Range` here means the fixed
		// list is in use; seeing Range without backticks means the .exe was
		// built before the fix.
		_sntprintf(szError, (sizeof(szError) / sizeof(TCHAR)) - 1,
			_T("%s\n  statement: %s"), _dbCommand->GetError(), szSQL.c_str());
		szError[(sizeof(szError) / sizeof(TCHAR)) - 1] = 0;
		return szError;
	}

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