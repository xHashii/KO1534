#pragma once

// ---------------------------------------------------------------------------
//  SchemaCheck.h - "is the database actually there?" at server startup.
//
//  Running the servers against an empty MySQL produces confusing failures
//  (every table load fails, the login server exits).  These helpers turn that
//  into one clear message naming the exact command to run.
//
//  They never modify anything: the migration itself is handled by
//  `docker compose up -d` (see docker-compose.yml) or tools/setup_database.*.
// ---------------------------------------------------------------------------

#include "MySqlConnection.h"
#include <string>
#include <cstdlib>

// Scalar COUNT(*) result, or -1 when the query itself fails (e.g. the schema
// does not exist, so DATABASE() has no TB_USER).
inline int CountSchemaTablesWhere(MySqlConnection & connection, const tstring & szSql)
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
	return CountSchemaTablesWhere(connection,
		_T("SELECT COUNT(*) FROM information_schema.TABLES "
		   "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_TYPE = 'BASE TABLE'"));
}

// True when the schema was imported.  TB_USER is the first table the servers
// need and exists in every complete import.
inline bool IsSchemaReady(MySqlConnection & connection)
{
	return CountSchemaTablesWhere(connection,
		_T("SELECT COUNT(*) FROM information_schema.TABLES "
		   "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'TB_USER'")) > 0;
}

// The message every server prints when the schema is missing.
inline std::string SchemaMissingHint(const MySqlConfig & config)
{
	std::string hint = "The MySQL database \"";
	hint += config.database;
	hint += "\" has no KO1534 schema.\n"
			"Set it up with one of these (from the repository root):\n"
			"    docker compose up -d          # import everything into a local container\n"
			"    tools/setup_database.ps1      # ...or into an existing MySQL installation\n";
	return hint;
}
