<#
.SYNOPSIS
  Apply RustMC Leafish patches, then build the Leafish binary (patch before compile).
#>
[CmdletBinding()]
param([switch]$Release)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
& (Join-Path $PSScriptRoot "Apply-LeafishPatches.ps1")

Set-Location (Join-Path $repoRoot "vendor\leafish")
$env:CARGO_TERM_COLOR = "never"
Remove-Item Env:RUSTFLAGS -ErrorAction SilentlyContinue

if ($Release) {
    cargo build -p leafish --release
} else {
    cargo build -p leafish
}
exit $LASTEXITCODE
