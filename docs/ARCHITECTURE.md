# RustMC Architecture (Bootstrap)

**Status:** Living Level-4 note for the family Minecraft-*like* Rust rebuild  
**Scope of this delivery:** git + constitution + three upstream pins + durable block mutate seed

## Dual-stack reality

The product goal names **two** complementary open-source foundations:

| Stack | Upstream | Role in this bootstrap |
|-------|----------|------------------------|
| Voxel RPG / engine | **Veloren** (`vendor/veloren`) | Present as the high-performance voxel world/engine reference. Secondary for launch smoke here (GPU/display heavy). Future work may grow Minecraft-like building/automation on this base. |
| Minecraft network protocol | **Pumpkin** (server) + **Leafish** (client) under `vendor/` | Present for vanilla-compatible protocol work. **Pumpkin is the intended primary headless launch smoke** (status/ping or CLI `--help`). Full `pumpkin` release builds pull wasmtime + generated `pumpkin-data` and may exceed CI/agent time/memory budgets; use `git submodule update --init --recursive` (nested `pumpkin-plugin-wit`) before building. Leafish is present but secondary (client/GPU/display). |

These are different architectures. This bootstrap requires **all three sources present**, one **durable block set/get API** (`crates/rustmc-world`), and one launch smoke — **not** a finished merge of both stacks.

## Durable block mutate (`rustmc-world`)

`WorldStore` is a sparse on-disk voxel map (`blocks.json`) with:

* `set_block` / `break_block` — place/break equivalent  
* `get_block` — query (air = `0`)  
* `create` / `open` / `save` — persistence across process reload  

It does **not** link Veloren or Pumpkin yet. It is the testable world-store boundary so Minecraft-like mutate can be proven without GPU or network.

## Deferred (explicitly out of this bootstrap)

* Porting **All The Mods 10** or **Create:Aeronautics** (and add-ons) into Rust — multi-year Java/NeoForge ecosystem work; names retained for later planning only  
* Full Minecraft parity (survival, crafting, mobs, dimensions, redstone, …)  
* Expanding Pumpkin into a complete custom Rust modding API platform  
* Family-ready polished multiplayer session / Veloren “feels like Minecraft” overhaul beyond the block-mutate seed

## Licensing note

Veloren is **GPL-3.0**. Any future tight linking/forking with other components must stay license-compatible; this bootstrap keeps Veloren as a vendored submodule reference and does not statically link it into `rustmc-world`.

## Local assets (family PC)

On a machine with an existing Minecraft install, `scripts/Discover-LocalMinecraftAssets.ps1` writes gitignored `config/local.minecraft.env` (assets dir, asset index, client jar, optional CurseForge ATM10 path). Leafish is launched via `scripts/Invoke-LeafishWithLocalAssets.ps1` with `--assets-dir` / `--asset-index` / `--client-jar`. Assets remain outside the git tree.

## IP

See [`IP-POLICY.md`](IP-POLICY.md): local reuse of an already-owned install is allowed for family play; **no Mojang/Minecraft assets or proprietary IP will be redistributed** via git or releases.
