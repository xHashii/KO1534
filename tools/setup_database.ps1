<#
.SYNOPSIS
    Creates the KO1534 database and imports every migration file into an
    existing MySQL 8.x installation (no Docker required).

.DESCRIPTION
    The C++ servers need a MySQL database containing the schema, the original
    1534 data and the ported stored routines.  This script does exactly what
    `docker compose up -d` does, but against a MySQL server you already run
    (the one you point Navicat/HeidiSQL at).

    It is idempotent-ish: it refuses to touch a database that already has the
    KO1534 tables unless you pass -Force (which drops and recreates it).

.PARAMETER Host
    MySQL host.  Default: 127.0.0.1

.PARAMETER Port
    MySQL port.  Default: 3306

.PARAMETER User
    An account allowed to create databases and users.  Default: root

.PARAMETER Password
    Password for -User.  Prompted for when omitted.

.PARAMETER Database
    Database to create.  Default: KO1534

.PARAMETER AppUser
    Application account created for the servers.  Default: ko1534

.PARAMETER AppPassword
    Password for the application account.  Default: ko1534 (local dev only).

.PARAMETER MySqlBin
    Folder containing mysql.exe.  Default: whatever is on PATH, then the usual
    MySQL Server install folders.

.PARAMETER Force
    Drop the existing database and re-import from scratch.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File tools\setup_database.ps1
#>
param(
    [string] $HostName = "127.0.0.1",
    [int]    $Port = 3306,
    [string] $User = "root",
    [string] $Password,
    [string] $Database = "KO1534",
    [string] $AppUser = "ko1534",
    [string] $AppPassword = "ko1534",
    [string] $MySqlBin,
    [switch] $Force
)

$ErrorActionPreference = "Stop"
$repo = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$migrationDir = Join-Path $repo "migrations\mysql"

function Find-MySql {
    if ($MySqlBin) {
        $exe = Join-Path $MySqlBin "mysql.exe"
        if (Test-Path $exe) { return $exe }
        throw "mysql.exe not found in $MySqlBin"
    }

    $cmd = Get-Command mysql.exe -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }

    $candidates = Get-ChildItem "C:\Program Files\MySQL" -Directory -ErrorAction SilentlyContinue |
        Sort-Object Name -Descending |
        ForEach-Object { Join-Path $_.FullName "bin\mysql.exe" }
    foreach ($c in $candidates) {
        if (Test-Path $c) { return $c }
    }
    throw "mysql.exe not found. Install MySQL Server 8.x, or pass -MySqlBin 'C:\path\to\bin'."
}

function Read-Password {
    param([string] $Prompt, [string] $Default)
    $secure = Read-Host -Prompt $Prompt -AsSecureString
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    try {
        $plain = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
        if ([string]::IsNullOrEmpty($plain)) { return $Default }
        return $plain
    } finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    }
}

function Invoke-MySql {
    param([string] $Query, [string] $InputFile)

    $mysqlArgs = @("--host=$HostName", "--port=$Port", "--user=$User", "--protocol=TCP",
                   "--default-character-set=latin1", "--batch")
    if ($Password) { $mysqlArgs += "--password=$Password" }

    if ($InputFile) {
        # Redirect the file into mysql.exe: 143 MB of INSERTs must not go
        # through a PowerShell variable.
        $cmdLine = '"' + $MySqlBinExe + '" ' + ($mysqlArgs -join ' ') + ' "' + $Database + '" < "' + $InputFile + '"'
        $out = cmd.exe /c $cmdLine 2>&1
    } else {
        $out = & $MySqlBinExe @mysqlArgs $Database --execute="$Query" 2>&1
    }

    if ($LASTEXITCODE -ne 0) {
        throw "mysql.exe failed ($LASTEXITCODE):`n$out"
    }
    return $out
}

$MySqlBinExe = Find-MySql
Write-Host "MySQL client : $MySqlBinExe"
Write-Host "Server       : $HostName`:$Port"
Write-Host "Database     : $Database"

if (-not $Password) {
    $Password = Read-Password "Password for MySQL user '$User'" $null
    if ([string]::IsNullOrEmpty($Password)) {
        throw "A password is required (pass -Password, or create a passwordless local root)."
    }
}

# ---------------------------------------------------------------------------
# 1. Does the database exist / is it already populated?
# ---------------------------------------------------------------------------
$check = Invoke-MySql -Query ("SELECT COUNT(*) FROM information_schema.TABLES " +
                              "WHERE TABLE_SCHEMA = '$Database' AND TABLE_NAME = 'TB_USER';")
$ready = ($check -match "^\s*1\s*$")

if ($ready -and -not $Force) {
    Write-Host ""
    Write-Host "Database '$Database' is already set up - nothing to do."
    Write-Host "Use -Force to drop and re-import it."
    exit 0
}

# ---------------------------------------------------------------------------
# 2. Create the database and the application account
# ---------------------------------------------------------------------------
if ($Force) {
    Write-Host "Dropping existing database '$Database'..."
    Invoke-MySql -Query "DROP DATABASE IF EXISTS ``$Database``;" | Out-Null
}

Write-Host "Creating database and account..."
$bootstrap = @"
CREATE DATABASE IF NOT EXISTS ``$Database`` CHARACTER SET latin1 COLLATE latin1_general_ci;
CREATE USER IF NOT EXISTS '$AppUser'@'%' IDENTIFIED BY '$AppPassword';
ALTER USER '$AppUser'@'%' IDENTIFIED BY '$AppPassword';
GRANT ALL PRIVILEGES ON ``$Database``.* TO '$AppUser'@'%';
FLUSH PRIVILEGES;
"@
$tmpSql = [System.IO.Path]::GetTempFileName()
Set-Content -Path $tmpSql -Value $bootstrap -Encoding ASCII
try {
    # No database selected yet, so run it against the server itself.
    $mysqlArgs = @("--host=$HostName", "--port=$Port", "--user=$User", "--protocol=TCP", "--batch")
    if ($Password) { $mysqlArgs += "--password=$Password" }
    $cmdLine = '"' + $MySqlBinExe + '" ' + ($mysqlArgs -join ' ') + ' < "' + $tmpSql + '"'
    $out = cmd.exe /c $cmdLine 2>&1
    if ($LASTEXITCODE -ne 0) { throw "Could not create the database: $out" }
} finally {
    Remove-Item $tmpSql -ErrorAction SilentlyContinue
}

# ---------------------------------------------------------------------------
# 3. Import the migration files, in the order the schema requires
#      001 schema  ->  002 data  ->  003..007 routines
# ---------------------------------------------------------------------------
function Import-SqlFile {
    param([string] $Path)
    Write-Host ("  importing {0} ..." -f (Split-Path -Leaf $Path))
    Invoke-MySql -InputFile $Path | Out-Null
}

$start = Get-Date

Import-SqlFile (Join-Path $migrationDir "001_schema.sql")


# The data ships gzipped (143 MB of INSERTs, ~2 MB compressed); GZipStream is
# part of .NET, so no extra tooling is needed to expand it.
$gz = Join-Path $migrationDir "002_data.sql.gz"
$plain = Join-Path $migrationDir "002_data.sql"

if (Test-Path $plain) {
    Import-SqlFile $plain
} elseif (Test-Path $gz) {
    Write-Host "  expanding 002_data.sql.gz ..."
    $tmp = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "ko1534_data.sql")
    $in = [System.IO.File]::OpenRead($gz)
    try {
        $outStream = [System.IO.File]::Create($tmp)
        try {
            $gzipStream = New-Object System.IO.Compression.GZipStream($in, [System.IO.Compression.CompressionMode]::Decompress)
            try { $gzipStream.CopyTo($outStream) } finally { $gzipStream.Dispose() }
        } finally { $outStream.Dispose() }
    } finally { $in.Dispose() }

    try { Import-SqlFile $tmp } finally { Remove-Item $tmp -ErrorAction SilentlyContinue }
} else {
    throw "Neither 002_data.sql nor 002_data.sql.gz exists. Regenerate them with: python3 tools/sqlserver_to_mysql.py"
}

Get-ChildItem $migrationDir -Filter "*.sql" |
    Where-Object { $_.Name -notin @("001_schema.sql", "002_data.sql") } |
    Sort-Object Name |
    ForEach-Object { Import-SqlFile $_.FullName }

$elapsed = (Get-Date) - $start
Write-Host ""
Write-Host ("Done in {0:n0}s.  Database '{1}' is ready." -f $elapsed.TotalSeconds, $Database)
Write-Host ""
Write-Host "Point the servers at it (config\*.ini):"
Write-Host "    [DATABASE]"
Write-Host "    HOST = $HostName"
Write-Host "    PORT = $Port"
Write-Host "    NAME = $Database"
Write-Host "    USER = $AppUser"
Write-Host "    PASSWORD = $AppPassword"
