# Delivery Report — RustMC bootstrap

**Title:** RustMC product bootstrap under AGENTS Constitution  
**Date:** 2026-08-18  
**One-sentence summary:** Clean RustMC git tree on GitHub with vendored constitution, three OSS upstream pins, and a durable tested block set/get API — no Mojang IP redistributed.

## Scope

- Product git at `https://github.com/MrWizard94-Compile/RustMC.git` (separate from WPAI empire worktree)
- Adopt AGENTS Constitution pack 5.0.1 (vendored Option B + Level-4 pointer)
- Pin Veloren, Pumpkin, Leafish as submodules with upstream LICENSE files
- Ship `rustmc-world` durable voxel set/get with reload round-trip tests
- Document dual-stack roles; defer ATM10 / Create:Aeronautics

## Rule ID self-audit

| Rule ID | Status | Notes |
|---------|--------|-------|
| CONST-GATE-001 | Pass | Section 0 scored below |
| CONST-DONE-001 | Pass | Drop-in product tree; tests + docs |
| CONST-COMPLETE-001 | Pass | No stubs/TODOs in shipped paths |
| CONST-DEP-001 | Pass | Pack, crates, submodules wired together |
| ENG-WARN-001 | Pass | `cargo test -p rustmc-world` clean |
| TEST-BEHAVIOR-001 | Pass | Tests call shipped `WorldStore` API across reload |
| DOC-SYNC-001 | Pass | README, ARCHITECTURE, IP-POLICY match code |
| SEC-INPUT-001 | Pass | Store validates schema/keys; no secrets in tree |
| SEC-SECRET-001 | Pass | No credentials committed |
| REV-PACK-001 | Pass | This report + MANIFEST |
| GOV-INT-001 | Pass | `verify-pack.ps1` exit 0 |
| GOV-PORT-001 | Pass | Relative pack pointer only |

## Section 0 (15-point) scores

| # | Check | Score |
|---|-------|-------|
| 1 | Completeness | PASS |
| 2 | Dependency-first | PASS |
| 3 | Zero warnings/errors | PASS (`rustmc-world`) |
| 4 | Tests exist & pass | PASS (3/3 ×2 runs) |
| 5 | Docs synchronized | PASS |
| 6 | Security & validation | PASS |
| 7 | Performance reasoning | PASS (sparse map; bootstrap-scale) |
| 8 | Version/stack fidelity | PASS (edition 2021 product crate) |
| 9 | Full package ready | PASS |
| 10 | Resource & constraint | PASS (no Mojang assets; headless-testable store) |
| 11 | Reproducibility | PASS (Cargo.lock + submodule SHAs) |
| 12 | IP / invention hygiene | PASS (`docs/IP-POLICY.md` verbatim no-redistribution) |
| 13 | Multi-agent coordination | N/A (single delivery stream) |
| 14 | Review packaging | PASS |
| 15 | Self-audit log | PASS (this section) |

**Residual doubt:** Full `pumpkin` server binary fails to **link** on this Windows MSVC agent host (`link.exe` LNK1120, ~2860 unresolved externals) after a clean rebuild — see launch-unavailable evidence. `cargo check -p pumpkin-util` still finishes (upstream crates compile). Escape hatch per plan: criteria 1–4 + unit/compile evidence. Family desktops / CI may still produce `pumpkin.exe`; do not treat agent-host link failure as a product logic defect in `rustmc-world`.

## Modules loaded

Always-load set + `ADOPT.md`, `REVIEW-PACKAGING.md`, `operations/DELIVERY.md`, `specialist/IP-AND-INVENTION.md` (IP policy), project Level-4 `AGENTS.md`.

## MANIFEST

See [`MANIFEST.md`](MANIFEST.md).

## How to verify

```powershell
cd RustMC
git remote -v
# expect: origin https://github.com/MrWizard94-Compile/RustMC.git

pwsh -File "AGENTS Constitution/tools/verify-pack.ps1"
# expect: RESULT: PASS, exit 0

cargo test -p rustmc-world
# expect: 3 passed

git submodule update --init --recursive
git submodule status
# expect: vendor/pumpkin, vendor/leafish, vendor/veloren with LICENSE files
```

## Suggested commit message(s)

Already on `main`:

```
Bootstrap RustMC: constitution, upstreams, durable block store
docs: note recursive submodule init for Pumpkin WIT
docs: note Pumpkin recursive WIT and heavy launch-build cost
docs: add bootstrap delivery MANIFEST
```

Follow-up (this report):

```
docs: Section 0 delivery report under AGENTS Constitution
```

## Risks / trade-offs

- Dual stacks (Veloren vs Pumpkin+Leafish) are present, not merged
- Veloren is GPL-3.0 — keep as submodule reference; do not casually link into MIT/Apache product crates
- Pumpkin nested `pumpkin-plugin-wit` requires recursive submodule init
- Full Pumpkin release/debug server compile is heavy (multi-GB rustc); family play machines should build overnight or use CI artifacts later

## Next actions for human (priority order)

1. Clone with `git clone --recurse-submodules https://github.com/MrWizard94-Compile/RustMC.git`
2. On a desktop with time/RAM: `cd vendor/pumpkin && git submodule update --init --recursive && cargo run -p pumpkin --release`
3. Point kids’ clients at the Pumpkin server once it listens (player-owned Mojang assets only — never commit them)
4. Later goals: Veloren building/automation feel; Pumpkin modding API; ATM10 / Create:Aeronautics ports

## Multi-agent coordination note *(if applicable)*

N/A
