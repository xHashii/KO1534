#!/usr/bin/env bash
# ---------------------------------------------------------------------------
#  run_tests.sh - compile and run the C++ unit tests that do not need Windows.
#
#  These cover the two pieces of C++ written for the MySQL port that can be
#  tested from a shell:
#      shared/database/SqlIdentifiers.h   quoting of column/table names
#      shared/RuntimePaths.h              where the servers look for Map/Quests
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

if [ "$status" -eq 0 ]; then
	echo "OK: C++ unit tests"
else
	echo "FAIL: at least one test failed"
fi

exit "$status"
