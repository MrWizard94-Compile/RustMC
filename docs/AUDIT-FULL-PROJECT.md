# Audit Report — RustMC Full Project Deep Audit

**Project / scope:** RustMC product tree (`RustMC/`) — family Minecraft-*like* Rust stack  
**Date:** 2026-08-18  
**Auditor:** Grok (agents-constitution skill — modes `self-run` + `gate` + product review)  
**SOP phases covered:** 8–10 (audit / harden / delivery packaging)  
**Related Rule IDs:** `CONST-GATE-001`, `CONST-DONE-001`, `CONST-COMPLETE-001`, `ENG-WARN-001`, `TEST-BEHAVIOR-001`, `DOC-SYNC-001`, `SEC-INPUT-001`, `SEC-SECRET-001`, `REV-PACK-001`, `GOV-INT-001`, `GOV-OVR-001`, `GOV-PORT-001`

## Summary

| Severity | Count |
|----------|------:|
| Critical | 0 |
| High | 0 |
| Medium | 2 |
| Low | 2 |
| Info | 4 |

**Overall product gate:** **PASS with accepted residual risks** (documented below).  
**Pack integrity:** **PASS** (`verify-pack`, `self-audit`, `run-full-constitution-self` all exit 0).

Constitution pack tools:

| Tool | Exit | Report |
|------|------|--------|
| `verify-pack.ps1` | 0 | RESULT: PASS (`GOV-INT-001`) |
| `self-audit.ps1` | 0 | `AGENTS Constitution/reports/SELF-AUDIT-latest.md` |
| `run-full-constitution-self.ps1` | 0 | `AGENTS Constitution/reports/FULL-CONSTITUTION-SELF-RUN-latest.md` |

Live smoke this audit: Pumpkin status ping **OK** (`version=1.7.2-26.2`, description present); local-assets assert **PASS**; product crate tests **5/5 PASS**, zero warnings on `crates/**`.

---

## Section 0 gate (`CONST-GATE-001`) — RustMC deliverable

| # | Check | Score | Evidence |
|---|-------|-------|----------|
| 1 | Completeness | **PASS** | No TODO/FIXME/`unimplemented!` in `crates/` or `scripts/` |
| 2 | Dependency-first | **PASS** | Pack vendored; submodules present; scripts wire build→run |
| 3 | Zero warnings/errors | **PASS (product) / waived (vendor)** | `cargo build -p rustmc-world -p rustmc-veloren-fork` clean; vendor via approved `docs/PROJECT-OVERRIDE.md` (`GOV-OVR-001`) |
| 4 | Tests exist & pass | **PASS** | `rustmc-world` 3 tests; `rustmc-veloren-fork` 2 tests — all drive shipped APIs |
| 5 | Docs synchronized | **PASS** | `FAMILY-PLAY.md` matches Build-Pumpkin/Leafish; IP line present |
| 6 | Security & validation | **PASS** | No secrets in tree; `local.minecraft.env` gitignored; jars/assets ignored; store validates keys/version |
| 7 | Performance reasoning | **PASS** | Sparse JSON world store; headless ping; rust-lld for large Pumpkin link |
| 8 | Version/stack fidelity | **PASS** | Edition 2021 product crates; Pumpkin rust-toolchain stable |
| 9 | Full package ready | **PASS** | Drop-in clone path documented; binaries present on this machine |
| 10 | Resource & constraint | **PASS** | Local Mojang assets reused in place; not vendored |
| 11 | Reproducibility | **PASS** | Submodule SHAs; `Cargo.lock`; Build-* scripts |
| 12 | IP / invention hygiene | **PASS** | Verbatim no-redistribution; ATM10/Create deferred as not Rust-ported |
| 13 | Multi-agent coordination | **N/A** | Single delivery stream |
| 14 | Review packaging | **PASS** | This audit + existing MANIFEST/delivery reports |
| 15 | Self-audit log | **PASS** | This section |

---

## Findings

| ID | Severity | Area | Description | Status |
|----|----------|------|-------------|--------|
| A-001 | Medium | Architecture | `rustmc-veloren-fork` is a **thin compose** over `rustmc-world`, not a deep Veloren terrain/engine integration. Honest for bootstrap mutate seed; overselling “Veloren fork” without reading `docs/VELOREN-FORK.md` risks expectation mismatch. | Accepted (documented) |
| A-002 | Medium | Ops / CI | No `.github/` CI in the RustMC product repo. Builds/tests rely on local scripts. Family LAN works; regression gate is manual. | Open |
| A-003 | Low | Vendor hygiene | Working tree dirty: Leafish `src/resources.rs` (patch applied), Pumpkin `.cargo/` (rust-lld). Intended; patch lives in `patches/` and Build scripts re-apply. Fresh clone must run `Build-Leafish` / `Build-Pumpkin`. | Accepted (by design) |
| A-004 | Low | Dual stack | Pumpkin+Leafish and Veloren reference remain **separate** — not one merged game binary. Documented in architecture; matches Non-goals. | Accepted (by design) |
| A-005 | Info | Scope | ATM10 / Create:Aeronautics are **not** Rust-ported; CurseForge path is inventory only. Explicit in `FAMILY-PLAY.md`. | Accepted |
| A-006 | Info | Licensing | Veloren pin is GPL-3.0; product crates avoid linking it (composition boundary). Keep this if deepening the fork. | Accepted |
| A-007 | Info | Assets | 0 product jars; 0 committed `assets/minecraft`; `local.minecraft.env` not tracked. IP policy holds. | Pass |
| A-008 | Info | Runtime | This machine has `pumpkin.exe` (~109 MB) and `leafish.exe` (~30 MB); live ping succeeded during audit. | Pass |

---

## Remediation

| Finding | Recommended fix | Priority |
|---------|-----------------|----------|
| A-001 | Next epic: integrate Veloren volume/terrain mutate or rename surface to “Veloren-track mutate API” in user-facing README headline if kids’ expectations are “full Veloren game.” | P2 |
| A-002 | Add GitHub Actions: `verify-pack`, `cargo test -p rustmc-world -p rustmc-veloren-fork`, optional cached Pumpkin build on Windows with rust-lld. | P2 |
| A-003 | Document in README clone checklist: `git submodule update --init --recursive` then `Build-Pumpkin` / `Build-Leafish`. (Already largely in FAMILY-PLAY.) | P3 |

---

## Residual risk (human-accepted)

1. Vendor compiler warnings remain under `PROJECT-OVERRIDE.md` until expiry **2027-02-18** or clean forks.  
2. Leafish GUI depends on GPU/display; headless agents use “alive after N seconds” ready signal.  
3. Family play requires a legitimate local Minecraft install for assets — not shipped by RustMC.  
4. ATM10 content stays on CurseForge Java; connecting it to Pumpkin is **not** this product’s claim.

---

## Inventory (audit snapshot)

| Area | State |
|------|--------|
| Remote | `origin` → `https://github.com/MrWizard94-Compile/RustMC.git` @ `bde6609` |
| Pack | AGENTS Constitution **5.0.1** vendored + Level-4 `AGENTS.md` |
| Crates | `rustmc-world`, `rustmc-veloren-fork` (5 unit tests) |
| Vendors | Pumpkin / Leafish / Veloren submodules + LICENSE files |
| Scripts | Build-Pumpkin, Build-Leafish, Apply-LeafishPatches, status ping, local-assets discover/assert/launch |
| Docs | FAMILY-PLAY, IP-POLICY, PROJECT-OVERRIDE, ARCHITECTURE, VELOREN-FORK, delivery reports |

---

## Sign-off

* Engineering (AI): Deep audit executed under agents-constitution `self-run` + `gate` — **PASS with A-001/A-002 open as P2**.  
* Security: No secrets; redistribution controls present — **PASS**.  
* Human director: Review findings A-001/A-002; approve residual risks or prioritize CI / deeper Veloren integration.
