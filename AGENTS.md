# AGENTS — Project Entry Point (RustMC)

**Project:** RustMC  
**Cross-project law:** [WPAI Constitution](https://github.com/MrWizard94-Compile/Agents-Constitution) accepted `main`

**Verified CI source:** `5a990520d53969bb90b72a886bbc62cb7f1b63aa` (6.3.1)

This file is **Level 4 project law entry only**. It does not duplicate the constitution.

---

## Binding source

The accepted GitHub repository is the sole editable cross-project law. Freeze
and validate one commit per agent invocation; load its `SKILL.md`, `AGENTS.md`,
`SOP.md`, `governance/EVOLUTION.md`, and applicable `law/*` files from that same
snapshot. This project file supplies RustMC facts and may tighten, but cannot
silently replace, the canonical Constitution. The removed vendored 5.0.1 pack
is recoverable from RustMC Git history before this migration.

---

## Project-local law (Level 4)

* Architecture: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)  
* IP / redistribution policy: [`docs/IP-POLICY.md`](docs/IP-POLICY.md)  
* Family play path: [`docs/FAMILY-PLAY.md`](docs/FAMILY-PLAY.md)  
* Approved override (vendor `ENG-WARN-001` only): [`docs/PROJECT-OVERRIDE.md`](docs/PROJECT-OVERRIDE.md)  
* Product README: [`README.md`](README.md)  

### Mission

Rebuild a Minecraft-*like* family play stack in Rust: Veloren as voxel RPG/engine reference, Pumpkin (server) + Leafish (client) for Minecraft-protocol compatibility, plus a durable RustMC block mutate API. Intended for family local play. **Local reuse of an already-owned Minecraft install on this PC is allowed; no Mojang/Minecraft assets or proprietary IP will be redistributed** (see `docs/IP-POLICY.md`, `scripts/Discover-LocalMinecraftAssets.ps1`).

### Stack pins (bootstrap)

| Component | Role | Location |
|-----------|------|----------|
| `rustmc-world` | Durable block set/get + reload | `crates/rustmc-world` |
| Pumpkin | MC protocol server (primary launch smoke) | `vendor/pumpkin` |
| Leafish | MC protocol client (secondary) | `vendor/leafish` |
| Veloren | Voxel RPG / engine reference (secondary) | `vendor/veloren` |

All The Mods 10 and Create:Aeronautics ports are **deferred** (see architecture note).

Project law may **tighten** standards. The existing vendor-only `ENG-WARN-001`
exception remains limited by `docs/PROJECT-OVERRIDE.md`; this migration does
not expand its scope or certify a warning-clean vendor build.

---

## Verify adoption

The [pinned CI workflow](.github/workflows/constitution.yml) validates the
exact canonical source, runs the read-only adoption audit with a hash-locked
historical-report disposition, and tests the Rust workspace. For local
product-crate verification, run from the repository root:

```powershell
cargo +1.97.1 fmt --all -- --check
cargo +1.97.1 clippy --workspace --all-targets --locked -- -D warnings
cargo +1.97.1 test --workspace --locked
```
