# MANIFEST — RustMC baseline and Constitution migration

The original bootstrap entries below are historical. The current adoption
package replaces the copied law with the canonical pointer and CI gate; the
product crates, submodule pins, and local-assets policy are unchanged.

**Repo:** https://github.com/MrWizard94-Compile/RustMC  
**Product root:** `RustMC/` (nested clean tree; not the WPAI empire worktree root)

## Changed / shipped paths

| Path | Role |
|------|------|
| `AGENTS.md`, `.github/workflows/constitution.yml` | Canonical pointer and pinned-source quality gate; the former 5.0.1 pack is retained in Git history |
| `scripts/check-constitution-adoption.py`, `scripts/test_check_constitution_adoption.py`, `docs/CONSTITUTION-MIGRATION.md` | Hash-locked historical-report disposition, fail-closed test, rollback, and evidence boundaries |
| `Cargo.toml`, `Cargo.lock` | Workspace for `rustmc-world` |
| `crates/rustmc-world/` | Durable block set/get + tests |
| `vendor/{pumpkin,leafish,veloren}` | Git submodules (pinned SHAs) |
| `.gitmodules` | Submodule URLs |
| `README.md` | Product overview + IP line |
| `docs/IP-POLICY.md` | No Mojang IP redistribution |
| `docs/ARCHITECTURE.md` | Dual-stack roles; ATM10 deferred |
| `docs/DELIVERY-REPORT.md` | Section 0 / REV-PACK delivery report |
| `config/local.minecraft.env.example` | Template for local asset paths |
| `scripts/Discover-LocalMinecraftAssets.ps1` | Find `%APPDATA%\.minecraft` → gitignored env |
| `scripts/Assert-LocalAssetsConfig.ps1` | Structural check (paths exist; not vendored) |
| `scripts/Invoke-LeafishWithLocalAssets.ps1` | Launch Leafish with `--assets-dir` etc. |
| `scripts/Build-Pumpkin.ps1` | Windows rust-lld Pumpkin build |
| `scripts/Build-Leafish.ps1` | Apply Leafish patch then cargo build |
| `scripts/Invoke-MinecraftStatusPing.ps1` | Live Java status/ping probe |
| `scripts/Apply-LeafishPatches.ps1` | Apply Windows Leafish zip-dir fix |
| `docs/PROJECT-OVERRIDE.md` | Approved vendor `ENG-WARN-001` waiver |
| `patches/leafish-windows-zip-dirs.patch` | Leafish AlreadyExists fix |
| `crates/rustmc-veloren-fork/` | Veloren fork block place/break API + tests |
| `docs/FAMILY-PLAY.md` | Family session play path |
| `.gitignore` | Ignores jars / official asset paths / local.env |

## How to verify

```powershell
cd RustMC
git remote -v   # origin -> https://github.com/MrWizard94-Compile/RustMC.git
# GitHub Actions: Verify RustMC and Constitution adoption (pinned source gate)
cargo +1.97.1 fmt --all -- --check
cargo +1.97.1 clippy --workspace --all-targets --locked -- -D warnings
cargo +1.97.1 test --workspace --locked
git submodule status                                     # three pins + LICENSE files under vendor/
```

## Suggested commits (already pushed)

1. `Bootstrap RustMC: constitution, upstreams, durable block store`
2. `docs: note recursive submodule init for Pumpkin WIT`
3. `docs: note Pumpkin recursive WIT and heavy launch-build cost`
