# WPAI Constitution adoption — RustMC

**Migration baseline:** RustMC `3bc607b07ba271004d1da9e1a01f30cb4f29b22f`

**Pinned accepted source:** WPAI Constitution `5a990520d53969bb90b72a886bbc62cb7f1b63aa` (6.3.1)

The GitHub WPAI Constitution is the sole editable cross-project law. RustMC's
root `AGENTS.md` remains the Level-4 product entry point; the copied 5.0.1 law
pack is removed from the current tree. Every removed tracked byte remains in
the RustMC baseline commit and earlier history. To inspect that baseline, run
`git ls-tree -r --name-only 3bc607b07ba271004d1da9e1a01f30cb4f29b22f`
and use `git show <commit>:<listed-path>` for a specific historical file.

The dated bootstrap, playable-delivery, and full-audit reports remain in
`docs/` as evidence of what was checked in August 2026, not as active
instructions. Each has a visible historical banner. The project adoption
wrapper runs the canonical read-only scanner, accepts only the exact hashes
of those three reports, and fails on any other legacy consumer or a changed
historical report. Its retained-reference lines remain visible in CI; this
is an explicit disposition, not a hidden skip.

The existing, human-approved vendor-only `ENG-WARN-001` exception remains in
`docs/PROJECT-OVERRIDE.md`, with its original scope and 2027-02-18 expiration.
This migration changes its canonical reference, not its approval or breadth.
Product crates still require zero warnings. CI runs source validation,
adoption audit, format, clippy with warnings denied, and locked workspace
tests at Rust 1.97.1. It does not build Pumpkin/Leafish or establish family
play runtime acceptance; those remain separate, device- and asset-dependent
checks under the approved vendor exception.

Rollback, if necessary, is to use the prior Git commit or revert the migration
commit. Do not copy the retired pack back into active RustMC law merely to
restore a command; use the source snapshot and the project-specific override.
