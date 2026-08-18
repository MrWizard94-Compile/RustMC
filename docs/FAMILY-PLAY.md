# RustMC — Family play path (local LAN)

**Audience:** You and your kids on this PC / home LAN  
**IP:** **No Mojang/Minecraft assets or proprietary IP will be redistributed** via git or releases. Local reuse of your already-owned install only (`docs/IP-POLICY.md`).

## What you play with

| Path | Role |
|------|------|
| **Pumpkin** (`vendor/pumpkin`) | Rust Minecraft-protocol **server** (primary session) |
| **Leafish** (`vendor/leafish`) | Rust client using **local** `.minecraft` assets |
| **Vanilla / launcher client** | Also fine — point at `127.0.0.1:25565` |
| **Veloren fork surface** (`crates/rustmc-veloren-fork`) | Durable Minecraft-like block place/break API (engine reference: `vendor/veloren`) |

## Session A — Pumpkin + Leafish (or vanilla)

1. Discover local assets (once per machine):

```powershell
pwsh -File scripts/Discover-LocalMinecraftAssets.ps1
pwsh -File scripts/Assert-LocalAssetsConfig.ps1
```

2. **Build Pumpkin with rust-lld** (required on Windows — bare `cargo run` hits MSVC LNK1120):

```powershell
pwsh -File scripts/Build-Pumpkin.ps1 -Release
# Binary: vendor/pumpkin/target/release/pumpkin.exe
```

3. Start the server (from a dedicated world directory):

```powershell
mkdir worlds\family -Force
cd worlds\family
..\..\vendor\pumpkin\target\release\pumpkin.exe
# Listens on 0.0.0.0:25565 by default
```

4. Prove the server:

```powershell
pwsh -File scripts/Invoke-MinecraftStatusPing.ps1 -HostName 127.0.0.1 -Port 25565
```

5. Connect:
   - **Leafish (build applies Windows patch, then compiles, then launches):**

```powershell
pwsh -File scripts/Build-Leafish.ps1 -Release
pwsh -File scripts/Invoke-LeafishWithLocalAssets.ps1 -Release
# Join 127.0.0.1 in the server list
```

   - **Vanilla client:** Multiplayer → Direct connect → `127.0.0.1:25565`

## Session B — Veloren fork block mutate (dev / tests)

```powershell
cargo test -p rustmc-veloren-fork
```

This exercises the shipped fork API (`place_block` / `break_block` / `get_block`) across world reload — the Minecraft-like mutate seed on the Veloren track.

## Do not

* Commit `%APPDATA%\.minecraft`, jars, `assets/objects`, or CurseForge ATM10 folders into this repo  
* Upload Mojang assets to GitHub releases  
* Use bare `cargo run -p pumpkin --release` on Windows without `Build-Pumpkin.ps1` (LNK1120)  
