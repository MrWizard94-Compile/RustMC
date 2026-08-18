# RustMC — IP and Redistribution Policy

**Status:** Binding project law (Level 4)  
**Audience:** Contributors and agents

## Non-negotiable (redistribution)

**No Mojang/Minecraft assets or proprietary IP will be redistributed.**

This project does **not** ship, commit, push, or otherwise redistribute:

* Official Minecraft client or server jars  
* Official Minecraft asset packs / object stores (`assets/objects`, `assets/indexes`, `assets/minecraft` from Mojang distributions)  
* Mojang/Microsoft proprietary textures, sounds, models, or other game assets  
* CurseForge / modpack proprietary content as part of the RustMC git remote  
* Any other Mojang/Minecraft proprietary intellectual property

The public GitHub tree hosts only original RustMC code and **open-source** upstream checkouts (Veloren, Pumpkin, Leafish) under their licenses.

## Local / family use on this machine (allowed)

For **private play on a machine that already has a legitimate Minecraft install** (parents + kids):

* RustMC **may point at** the existing `%APPDATA%\.minecraft` (or equivalent) assets, indexes, and client jar **in place**  
* Launch helpers under `scripts/` write **gitignored** `config/local.minecraft.env` with absolute local paths  
* Assets stay on disk under the Mojang/Microsoft launcher (or CurseForge instance) directories — they are **not** copied into the RustMC repository  

This is **reuse of files you already have**, not redistribution. Do not zip those trees into releases, PRs, or the GitHub remote.

## How agents must behave

1. Prefer `scripts/Discover-LocalMinecraftAssets.ps1` over copying assets  
2. Keep `config/local.minecraft.env` gitignored  
3. Never `git add` jars, `assets/objects`, or ATM10 instance folders  
4. Document player-side obtainment for anyone without an install  

## What we do redistribute

* Original RustMC source (MIT OR Apache-2.0 unless a file says otherwise)  
* Vendored AGENTS Constitution pack  
* Git submodules / pins of open-source upstreams **with their upstream LICENSE files**  
* Docs and scripts that **reference** local asset paths without embedding the assets  

## Attribution

Upstream projects remain attributed via submodule history and their LICENSE files under `vendor/`.
