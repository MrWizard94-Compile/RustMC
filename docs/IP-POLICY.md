# RustMC — IP and Redistribution Policy

**Status:** Binding project law (Level 4)  
**Audience:** Contributors and agents

## Non-negotiable

**No Mojang/Minecraft assets or proprietary IP will be redistributed.**

This project does **not** ship, commit, or redistribute:

* Official Minecraft client or server jars  
* Official Minecraft asset packs (`assets/minecraft` from Mojang distributions)  
* Mojang/Microsoft proprietary textures, sounds, models, or other game assets  
* Any other Mojang/Minecraft proprietary intellectual property

Players who use a Minecraft-compatible client/server stack must obtain any required official assets **themselves** through legitimate Mojang/Microsoft channels. This repository only hosts original RustMC code and **open-source** upstream checkouts (Veloren, Pumpkin, Leafish) under their respective licenses.

## What we do redistribute

* Original RustMC source (MIT OR Apache-2.0 unless a file says otherwise)  
* Vendored AGENTS Constitution pack (its own license/terms inside that tree)  
* Git submodules / pins of open-source upstreams **with their upstream LICENSE files**  
* Documentation describing how to build and run without bundling proprietary assets

## Attribution

Upstream projects remain attributed via submodule history and their LICENSE files under `vendor/`.
