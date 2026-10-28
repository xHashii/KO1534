#include "stdafx.h"
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <algorithm>
#include <mysql.h>
#include "MySqlConnection.h"

// ---------------------------------------------------------------------------
//  Statement rendering
//
//  The call sites were written for ODBC, so the statement text still looks like
//      {? = CALL ACCOUNT_LOGIN(?, ?)}
//      {CALL LOAD_USER_DATA(?, ?)}
//      UPDATE SERVER_LIST SET ... WHERE GroupID = 1
//  BuildStatement() removes the ODBC escape and replaces every '?' with the
//  escaped literal of the next bound input parameter.
// ---------------------------------------------------------------------------

namespace {

std::string IntegerLiteral(SQLSMALLINT ctype, SQLPOINTER address)
{
	char buffer[64];

	switch (ctype)
	{
	case SQL_C_UTINYINT:
		_snprintf_s(buffer, _countof(buffer), _TRUNCATE, "%u", (unsigned)*(const uint8 *)address);
		break;
	case SQL_C_STINYINT:
		_snprintf_s(buffer, _countof(buffer), _TRUNCATE, "%d", (int)*(const int8 *)address);
		break;
	case SQL_C_USHORT:
		_snprintf_s(buffer, _countof(buffer), _TRUNCATE, "%u", (unsigned)*(const uint16 *)address);
		break;
	case SQL_C_SSHORT:
		_snprintf_s(buffer, _countof(buffer), _TRUNCATE, "%d", (int)*(const int16 *)address);
		break;
	case SQL_C_ULONG:
		_snprintf_s(buffer, _countof(buffer), _TRUNCATE, "%lu", (unsigned long)*(const uint32 *)address);
		break;
	case SQL_C_SLONG:
		_snprintf_s(buffer, _countof(buffer), _TRUNCATE, "%ld", (long)*(const int32 *)address);
		break;
	case SQL_C_UBIGINT:
		_snprintf_s(buffer, _countof(buffer), _TRUNCATE, "%llu", (unsigned long long)*(const uint64 *)address);
		break;
	case SQL_C_SBIGINT:
		_snprintf_s(buffer, _countof(buffer), _TRUNCATE, "%lld", (long long)*(const int64 *)address);
		break;
	default:
		return std::string("0");
	}

	return std::string(buffer);
}

std::string FloatingLiteral(SQLSMALLINT ctype, SQLPOINTER address)
{
	char buffer[64];

	if (ctype == SQL_C_FLOAT)
		_snprintf_s(buffer, _countof(buffer), _TRUNCATE, "%.9g", (double)*(const float *)address);
	else
		_snprintf_s(buffer, _countof(buffer), _TRUNCATE, "%.17g", *(const double *)address);

	return std::string(buffer);
}

std::string HexLiteral(const char * data, size_t length)
{
	static const char * digits = "0123456789ABCDEF";
	std::string out;
	out.reserve(2 + length * 2);
	out += "0x";

	for (size_t i = 0; i < length; i++)
	{
		unsigned char c = (unsigned char)data[i];
		out += digits[c >> 4];
		out += digits[c & 0x0F];
	}

	// 0x alone is not a valid literal; an empty binary value is an empty string.
	if (length == 0)
		out = "''";

	return out;
}

} // namespace

static std::string EscapeString(MYSQL * handle, const char * value, size_t length)
{
	std::string out;
	out.reserve(length + 2);
	out += '\'';

	if (length > 0)
	{
		std::string escaped;
		escaped.resize(length * 2 + 1);

		unsigned long escapedLength = mysql_real_escape_string(handle, &escaped[0], value, (unsigned long)length);
		out.append(escaped.c_str(), escapedLength);
	}

	out += '\'';
	return out;
}

MySqlCommand::MySqlCommand(MySqlConnection * conn)
	: m_connection(conn), m_bOpen(false), m_resultIndex(0), m_current(nullptr),
	  m_row(nullptr), m_lengths(nullptr)
{
	if (m_connection != nullptr)
		m_connection->AddCommand(this);
}

MySqlCommand::~MySqlCommand()
{
	Close();

	for (auto itr = m_params.begin(); itr != m_params.end(); itr++)
		delete itr->second;

	m_params.clear();

	if (m_connection != nullptr)
		m_connection->RemoveCommand(this);
}

void MySqlCommand::Detach()
{
	if (m_connection != nullptr)
		m_connection->RemoveCommand(this);

	m_connection = nullptr;
}

bool MySqlCommand::CheckConnection()
{
	if (m_connection == nullptr)
	{
		m_szError = _T("No database connection.");
		return false;
	}

	return true;
}

bool MySqlCommand::BuildStatement(const tstring & szSQL, std::string & outStatement,
								  std::vector<MySqlParameter *> & outputParams)
{
	outputParams.clear();

	std::string sql(szSQL);

	// ---- strip the ODBC escape braces -----------------------------------
	bool hasReturnValue = false;
	size_t openBrace = sql.find('{');
	if (openBrace != std::string::npos)
	{
		size_t closeBrace = sql.rfind('}');
		std::string inner = sql.substr(openBrace + 1,
			(closeBrace == std::string::npos ? sql.length() : closeBrace) - openBrace - 1);

		size_t firstNonSpace = inner.find_first_not_of(" \t\r\n");
		if (firstNonSpace != std::string::npos && inner[firstNonSpace] == '?')
		{
			hasReturnValue = true;
			inner.erase(firstNonSpace, 1);
			firstNonSpace = inner.find_first_not_of(" \t\r\n");
			if (firstNonSpace != std::string::npos && inner[firstNonSpace] == '=')
				inner.erase(firstNonSpace, 1);
		}

		sql = inner;
	}

	size_t firstParamIndex = 0;
	if (hasReturnValue)
	{
		// The return value is the first bound parameter and never appears as a
		// '?' in the rendered argument list.
		if (m_params.empty() || !m_params.begin()->second->IsOutput())
		{
			m_szError = _T("Statement expects a return value but no output parameter was bound first.");
			return false;
		}

		outputParams.push_back(m_params.begin()->second);
		firstParamIndex = 1;
	}

	// ---- render the statement -------------------------------------------
	std::string rendered;
	rendered.reserve(sql.length() + 64);

	std::vector<std::pair<size_t, MySqlParameter *> > ordered(m_params.begin(), m_params.end());
	size_t nextParam = firstParamIndex;
	std::string sets;

	for (char ch : sql)
	{
		if (ch != '?')
		{
			rendered += ch;
			continue;
		}

		if (nextParam >= ordered.size())
		{
			m_szError = _T("More placeholders than bound parameters.");
			return false;
		}

		size_t paramIndex = ordered[nextParam].first;
		MySqlParameter * pParam = ordered[nextParam].second;
		++nextParam;

		// Output parameters become session variables and are read back from a
		// trailing SELECT once the statement has run.
		if (pParam->IsOutput())
		{
			std::string var = "@ko_out" + std::to_string(paramIndex);
			rendered += var;

			if (std::find(outputParams.begin(), outputParams.end(), pParam) == outputParams.end())
				outputParams.push_back(pParam);

			continue;
		}

		SQLSMALLINT ctype = pParam->GetCDataType();
		SQLPOINTER  address = pParam->GetAddress();
		SQLLEN      length = pParam->GetDataTypeSize();

		if (address == nullptr || length == SQL_NULL_DATA)
		{
			rendered += "NULL";
			continue;
		}

		switch (ctype)
		{
		case SQL_C_FLOAT:
		case SQL_C_DOUBLE:
			rendered += FloatingLiteral(ctype, address);
			break;

		case SQL_CHAR:
		case SQL_VARCHAR:
			rendered += EscapeString(m_connection->m_handle, (const char *)address,
									 length < 0 ? strlen((const char *)address) : (size_t)length);
			break;

		case SQL_BINARY:
		case SQL_VARBINARY:
			// Opaque payloads (item/skill/quest buffers) go over the wire as
			// hex so no charset or escape processing can alter a byte.
			rendered += HexLiteral((const char *)address, length < 0 ? 0 : (size_t)length);
			break;

		default:
			rendered += IntegerLiteral(ctype, address);
			break;
		}
	}

	// ---- assemble --------------------------------------------------------
	outStatement.clear();

	for (auto itr = m_params.begin(); itr != m_params.end(); itr++)
	{
		if (!itr->second->IsOutput())
			continue;

		outStatement += "SET @ko_out";
		outStatement += std::to_string(itr->first);
		outStatement += " = NULL; ";
	}

	outStatement += rendered;

	if (!outputParams.empty())
	{
		outStatement += "; SELECT ";
		for (size_t i = 0; i < outputParams.size(); i++)
		{
			if (i > 0)
				outStatement += ", ";

			for (auto itr = m_params.begin(); itr != m_params.end(); itr++)
			{
				if (itr->second == outputParams[i])
				{
					outStatement += "@ko_out";
					outStatement += std::to_string(itr->first);
					break;
				}
			}
		}
	}

	return true;
}

bool MySqlCommand::Execute(const tstring & szSQL)
{
	return Prepare(szSQL);
}

bool MySqlCommand::Prepare(const tstring & szSQL)
{
	Close();

	if (!CheckConnection())
		return false;

	std::vector<MySqlParameter *> outputParams;
	std::string statement;

	MYSQL * handle = m_connection->m_handle;
	if (handle == nullptr)
	{
		m_szError = _T("No database connection.");
		return false;
	}

#ifdef USE_SQL_TRACE
	TRACE((szSQL + _T("\n")).c_str());
#endif

	if (!BuildStatement(szSQL, statement, outputParams))
		return false;

#ifdef USE_SQL_TRACE
	TRACE(("  -> " + statement + "\n").c_str());
#endif

	{
		Guard lock(m_connection->m_lock);

		if (mysql_real_query(handle, statement.c_str(), (unsigned long)statement.length()) != 0)
		{
			m_szError = m_connection->ReportLastMySqlError((TCHAR *)szSQL.c_str(),
														  _T("Failed to execute statement."));
			return false;
		}
	}

	m_bOpen = true;

	if (!CollectResults(outputParams))
	{
		Close();
		return false;
	}

	// Position on the first row of the first data result set, exactly like the
	// ODBC wrapper did (callers test hasData() right after Execute()).
	if (!MoveNext())
		MoveNextSet();

	return true;
}

bool MySqlCommand::CollectResults(const std::vector<MySqlParameter *> & outputParams)
{
	MYSQL * handle = m_connection->m_handle;

	int nextResult = 0;

	do
	{
		MYSQL_RES * result = mysql_store_result(handle);
		if (result != nullptr)
		{
			ResultSet set;
			set.handle = result;
			m_resultSets.push_back(set);
		}
		else if (mysql_field_count(handle) != 0)
		{
			m_szError = m_connection->ReportLastMySqlError(_T("mysql_store_result"),
														   _T("Failed to buffer the result set."));
			return false;
		}

		nextResult = mysql_next_result(handle);
	} while (nextResult == 0);

	// mysql_next_result() returns >0 when one of the statements failed.  That
	// case used to fall out of the loop silently: an output parameter then kept
	// the value it started with, and the caller reported a "not found" instead
	// of the SQL error that actually happened (this is how a failing
	// ACCOUNT_LOGIN CALL looked like a missing account at the login screen).
	if (nextResult > 0)
	{
		m_szError = m_connection->ReportLastMySqlError(_T("mysql_next_result"),
													   _T("A statement in the batch failed."));
		return false;
	}

	// The trailing "SELECT @ko_out..." is the output parameter block, not data
	// for the caller: consume it and write the values back into the bound
	// variables (in binding order, one column each).
	if (!outputParams.empty())
	{
		if (!m_resultSets.empty())
		{
			ResultSet & last = m_resultSets.back();
			MYSQL_ROW row = mysql_fetch_row((MYSQL_RES *)last.handle);

			if (row != nullptr)
			{
				for (size_t i = 0; i < outputParams.size(); i++)
				{
					if (row[i] == nullptr)
						continue;

					MySqlParameter * pParam = outputParams[i];
					if (pParam->GetAddress() == nullptr)
						continue;

					int64 value = _strtoi64(row[i], nullptr, 10);

					switch (pParam->GetCDataType())
					{
					case SQL_C_UTINYINT: *(uint8  *)pParam->GetAddress() = (uint8)value;  break;
					case SQL_C_STINYINT: *(int8   *)pParam->GetAddress() = (int8)value;   break;
					case SQL_C_USHORT:   *(uint16 *)pParam->GetAddress() = (uint16)value; break;
					case SQL_C_SSHORT:   *(int16  *)pParam->GetAddress() = (int16)value;  break;
					case SQL_C_ULONG:    *(uint32 *)pParam->GetAddress() = (uint32)value; break;
					case SQL_C_SLONG:    *(int32  *)pParam->GetAddress() = (int32)value;  break;
					case SQL_C_UBIGINT:  *(uint64 *)pParam->GetAddress() = (uint64)value; break;
					case SQL_C_SBIGINT:  *(int64  *)pParam->GetAddress() = value;         break;
					default: break;
					}
				}
			}

			mysql_free_result((MYSQL_RES *)last.handle);
			m_resultSets.pop_back();
		}
	}

	m_resultIndex = 0;
	m_current = m_resultSets.empty() ? nullptr : &m_resultSets[0];
	m_row = nullptr;
	m_lengths = nullptr;

	return true;
}

void MySqlCommand::ClearResults()
{
	for (auto itr = m_resultSets.begin(); itr != m_resultSets.end(); itr++)
	{
		if (itr->handle != nullptr)
			mysql_free_result((MYSQL_RES *)itr->handle);
	}

	m_resultSets.clear();
	m_current = nullptr;
	m_row = nullptr;
	m_lengths = nullptr;
	m_resultIndex = 0;
}

bool MySqlCommand::MoveNext()
{
	if (m_current == nullptr || m_current->handle == nullptr)
		return false;

	MYSQL_ROW row = mysql_fetch_row((MYSQL_RES *)m_current->handle);
	if (row == nullptr)
	{
		m_row = nullptr;
		m_lengths = nullptr;
		return false;
	}

	m_current->row = row;
	m_current->lengths = mysql_fetch_lengths((MYSQL_RES *)m_current->handle);

	m_row = (void *)row;
	m_lengths = m_current->lengths;
	return true;
}

bool MySqlCommand::MoveNextSet()
{
	if (m_resultSets.empty())
		return false;

	while (m_resultIndex + 1 < m_resultSets.size())
	{
		m_resultIndex++;
		m_current = &m_resultSets[m_resultIndex];

		if (MoveNext())
			return true;
	}

	m_current = nullptr;
	m_row = nullptr;
	m_lengths = nullptr;
	return false;
}

const char * MySqlCommand::FieldAt(int pos, unsigned long & length) const
{
	length = 0;

	if (m_row == nullptr || pos <= 0)
		return nullptr;

	MYSQL_ROW row = (MYSQL_ROW)m_row;
	const char * value = row[pos - 1];
	if (value == nullptr)
		return nullptr;

	length = m_lengths != nullptr ? m_lengths[pos - 1] : (unsigned long)strlen(value);
	return value;
}

#define ADD_DB_PARAMETER(name, type, sqlType)                                              \
	type MySqlCommand::Fetch ## name(int pos)                                              \
	{                                                                                      \
		unsigned long length = 0;                                                          \
		const char * value = FieldAt(pos, length);                                         \
		if (value == nullptr)                                                              \
			return 0;                                                                      \
		return (type)Convert ## name(value, length);                                       \
	}                                                                                      \
	void MySqlCommand::Fetch ## name(int pos, type & outValue)                             \
	{                                                                                      \
		unsigned long length = 0;                                                          \
		const char * value = FieldAt(pos, length);                                         \
		outValue = value == nullptr ? (type)0 : (type)Convert ## name(value, length);      \
	}

// Conversion helpers: MySQL returns text, so every fetch parses the field.
static int64   ConvertByte(const char * v, unsigned long)   { return (int64)_strtoi64(v, nullptr, 10); }
static int64   ConvertSByte(const char * v, unsigned long)  { return (int64)_strtoi64(v, nullptr, 10); }
static uint64  ConvertUInt16(const char * v, unsigned long) { return (uint64)_strtoui64(v, nullptr, 10); }
static int64   ConvertInt16(const char * v, unsigned long)  { return (int64)_strtoi64(v, nullptr, 10); }
static uint64  ConvertUInt32(const char * v, unsigned long) { return (uint64)_strtoui64(v, nullptr, 10); }
static int64   ConvertInt32(const char * v, unsigned long)  { return (int64)_strtoi64(v, nullptr, 10); }
static float   ConvertSingle(const char * v, unsigned long) { return (float)atof(v); }
static double  ConvertDouble(const char * v, unsigned long) { return atof(v); }
static uint64  ConvertUInt64(const char * v, unsigned long) { return (uint64)_strtoui64(v, nullptr, 10); }
static int64   ConvertInt64(const char * v, unsigned long)  { return (int64)_strtoi64(v, nullptr, 10); }

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

void MySqlCommand::AddParameter(SQLSMALLINT paramType, const char * value, SQLLEN maxLength, SQLSMALLINT sqlDataType)
{
	m_params.insert(std::make_pair(m_params.size(),
		new MySqlParameter(paramType, sqlDataType, (SQLPOINTER)value, maxLength)));
}

bool MySqlCommand::FetchString(int pos, char * charArray, SQLLEN maxLength, SQLLEN * bufferSize)
{
	if (charArray == nullptr || maxLength <= 0)
		return false;

	memset(charArray, 0x00, (size_t)maxLength);

	unsigned long length = 0;
	const char * value = FieldAt(pos, length);

	if (bufferSize != nullptr)
		*bufferSize = value == nullptr ? SQL_NULL_DATA : (SQLLEN)length;

	if (value == nullptr)
		return true;

	size_t copyLength = length;
	if (copyLength > (size_t)maxLength - 1)
		copyLength = (size_t)maxLength - 1;

	memcpy(charArray, value, copyLength);
	return true;
}

bool MySqlCommand::FetchBinary(int pos, char * charArray, SQLLEN maxLength, SQLLEN * bufferSize)
{
	return FetchString(pos, charArray, maxLength, bufferSize);
}

bool MySqlCommand::FetchString(int pos, std::string & value)
{
	unsigned long length = 0;
	const char * field = FieldAt(pos, length);

	if (field == nullptr)
	{
		value.clear();
		return true;
	}

	value.assign(field, length);

	// char(n) columns come back space padded; the call sites expect trimmed
	// string ids.  FetchString(pos, char*, len) is the untrimmed variant.
	rtrim(value);
	return true;
}

void MySqlCommand::Close()
{
	ClearResults();
	m_bOpen = false;
}
