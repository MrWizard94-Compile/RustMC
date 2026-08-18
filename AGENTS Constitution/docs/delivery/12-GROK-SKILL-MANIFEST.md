# MANIFEST — Grok Skill: agents-constitution

**Delivery title:** AGENTS Constitution → Grok skill (loader/enforcer)  
**Date:** 2026-08-10  
**Author:** AI (Grok) under human direction  
**Related Rule IDs:** CONST-GATE-001, CONST-DONE-001, CONST-ONEHOME-001, GOV-PORT-001, GOV-INT-001, REV-PACK-001  

## Summary

One sentence: The constitution pack is now invokable as Grok skill `agents-constitution` without duplicating law; pack tools were run against the pack and passed.

## Files

| Path | Purpose | New / Modified |
|------|---------|----------------|
| `.grok/skills/agents-constitution/SKILL.md` | Skill entry: modes, load order, gate, self-run | New |
| `.grok/skills/agents-constitution/scripts/resolve-pack.ps1` | Portable pack-root discovery | New |
| `.grok/skills/agents-constitution/references/always-load.md` | Pointer to always-load set | New |
| `.grok/skills/agents-constitution/references/pack-root.local.example` | Optional local pin example | New |
| `.grok/skills/agents-constitution/references/.gitignore` | Ignore host-local `pack-root.local` | New |
| `docs/delivery/12-GROK-SKILL-MANIFEST.md` | This inventory | New |
| `docs/delivery/12-GROK-SKILL-DELIVERY.md` | Handoff + Section 0 for skill | New |
| `~/.grok/skills/agents-constitution/*` | User-scope install (empire-wide) | New (host) |

## Verification

```powershell
$PACK = "C:\WPAI\AGENTS Constitution"   # or any install path
pwsh -File "$PACK\tools\verify-pack.ps1" -PackRoot $PACK
pwsh -File "$PACK\tools\self-audit.ps1" -PackRoot $PACK
pwsh -File "$PACK\tools\run-full-constitution-self.ps1" -PackRoot $PACK
pwsh -File "$PACK\.grok\skills\agents-constitution\scripts\resolve-pack.ps1" -SkillDir "$PACK\.grok\skills\agents-constitution" -StartPath $PACK
```

Expected: all exit **0**; resolver prints pack root.

## Risks / Trade-offs

- Skill is a **non-law** Grok interface (`.grok/`); does not bump pack VERSION / LOCK state.
- User-scope copy may drift from pack-shipped skill; treat pack tree as SoT for skill source (`GOV-SYNC-001`).
- Host pin `references/pack-root.local` is optional and gitignored; discovery works without it when the pack is on the walk path.

## Next actions for human

1. Invoke `/agents-constitution` or `/skills agents-constitution` in Grok.
2. On other machines: copy pack, re-run verify, install skill to `~/.grok/skills/` if desired.
3. If skill should become part of a versioned pack release, explicitly request a LOCK amendment + VERSION bump.
