# Delivery Report — Playable Pumpkin + Leafish + Veloren fork

**Date:** 2026-08-18  
**One-sentence summary:** Pumpkin server builds (rust-lld), runs on `:25565`, and status-pings; Leafish builds and launches with local Minecraft assets; Veloren-fork crate provides durable block place/break tests.

## Section 0 (`CONST-GATE-001`)

| # | Check | Score |
|---|-------|-------|
| 1 | Completeness | PASS |
| 2 | Dependency-first | PASS |
| 3 | Zero warnings/errors | PASS for `crates/**`; vendor Pumpkin/Leafish warnings **waived** via approved [`PROJECT-OVERRIDE.md`](PROJECT-OVERRIDE.md) (`ENG-WARN-001`, `GOV-OVR-001`) — not a silent PASS |
| 4 | Tests exist & pass | PASS (`rustmc-veloren-fork`, `rustmc-world`) |
| 5 | Docs synchronized | PASS (`FAMILY-PLAY.md`, IP policy) |
| 6 | Security & validation | PASS (local assets gitignored; ping validates JSON) |
| 7 | Performance reasoning | PASS (headless ping; rust-lld link) |
| 8 | Version/stack fidelity | PASS |
| 9 | Full package ready | PASS |
| 10 | Resource & constraint | PASS (local asset reuse; no redistribute) |
| 11 | Reproducibility | PASS (Build-Pumpkin.ps1, patches) |
| 12 | IP hygiene | PASS — **no Mojang/Minecraft assets or proprietary IP will be redistributed** |
| 13 | Multi-agent | N/A |
| 14 | Review packaging | PASS |
| 15 | Self-audit log | PASS (this file) |

## Rule IDs

`CONST-GATE-001`, `CONST-DONE-001`, `CONST-COMPLETE-001`, `ENG-WARN-001` (product crates), `TEST-BEHAVIOR-001`, `DOC-SYNC-001`, `REV-PACK-001`, `GOV-INT-001`

## How to verify

```powershell
pwsh -File "AGENTS Constitution/tools/verify-pack.ps1"   # 0
pwsh -File scripts/Build-Pumpkin.ps1 -Release
# run vendor/pumpkin/target/release/pumpkin.exe; then:
pwsh -File scripts/Invoke-MinecraftStatusPing.ps1 -HostName 127.0.0.1 -Port 25565
pwsh -File scripts/Build-Leafish.ps1 -Release   # Apply-LeafishPatches THEN cargo build
pwsh -File scripts/Assert-LocalAssetsConfig.ps1
pwsh -File scripts/Invoke-LeafishWithLocalAssets.ps1 -Release
cargo test -p rustmc-veloren-fork
```

## Suggested commit

```
feat: playable Pumpkin server, Leafish launch, Veloren fork blocks
```
