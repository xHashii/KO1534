#!/usr/bin/env bash
# ---------------------------------------------------------------------------
#  run_tests.sh - compile and run the C++ unit tests that do not need Windows.
#
#  These cover the pieces of C++ written for the MySQL port that can be tested
#  from a shell:
#      shared/database/SqlIdentifiers.h   quoting of column/table names
#      shared/RuntimePaths.h              where the servers look for Map/Quests
#      shared/database/MySqlCommand.cpp   the SQL text it sends to MySQL
#
#  WHAT THIS PROVES: the logic is right and compiles as C++14.
#  WHAT IT DOES NOT PROVE: that MSVC accepts it, or how the real Win32 calls
#  behave. Those need a Windows build and a run - see README.
#
#  Usage: tools/tests/run_tests.sh
# ---------------------------------------------------------------------------
set -u

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
OUT="$(mktemp -d)"
trap 'rm -rf "$OUT"' EXIT

if ! command -v g++ >/dev/null 2>&1; then
	echo "g++ not found - skipping (these tests are optional)."
	exit 0
fi

status=0

for test in test_sql_identifiers test_runtime_paths; do
	echo "=== $test"
	if ! g++ -std=c++14 -Wall -Wextra -Werror -o "$OUT/$test" "$ROOT/tools/tests/$test.cpp"; then
		echo "FAIL: $test does not compile"
		status=1
		continue
	fi

	if ! "$OUT/$test"; then
		status=1
	fi
	echo ""
done

# ---------------------------------------------------------------------------
# The statement renderer needs the database layer itself, so it is built the
# same way tools/syntax_check_db_layer.sh type-checks it: against the stubs.
# ---------------------------------------------------------------------------
echo "=== test_statement_rendering"
DBWORK="$OUT/db"
mkdir -p "$DBWORK/shim"
cp "$ROOT/tools/cxx_shim"/*.h "$DBWORK/shim/"
cp "$ROOT/shared/tstring.h" "$DBWORK/"
cp "$ROOT/shared/database"/MySqlCommand.h "$ROOT/shared/database"/MySqlCommand.cpp \
   "$ROOT/shared/database"/MySqlConnection.h "$ROOT/shared/database"/MySqlConnection.cpp \
   "$ROOT/shared/database"/MySqlParameter.h "$ROOT/shared/database"/DbTypes.h \
   "$DBWORK/"

cp "$ROOT/tools/tests/test_statement_rendering.cpp" "$DBWORK/"
(
	cd "$DBWORK" || exit 1
	sed -i 's|#include "stdafx.h"|#include "shim/stdafx.h"|;
	        s|#include <mysql.h>|#include "shim/mysql.h"|;
	        s|#include "../tstring.h"|#include "tstring.h"|' \
		MySqlCommand.cpp MySqlCommand.h MySqlConnection.cpp MySqlConnection.h
	g++ -std=c++14 -Wall -Wextra -Werror -Wno-unused-parameter -I. -Ishim \
		-o rendering test_statement_rendering.cpp MySqlCommand.cpp MySqlConnection.cpp
) || {
	echo "FAIL: test_statement_rendering does not compile"
	status=1
}

if [ -x "$DBWORK/rendering" ] && ! (cd "$DBWORK" && ./rendering); then
	status=1
fi
echo ""

if [ "$status" -eq 0 ]; then
	echo "OK: C++ unit tests"
else
	echo "FAIL: at least one test failed"
fi

exit "$status"
