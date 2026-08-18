<#
.SYNOPSIS
  Apply RustMC Leafish patches (Windows zip directory AlreadyExists fix).
#>
[CmdletBinding()]
param()
$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$leafish = Join-Path $repoRoot "vendor\leafish"
$patch = Join-Path $repoRoot "patches\leafish-windows-zip-dirs.patch"
if (-not (Test-Path $patch)) { throw "Missing $patch" }
Set-Location $leafish
git apply --check $patch 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Patch already applied or not applicable (ok if resources.rs already fixed)"
    exit 0
}
git apply $patch
Write-Host "Applied $patch"
exit 0
