[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$InputPath,

    [Parameter(Mandatory = $true)]
    [string]$OutputPath,

    [Parameter(Mandatory = $false)]
    [string]$ImplodeToolPath = "l5xplode"
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Write-Section {
    param([string]$Message)
    Write-Host ""
    Write-Host "=== $Message ==="
}

Write-Section "Implode exploded content to L5X"

if (-not (Test-Path -Path $InputPath -PathType Container)) {
    throw "InputPath is not a directory: $InputPath"
}

$resolvedInput = (Resolve-Path -Path $InputPath -ErrorAction Stop).Path
$outputPathFull = [System.IO.Path]::GetFullPath($OutputPath)
$outputDir = Split-Path -Path $outputPathFull -Parent

if (-not (Test-Path -Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

if (Test-Path -Path $outputPathFull -PathType Leaf) {
    Remove-Item -Path $outputPathFull -Force
}

Write-Host "InputPath      : $resolvedInput"
Write-Host "OutputPath     : $outputPathFull"
Write-Host "ImplodeToolPath: $ImplodeToolPath"

Write-Section "Run l5xplode implode"

& $ImplodeToolPath implode --dir $resolvedInput --l5x $outputPathFull

if ($LASTEXITCODE -ne 0) {
    throw "l5xplode implode failed with exit code $LASTEXITCODE"
}

if (-not (Test-Path -Path $outputPathFull -PathType Leaf)) {
    throw "Implode step did not create expected output file: $outputPathFull"
}

Write-Section "Done"
Write-Host "Created L5X: $outputPathFull"