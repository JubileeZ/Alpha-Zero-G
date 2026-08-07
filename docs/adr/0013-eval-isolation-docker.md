# Eval Isolation (Docker agent for Trap/Lite)

3-arm Agent CLI campaigns must not see host `~/.cursor` from Device Setup. Shared image `azg-eval-agent` + `evals/run-agent-isolated.sh`. Lite SWE-bench score containers stay separate. Isolated HOME / VM deferred.

**Status:** accepted

**Considered options:** operator runbook only (rejected — skipped under time pressure); isolated HOME v1 (rejected for now — Docker chosen for hermetic empty home); VM (rejected — overkill vs Docker); mounting host agent binary (debug-only later).

**Consequences:** Default `AZG_EVAL_DOCKER=1`. `AZG_EVAL_DOCKER=0` tags `isolation=host`; `analyze-trap.sh` refuses promote unless `isolation=docker`. Auth via `CURSOR_API_KEY` or host auth.json mounted into empty container home — never host `~/.cursor`.
