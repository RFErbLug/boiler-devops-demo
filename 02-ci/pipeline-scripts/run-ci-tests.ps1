[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$AcdPath,

    [Parameter(Mandatory = $true)]
    [string]$SolutionPath,

    [Parameter(Mandatory = $false)]
    [string]$Configuration = "Release",

    [Parameter(Mandatory = $false)]
    [switch]$RequireAcd
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Write-Section {
    param([string]$Message)
    Write-Host ""
    Write-Host "=== $Message ==="
}

Write-Section "Run CI tests"

$resolvedSolution = Resolve-Path -Path $SolutionPath -ErrorAction Stop
$solutionDir = Split-Path -Path $resolvedSolution -Parent
$consoleProject = Join-Path $solutionDir 'UnitTesting_ConsoleApp\UnitTesting_ConsoleApp.csproj'

if (-not (Test-Path -Path $consoleProject)) {
    throw "Console app project not found: $consoleProject"
}

$acdExists = Test-Path -Path $AcdPath

Write-Host "AcdPath         : $AcdPath"
Write-Host "AcdExists       : $acdExists"
Write-Host "RequireAcd      : $RequireAcd"
Write-Host "SolutionPath    : $resolvedSolution"
Write-Host "ConsoleProject  : $consoleProject"
Write-Host "Configuration   : $Configuration"

Write-Section "Restore"
dotnet restore $resolvedSolution
if ($LASTEXITCODE -ne 0) {
    throw "dotnet restore failed with exit code $LASTEXITCODE"
}

Write-Section "Build"
dotnet build $resolvedSolution -c $Configuration --no-restore
if ($LASTEXITCODE -ne 0) {
    throw "dotnet build failed with exit code $LASTEXITCODE"
}

if (-not $acdExists) {
    if ($RequireAcd) {
        throw "Required ACD file not found: $AcdPath"
    }

    Write-Section "Skip test execution"
    Write-Host "ACD file does not exist yet, so the harness build was verified but execution was skipped."
    exit 0
}

$resolvedAcd = Resolve-Path -Path $AcdPath -ErrorAction Stop

Write-Section "Run test harness"
dotnet run --project $consoleProject -c $Configuration -- $resolvedAcd
if ($LASTEXITCODE -ne 0) {
    throw "Test harness failed with exit code $LASTEXITCODE"
}

Write-Section "Done"
Write-Host "CI tests completed successfully."