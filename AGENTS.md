# AGENTS — Project Entry Point (RustMC)

**Project:** RustMC  
**Pack:** AGENTS Constitution (universal)  
**Pack path (relative to this file):** `AGENTS Constitution/`  
**Pack version:** see `AGENTS Constitution/VERSION`

This file is **Level 4 project law entry only**. It does not duplicate the constitution.

---

## Binding pack

→ **Constitution (SOUL):** [`AGENTS Constitution/AGENTS.md`](AGENTS%20Constitution/AGENTS.md)  

→ **Process (SOP):** [`AGENTS Constitution/SOP.md`](AGENTS%20Constitution/SOP.md)  

→ **Adopt / move guide:** [`AGENTS Constitution/ADOPT.md`](AGENTS%20Constitution/ADOPT.md)  

→ **Pack identity:** [`AGENTS Constitution/PACK.md`](AGENTS%20Constitution/PACK.md)  

---

## Always load (via pack)

* Pack `AGENTS.md`  
* Pack `SOP.md`  
* Pack `constitution/03-DEFINITION-OF-DONE.md`  
* Pack `standards/ENGINEERING.md`  
* Pack `standards/TESTING.md`  
* Pack `standards/DOCUMENTATION.md`  

Then load pack modules per the applicability matrix in pack `AGENTS.md`.

---

## Project-local law (Level 4)

* Architecture: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)  
* IP / redistribution policy: [`docs/IP-POLICY.md`](docs/IP-POLICY.md)  
* Product README: [`README.md`](README.md)  

### Mission

Rebuild a Minecraft-*like* family play stack in Rust: Veloren as voxel RPG/engine reference, Pumpkin (server) + Leafish (client) for Minecraft-protocol compatibility, plus a durable RustMC block mutate API. Intended for family local play. **No Mojang/Minecraft assets or proprietary IP will be redistributed.**

### Stack pins (bootstrap)

| Component | Role | Location |
|-----------|------|----------|
| `rustmc-world` | Durable block set/get + reload | `crates/rustmc-world` |
| Pumpkin | MC protocol server (primary launch smoke) | `vendor/pumpkin` |
| Leafish | MC protocol client (secondary) | `vendor/leafish` |
| Veloren | Voxel RPG / engine reference (secondary) | `vendor/veloren` |

All The Mods 10 and Create:Aeronautics ports are **deferred** (see architecture note).

Project law may **tighten** standards. It may not weaken `CONST-*`, `ENG-WARN-001`, `TEST-BEHAVIOR-001`, or `SEC-INPUT-001` without a documented override.

---

## Verify pack (from pack root)

```powershell
pwsh -File "AGENTS Constitution/tools/verify-pack.ps1"
```

Must exit `0` after pack install, move, or update.
