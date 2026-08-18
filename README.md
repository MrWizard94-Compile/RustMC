# RustMC

Family Minecraft-*like* play stack in **Rust**, built for local co-op (parents + kids).

**No Mojang/Minecraft assets or proprietary IP will be redistributed.**

## What this repo is (bootstrap)

1. **AGENTS Constitution** adopted (quality/process law) — see `AGENTS.md`  
2. Open-source upstreams pinned as git submodules under `vendor/`:  
   - [Veloren](https://veloren.net/) — voxel RPG / engine reference  
   - [Pumpkin](https://github.com/Pumpkin-MC/Pumpkin) — Minecraft-protocol server  
   - [Leafish](https://github.com/Lea-fish/Leafish) — Minecraft-protocol client  
3. **`rustmc-world`** — durable voxel block **set + get** (place/break) that survives world reload  

All The Mods 10 / Create:Aeronautics ports are **deferred** (see `docs/ARCHITECTURE.md`).

## Quick start

```powershell
# Constitution pack integrity
pwsh -File "AGENTS Constitution/tools/verify-pack.ps1"

# Durable block API tests
cargo test -p rustmc-world

# Primary launch smoke (Pumpkin help / server binary when built)
cargo --manifest-path vendor/pumpkin/Cargo.toml --version
# After building Pumpkin per its README, run its documented server entry.
```

Clone with submodules (recursive — Pumpkin nests `pumpkin-plugin-wit`):

```powershell
git clone --recurse-submodules https://github.com/MrWizard94-Compile/RustMC.git
# or, after a plain clone:
git submodule update --init --recursive
```

## Layout

| Path | Purpose |
|------|---------|
| `AGENTS.md` | Level-4 pointer into the constitution pack |
| `AGENTS Constitution/` | Vendored universal quality/process pack |
| `crates/rustmc-world/` | Durable block store + tests |
| `vendor/pumpkin/` | Upstream Pumpkin (submodule) |
| `vendor/leafish/` | Upstream Leafish (submodule) |
| `vendor/veloren/` | Upstream Veloren (submodule) |
| `docs/ARCHITECTURE.md` | How the stacks relate; deferred work |
| `docs/IP-POLICY.md` | No Mojang IP redistribution |

## License

RustMC original code: MIT OR Apache-2.0. Upstream trees keep their own licenses (see each `vendor/*/LICENSE*`).
