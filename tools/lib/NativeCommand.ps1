# ---------------------------------------------------------------------------
#  NativeCommand.ps1 - run an external program without its stderr ending the run.
#
#  Windows PowerShell 5.1 turns every line a native program writes to stderr
#  into a PowerShell error record.  When that output is redirected (`2>$null`,
#  `2>&1`) and $ErrorActionPreference is "Stop" - which every script in tools\
#  sets - PowerShell treats it as a terminating error and the script dies, even
#  though the program succeeded.
#
#  That is exactly what stopped the database probe:
#
#      docker : mysql: [Warning] Using a password on the command line interface
#      can be insecure.
#          + CategoryInfo : NotSpecified: (...) [RemoteException], RemoteException
#          + FullyQualifiedErrorId : NativeCommandError
#
#  The client is warning about the throwaway local password; its exit code is 0.
#
#  Invoke-Native therefore captures stdout and stderr separately, keeps the real
#  exit code, and never throws.  The caller decides whether a non-zero exit is
#  fatal.  stderr is still available, because that is where mysql reports real
#  failures (ERROR 1045, ERROR 2002, ...).
# ---------------------------------------------------------------------------

function Invoke-Native {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string] $FilePath,

        [string[]] $ArgumentList = @(),

        # Extra environment variables for this call only, e.g. MYSQL_PWD.
        [hashtable] $Environment = @{},

        # Show what the program printed, as it would have been shown before.
        [switch] $Echo
    )

    $savedEnvironment = @{}
    foreach ($name in $Environment.Keys) {
        $savedEnvironment[$name] = [Environment]::GetEnvironmentVariable($name)
        [Environment]::SetEnvironmentVariable($name, [string] $Environment[$name])
    }

    # "Continue" in this function's scope only: a native command's stderr becomes
    # a non-terminating error record instead of aborting the script.
    $previousErrorAction = $ErrorActionPreference
    $ErrorActionPreference = "Continue"

    try {
        $captured = & $FilePath @ArgumentList 2>&1 | ForEach-Object {
            if ($_ -is [System.Management.Automation.ErrorRecord]) {
                [pscustomobject]@{ Stream = "error"; Line = $_.ToString() }
            }
            else {
                [pscustomobject]@{ Stream = "output"; Line = "$_" }
            }
        }
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousErrorAction
        foreach ($name in $savedEnvironment.Keys) {
            [Environment]::SetEnvironmentVariable($name, $savedEnvironment[$name])
        }
    }

    $all = @($captured)
    $standardOutput = @($all | Where-Object { $_.Stream -eq "output" } | ForEach-Object { $_.Line })
    $standardError = @($all | Where-Object { $_.Stream -eq "error" } | ForEach-Object { $_.Line })

    if ($Echo) {
        foreach ($line in $standardOutput) { Write-Host $line }
        foreach ($line in $standardError) { Write-Host $line }
    }

    return [pscustomobject]@{
        ExitCode = $exitCode
        StdOut   = ($standardOutput -join [Environment]::NewLine)
        StdErr   = ($standardError -join [Environment]::NewLine)
        Text     = (($standardOutput + $standardError) -join [Environment]::NewLine)
    }
}

# mysql prints this on every call that uses -p<password>.  It is informational.
function Get-MySqlStderrText {
    param([string] $StandardError)

    $lines = @($StandardError -split "`r?`n" | Where-Object {
        $_ -and $_ -notmatch "Using a password on the command line interface can be insecure"
    })

    return ($lines -join [Environment]::NewLine)
}
