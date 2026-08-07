# Active Task: Docker Process Gate — auto-watch

- **Status:** Campaign resumed (was early-stop at 3/42); auto-check loop armed
- **Objective:** Complete `azg-concept-docker` 42 cells; analyze promote/ablate; update continuity
- **Acceptance:** 42/42 scored; `isolation=docker`; promote only if Candidate ≥ Current ≥ Baseline and nulls=0
- **Issue/Ticket:** Grill-with-docs 2026-08-07 · ADR 0012/0013

## Work Packet (SFDBN)

- **Status:** Early finish bug mitigated (PID wait + nulls block promote); resume in flight; loop every 5m
- **Files:** `evals/run-trap-campaign.sh` · `evals/analyze-trap.sh` · camp `azg-concept-docker`
- **Decisions:** Auto: if dead+pending → resume; if 42/42 → analyze + update CAMPAIGN/task/current-state + report
- **Blocked:** None
- **Next:** Loop ticks until complete

## Todo
- [x] Clarity push
- [x] Fix analyze nulls + campaign wait-by-PID
- [ ] Docker Process Gate complete (auto-watched)
- [ ] Report promote/ablate
- [ ] Lite Agent arms (follow-up)

## Blockers / Notes
- Monitor log: `evals/traps/campaigns/azg-concept-docker/campaign.nohup.log`
