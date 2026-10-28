#pragma once

// ---------------------------------------------------------------------------
//  DbTypes.h - the small type/constant vocabulary the KO1534 database layer
//  uses to describe parameters.  It replaces the ODBC headers (sqlext.h) that
//  the SQL Server build needed; nothing here talks to ODBC.
//
//  The numeric values only have to be self-consistent: they are interpreted by
//  MySqlCommand when it renders a parameter into SQL text, never handed to a
//  driver.
// ---------------------------------------------------------------------------

#include <cstdint>
#include <cstddef>

typedef intptr_t    SQLLEN;         // pointer sized, like SQLBIGINT on Win64
typedef short       SQLSMALLINT;
typedef void      * SQLPOINTER;
typedef void      * SQLHANDLE;

// parameter directions
#define SQL_PARAM_INPUT          1
#define SQL_PARAM_OUTPUT         2
#define SQL_PARAM_INPUT_OUTPUT   3

// C (buffer) types
#define SQL_C_STINYINT           101
#define SQL_C_UTINYINT           102
#define SQL_C_SSHORT             103
#define SQL_C_USHORT             104
#define SQL_C_SLONG              105
#define SQL_C_ULONG              106
#define SQL_C_SBIGINT            107
#define SQL_C_UBIGINT            108
#define SQL_C_FLOAT              109
#define SQL_C_DOUBLE             110

// SQL (column) types
#define SQL_CHAR                 201
#define SQL_VARCHAR              202
#define SQL_BINARY               203
#define SQL_VARBINARY            204
#define SQL_TINYINT              205
#define SQL_SMALLINT             206
#define SQL_INTEGER              207
#define SQL_FLOAT                208
#define SQL_DOUBLE               209

// length sentinels
#define SQL_NULL_DATA            (-1)
#define SQL_NTS                  (-3)

// ---------------------------------------------------------------------------
//  MySqlConfig - connection settings read from the server .ini files.
//
//  Deliberately a plain value type: the servers keep their own copy, log
//  Describe() (never the password) and pass it to MySqlConnection::Connect().
// ---------------------------------------------------------------------------
#include <string>

struct MySqlConfig
{
	std::string host            = "127.0.0.1";
	uint16_t    port            = 3306;
	std::string database;
	std::string user;
	std::string password;
	// Byte-exact charset for the original data (see docs/MYSQL_NOTES.md).
	std::string charset         = "latin1";
	int         connectTimeout  = 15;
	bool        compress        = false;

	bool IsValid() const { return !database.empty(); }

	// "user@host:port/database" - safe to log.
	std::string Describe() const
	{
		std::string out = user;
		out += '@';
		out += host;
		out += ':';
		out += std::to_string(port);
		out += '/';
		out += database;
		return out;
	}
};
