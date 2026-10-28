<#
.SYNOPSIS
    Build the KO1534 servers without needing a Developer Command Prompt.

.DESCRIPTION
    Finds MSBuild through vswhere, locates a MySQL-protocol client library
    (MariaDB Connector/C or MySQL Connector/C) and builds the solution.

    Both of those are the two things that usually go wrong by hand:
      * msbuild is not on PATH in a normal PowerShell window;
      * the projects default MYSQL_ROOT to "C:\Program Files\MySQL\MySQL Server
        8.4", which may not exist, and a 32-bit build cannot link the 64-bit
        libmysql.lib that ships with MySQL 8.x.

    Nothing is copied or installed: it only runs MSBuild.

.PARAMETER Configuration
    Debug (default) or Release.

.PARAMETER Platform
    Win32 (default) or x64.

.PARAMETER Lib
    Import library name.  Default: libmariadb.lib for Win32 (the only 32-bit
    client library that is easy to get), libmysql.lib for x64.

.PARAMETER MySqlRoot
    Install prefix with include\mysql.h and lib\<lib>.  Auto-detected when
    omitted.

.PARAMETER Clean
    Rebuild instead of incremental build.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File tools\build.ps1
#>
param(
    [ValidateSet("Debug", "Release")]
    [string] $Configuration = "Debug",
    [ValidateSet("Win32", "x64")]
    [string] $Platform = "Win32",
    [string] $Lib = "",
    [string] $MySqlRoot = "",
    [switch] $Clean
)

$ErrorActionPreference = "Stop"
$repo = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$solution = Join-Path $repo "ALPHAGAME v1534.sln"

if (-not $Lib) {
    if ($Platform -eq "Win32") { $Lib = "libmariadb.lib" } else { $Lib = "libmysql.lib" }
}

# ---------------------------------------------------------------------------
# MSBuild
# ---------------------------------------------------------------------------
function Find-MSBuild {
    $pf86 = ${env:ProgramFiles(x86)}
    $vswhere = $null
    if ($pf86) { $vswhere = Join-Path $pf86 "Microsoft Visual Studio\Installer\vswhere.exe" }
    if ($vswhere -and (Test-Path $vswhere)) {
        $found = & $vswhere -latest -products * -requires Microsoft.Component.MSBuild `
                            -find "MSBuild\**\Bin\MSBuild.exe" 2>$null
        if ($found) { return ($found | Select-Object -First 1) }
    }

    $onPath = Get-Command msbuild -ErrorAction SilentlyContinue
    if ($onPath) { return $onPath.Source }

    foreach ($edition in @("Enterprise", "Professional", "Community", "BuildTools")) {
        $candidate = "C:\Program Files\Microsoft Visual Studio\2022\$edition\MSBuild\Current\Bin\MSBuild.exe"
        if (Test-Path $candidate) { return $candidate }
    }

    throw "MSBuild not found. Install Visual Studio 2022 (or Build Tools) with the 'Desktop development with C++' workload."
}

# ---------------------------------------------------------------------------
# MySQL-protocol client library
# ---------------------------------------------------------------------------
function Test-Root([string] $Root, [string] $LibName) {
    if (-not $Root) { return $false }
    return (Test-Path (Join-Path $Root "include\mysql.h")) -and
           (Test-Path (Join-Path $Root "lib\$LibName"))
}

function Find-MySqlRoot([string] $LibName) {
    if ($MySqlRoot) {
        if (-not (Test-Path (Join-Path $MySqlRoot "include\mysql.h"))) {
            throw "$MySqlRoot\include\mysql.h not found - -MySqlRoot must be the install prefix of a client library."
        }
        if (-not (Test-Path (Join-Path $MySqlRoot "lib\$LibName"))) {
            $found = (Get-ChildItem (Join-Path $MySqlRoot "lib") -Filter *.lib -ErrorAction SilentlyContinue |
                      Select-Object -ExpandProperty Name) -join ", "
            throw ("$MySqlRoot\lib\$LibName not found. Available libs: $found")
        }
        return $MySqlRoot
    }

    $candidates = @()
    if ($env:MYSQL_ROOT) { $candidates += $env:MYSQL_ROOT }
    foreach ($parent in @("C:\Program Files\MariaDB", "C:\Program Files\MySQL",
                          "C:\Program Files (x86)\MariaDB")) {
        if (Test-Path $parent) {
            $candidates += (Get-ChildItem $parent -Directory -ErrorAction SilentlyContinue |
                            Sort-Object Name -Descending |
                            Select-Object -ExpandProperty FullName)
        }
    }

    foreach ($candidate in $candidates) {
        if (Test-Root $candidate $LibName) { return $candidate }
    }

    # Nothing matched exactly: say what was found so the fix is obvious.
    $seen = @()
    foreach ($candidate in $candidates) {
        if ($candidate -and (Test-Path $candidate)) {
            $hasHeader = Test-Path (Join-Path $candidate "include\mysql.h")
            $libs = @()
            if (Test-Path (Join-Path $candidate "lib")) {
                $libs = (Get-ChildItem (Join-Path $candidate "lib") -Filter *.lib -ErrorAction SilentlyContinue |
                         Select-Object -ExpandProperty Name) -join ","
            }
            $seen += "  {0}  (mysql.h: {1}, libs: {2})" -f $candidate, $hasHeader, $libs
        }
    }

    throw ("No install with include\mysql.h and lib\$LibName found.`n" +
           "Searched:`n" + ($seen -join "`n") + "`n`n" +
           "Install one of these, then re-run:`n" +
           "  * MariaDB Connector/C (win32 package) for /p:Platform=Win32`n" +
           "  * MySQL 8.4 (or Connector/C) for /p:Platform=x64`n" +
           "Or point at an existing install:  tools\build.ps1 -MySqlRoot 'C:\path\to\install'")
}

$msbuild = Find-MSBuild
$root = Find-MySqlRoot $Lib

Write-Host "MSBuild      : $msbuild"
Write-Host "Client lib   : $root\lib\$Lib"
Write-Host "Target       : $Configuration|$Platform"
Write-Host ""

$target = "Build"
if ($Clean) { $target = "Rebuild" }

& $msbuild $solution "/m" "/t:$target" "/p:Configuration=$Configuration" `
    "/p:Platform=$Platform" "/p:MYSQL_ROOT=$root" "/p:MySQLClientLib=$Lib" `
    "/nologo" "/v:minimal" "/clp:Summary"

$code = $LASTEXITCODE
Write-Host ""

if ($code -ne 0) {
    Write-Host "Build FAILED (exit $code). Common causes:" -ForegroundColor Red
    Write-Host "  LNK1112 machine type 'x64' conflicts with 'x86'  -> 32-bit build linking a 64-bit lib"
    Write-Host "  LNK1104 cannot open file 'libmariadb.lib'        -> wrong -MySqlRoot"
    Write-Host "  C1083 cannot open include file 'mysql.h'         -> wrong -MySqlRoot"
    exit $code
}

$binDir = Join-Path $repo ("bin\{0}\{1}" -f $Configuration, $Platform)
$exes = @("AIServer.exe", "LogInServer.exe", "GameServer.exe") |
    ForEach-Object { Join-Path $binDir $_ }

$missing = $exes | Where-Object { -not (Test-Path $_) }
if ($missing) {
    Write-Host "Build reported success but these are missing:" -ForegroundColor Yellow
    $missing | ForEach-Object { Write-Host "  $_" }
    exit 1
}

Write-Host "Build OK:" -ForegroundColor Green
$exes | ForEach-Object { Write-Host "  $_" }

$dll = $Lib -replace "\.lib$", ".dll"
$dllPath = Join-Path $binDir $dll
if (-not (Test-Path $dllPath)) {
    $source = Join-Path $root "lib\$dll"
    if (Test-Path $source) {
        Copy-Item $source $dllPath
        Write-Host "Copied $dll next to the executables"
    } else {
        Write-Host "NOTE: $dll not found in $root\lib - it must be next to the .exe or on PATH to run." -ForegroundColor Yellow
    }
}
