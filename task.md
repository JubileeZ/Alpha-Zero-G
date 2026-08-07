# Active Task: Docker Process Gate — concept Candidate (D+clarity)

- **Status:** Clarity committed; Docker Process Gate launching
- **Objective:** Clean `isolation=docker` 3-arm Trap Suite; Candidate = HEAD (D + WFA glosses) vs Current `d5711c2` vs Baseline
- **Acceptance:** Campaign complete; `promote-result.json` with `isolation=docker`; promote or ablate per ADR 0012
- **Issue/Ticket:** Grill-with-docs 2026-08-07 · ADR 0012/0013

## Work Packet (SFDBN)

- **Status:** Clarity pass committed; Docker campaign starting
- **Files:** Candidate at HEAD · camp `evals/traps/campaigns/azg-concept-docker`
- **Decisions:** AZG_EVAL_DOCKER=1; TRAP_CANDIDATE_PACK=none; AZG_CURRENT_REF=d5711c2; AZG_CANDIDATE_REF=HEAD
- **Blocked:** None
- **Next:** Wait campaign → `bash evals/analyze-trap.sh "$TRAP_CAMP"`

## Todo
- [x] Grill + Candidate (D) + WFA clarity
- [x] Commit + push
- [ ] Docker Process Gate run
- [ ] Analyze promote/ablate
- [ ] Lite Agent arms via same helper (follow-up)

## Blockers / Notes
- Launch env below; build image if missing: `bash evals/docker/azg-eval-agent/build.sh`
