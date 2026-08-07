# Active Task: Docker Process Gate — auto-watch

- **Status:** Campaign healthy (~12/42); auto-check every 5m
- **Objective:** Complete `azg-concept-docker` 42 cells; analyze promote/ablate; update continuity
- **Acceptance:** 42/42 scored; `isolation=docker`; promote only if Candidate ≥ Current and ≥ Baseline and nulls=0
- **Issue/Ticket:** Grill-with-docs 2026-08-07 · ADR 0012/0013

## Work Packet (SFDBN)

- **Status:** Root cause fixed (cells stole scenario-list stdin → early EOF); resumed; loop PID 617213
- **Files:** `evals/run-trap-campaign.sh` · `evals/analyze-trap.sh` · camp `azg-concept-docker`
- **Decisions:** Auto: dead+pending → resume; 42/42 → analyze + update CAMPAIGN/task/current-state + report; nulls block promote
- **Blocked:** None
- **Next:** Loop ticks until complete (~5m cadence)

## Todo
- [x] Clarity push
- [x] Fix analyze nulls + PID wait + stdin steal
- [ ] Docker Process Gate complete (auto-watched)
- [ ] Report promote/ablate
- [ ] Lite Agent arms (follow-up)

## Blockers / Notes
- Log: `evals/traps/campaigns/azg-concept-docker/campaign.nohup.log`
- Loop sentinel: `AGENT_LOOP_TICK_trapgate`
