# Eval Isolation (Docker agent for Trap/Lite)

3-arm Agent CLI campaigns must not see host `~/.cursor` from Device Setup. Shared image `azg-eval-agent` + `evals/run-agent-isolated.sh`. Lite SWE-bench score containers stay separate. VM deferred.

**Status:** accepted (amended 2026-08-07 — Eval Device Home)

**Decision:** Docker empty home by default. Current/Candidate mount an **Eval Device Home** staged from the arm git ref (`evals/stage-eval-home.sh`): Ponytail + AGENT-INSTRUCTIONS `.mdc` + azg-owned skills only — read-only under container `$HOME/.cursor/{rules,skills}` (+ `.agents/skills`). Baseline mounts none. Worktree holds fixture only (no azg rule inject). Fable-pack Candidate may still inject into worktree.

**Considered options:** operator runbook only (rejected); isolated HOME without Docker (rejected for hermetic empty home); VM (overkill); worktree-only inject (rejected for real-world Device Setup fidelity — amended away); full vendor+MCP in eval home (rejected — noise vs Process Gate).

**Consequences:** Default `AZG_EVAL_DOCKER=1`. `AZG_EVAL_DOCKER=0` tags `isolation=host`; `analyze-trap.sh` refuses promote unless `isolation=docker` and scorecards complete. Auth via `CURSOR_API_KEY` or host auth.json only — never host `~/.cursor`. Changing Device Home delivery requires re-running Process Gate (inject-era rates not comparable).
