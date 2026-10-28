#pragma once
// Thin stub of libmysqlclient's public surface (syntax check only).
#include <cstddef>
typedef struct MYSQL MYSQL;
typedef char ** MYSQL_ROW;
typedef struct MYSQL_RES MYSQL_RES;
typedef struct MYSQL_FIELD MYSQL_FIELD;
typedef struct MYSQL_STMT MYSQL_STMT;

#define CLIENT_MULTI_STATEMENTS 65536UL
enum mysql_option { MYSQL_OPT_CONNECT_TIMEOUT = 0, MYSQL_OPT_RECONNECT, MYSQL_SET_CHARSET_NAME, MYSQL_OPT_COMPRESS };

MYSQL * mysql_init(MYSQL *);
MYSQL * mysql_real_connect(MYSQL *, const char *, const char *, const char *, const char *, unsigned int, const char *, unsigned long);
void    mysql_close(MYSQL *);
int     mysql_options(MYSQL *, enum mysql_option, const void *);
int     mysql_ping(MYSQL *);
int     mysql_real_query(MYSQL *, const char *, unsigned long);
unsigned long mysql_real_escape_string(MYSQL *, char *, const char *, unsigned long);
MYSQL_RES * mysql_store_result(MYSQL *);
unsigned int mysql_field_count(MYSQL *);
MYSQL_ROW mysql_fetch_row(MYSQL_RES *);
unsigned long * mysql_fetch_lengths(MYSQL_RES *);
void mysql_free_result(MYSQL_RES *);
int mysql_next_result(MYSQL *);
const char * mysql_error(MYSQL *);
const char * mysql_sqlstate(MYSQL *);
