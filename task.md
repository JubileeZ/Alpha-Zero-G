# Active Task: Eval Isolation + clean Process Gate

- **Status:** Eval Isolation harness landed; clean Docker Process Gate still pending
- **Objective:** Docker `azg-eval-agent` so host Device Setup cannot leak; then re-run concept Candidate promote-grade.
- **Acceptance:** ADR 0013 + tests green; trap executor/judge isolated; host smoke tagged non-promote; clean `isolation=docker` campaign analyzed.
- **Issue/Ticket:** Grill Eval Isolation 2026-08-07 · ADR 0013

## Work Packet (SFDBN)

- **Status:** Dockerfile + `run-agent-isolated.sh` + trap wiring + analyze gate done; Lite agent wire **follow-up**
- **Files:** `evals/docker/azg-eval-agent/*` · `evals/run-agent-isolated.sh` · `evals/run-trap-cell.sh` · `evals/prepare-trap-campaign.sh` · `evals/analyze-trap.sh` · `docs/adr/0013-eval-isolation-docker.md` · `CONTEXT.md` · `tests/test-eval-isolation.sh`
- **Decisions:** Docker v1; every eval agent call; default on; host smoke not promote-grade; auth key or auth.json only
- **Blocked:** None
- **Next:** Rebuild image if needed → clean full Trap Suite (`TRAP_CANDIDATE_PACK=none` `AZG_CANDIDATE_REF=HEAD`) with `AZG_EVAL_DOCKER=1`

## Todo
- [x] Eval Isolation grill locked
- [x] Docker image + isolated runner + trap wire
- [x] Tag host smoke non-promote
- [ ] Clean Docker Process Gate re-run
- [ ] Lite Agent arms via same helper (follow-up)

## Blockers / Notes
- Host smoke rates (curiosity only): B/C/F = 71/71/79 — blocked by isolation
- Build: `bash evals/docker/azg-eval-agent/build.sh`
