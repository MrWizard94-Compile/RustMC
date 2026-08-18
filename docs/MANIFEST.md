# MANIFEST — RustMC bootstrap delivery

**Repo:** https://github.com/MrWizard94-Compile/RustMC  
**Product root:** `RustMC/` (nested clean tree; not the WPAI empire worktree root)

## Changed / shipped paths

| Path | Role |
|------|------|
| `AGENTS.md` | Level-4 constitution pointer |
| `AGENTS Constitution/` | Vendored pack 5.0.1 |
| `Cargo.toml`, `Cargo.lock` | Workspace for `rustmc-world` |
| `crates/rustmc-world/` | Durable block set/get + tests |
| `vendor/{pumpkin,leafish,veloren}` | Git submodules (pinned SHAs) |
| `.gitmodules` | Submodule URLs |
| `README.md` | Product overview + IP line |
| `docs/IP-POLICY.md` | No Mojang IP redistribution |
| `docs/ARCHITECTURE.md` | Dual-stack roles; ATM10 deferred |
| `.gitignore` | Ignores jars / official asset paths |

## How to verify

```powershell
cd RustMC
git remote -v   # origin -> https://github.com/MrWizard94-Compile/RustMC.git
pwsh -File "AGENTS Constitution/tools/verify-pack.ps1"   # exit 0
cargo test -p rustmc-world                               # 3 tests pass
git submodule status                                     # three pins + LICENSE files under vendor/
```

## Suggested commits (already pushed)

1. `Bootstrap RustMC: constitution, upstreams, durable block store`
2. `docs: note recursive submodule init for Pumpkin WIT`
3. `docs: note Pumpkin recursive WIT and heavy launch-build cost`
