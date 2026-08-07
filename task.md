# Active Task: Concept Candidate (D) patched → Docker Process Gate

- **Status:** Grill closed; Candidate prose patch landed; Docker Process Gate pending
- **Objective:** Upgrade concept Candidate (Q6 split + sharpen authority/Twin under WFA); clean Docker Process Gate vs Current Treatment.
- **Acceptance:** Structural tests green; Candidate matches grill; `isolation=docker` campaign analyzed.
- **Issue/Ticket:** Grill-with-docs 2026-08-07 · ADR 0012/0013

## Work Packet (SFDBN)

- **Status:** Candidate (D) patched + committed (`397c3da`); Docker Process Gate pending
- **Files:** `templates/global/AGENTS.md` · `azg-method-refs` · `CONTEXT.md` · `tests/test-intent-gates-candidate.sh` · research note
- **Decisions:** (D) all three classes; Impl-Equivalent Default / Intent Tie; Twin fix-or-list; WFA thin+JIT; host smoke triage only
- **Blocked:** None
- **Next:** Docker Process Gate (`TRAP_CANDIDATE_PACK=none` `AZG_CANDIDATE_REF=HEAD` `AZG_CURRENT_REF=d5711c2` `AZG_EVAL_DOCKER=1`)

## Todo
- [x] Grill Q1–Q10
- [x] Research Unattended tied defaults
- [x] Candidate patch (D/Q9)
- [x] Structural tests green
- [x] Commit (`397c3da`)
- [ ] Clean Docker Process Gate re-run
- [ ] Lite Agent arms via same helper (follow-up)

## Blockers / Notes
- Research: `docs/research/2026-08-07-unattended-tied-defaults-loop-engineering.md`
- Build: `bash evals/docker/azg-eval-agent/build.sh`
