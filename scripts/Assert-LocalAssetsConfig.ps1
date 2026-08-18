<#
.SYNOPSIS
  Structural check: local Minecraft asset config resolves on this machine.
  Does not read or copy proprietary asset bytes into the repo.
#>
[CmdletBinding()]
param(
    [string]$EnvFile = ""
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
if (-not $EnvFile) {
    $EnvFile = Join-Path $repoRoot "config\local.minecraft.env"
}

if (-not (Test-Path $EnvFile)) {
    & (Join-Path $PSScriptRoot "Discover-LocalMinecraftAssets.ps1") -OutFile $EnvFile
}

$map = @{}
Get-Content $EnvFile | ForEach-Object {
    if ($_ -match '^\s*#' -or $_ -match '^\s*$') { return }
    if ($_ -match '^(?<k>[^=]+)=(?<v>.*)$') { $map[$Matches.k] = $Matches.v }
}

$required = @("MINECRAFT_DIR", "MINECRAFT_ASSETS_DIR", "MINECRAFT_ASSET_INDEX")
foreach ($k in $required) {
    if (-not $map.ContainsKey($k) -or [string]::IsNullOrWhiteSpace($map[$k])) {
        throw "Missing $k in $EnvFile"
    }
}

$assets = $map["MINECRAFT_ASSETS_DIR"]
$indexPath = Join-Path $assets "indexes\$($map['MINECRAFT_ASSET_INDEX']).json"
if (-not (Test-Path $assets)) { throw "Assets dir missing: $assets" }
if (-not (Test-Path $indexPath)) { throw "Asset index missing: $indexPath" }

$objects = Join-Path $assets "objects"
$count = (Get-ChildItem $objects -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count
if ($count -lt 1) { throw "No object files under $objects" }

# Ensure we did not vendore assets into the product tree for redistribution
$bad = @(
    (Join-Path $repoRoot "assets\minecraft"),
    (Join-Path $repoRoot "minecraft-assets"),
    (Join-Path $repoRoot "config\objects")
) | Where-Object { Test-Path $_ }
if ($bad) {
    throw "Refuse: proprietary-looking trees present in repo: $($bad -join ', ')"
}

Write-Host "PASS local assets config"
Write-Host "  index=$($map['MINECRAFT_ASSET_INDEX']) objects=$count"
Write-Host "  path=$assets"
Write-Host "  env_file=$EnvFile (gitignored)"
exit 0
