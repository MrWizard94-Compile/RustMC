<#
.SYNOPSIS
  Run Leafish using this PC's Minecraft assets (from config/local.minecraft.env).

.DESCRIPTION
  Applies the Windows zip-dir patch, rebuilds Leafish when source is newer than the
  binary (so the patch reaches the exe), then launches with local assets.
  Does not copy Mojang assets into the repo.
#>
[CmdletBinding()]
param(
    [string]$EnvFile = "",
    [string[]]$ExtraArgs = @(),
    [switch]$Release
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot

if (-not $EnvFile) {
    $EnvFile = Join-Path $repoRoot "config\local.minecraft.env"
}

if (-not (Test-Path $EnvFile)) {
    Write-Host "No $EnvFile — discovering..."
    & (Join-Path $PSScriptRoot "Discover-LocalMinecraftAssets.ps1")
}

Get-Content $EnvFile | ForEach-Object {
    if ($_ -match '^\s*#' -or $_ -match '^\s*$') { return }
    if ($_ -match '^(?<k>[^=]+)=(?<v>.*)$') {
        Set-Item -Path "Env:$($Matches.k)" -Value $Matches.v
    }
}

foreach ($req in @("MINECRAFT_ASSETS_DIR", "MINECRAFT_ASSET_INDEX")) {
    if (-not (Test-Path "Env:$req") -or -not (Get-Item "Env:$req").Value) {
        throw "Missing $req in $EnvFile"
    }
}
if (-not (Test-Path $env:MINECRAFT_ASSETS_DIR)) {
    throw "Assets dir missing: $env:MINECRAFT_ASSETS_DIR"
}

$profile = if ($Release) { "release" } else { "debug" }
$exe = Join-Path $repoRoot "vendor\leafish\target\$profile\leafish.exe"
$resourcesRs = Join-Path $repoRoot "vendor\leafish\src\resources.rs"

# Always apply patch first; rebuild if binary missing or older than patched source.
& (Join-Path $PSScriptRoot "Apply-LeafishPatches.ps1")
$needBuild = -not (Test-Path $exe)
if (-not $needBuild -and (Test-Path $resourcesRs)) {
    if ((Get-Item $resourcesRs).LastWriteTimeUtc -gt (Get-Item $exe).LastWriteTimeUtc) {
        $needBuild = $true
    }
}
if ($needBuild) {
    Write-Host "Building Leafish ($profile) so patched resources.rs is in the binary..."
    if ($Release) {
        & (Join-Path $PSScriptRoot "Build-Leafish.ps1") -Release
    } else {
        & (Join-Path $PSScriptRoot "Build-Leafish.ps1")
    }
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

if (-not (Test-Path $exe)) {
    throw "Leafish binary still missing at $exe after build"
}

$launchArgs = @(
    "--assets-dir", $env:MINECRAFT_ASSETS_DIR,
    "--asset-index", $env:MINECRAFT_ASSET_INDEX
)
if ($env:MINECRAFT_CLIENT_JAR -and (Test-Path $env:MINECRAFT_CLIENT_JAR)) {
    $launchArgs += @("--client-jar", $env:MINECRAFT_CLIENT_JAR)
}
$launchArgs += $ExtraArgs

Write-Host "Starting Leafish with local assets (not copied into git):"
Write-Host "  $exe $($launchArgs -join ' ')"
& $exe @launchArgs
exit $LASTEXITCODE
