#pragma once
// Minimal stand-in for the Windows/PCH environment, used by
// tools/syntax_check_db_layer.sh to type-check the database layer on Linux.
// It is NOT a Windows build and proves nothing about MSVC/winsock behaviour.
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <cstdarg>
#include <string>
#include <vector>
#include <map>
#include <set>
#include <type_traits>
#include <mutex>
#include <algorithm>

typedef char          TCHAR;
#define _T(x) x
#define _countof(a) (sizeof(a)/sizeof((a)[0]))
#define _snprintf_s(buf, size, trunc, fmt, ...) snprintf(buf, size, fmt, __VA_ARGS__)

#define _strtoi64 strtoll
#define _strtoui64 strtoull
#define INLINE inline

typedef uint8_t  uint8;
typedef int8_t   int8;
typedef uint16_t uint16;
typedef int16_t  int16;
typedef uint32_t uint32;
typedef int32_t  int32;
typedef uint64_t uint64;
typedef int64_t  int64;

class Guard
{
public:
	Guard(std::recursive_mutex & m) : target(m) { target.lock(); }
	Guard(std::recursive_mutex * m) : target(*m) { target.lock(); }
	~Guard() { target.unlock(); }
private:
	std::recursive_mutex & target;
};

#define GlobalError(file, line) ((void)0)
#define TRACE(...) ((void)0)
