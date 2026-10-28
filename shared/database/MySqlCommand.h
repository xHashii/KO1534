#pragma once

#include "MySqlParameter.h"
#include "../tstring.h"
#include <map>
#include <type_traits>
#include <string>
#include <vector>

// ---------------------------------------------------------------------------
//  MySqlCommand - one statement against the game/account database.
//
//  Usage is unchanged from the SQL Server build:
//      unique_ptr<MySqlCommand> cmd(db->CreateCommand());
//      if (cmd == nullptr) return;
//      int8 ret = -2;
//      cmd->AddParameter(SQL_PARAM_OUTPUT, &ret);        // first, if any
//      cmd->AddParameter(SQL_PARAM_INPUT, str.c_str(), str.length());
//      if (!cmd->Execute(_T("{? = CALL SOME_PROC(?, %d)}")))
//          ReportSQLError(cmd->GetError());
//
//  How the ODBC-isms are translated (no server-side prepare is used, which is
//  why the original '?' placeholders can stay in the call sites):
//
//    "{? = CALL P(a, b)}"  ->  SET @ko_out = NULL; CALL P(a, b); SELECT @ko_out
//    "{CALL P(a, b)}"      ->  CALL P(a, b)
//
//  Each '?' is replaced by an escaped literal built from the bound parameter,
//  in AddParameter order (the leading output parameter only appears as the
//  session variable).  After execution the trailing "SELECT @ko_out" result is
//  consumed and written back into the output parameter, and any result set the
//  procedure itself returned stays buffered for MoveNext()/Fetch*().
//
//  Everything is buffered client side (mysql_store_result), so the fetch
//  semantics the call sites rely on - "hasData() then Fetch*(1..n)" - are the
//  same as before.
// ---------------------------------------------------------------------------
class MySqlConnection;
class MySqlCommand
{
public:
	typedef std::map<size_t, MySqlParameter *> MySqlParameterCollection;

	explicit MySqlCommand(MySqlConnection * conn);

	inline bool isOpen() { return m_bOpen; };
	inline TCHAR * GetError() { return (TCHAR *)m_szError.c_str(); };
	inline bool hasData() { return m_row != nullptr; };

	bool Execute(const tstring & szSQL);
	// Kept for source compatibility: MySQL is executed directly, so this is
	// the same as Execute().
	bool Prepare(const tstring & szSQL);

	bool MoveNext();
	bool MoveNextSet();

	// ---- parameters -------------------------------------------------------
	template <typename T>
	void AddParameter(SQLSMALLINT paramType, T * value, SQLLEN maxLength = sizeof(T));

	void AddParameter(SQLSMALLINT paramType, const char * value, SQLLEN maxLength,
					  SQLSMALLINT sqlDatatype = SQL_CHAR);

	// Renders one bound value into the statement.  The C type is derived from
	// the static type of the bound variable so call sites stay as they were.
	template <typename T>
	static SQLSMALLINT CTypeOf()
	{
		if constexpr (std::is_floating_point_v<T>)
			return sizeof(T) == 4 ? SQL_C_FLOAT : SQL_C_DOUBLE;
		else if constexpr (std::is_signed_v<T>)
		{
			if (sizeof(T) == 1) return SQL_C_STINYINT;
			if (sizeof(T) == 2) return SQL_C_SSHORT;
			if (sizeof(T) == 4) return SQL_C_SLONG;
			return SQL_C_SBIGINT;
		}
		else
		{
			if (sizeof(T) == 1) return SQL_C_UTINYINT;
			if (sizeof(T) == 2) return SQL_C_USHORT;
			if (sizeof(T) == 4) return SQL_C_ULONG;
			return SQL_C_UBIGINT;
		}
	}

	// ---- fetching ---------------------------------------------------------
#define ADD_DB_PARAMETER(name, type, sqlType)         \
	type Fetch ## name(int pos);                      \
	void Fetch ## name(int pos, type & value);

	ADD_DB_PARAMETER(Byte,   uint8,  SQL_C_UTINYINT)
	ADD_DB_PARAMETER(SByte,  int8,   SQL_C_STINYINT)
	ADD_DB_PARAMETER(UInt16, uint16, SQL_C_USHORT)
	ADD_DB_PARAMETER(Int16,  int16,  SQL_C_SSHORT)
	ADD_DB_PARAMETER(UInt32, uint32, SQL_C_ULONG)
	ADD_DB_PARAMETER(Int32,  int32,  SQL_C_SLONG)
	ADD_DB_PARAMETER(Single, float,  SQL_C_FLOAT)
	ADD_DB_PARAMETER(Double, double, SQL_C_DOUBLE)
	ADD_DB_PARAMETER(UInt64, uint64, SQL_C_UBIGINT)
	ADD_DB_PARAMETER(Int64,  int64,  SQL_C_SBIGINT)
#undef ADD_DB_PARAMETER

	inline bool FetchString(int pos, char * outBuffer, SQLLEN maxLength)
	{
		SQLLEN bufferSize = 0;
		return FetchString(pos, outBuffer, maxLength, &bufferSize);
	};

	bool FetchString(int pos, char * charArray, SQLLEN maxLength, SQLLEN * bufferSize);
	bool FetchString(int pos, std::string & value);

	inline bool FetchBinary(int pos, char * outBuffer, SQLLEN maxLength)
	{
		SQLLEN bufferSize = 0;
		return FetchBinary(pos, outBuffer, maxLength, &bufferSize);
	};
	bool FetchBinary(int pos, char * charArray, SQLLEN maxLength, SQLLEN * bufferSize);

	void Detach();
	~MySqlCommand();

	void Close();

private:
	bool CheckConnection();
	// Renders the statement, substituting bound parameter literals for '?'
	// and handling the "{? = CALL ...}" escape.
	bool BuildStatement(const tstring & szSQL, std::string & outStatement,
						MySqlParameter ** ppOutputParam);
	// Drains every result set the server produced.  Data result sets are kept
	// (and chained) for MoveNext(); the trailing OUT value is written back.
	bool CollectResults(MySqlParameter * pOutputParam);
	void ClearResults();

	const char * FieldAt(int pos, unsigned long & length) const;

private:
	MySqlConnection * m_connection;
	MySqlParameterCollection m_params;

	tstring m_szError;
	bool   m_bOpen;

	struct ResultSet
	{
		void * handle = nullptr;    // MYSQL_RES*
		void * row    = nullptr;    // MYSQL_ROW of the current row
		unsigned long * lengths = nullptr;
	};

	std::vector<ResultSet> m_resultSets;
	size_t m_resultIndex;
	ResultSet * m_current;          // points into m_resultSets (or null)
	void * m_row;                   // convenience: current MYSQL_ROW
	unsigned long * m_lengths;
};

template <typename T>
void MySqlCommand::AddParameter(SQLSMALLINT paramType, T * value, SQLLEN maxLength)
{
	m_params.insert(std::make_pair(m_params.size(),
		new MySqlParameter(paramType, CTypeOf<T>(), (SQLPOINTER)value, maxLength)));
}
