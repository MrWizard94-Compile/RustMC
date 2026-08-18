<#
.SYNOPSIS
  Build Pumpkin on Windows using rust-lld (avoids MSVC LNK1120 on this tree).
#>
[CmdletBinding()]
param([switch]$Release)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location (Join-Path $repoRoot "vendor\pumpkin")

if (-not (Test-Path "crates\pumpkin-plugin-wit\v0.1")) {
    git submodule update --init --recursive
}

$lld = Join-Path $env:USERPROFILE ".rustup\toolchains\stable-x86_64-pc-windows-msvc\lib\rustlib\x86_64-pc-windows-msvc\bin\rust-lld.exe"
if (-not (Test-Path $lld)) {
    $lld = Get-ChildItem (Join-Path $env:USERPROFILE ".rustup\toolchains") -Recurse -Filter "rust-lld.exe" |
        Select-Object -First 1 -ExpandProperty FullName
}
if (-not $lld) { throw "rust-lld.exe not found under ~/.rustup/toolchains" }

New-Item -ItemType Directory -Force -Path ".cargo" | Out-Null
@"
[target.x86_64-pc-windows-msvc]
linker = "rust-lld"
"@ | Set-Content -Encoding utf8 ".cargo\config.toml"

$env:CARGO_INCREMENTAL = "0"
$env:CARGO_TERM_COLOR = "never"
$env:RUSTFLAGS = "-C linker=$lld"

if ($Release) {
    cargo build -p pumpkin --release
} else {
    cargo build -p pumpkin
}
exit $LASTEXITCODE
