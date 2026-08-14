# Eval Isolation (Docker agent for Trap Suite)

3-arm Agent CLI Trap campaigns must not see host `~/.cursor` from Device Setup. Shared image `azg-eval-agent` + `evals/run-agent-isolated.sh`. Lite suite removed (ADR 0007 superseded) — no separate SWE-bench score path in-repo. VM deferred.

**Status:** accepted (amended 2026-08-07 — Eval Device Home; Trap-only; 2026-08-14 — fable-pack inject retired)

**Decision:** Docker empty home by default. Current/Candidate mount an **Eval Device Home** staged from the arm git ref (`evals/stage-eval-home.sh`): AGENT-INSTRUCTIONS `.mdc` plus azg Device Setup skills present at that ref — read-only under container `$HOME/.cursor/{rules,skills}` (+ `.agents/skills`). Baseline mounts none. Worktree holds fixture only (no pack inject). Custom Candidate packs: `templates/candidates/<id>/` + stager.

**Considered options:** operator runbook only (rejected); isolated HOME without Docker (rejected for hermetic empty home); VM (overkill); worktree-only inject (rejected for Device Setup fidelity); full vendor+MCP in eval home (rejected — noise vs Process Gate).

**Consequences:** Default `AZG_EVAL_DOCKER=1`. `AZG_EVAL_DOCKER=0` tags `isolation=host`; `analyze-trap.sh` refuses promote unless `isolation=docker` and scorecards complete. Auth via `CURSOR_API_KEY` or host auth.json only — never host `~/.cursor`. Changing Device Home delivery requires re-running Process Gate (inject-era rates not comparable).
