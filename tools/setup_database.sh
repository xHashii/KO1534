#!/usr/bin/env bash
# ---------------------------------------------------------------------------
#  setup_database.sh - import the KO1534 schema, data and routines into an
#  existing MySQL 8.x server (no Docker required, Linux/macOS counterpart of
#  tools/setup_database.ps1).
#
#  Usage:
#      tools/setup_database.sh                       # interactive
#      MYSQL_PWD=secret tools/setup_database.sh      # non-interactive
#      DB=KO1534 USER_NAME=root HOST=127.0.0.1 tools/setup_database.sh --force
#
#  With Docker the same result comes from `docker compose up -d`; this script
#  is for people who already run MySQL locally.
# ---------------------------------------------------------------------------
set -euo pipefail

HOST="${HOST:-127.0.0.1}"
PORT="${PORT:-3306}"
ADMIN_USER="${USER_NAME:-root}"
DATABASE="${DB:-KO1534}"
APP_USER="${APP_USER:-ko1534}"
APP_PASSWORD="${APP_PASSWORD:-ko1534}"
FORCE="${1:-}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MIG="$ROOT/migrations/mysql"

if ! command -v mysql >/dev/null 2>&1; then
	echo "mysql client not found. Install mysql-client (or use: docker compose up -d)." >&2
	exit 1
fi

MYSQL=(mysql --host="$HOST" --port="$PORT" --user="$ADMIN_USER" --protocol=TCP
       --default-character-set=latin1 --batch)

run_file() {
	echo "  importing $(basename "$1") ..."
	"${MYSQL[@]}" --database="$DATABASE" < "$1"
}

ready=$("${MYSQL[@]}" -N -B --execute="SELECT COUNT(*) FROM information_schema.TABLES \
        WHERE TABLE_SCHEMA = '$DATABASE' AND TABLE_NAME = 'TB_USER';")

if [ "$ready" = "1" ] && [ "$FORCE" != "--force" ]; then
	echo "Database '$DATABASE' is already set up - nothing to do (use --force to rebuild)."
	exit 0
fi

if [ "$FORCE" = "--force" ]; then
	echo "Dropping '$DATABASE' ..."
	"${MYSQL[@]}" --execute="DROP DATABASE IF EXISTS \`$DATABASE\`;"
fi

echo "Creating database '$DATABASE' and account '$APP_USER' ..."
"${MYSQL[@]}" <<SQL
CREATE DATABASE IF NOT EXISTS \`$DATABASE\` CHARACTER SET latin1 COLLATE latin1_general_ci;
CREATE USER IF NOT EXISTS '$APP_USER'@'%' IDENTIFIED BY '$APP_PASSWORD';
ALTER USER '$APP_USER'@'%' IDENTIFIED BY '$APP_PASSWORD';
GRANT ALL PRIVILEGES ON \`$DATABASE\`.* TO '$APP_USER'@'%';
FLUSH PRIVILEGES;
SQL

start=$(date +%s)

# 001 schema -> 002 data -> 003..007 routines
run_file "$MIG/001_schema.sql"

if [ -f "$MIG/002_data.sql" ]; then
	run_file "$MIG/002_data.sql"
elif [ -f "$MIG/002_data.sql.gz" ]; then
	tmp="$(mktemp)"
	trap 'rm -f "$tmp"' EXIT
	echo "  expanding 002_data.sql.gz ..."
	gzip -dc "$MIG/002_data.sql.gz" > "$tmp"
	run_file "$tmp"
else
	echo "Neither 002_data.sql nor 002_data.sql.gz exists. Regenerate with: python3 tools/sqlserver_to_mysql.py" >&2
	exit 1
fi

for f in "$MIG"/0*.sql; do
	case "$(basename "$f")" in
		001_schema.sql|002_data.sql) continue ;;
	esac
	run_file "$f"
done

echo
echo "Done in $(( $(date +%s) - start ))s. Database '$DATABASE' is ready."
echo "Point config/*.ini at it:  HOST=$HOST PORT=$PORT NAME=$DATABASE USER=$APP_USER PASSWORD=$APP_PASSWORD"
