#pragma once

// ---------------------------------------------------------------------------
//  DbConfigReader.h - reads a MySqlConfig from an .ini section.
//
//  Example (GameServer.ini):
//      [DATABASE]
//      HOST      = 127.0.0.1
//      PORT      = 3306
//      NAME      = KO1534
//      USER      = ko1534
//      PASSWORD  = change_me
//      CHARSET   = latin1
//
//  No DSN, no driver-manager configuration: just the five values libmysqlclient
//  needs.  See config/ for complete sample files.
// ---------------------------------------------------------------------------

#include "DbTypes.h"
#include "../Ini.h"

inline MySqlConfig ReadDatabaseConfig(CIni & ini, const char * section)
{
	MySqlConfig config;

	ini.GetString(section, "HOST", config.host.c_str(), config.host, false);

	int port = ini.GetInt(section, "PORT", (int)config.port);
	if (port > 0 && port <= 65535)
		config.port = (uint16_t)port;

	ini.GetString(section, "NAME", "", config.database, false);
	ini.GetString(section, "USER", "", config.user, false);
	ini.GetString(section, "PASSWORD", "", config.password, false);
	ini.GetString(section, "CHARSET", config.charset.c_str(), config.charset, false);

	config.connectTimeout = ini.GetInt(section, "CONNECT_TIMEOUT", config.connectTimeout);
	config.compress = ini.GetBool(section, "COMPRESS", false);

	return config;
}
