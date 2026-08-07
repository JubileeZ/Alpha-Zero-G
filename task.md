# Active Task: Process Gate Candidate — authority · Reversible Default · Twin Sweep

- **Status:** Candidate prose landed; Process Gate re-run still pending
- **Objective:** Combined always-on + method-refs Candidate from grill (keep azg; concept-level harden three failure modes).
- **Acceptance:** Structural tests green; no fixture IDs in gates; Process Gate later ≥ current and ≥ baseline to promote.
- **Issue/Ticket:** Grill 2026-08-07 · ROADMAP Process Gate

## Work Packet (SFDBN)

- **Status:** Implemented Candidate text in templates; glossary + CAMPAIGN notes; **not** yet Process-Gated
- **Files:** `templates/global/AGENTS.md` · `templates/global/skills/azg/azg-method-refs/SKILL.md` · `CONTEXT.md` · `tests/test-intent-gates-candidate.sh` · `tests/run-all.sh` · `evals/traps/CAMPAIGN.md` · `docs/agents/current-state.md` · `ROADMAP.md`
- **Decisions:** Combined Candidate; thin always-on + JIT refs; Reversible Default + Unattended; INTENT losing side; Twin Sweep same construct/same risk; anti-memorization (no fixture IDs)
- **Blocked:** None
- **Next:** `TRAP_CANDIDATE_PACK=` unset / `AZG_CANDIDATE_REF=HEAD` full Trap Suite vs current `d5711c2` + baseline; promote only if ≥ both

## Todo
- [x] Grill concepts locked
- [x] Always-on + method-refs Candidate
- [x] Glossary + structural tests
- [ ] Process Gate re-run on this Candidate
- [ ] Promote or ablate per ADR 0012

## Blockers / Notes
- Prior Fable-pack run: keep as historical no-promote (`evals/traps/CAMPAIGN.md`)
- Device: `./azg setup` (or `--force`) to refresh global rules/skills from templates
