# Project Override / Exception

**Project:** RustMC  
**Date:** 2026-08-18  
**Requested by (human):** MrWizard94 (project director; goal: complete Pumpkin + Leafish/Veloren fork end-to-end)  
**Status:** Approved  

## Rule(s) affected

| Rule ID | Canonical home |
|---------|----------------|
| `ENG-WARN-001` | `AGENTS Constitution/standards/ENGINEERING.md` |

## Why this exception is required

Upstream **Pumpkin** and **Leafish** (vendored as git submodules under `vendor/`) emit compiler/linter warnings in their current pins. Fixing every upstream warning would require forking and maintaining large third-party trees beyond this delivery. Product crates (`rustmc-world`, `rustmc-veloren-fork`) remain zero-warning.

## Scope (what is allowed)

* `ENG-WARN-001` may be **N/A / waived only for** `vendor/pumpkin/**` and `vendor/leafish/**` build output while those trees remain unmodified upstream pins (plus the single Windows zip-dir patch under `patches/`).
* Section 0 item 3 for a delivery that includes those vendor builds may be scored **PASS (product crates) / waived for vendor via this override**.

## Scope (what is still forbidden)

* Warnings in RustMC product crates (`crates/**`) — still stop-ship  
* Silent blanket `allow`/`cfg` suppressions in product code without cause  
* Waiving `CONST-GATE-001`, `CONST-COMPLETE-001`, `TEST-BEHAVIOR-001`, `SEC-INPUT-001`, or safety/legal  
* Using this override to skip fixing regressions we introduce in vendor patches

## Expiration / removal date

2027-02-18 or when vendor pins are replaced with warning-clean forks — whichever first.

## Compensating controls

* Product crates tested with `cargo test -p rustmc-world` and `cargo test -p rustmc-veloren-fork` (must be warning-clean)  
* Vendor warnings captured in scratch build logs for audit  
* Single Leafish patch is reviewed and applied via `scripts/Apply-LeafishPatches.ps1` / `Build-Leafish.ps1`

## Human approval

* Name: MrWizard94 (GitHub: MrWizard94-Compile; RustMC product owner)  
* Date: 2026-08-18  
* Signature / note: Explicit goal instruction to complete Pumpkin server + Leafish/Veloren fork end-to-end on this machine using those upstreams; override limited to vendor warning noise only (`GOV-OVR-001`).

**Note:** Overrides cannot waive safety/legal constraints. Core quality exceptions require explicit human approval and must not become silent defaults.
