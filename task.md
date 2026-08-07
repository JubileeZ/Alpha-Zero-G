# Active Task: Concept Candidate (D) patched → Docker Process Gate

- **Status:** Grill closed; Candidate prose patch landed; Docker Process Gate pending
- **Objective:** Upgrade concept Candidate (Q6 split + sharpen authority/Twin under WFA); clean Docker Process Gate vs Current Treatment.
- **Acceptance:** Structural tests green; Candidate matches grill; `isolation=docker` campaign analyzed.
- **Issue/Ticket:** Grill-with-docs 2026-08-07 · ADR 0012/0013

## Work Packet (SFDBN)

- **Status:** Patch done (AGENTS + method-refs + CONTEXT + tests + research note); commit next; Docker gate after
- **Files:** `templates/global/AGENTS.md` · `templates/global/skills/azg/azg-method-refs/SKILL.md` · `CONTEXT.md` · `tests/test-intent-gates-candidate.sh` · `docs/research/2026-08-07-unattended-tied-defaults-loop-engineering.md`
- **Decisions:** (D) all three classes; Q6 impl-equivalent/Intent Tie; Twin fix-or-list always-on bar; WFA thin+JIT; host smoke triage only
- **Blocked:** None
- **Next:** Commit → Docker Process Gate (`TRAP_CANDIDATE_PACK=none` `AZG_CANDIDATE_REF=HEAD` `AZG_EVAL_DOCKER=1`)

## Todo
- [x] Grill Q1–Q10
- [x] Research Unattended tied defaults
- [x] Candidate patch (D/Q9)
- [x] Structural tests green
- [ ] Commit
- [ ] Clean Docker Process Gate re-run
- [ ] Lite Agent arms via same helper (follow-up)

## Blockers / Notes
- Research: `docs/research/2026-08-07-unattended-tied-defaults-loop-engineering.md`
- Build: `bash evals/docker/azg-eval-agent/build.sh`
