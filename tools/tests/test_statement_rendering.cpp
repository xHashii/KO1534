// ---------------------------------------------------------------------------
//  test_statement_rendering.cpp
//
//  Checks the text MySqlCommand::BuildStatement() produces.  Nothing here
//  talks to a server: the point is the statement string itself, because two
//  bugs lived there and both were invisible until a login was attempted:
//
//    * "CALL ACCOUNT_LOGIN('test','<hash>')" was sent for the call site
//      "{? = CALL ACCOUNT_LOGIN(?, ?)}" - the ODBC return-value placeholder
//      was turned into SET @ko_out0 = NULL but never put back into the
//      argument list, so MySQL answered
//          ERROR 42000: Incorrect number of arguments for PROCEDURE ...
//      and LogInServer reported the account as missing.
//    * every failure inside the batch was dropped by CollectResults().
//
//  WHAT THIS PROVES: the renderer emits a CALL with one argument per
//  procedure parameter, in order, and a trailing SELECT for the OUT value.
//  WHAT IT DOES NOT PROVE: that MySQL accepts the text (that needs a server)
//  or that MSVC compiles the layer.
//
//  Built by tools/tests/run_tests.sh.
// ---------------------------------------------------------------------------
#include "shim/stdafx.h"
#include "shim/mysql.h"

// The stub header leaves MYSQL opaque; the test needs storage for the one
// handle mysql_init() hands out.
struct MYSQL { int unused; };

// BuildStatement() and m_params are private; the renderer is the whole point of
// this test, so access is opened for this translation unit only.
#define private public
#define protected public
#include "MySqlCommand.h"
#include "MySqlConnection.h"
#include "MySqlParameter.h"
#undef private
#undef protected

#include <cstdio>
#include <cstring>
#include <string>
#include <vector>

// ---- libmysql stubs -------------------------------------------------------
// Only what the two database-layer objects below reference.  The escape stub
// copies the bytes through, which is enough: this checks argument placement,
// not escaping.
MYSQL * mysql_init(MYSQL *) { static MYSQL handle = { 0 }; return &handle; }
void    mysql_close(MYSQL *) {}
int     mysql_options(MYSQL *, enum mysql_option, const void *) { return 0; }
int     mysql_ping(MYSQL *) { return 0; }
MYSQL * mysql_real_connect(MYSQL *, const char *, const char *, const char *,
                           const char *, unsigned int, const char *, unsigned long)
{
	return nullptr;
}
unsigned long mysql_real_escape_string(MYSQL *, char * to, const char * from, unsigned long length)
{
	memcpy(to, from, length);
	to[length] = 0;
	return length;
}
int          mysql_real_query(MYSQL *, const char *, unsigned long) { return 1; }
MYSQL_RES *  mysql_store_result(MYSQL *) { return nullptr; }
unsigned int mysql_field_count(MYSQL *) { return 0; }
MYSQL_ROW    mysql_fetch_row(MYSQL_RES *) { return nullptr; }
unsigned long * mysql_fetch_lengths(MYSQL_RES *) { return nullptr; }
void         mysql_free_result(MYSQL_RES *) {}
int          mysql_next_result(MYSQL *) { return -1; }
const char * mysql_error(MYSQL *) { return "stub"; }
const char * mysql_sqlstate(MYSQL *) { return "HY000"; }

// shared/tstring.cpp defines this on Windows; the renderer never calls it,
// but MySqlCommand.cpp references it from FetchString().
std::string & rtrim(std::string & s)
{
	while (!s.empty() && (s.back() == ' ' || s.back() == '\t' || s.back() == '\r' || s.back() == '\n'))
		s.pop_back();

	return s;
}

// ---- tiny harness ---------------------------------------------------------
static int g_failures = 0;

static void ExpectEqual(const char * what, const std::string & actual, const std::string & expected)
{
	if (actual == expected)
	{
		printf("  ok   %s\n", what);
		return;
	}

	printf("  FAIL %s\n       expected: %s\n       actual:   %s\n",
		what, expected.c_str(), actual.c_str());
	g_failures++;
}

static void ExpectTrue(const char * what, bool condition)
{
	if (condition)
	{
		printf("  ok   %s\n", what);
		return;
	}

	printf("  FAIL %s\n", what);
	g_failures++;
}

// Renders a statement with the parameters a given call site binds and returns
// the text, or "<failed: ...>" when BuildStatement refuses it.
static std::string Render(MySqlCommand & cmd, const tstring & sql)
{
	std::string statement;
	std::vector<MySqlParameter *> outputs;

	if (!cmd.BuildStatement(sql, statement, outputs))
		return std::string("<failed: ") + (const char *) cmd.GetError() + ">";

	return statement;
}

int main()
{
	MySqlConnection connection;   // constructor calls the stub mysql_init

	// ---- 1. the login call site -------------------------------------------
	// {? = CALL ACCOUNT_LOGIN(?, ?)}  ->  OUT first, then the two inputs.
	{
		printf("ACCOUNT_LOGIN\n");
		MySqlCommand cmd(&connection);

		int16 result = 2;
		std::string accountID = "test";
		std::string password = "ABCDEF12345678";

		cmd.AddParameter(SQL_PARAM_OUTPUT, &result);
		cmd.AddParameter(SQL_PARAM_INPUT, accountID.c_str(), (SQLLEN) accountID.length());
		cmd.AddParameter(SQL_PARAM_INPUT, password.c_str(), (SQLLEN) password.length());

		ExpectEqual("OUT variable is the first argument",
			Render(cmd, _T("{? = CALL ACCOUNT_LOGIN(?, ?)}")),
			"SET @ko_out0 = NULL; CALL ACCOUNT_LOGIN(@ko_out0, 'test', 'ABCDEF12345678'); SELECT @ko_out0");
	}

	// ---- 2. a single-input call site --------------------------------------
	{
		printf("ACCOUNT_PREMIUM\n");
		MySqlCommand cmd(&connection);

		int16 hours = 0;
		std::string accountID = "admin";

		cmd.AddParameter(SQL_PARAM_OUTPUT, &hours);
		cmd.AddParameter(SQL_PARAM_INPUT, accountID.c_str(), (SQLLEN) accountID.length());

		ExpectEqual("one input keeps its place after the OUT variable",
			Render(cmd, _T("{? = CALL ACCOUNT_PREMIUM(?)}")),
			"SET @ko_out0 = NULL; CALL ACCOUNT_PREMIUM(@ko_out0, 'admin'); SELECT @ko_out0");
	}

	// ---- 3. printf-expanded literals mixed with placeholders ---------------
	// CREATE_NEW_CHAR(OUT, ?, ?, ?, ...) is the widest call site; the numbers
	// are already part of the statement text, not bound parameters.
	{
		printf("CREATE_NEW_CHAR\n");
		MySqlCommand cmd(&connection);

		uint8  result = 0;
		std::string accountID = "acct";
		std::string charID = "Hero";

		cmd.AddParameter(SQL_PARAM_OUTPUT, &result);
		cmd.AddParameter(SQL_PARAM_INPUT, accountID.c_str(), (SQLLEN) accountID.length());
		cmd.AddParameter(SQL_PARAM_INPUT, charID.c_str(), (SQLLEN) charID.length());

		const std::string actual = Render(cmd,
			"{? = CALL CREATE_NEW_CHAR(?, %d, ?, %d, %d)}");

		// %d is expanded by string_format() at the call site, so the renderer
		// sees real numbers; keep the same shape here with a literal.
		ExpectTrue("OUT variable leads the %d-style argument list",
			actual.find("CALL CREATE_NEW_CHAR(@ko_out0, 'acct', ") != std::string::npos);
		ExpectTrue("trailing SELECT reads the OUT value back",
			actual.find("; SELECT @ko_out0") != std::string::npos);
		ExpectTrue("enclosing braces are stripped",
			actual.find('{') == std::string::npos && actual.find('}') == std::string::npos);
	}

	// ---- 4. a procedure without a return value ----------------------------
	// {CALL ...} must NOT gain an argument: LOAD_USER_DATA takes two inputs
	// and nothing else.
	{
		printf("LOAD_USER_DATA\n");
		MySqlCommand cmd(&connection);

		std::string accountID = "acct";
		std::string charID = "Hero";

		cmd.AddParameter(SQL_PARAM_INPUT, accountID.c_str(), (SQLLEN) accountID.length());
		cmd.AddParameter(SQL_PARAM_INPUT, charID.c_str(), (SQLLEN) charID.length());

		ExpectEqual("no OUT variable and no trailing SELECT",
			Render(cmd, _T("{CALL LOAD_USER_DATA(?, ?)}")),
			"CALL LOAD_USER_DATA('acct', 'Hero')");
	}

	// ---- 5. empty argument list with a return value -----------------------
	{
		printf("empty argument list\n");
		MySqlCommand cmd(&connection);

		int16 result = 0;
		cmd.AddParameter(SQL_PARAM_OUTPUT, &result);

		ExpectEqual("the variable is inserted without a stray comma",
			Render(cmd, _T("{? = CALL SOMETHING()}")),
			"SET @ko_out0 = NULL; CALL SOMETHING(@ko_out0); SELECT @ko_out0");
	}

	// ---- 6. numeric parameters keep their types --------------------------
	{
		printf("numeric parameters\n");
		MySqlCommand cmd(&connection);

		uint8 result = 0;
		int32 big = 2000000000;
		uint64 serial = 1099511627776ULL;

		cmd.AddParameter(SQL_PARAM_OUTPUT, &result);
		cmd.AddParameter(SQL_PARAM_INPUT, &big);
		cmd.AddParameter(SQL_PARAM_INPUT, &serial);

		int32 copyOfBig = big;      // referenced so -Wunused does not fire
		ExpectTrue("int32 renders as a bare number",
			Render(cmd, _T("{? = CALL X(?, ?)}")).find("CALL X(@ko_out0, 2000000000, 1099511627776)") != std::string::npos);
		ExpectTrue("the bound value is untouched", copyOfBig == big);
	}

	if (g_failures == 0)
	{
		printf("\nOK: statement rendering\n");
		return 0;
	}

	printf("\nFAIL: %d rendering check(s) failed\n", g_failures);
	return 1;
}
