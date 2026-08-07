# Active Task: Process Gate Candidate — authority · Reversible Default · Twin Sweep

- **Status:** Candidate prose landed; Process Gate re-run still pending
- **Objective:** Combined always-on + method-refs Candidate from grill (keep azg; concept-level harden three failure modes).
- **Acceptance:** Structural tests green; no fixture IDs in gates; Process Gate later ≥ current and ≥ baseline to promote.
- **Issue/Ticket:** Grill 2026-08-07 · ROADMAP Process Gate

## Work Packet (SFDBN)

- **Status:** Process Gate **running** — `evals/traps/campaigns/azg-concept-candidate/`
- **Files:** (unchanged Candidate prose) · campaign tree gitignored
- **Decisions:** `TRAP_CANDIDATE_PACK=none` (azg overlay @ HEAD); current `d5711c2`; full S1–S14
- **Blocked:** None — wall-clock ~15–20 min
- **Next:** Wait for 42 cells → `analyze-trap.sh` → promote or ablate

## Todo
- [x] Grill concepts locked
- [x] Always-on + method-refs Candidate
- [x] Glossary + structural tests
- [ ] Process Gate re-run on this Candidate
- [ ] Promote or ablate per ADR 0012

## Blockers / Notes
- Prior Fable-pack run: keep as historical no-promote (`evals/traps/CAMPAIGN.md`)
- Device: `./azg setup` (or `--force`) to refresh global rules/skills from templates
