<#
.SYNOPSIS
  Run Leafish using this PC's Minecraft assets (from config/local.minecraft.env).

.DESCRIPTION
  Does not copy assets into the repo. Requires Leafish to be built first:
    cargo build --manifest-path vendor/leafish/Cargo.toml --release
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
if (-not (Test-Path $exe)) {
    throw "Leafish binary not found at $exe — build it first (cargo build -p leafish in vendor/leafish)"
}

$args = @(
    "--assets-dir", $env:MINECRAFT_ASSETS_DIR,
    "--asset-index", $env:MINECRAFT_ASSET_INDEX
)
if ($env:MINECRAFT_CLIENT_JAR -and (Test-Path $env:MINECRAFT_CLIENT_JAR)) {
    $args += @("--client-jar", $env:MINECRAFT_CLIENT_JAR)
}
$args += $ExtraArgs

Write-Host "Starting Leafish with local assets (not copied into git):"
Write-Host "  $exe $($args -join ' ')"
& $exe @args
exit $LASTEXITCODE
