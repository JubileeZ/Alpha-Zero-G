# Active Task: Docker Process Gate — concept Candidate (D+clarity)

- **Status:** Docker Process Gate **running** (`azg-concept-docker`)
- **Objective:** Clean `isolation=docker` 3-arm Trap Suite; Candidate = HEAD (D + WFA glosses) vs Current `d5711c2` vs Baseline
- **Acceptance:** Campaign complete; `promote-result.json` with `isolation=docker`; promote or ablate per ADR 0012
- **Issue/Ticket:** Grill-with-docs 2026-08-07 · ADR 0012/0013

## Work Packet (SFDBN)

- **Status:** Pushed `87b4eda`; campaign in flight (jobs=3, luna-low, isolation=docker)
- **Files:** camp `evals/traps/campaigns/azg-concept-docker` · log `campaign.nohup.log`
- **Decisions:** AZG_EVAL_DOCKER=1; TRAP_CANDIDATE_PACK=none; AZG_CURRENT_REF=d5711c2; AZG_CANDIDATE_REF=HEAD
- **Blocked:** None
- **Next:** When done → `bash evals/analyze-trap.sh evals/traps/campaigns/azg-concept-docker`

## Todo
- [x] Grill + Candidate (D) + WFA clarity
- [x] Commit + push (`87b4eda`)
- [ ] Docker Process Gate run (in flight)
- [ ] Analyze promote/ablate
- [ ] Lite Agent arms via same helper (follow-up)

## Blockers / Notes
- Monitor: `tail -f evals/traps/campaigns/azg-concept-docker/campaign.nohup.log`
