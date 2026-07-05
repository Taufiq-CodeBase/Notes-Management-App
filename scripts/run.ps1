param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('web', 'android', 'ios', 'macos', 'windows', 'linux')]
    [string]$Target,

    [string]$EnvFile = ".env"
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

if (-not (Test-Path $EnvFile)) {
    Write-Error "Missing '$EnvFile'. Copy '.env.example' to '$EnvFile' and fill in your values."
}

$args = @('run', "--dart-define-from-file=$EnvFile", '-d', $Target)
& flutter @args
