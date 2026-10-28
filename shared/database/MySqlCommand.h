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
//    "{? = CALL P(a, b)}"     ->  SET @ko_out0 = NULL; CALL P(@ko_out0, a, b);
//                                 SELECT @ko_out0
//    "{CALL P(?, ?)}" with OUT  ->  SET @ko_out1 = NULL; CALL P(a, @ko_out1);
//                                 SELECT @ko_out1
//    "{CALL P(a, b)}"           ->  CALL P(a, b)
//
//  Each '?' is replaced by an escaped literal built from the bound parameter,
//  in AddParameter order; a parameter bound as SQL_PARAM_OUTPUT becomes a
//  session variable instead.  After execution the trailing "SELECT @ko_out..."
//  result is consumed and written back into the bound variables, and any result
//  set the procedure itself returned stays buffered for MoveNext()/Fetch*().
//
//  Both output forms occur in KO1534: the usual "{? = CALL ...}" return value
//  and LOAD_PREMIUM_SERVICE_USER(?, OUT, OUT), which has no return value but
//  two output parameters inside the argument list.
//
//  Everything is buffered client side (mysql_store_result), so the fetch
//  semantics the call sites rely on - "hasData() then Fetch*(1..n)" - are the
//  same as before.
// ---------------------------------------------------------------------------
class MySqlConnection;
namespace ko_db_detail {

// Integral types map by size and signedness, so char, signed/unsigned char,
// short, int, long, long long and bool all work without being listed; a type
// that is not an integral or floating point type is a compile error instead of
// a silently wrong literal.
template <int Size, bool Signed> struct CTypeBySize;

template <> struct CTypeBySize<1, true>  { static SQLSMALLINT Value() { return SQL_C_STINYINT; } };
template <> struct CTypeBySize<1, false> { static SQLSMALLINT Value() { return SQL_C_UTINYINT; } };
template <> struct CTypeBySize<2, true>  { static SQLSMALLINT Value() { return SQL_C_SSHORT; } };
template <> struct CTypeBySize<2, false> { static SQLSMALLINT Value() { return SQL_C_USHORT; } };
template <> struct CTypeBySize<4, true>  { static SQLSMALLINT Value() { return SQL_C_SLONG; } };
template <> struct CTypeBySize<4, false> { static SQLSMALLINT Value() { return SQL_C_ULONG; } };
template <> struct CTypeBySize<8, true>  { static SQLSMALLINT Value() { return SQL_C_SBIGINT; } };
template <> struct CTypeBySize<8, false> { static SQLSMALLINT Value() { return SQL_C_UBIGINT; } };

template <typename T, bool IsFloatingPoint> struct CTypeSelector;

template <typename T>
struct CTypeSelector<T, true>
{
	static SQLSMALLINT Value()
	{
		// Only float and double are bound as floating point values.
		return sizeof(T) == 4 ? SQL_C_FLOAT : SQL_C_DOUBLE;
	}
};

template <typename T>
struct CTypeSelector<T, false>
{
	static SQLSMALLINT Value()
	{
		return CTypeBySize<sizeof(T), std::is_signed<T>::value>::Value();
	}
};

} // namespace ko_db_detail

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

	// The C type of a bound variable, derived from its static type so that the
	// call sites look exactly as they did with ODBC.
	//
	// A compile-time map, not "if constexpr": the projects build as C++14 (no
	// /std:c++17), where "if constexpr" is a non-standard extension (MSVC warns
	// C4984 about it).
	template <typename T>
	static SQLSMALLINT CTypeOf()
	{
		return ko_db_detail::CTypeSelector<T, std::is_floating_point<T>::value>::Value();
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
						std::vector<MySqlParameter *> & outputParams);
	// Drains every result set the server produced.  Data result sets are kept
	// (and chained) for MoveNext(); the trailing OUT value is written back.
	bool CollectResults(const std::vector<MySqlParameter *> & outputParams);
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
