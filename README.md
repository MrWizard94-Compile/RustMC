# RustMC

Family Minecraft-*like* play stack in **Rust**, built for local co-op (parents + kids).

**No Mojang/Minecraft assets or proprietary IP will be redistributed.**

## What this repo is

**RustMC** is a family Minecraft-*like* stack in Rust:

1. **Pumpkin** server — build with `scripts/Build-Pumpkin.ps1 -Release`, listen on `0.0.0.0:25565`  
2. **Leafish** client — uses your local `.minecraft` assets (not copied into git)  
3. **Veloren fork surface** (`crates/rustmc-veloren-fork`) — durable block place/break API  
4. **AGENTS Constitution** — quality/process law (`AGENTS.md`)

Family session steps: [`docs/FAMILY-PLAY.md`](docs/FAMILY-PLAY.md).  
**No Mojang/Minecraft assets or proprietary IP will be redistributed.**

All The Mods 10 / Create:Aeronautics ports remain deferred (see `docs/ARCHITECTURE.md`).

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

## Local Minecraft assets (family machine)

This PC may already have a legitimate Minecraft install. **Reuse those assets in place** for Leafish — do **not** copy them into git.

```powershell
# Writes gitignored config/local.minecraft.env pointing at %APPDATA%\.minecraft
pwsh -File scripts/Discover-LocalMinecraftAssets.ps1

# Structural check (paths resolve; nothing vendored into the repo)
pwsh -File scripts/Assert-LocalAssetsConfig.ps1

# After Leafish is built:
#   cargo build --manifest-path vendor/leafish/Cargo.toml --release
pwsh -File scripts/Invoke-LeafishWithLocalAssets.ps1 -Release
```

Policy: [`docs/IP-POLICY.md`](docs/IP-POLICY.md) — local reuse OK; **no redistribution** to the GitHub remote.

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
