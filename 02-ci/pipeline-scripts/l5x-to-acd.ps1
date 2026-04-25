[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$InputPath,

    [Parameter(Mandatory = $true)]
    [string]$OutputPath,

    [Parameter(Mandatory = $false)]
    [string]$ConverterToolPath = "l5xgit"
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Write-Section {
    param([string]$Message)
    Write-Host ""
    Write-Host "=== $Message ==="
}

Write-Section "Convert L5X to ACD"

if (-not (Test-Path -Path $InputPath -PathType Leaf)) {
    throw "InputPath is not a file: $InputPath"
}

$resolvedInput = (Resolve-Path -Path $InputPath -ErrorAction Stop).Path
$outputPathFull = [System.IO.Path]::GetFullPath($OutputPath)
$outputDir = Split-Path -Path $outputPathFull -Parent

if (-not (Test-Path -Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}


Write-Host "InputPath         : $resolvedInput"
Write-Host "OutputPath        : $outputPathFull"
Write-Host "ConverterToolPath : $ConverterToolPath"

Write-Section "Run l5xgit l5x2acd"

& $ConverterToolPath l5x2acd --l5x $resolvedInput --acd $outputPathFull

if ($LASTEXITCODE -ne 0) {
    throw "l5xgit l5x2acd failed with exit code $LASTEXITCODE"
}

if (-not (Test-Path -Path $outputPathFull -PathType Leaf)) {
    throw "L5X to ACD conversion did not create expected output file: $outputPathFull"
}

Write-Section "Done"
Write-Host "Created ACD: $outputPathFull"