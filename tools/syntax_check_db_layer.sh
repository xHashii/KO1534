#!/usr/bin/env bash
# ---------------------------------------------------------------------------
#  syntax_check_db_layer.sh
#
#  Type-checks shared/database/*.cpp on Linux with g++ against the stub headers
#  in tools/cxx_shim (a minimal Windows/PCH stand-in and a fake mysql.h).
#
#  WHAT THIS PROVES: the new MySQL client layer is syntactically valid C++17 and
#  its own declarations/definitions are consistent.
#  WHAT IT DOES NOT PROVE: that it compiles with MSVC (Win32, v143), links
#  against the real libmysql.lib, or works against a real server. Those still
#  need a Windows build - see README.
#
#  Usage: tools/syntax_check_db_layer.sh [repo_root]
# ---------------------------------------------------------------------------
set -u

ROOT="${1:-.}"
SHIM="$ROOT/tools/cxx_shim"
SRC="$ROOT/shared/database"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

if ! command -v g++ >/dev/null 2>&1; then
	echo "g++ not found - skipping (this check is optional)."
	exit 0
fi

mkdir -p "$WORK/shim"
cp "$SHIM"/*.h "$WORK/shim/"
cp "$ROOT/shared/tstring.h" "$WORK/tstring.h"
cp "$SRC"/MySqlCommand.h "$SRC"/MySqlCommand.cpp \
   "$SRC"/MySqlConnection.h "$SRC"/MySqlConnection.cpp \
   "$SRC"/MySqlParameter.h "$SRC"/DbTypes.h "$SRC"/SchemaCheck.h "$WORK/"

cd "$WORK" || exit 1

# Point the includes at the stubs.
sed -i 's|#include "stdafx.h"|#include "shim/stdafx.h"|;
        s|#include <mysql.h>|#include "shim/mysql.h"|;
        s|#include "../tstring.h"|#include "tstring.h"|' \
	MySqlCommand.cpp MySqlConnection.cpp MySqlCommand.h MySqlConnection.h

# Instantiates every helper in SchemaCheck.h so a broken signature there fails
# here instead of inside a Windows build.
cat > schema_check_tu.cpp <<'EOF'
#include "shim/stdafx.h"
#include "SchemaCheck.h"
#include <cstdio>

int CheckSchema(MySqlConnection & connection, const MySqlConfig & config)
{
	if (!IsSchemaReady(connection))
	{
		printf("%s", SchemaMissingHint(config).c_str());
		return CountSchemaTables(connection);
	}

	MySqlConfig copy = config;
	printf("%s", copy.Describe().c_str());
	return 0;
}
EOF

cd "$WORK" || exit 1

status=0
for f in MySqlCommand.cpp MySqlConnection.cpp schema_check_tu.cpp; do
	echo "checking $f"
	if ! g++ -std=c++17 -Wall -Wextra -Wno-unused-parameter -fsyntax-only \
			-I. -Ishim "$f"; then
		status=1
	fi
done

if [ "$status" -eq 0 ]; then
	echo "OK: database layer type-checks (stub headers, not an MSVC build)"
fi
exit "$status"
