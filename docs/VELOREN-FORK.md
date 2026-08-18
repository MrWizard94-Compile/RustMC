# RustMC Veloren fork surface

Upstream Veloren remains pinned at `vendor/veloren` (engine reference, GPL-3.0).

The **forked product API** for Minecraft-like durable block **place** / **break** is:

* Crate: `crates/rustmc-veloren-fork`
* Type: `VelorenForkWorld`
* Methods: `place_block`, `break_block`, `get_block`, `create` / `open` / `save`

Tests (`cargo test -p rustmc-veloren-fork`) drive that shipped API across world reopen.
