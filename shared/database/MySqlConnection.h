#pragma once

// ---------------------------------------------------------------------------
//  MySqlConnection - native MySQL 8.x connection (libmysqlclient).
//
//  There is no ODBC/DSN layer any more: the servers read host/port/database/
//  user/password from their .ini file and hand them over as a MySqlConfig.
//  Connect with e.g.
//      MySqlConfig cfg; cfg.host = "127.0.0.1"; cfg.database = "KO1534";
//      cfg.user = "ko1534"; cfg.password = "...";
//      if (!db->Connect(cfg)) ...
// ---------------------------------------------------------------------------

#include "DbTypes.h"
#include "../tstring.h"
#include <set>
#include <string>
#include <vector>
#include <mutex>

// Forward declarations instead of <mysql.h>: the header is kept out of every
// translation unit that only holds a pointer (it pulls in winsock2.h, which
// must be included first).
struct MYSQL;

struct MySqlError
{
	tstring Source;
	tstring ErrorMessage;
	tstring ExtendedErrorMessage;
};

#include "MySqlCommand.h"

class MySqlConnection
{
	friend class MySqlCommand;

public:
	MySqlConnection();
	~MySqlConnection();

	bool isConnected();
	bool isError();

	bool Connect(const MySqlConfig & config);
	void Disconnect();

	MySqlCommand * CreateCommand();

	MySqlError * GetError();
	void ResetErrors();

	// Errors are collected per connection (the servers print them from the
	// database thread); Source describes the statement or API call.
	tstring ReportError(const TCHAR * szSource, const TCHAR * szError, ...);
	tstring ReportLastMySqlError(const TCHAR * szSource, const TCHAR * szContext);

	const MySqlConfig & GetConfig() const { return m_config; }

	// stable ping used by the watchdog threads
	bool Ping();

private:
	void AddCommand(MySqlCommand * dbCommand);
	void RemoveCommand(MySqlCommand * dbCommand);

private:
	MySqlConfig   m_config;
	MYSQL       * m_handle;
	bool          m_bConnected;

	std::recursive_mutex * m_lock;

	std::vector<MySqlError *>   m_errors;
	std::set    <MySqlCommand *> m_commandSet;
};
