#include "stdafx.h"
#include <cstdarg>
#include <mysql.h>
#include "MySqlConnection.h"

// The import library is named by the projects ($(MySQLClientLib), default
// libmysql.lib) instead of being hard-coded here: Oracle's MySQL 8.x Windows
// packages are x64-only, so a Win32 build links a 32-bit client library such as
// MariaDB Connector/C's libmariadb.lib - same API, MySQL protocol.

MySqlConnection::MySqlConnection()
	: m_handle(nullptr), m_bConnected(false), m_lock(new std::recursive_mutex())
{
}

MySqlConnection::~MySqlConnection()
{
	for (auto itr = m_errors.begin(); itr != m_errors.end(); itr++)
		delete *itr;

	m_errors.clear();

	Disconnect();
	delete m_lock;
}

bool MySqlConnection::isConnected()
{
	Guard lock(m_lock);
	return m_bConnected && m_handle != nullptr;
}

bool MySqlConnection::isError()
{
	Guard lock(m_lock);
	return !m_errors.empty();
}

bool MySqlConnection::Connect(const MySqlConfig & config)
{
	Guard lock(m_lock);

	if (!config.IsValid())
	{
		ReportError(_T("MySqlConnection::Connect"), _T("Database name is empty; check the [DATABASE] section of the .ini file."));
		return false;
	}

	if (m_handle != nullptr)
		Disconnect();

	m_config = config;

	m_handle = mysql_init(nullptr);
	if (m_handle == nullptr)
	{
		ReportError(_T("mysql_init"), _T("Unable to allocate a MySQL connection handle."));
		return false;
	}

	unsigned int timeout = (unsigned int)m_config.connectTimeout;
	mysql_options(m_handle, MYSQL_OPT_CONNECT_TIMEOUT, &timeout);
	mysql_options(m_handle, MYSQL_SET_CHARSET_NAME, m_config.charset.c_str());

	// Reconnect is deliberately not enabled: a silently rebuilt session loses
	// the transaction/session state and the servers already handle a failed
	// command by reporting it and retrying the request.
	bool reconnect = false;
	mysql_options(m_handle, MYSQL_OPT_RECONNECT, &reconnect);

	if (m_config.compress)
		mysql_options(m_handle, MYSQL_OPT_COMPRESS, nullptr);

	// CLIENT_MULTI_STATEMENTS is required because an output parameter is
	// translated into "SET @out = NULL; CALL ...; SELECT @out".
	if (mysql_real_connect(m_handle,
			m_config.host.c_str(), m_config.user.c_str(), m_config.password.c_str(),
			m_config.database.c_str(), m_config.port, nullptr,
			CLIENT_MULTI_STATEMENTS) == nullptr)
	{
		ReportLastMySqlError(_T("mysql_real_connect"), _T("Unable to establish a MySQL connection."));
		mysql_close(m_handle);
		m_handle = nullptr;
		return false;
	}

	// Make sure the session matches the byte-oriented data (latin1 == one
	// byte per character, PAD SPACE, case insensitive) regardless of what the
	// server default is.
	std::string charsetSql = "SET NAMES " + m_config.charset;
	mysql_real_query(m_handle, charsetSql.c_str(), (unsigned long)charsetSql.length());

	m_bConnected = true;
	return true;
}

void MySqlConnection::Disconnect()
{
	Guard lock(m_lock);

	if (m_handle != nullptr)
	{
		mysql_close(m_handle);
		m_handle = nullptr;
	}

	m_bConnected = false;
}

MySqlCommand * MySqlConnection::CreateCommand()
{
	if (!isConnected() && !Connect(m_config))
		return nullptr;

	return new MySqlCommand(this);
}

bool MySqlConnection::Ping()
{
	Guard lock(m_lock);

	if (m_handle == nullptr)
		return false;

	return mysql_ping(m_handle) == 0;
}

void MySqlConnection::AddCommand(MySqlCommand * dbCommand)
{
	Guard lock(m_lock);
	m_commandSet.insert(dbCommand);
}

void MySqlConnection::RemoveCommand(MySqlCommand * dbCommand)
{
	Guard lock(m_lock);
	m_commandSet.erase(dbCommand);
}

MySqlError * MySqlConnection::GetError()
{
	Guard lock(m_lock);

	if (m_errors.empty())
		return nullptr;

	return m_errors.front();
}

void MySqlConnection::ResetErrors()
{
	Guard lock(m_lock);

	for (auto itr = m_errors.begin(); itr != m_errors.end(); itr++)
		delete *itr;

	m_errors.clear();
}

tstring MySqlConnection::ReportLastMySqlError(const TCHAR * szSource, const TCHAR * szContext)
{
	tstring mysqlError;
	tstring mysqlState;

	if (m_handle != nullptr)
	{
		mysqlError = mysql_error(m_handle);
		mysqlState = mysql_sqlstate(m_handle);
	}

	MySqlError * pError = new MySqlError();
	pError->Source = szSource == nullptr ? _T("") : szSource;
	pError->ExtendedErrorMessage = mysqlState;
	pError->ErrorMessage = szContext == nullptr ? _T("") : szContext;

	if (!mysqlError.empty())
	{
		pError->ErrorMessage += _T(" [");
		pError->ErrorMessage += mysqlError;
		pError->ErrorMessage += _T("]");
	}

	Guard lock(m_lock);
	m_errors.push_back(pError);

	return pError->ErrorMessage;
}

tstring MySqlConnection::ReportError(const TCHAR * szSource, const TCHAR * szError, ...)
{
	TCHAR buffer[1024] = {0};

	if (szError != nullptr)
	{
		va_list args;
		va_start(args, szError);
		_vsntprintf(buffer, _countof(buffer) - 1, szError, args);
		va_end(args);
	}

	MySqlError * pError = new MySqlError();
	pError->Source = szSource == nullptr ? _T("") : szSource;
	pError->ErrorMessage = buffer;

	Guard lock(m_lock);
	m_errors.push_back(pError);

	return pError->ErrorMessage;
}
