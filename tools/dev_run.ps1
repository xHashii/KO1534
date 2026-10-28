<#
.SYNOPSIS
    One command to get a running KO1534 stack: database up and imported,
    configuration in place, servers started.

.DESCRIPTION
    What it does, in order:
      1. `docker compose up -d` and wait until MySQL answers.
      2. Wait until the KO1534 schema is fully imported (first run imports
         001..007 automatically; that takes a couple of minutes).
      3. Copy config\*.ini into data\ if they are not there yet, so the
         servers find ./GameServer.ini and ./map from their working directory.
      4. Start AIServer, LogInServer and GameServer from bin\<Config>\Win32\
         with data\ as the working directory.

.PARAMETER Configuration
    Debug (default) or Release - which build output to launch.

.PARAMETER NoLaunch
    Only prepare the database and the configuration, do not start the servers.

.PARAMETER ResetDatabase
    Destroy the MySQL volume and re-import from scratch.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File tools\dev_run.ps1
#>
param(
    [ValidateSet("Debug", "Release")]
    [string] $Configuration = "Debug",
    [switch] $NoLaunch,
    [switch] $ResetDatabase
)

$ErrorActionPreference = "Stop"
$repo = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$dataDir = Join-Path $repo "data"
$binDir = Join-Path $repo ("bin\{0}\Win32" -f $Configuration)

# Credentials: defaults, overridable through .env (same file docker compose reads).
function Get-DotEnv([string] $Key, [string] $Default) {
    $file = Join-Path $repo ".env"
    if (Test-Path $file) {
        foreach ($line in Get-Content $file) {
            if ($line -match "^\s*$Key\s*=\s*(.*)$") { return $Matches[1].Trim() }
        }
    }
    return $Default
}

$dbName = Get-DotEnv "MYSQL_DATABASE" "KO1534"
$dbUser = Get-DotEnv "MYSQL_USER" "ko1534"
$dbPass = Get-DotEnv "MYSQL_PASSWORD" "ko1534"

function Wait-For([scriptblock] $Probe, [string] $What, [int] $TimeoutSeconds = 600) {
    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    while ((Get-Date) -lt $deadline) {
        if (& $Probe) { return $true }
        Start-Sleep -Seconds 3
    }
    throw "Timed out waiting for $What. Check: docker compose logs mysql"
}

# ---------------------------------------------------------------------------
# 1. MySQL container
# ---------------------------------------------------------------------------
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw "Docker is not installed. Install Docker Desktop, or run tools\setup_database.ps1 against an existing MySQL."
}

Push-Location $repo
try {
    if ($ResetDatabase) {
        Write-Host "Resetting the database volume..."
        docker compose down -v
    }

    Write-Host "Starting MySQL..."
    docker compose up -d
    if ($LASTEXITCODE -ne 0) { throw "docker compose up failed." }

    # -----------------------------------------------------------------------
    # 2. Wait for the schema.  On the very first start the container itself
    #    imports 001..007 (~1-3 minutes for the 143 MB of INSERTs), so this
    #    loop is the "wait until the database is actually usable" step; it
    #    fails until the database and the TB_USER table both exist.
    # -----------------------------------------------------------------------
    $probe = "SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA='$dbName' AND TABLE_NAME='TB_USER';"
    Write-Host "Waiting for the schema (first run imports the data: 1-3 minutes)..."
    Wait-For -What "the KO1534 schema to be imported" -Probe {
        $count = docker compose exec -T mysql mysql "-u$dbUser" "-p$dbPass" -N -B -e $probe 2>$null
        return ($count -match "1")
    }
}
finally {
    Pop-Location
}

Write-Host "Database ready: mysql://${dbUser}:***@127.0.0.1:3306/$dbName"

# ---------------------------------------------------------------------------
# 3. Configuration next to the data (the servers read ./<name>.ini)
# ---------------------------------------------------------------------------
foreach ($ini in @("AIServer.ini", "GameServer.ini", "LogInServer.ini")) {
    $target = Join-Path $dataDir $ini
    if (-not (Test-Path $target)) {
        Copy-Item (Join-Path $repo "config\$ini") $target
        Write-Host "Wrote $target"
    }
}

# ---------------------------------------------------------------------------
# 3b. Client DLL next to the executables (libmysql.dll / libmariadb.dll).
#     Only when MYSQL_ROOT points at a client install; otherwise rely on PATH.
# ---------------------------------------------------------------------------
if ($env:MYSQL_ROOT) {
    foreach ($dll in @("libmysql.dll", "libmariadb.dll")) {
        $candidate = Join-Path $env:MYSQL_ROOT "bin\$dll"
        if (-not (Test-Path $candidate)) { $candidate = Join-Path $env:MYSQL_ROOT "lib\$dll" }
        if (Test-Path $candidate) {
            Copy-Item $candidate (Join-Path $binDir $dll) -Force
            Write-Host "Copied $dll next to the executables"
        }
    }
}

if ($NoLaunch) { return }

# ---------------------------------------------------------------------------
# 4. Servers
# ---------------------------------------------------------------------------
# Fixed order, not a hashtable: the game server talks to the AI server, so they
# must come up AI -> Login -> Game.
$exes = @(
    @{ Name = "AIServer";    Path = (Join-Path $binDir "AIServer.exe");    Wait = 2 },
    @{ Name = "LogInServer"; Path = (Join-Path $binDir "LogInServer.exe"); Wait = 1 },
    @{ Name = "GameServer";  Path = (Join-Path $binDir "GameServer.exe");  Wait = 0 }
)

foreach ($exe in $exes) {
    if (-not (Test-Path $exe.Path)) {
        throw "$($exe.Path) not found. Build the solution in Visual Studio 2022 (Win32/$Configuration) first."
    }
}

foreach ($exe in $exes) {
    Write-Host ("Starting {0} (working directory: {1})" -f $exe.Name, $dataDir)
    Start-Process -FilePath $exe.Path -WorkingDirectory $dataDir
    if ($exe.Wait -gt 0) { Start-Sleep -Seconds $exe.Wait }
}

Write-Host ""
Write-Host "Servers are starting. To stop them:"
Write-Host "    Get-Process AIServer,LogInServer,GameServer | Stop-Process"
Write-Host "To stop the database:  docker compose down"
