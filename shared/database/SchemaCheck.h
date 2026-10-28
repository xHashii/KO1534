#pragma once

// ---------------------------------------------------------------------------
//  SchemaCheck.h - "is the database actually there?" at server startup.
//
//  Running the servers against an empty MySQL produces confusing failures
//  (every table load fails, the login server exits).  So does a *partially*
//  imported database: the container imports 001..007 in order and stops at the
//  first bad file, which leaves tables and data in place but some routines
//  missing - the servers then start fine and fail later on a CALL, which is
//  much harder to diagnose.
//
//  These helpers turn both cases into one clear message naming the command to
//  run.  They never modify anything: the import itself is handled by
//  `docker compose up -d` (see docker-compose.yml) or tools/setup_database.*.
// ---------------------------------------------------------------------------

#include "MySqlConnection.h"
#include <string>
#include <cstdlib>

// 001_schema.sql creates 104 tables, 003..007 create 118 routines.  Bumping
// these numbers is part of adding a table or a routine to the migration.
static const int kExpectedSchemaTables  = 104;
static const int kExpectedSchemaRoutines = 118;

// Scalar COUNT(*) result, or -1 when the query itself fails (e.g. the schema
// does not exist, so DATABASE() has no TB_USER).
inline int CountSchemaRows(MySqlConnection & connection, const tstring & szSql)
{
	int count = -1;

	MySqlCommand * pCommand = connection.CreateCommand();
	if (pCommand == nullptr)
		return -1;

	if (pCommand->Execute(szSql) && pCommand->hasData())
	{
		char szBuffer[32] = { 0 };
		if (pCommand->FetchString(1, szBuffer, sizeof(szBuffer)))
			count = atoi(szBuffer);
	}

	pCommand->Close();
	delete pCommand;
	return count;
}

// Number of BASE TABLEs in the connected schema.  -1 when the query fails.
inline int CountSchemaTables(MySqlConnection & connection)
{
	return CountSchemaRows(connection,
		_T("SELECT COUNT(*) FROM information_schema.TABLES "
		   "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_TYPE = 'BASE TABLE'"));
}

// Number of stored procedures + functions in the connected schema.
inline int CountSchemaRoutines(MySqlConnection & connection)
{
	return CountSchemaRows(connection,
		_T("SELECT COUNT(*) FROM information_schema.ROUTINES "
		   "WHERE ROUTINE_SCHEMA = DATABASE()"));
}

// True when every table and every routine of the migration is present.
// TB_USER is checked by name because it is the first table the servers need,
// and a database with zero tables of ours looks exactly like an empty one.
inline bool IsSchemaReady(MySqlConnection & connection)
{
	int byName = CountSchemaRows(connection,
		_T("SELECT COUNT(*) FROM information_schema.TABLES "
		   "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'TB_USER'"));
	if (byName <= 0)
		return false;

	return CountSchemaTables(connection) >= kExpectedSchemaTables
		&& CountSchemaRoutines(connection) >= kExpectedSchemaRoutines;
}

// The message every server prints when the schema is missing or incomplete.
inline std::string SchemaMissingHint(MySqlConnection & connection, const MySqlConfig & config)
{
	std::string hint = "The MySQL database \"";
	hint += config.database;

	int tables = CountSchemaTables(connection);
	int routines = CountSchemaRoutines(connection);

	if (tables <= 0)
	{
		hint += "\" has no KO1534 schema.\n";
	}
	else
	{
		// A partial import: the container stops at the first file that fails and
		// never retries (the data directory is no longer empty), so the fix is a
		// reset, not another `up`.
		hint += "\" is only partly imported: ";
		hint += std::to_string(tables) + " of " + std::to_string(kExpectedSchemaTables) + " tables, ";
		hint += std::to_string(routines) + " of " + std::to_string(kExpectedSchemaRoutines) + " routines.\n";
		hint += "A failed import does not resume - reset it and start over:\n"
				"    docker compose down -v\n"
				"    docker compose up -d\n";
		return hint;
	}

	hint +=
		"Set it up with one of these (from the repository root):\n"
		"    docker compose up -d          # import everything into a local container\n"
		"    tools/setup_database.ps1      # ...or into an existing MySQL installation\n";
	return hint;
}
