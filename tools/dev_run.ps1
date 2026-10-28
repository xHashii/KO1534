<#
.SYNOPSIS
    One command to get a running KO1534 stack: database up and imported,
    configuration in place, servers started.

.DESCRIPTION
    What it does, in order:
      1. `docker compose up -d` and wait until MySQL answers.
      2. Wait until the KO1534 schema is fully imported (first run imports
         001..007 automatically; that takes a couple of minutes).
      3. Deploy the runtime files next to the executables: copy config\*.ini
         into bin\<Config>\<Platform>\ and link Map\ and Quests\ to data\,
         so each server finds ./<name>.ini, ./map and ./Quests beside the .exe.
      4. Start AIServer, LogInServer and GameServer from that folder, with it
         as the working directory.

.PARAMETER Configuration
    Debug (default) or Release - which build output to launch.

.PARAMETER Platform
    Win32 (default) or x64 - must match the platform you built. The MySQL
    client library shipped with MySQL 8.x is x64-only, so x64 is the usual
    choice.

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
    [ValidateSet("Win32", "x64")]
    [string] $Platform = "Win32",
    [switch] $NoLaunch,
    [switch] $ResetDatabase
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "lib\NativeCommand.ps1")

$repo = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$dataDir = Join-Path $repo "data"
# Search the selected platform first, then the other one: the output folder
# differs between Win32 and x64 builds and the wrong guess wastes a run.
$binDirs = @(
    (Join-Path $repo ("bin\{0}\{1}" -f $Configuration, $Platform)),
    (Join-Path $repo ("bin\{0}\{1}" -f $Configuration, $(if ($Platform -eq "Win32") { "x64" } else { "Win32" })))
)
$binDir = $binDirs[0]
foreach ($candidate in $binDirs) {
    if (Test-Path (Join-Path $candidate "GameServer.exe")) { $binDir = $candidate; break }
}

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
        $result = Invoke-Native -FilePath docker -ArgumentList @("compose", "down", "-v")
        if ($result.Text) { Write-Host $result.Text }
        if ($result.ExitCode -ne 0) { throw ("docker compose down failed:`n" + $result.Text) }
    }

    Write-Host "Starting MySQL..."
    $result = Invoke-Native -FilePath docker -ArgumentList @("compose", "up", "-d")
    if ($result.Text) { Write-Host $result.Text }
    if ($result.ExitCode -ne 0) { throw ("docker compose up failed:`n" + $result.Text) }

    # -----------------------------------------------------------------------
    # 2. Wait for the schema.  On the very first start the container itself
    #    imports 001..007 (~1-3 minutes for the 143 MB of INSERTs), so this
    #    loop is the "wait until the database is actually usable" step; it
    #    fails until the database and the TB_USER table both exist.
    # -----------------------------------------------------------------------
    # The import is done when the routines are there, not just the tables: a
    # failed migration file leaves 001/002 applied, so "TB_USER exists" alone
    # would let the servers start against a half-imported database.
    $probe = "SELECT CONCAT((SELECT COUNT(*) FROM information_schema.TABLES " +
             "WHERE TABLE_SCHEMA='$dbName' AND TABLE_TYPE='BASE TABLE'), '/', " +
             "(SELECT COUNT(*) FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA='$dbName'));"
    # base tables / routines of a complete import.  ">=" rather than "==" so a
    # database that already had extra objects is not rejected forever.
    $expectedTables = 105
    $expectedRoutines = 65
    $expected = "$expectedTables/$expectedRoutines"

    Write-Host "Waiting for the schema (first run imports the data: 1-3 minutes)..."
    $deadline = (Get-Date).AddMinutes(10)
    $counts = ""
    $lastCounts = ""
    $stableSince = Get-Date
    while ($true) {
        # docker inspect is used instead of `compose ps --format` because the
        # available template fields differ between compose versions.
        # Exit code 1 just means "no such container yet"; no exception either way.
        $state = (Invoke-Native -FilePath docker -ArgumentList @(
            "inspect", "-f", "{{.State.Status}}", "ko1534-mysql")).StdOut.Trim()
        if ($state -match "exited|dead") {
            Write-Host ""
            Write-Host "The MySQL container stopped: the import failed." -ForegroundColor Red
            Write-Host "See what went wrong:"
            Write-Host "    docker compose logs --tail 40 mysql"
            Write-Host "Then reset the volume, because a failed import does NOT resume:"
            Write-Host "    docker compose down -v"
            Write-Host "    docker compose up -d"
            throw "MySQL container exited during the import."
        }

        # The password warning goes to stderr and is filtered out; a real
        # client error stays in StdErr and is shown only if we time out.
        $probeResult = Invoke-Native -FilePath docker -ArgumentList @(
            "compose", "exec", "-T", "mysql", "mysql", "-u$dbUser", "-p$dbPass",
            "-N", "-B", "-e", $probe)
        $counts = $probeResult.StdOut.Trim()
        $probeError = Get-MySqlStderrText $probeResult.StdErr

        if ($counts -ne $lastCounts) {
            if ($counts) { Write-Host ("  tables/routines: {0}" -f $counts) }
            $lastCounts = $counts
            $stableSince = Get-Date
        }

        if ($counts -match '^(\d+)/(\d+)$') {
            $tables = [int] $Matches[1]
            $routines = [int] $Matches[2]

            if ($tables -ge $expectedTables -and $routines -ge $expectedRoutines) { break }

            # 001 creates the tables, 002 inserts the data (the slow part), then
            # 003..007 create the routines.  A non-zero routine count that stops
            # moving means the importer reached the routines and one of them
            # failed - waiting another eight minutes would not help.
            if ($routines -ge 1 -and $routines -lt $expectedRoutines -and
                ((Get-Date) - $stableSince).TotalSeconds -ge 20) {
                $message = ("The import stopped after {0} of {1} routines " +
                            "({2} tables). A stored routine in 003..007 failed, and an " +
                            "import does not resume from where it stopped.") -f `
                            $routines, $expectedRoutines, $tables
                if ($probeError) { $message += "`nmysql said:`n$probeError" }
                $message += "`nReset the volume and import again:`n" +
                            "    docker compose down -v`n    docker compose up -d`n" +
                            "Then check: docker compose logs mysql"
                throw $message
            }
        }

        if ((Get-Date) -gt $deadline) {
            $message = "Timed out waiting for the import (expected {0}, now '{1}')." -f $expected, $counts
            if ($probeError) { $message += "`nmysql said:`n$probeError" }
            $message += "`nCheck: docker compose logs mysql"
            throw $message
        }
        Start-Sleep -Seconds 3
    }
}
finally {
    Pop-Location
}

Write-Host "Database ready: mysql://${dbUser}:***@127.0.0.1:3306/$dbName  (tables/routines: $counts)"

# ---------------------------------------------------------------------------
# 3. Runtime files next to the executables.
#    The servers read ./<name>.ini, ./Map and ./Quests from the working
#    directory, so everything they need is deployed into $binDir and the
#    process is started there - no separate data\ layout to remember.
# ---------------------------------------------------------------------------
foreach ($ini in @("AIServer.ini", "GameServer.ini", "LogInServer.ini")) {
    $target = Join-Path $binDir $ini
    if (-not (Test-Path $target)) {
        Copy-Item (Join-Path $repo "config\$ini") $target
        Write-Host "Wrote $target"
    }
}

# Map\ is 100 MB and Quests\ is a few thousand .lua files, so they are linked
# rather than copied: the servers see them beside the .exe, git sees data\.
foreach ($asset in @("Map", "Quests")) {
    $link = Join-Path $binDir $asset
    $source = Join-Path $dataDir $asset
    if (Test-Path $link) { continue }
    if (-not (Test-Path $source)) { continue }
    try {
        New-Item -ItemType Junction -Path $link -Target $source -ErrorAction Stop | Out-Null
        Write-Host "Linked $link -> $source"
    }
    catch {
        # Junction creation can be blocked by policy.  Not fatal: the servers
        # walk up from the .exe and find data\Map and data\Quests themselves.
        Write-Host "Could not link $link ($($_.Exception.Message)); the servers will find $source on their own"
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

# ---------------------------------------------------------------------------
# 3c. Runtime layout check: what the servers will actually see.
# ---------------------------------------------------------------------------
$missing = @()
foreach ($required in @("GameServer.ini", "LogInServer.ini", "AIServer.ini")) {
    if (-not (Test-Path (Join-Path $binDir $required))) { $missing += $required }
}
if ($missing) {
    throw ("$binDir is missing: " + ($missing -join ", ") + "`n" +
           "The servers read ./<name>.ini from the working directory, which is the folder the .exe lives in.`n" +
           "Expected: $binDir\GameServer.ini, LogInServer.ini, AIServer.ini`n" +
           "They are copied from config\ by this script; copy them by hand if you launch the .exe directly.")
}

foreach ($asset in @("Map", "Quests")) {
    if (-not (Test-Path (Join-Path $binDir $asset))) {
        Write-Host "Note: $binDir\$asset is not present; the server will fall back to $dataDir\$asset"
    }
}

$mapCount = (Get-ChildItem (Join-Path $dataDir "Map") -Filter *.smd -ErrorAction SilentlyContinue).Count
$questCount = (Get-ChildItem (Join-Path $dataDir "Quests") -Filter *.lua -ErrorAction SilentlyContinue).Count
Write-Host "Working directory: $binDir"
Write-Host ("  Map\    {0} .smd, {1} .aievt" -f $mapCount,
    (Get-ChildItem (Join-Path $dataDir "Map") -Filter *.aievt -ErrorAction SilentlyContinue).Count)
Write-Host ("  Quests\ {0} .lua" -f $questCount)

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
        throw ("{0} not found. Build the solution in Visual Studio 2022 ({1}/{2}) first." -f `
               $exe.Path, $Platform, $Configuration)
    }
}

foreach ($exe in $exes) {
    Write-Host ("Starting {0} (working directory: {1})" -f $exe.Name, $binDir)
    Start-Process -FilePath $exe.Path -WorkingDirectory $binDir
    if ($exe.Wait -gt 0) { Start-Sleep -Seconds $exe.Wait }
}

Write-Host ""
Write-Host "Servers are starting. To stop them:"
Write-Host "    Get-Process AIServer,LogInServer,GameServer | Stop-Process"
Write-Host "To stop the database:  docker compose down"
