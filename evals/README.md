# Evaluation Suite

**Sole gate:** Behavior Corpus Process Gate (ADR 0019). Runners/isolation ADR 0012+0013. Task Success = Observable Outcome. SWE-bench Lite (ADR 0007) **deleted**.

| Gate | Path | Role | Default models |
|------|------|------|----------------|
| **Behavior Corpus** | [`traps/`](traps/) | Treatment adopt (executor Outcome scorers) | `gpt-5.6-luna-low` · Preview+Adopt Ledger R=5 |

Shared isolation: [`docker/azg-eval-agent/`](docker/azg-eval-agent/) + `run-agent-isolated.sh` + `stage-eval-home.sh`.

## Layout (tracked)

```
evals/
  README.md
  docker/azg-eval-agent/          # ADR 0013 image
  traps/                          # corpus, CAMPAIGN, run-process-gate.sh
  run-agent-isolated.sh  stage-eval-home.sh
  *-trap*.sh                      # prepare / cell / campaign / score / analyze / report / select
  analyze-trap-ledger.sh
```

| Tracked | Ignored |
|---------|---------|
| runners + `traps/{README,CAMPAIGN,corpus,relevance-map,scenarios,score_outcome.py,analyze_ledger.py,run-process-gate.sh}` | `traps/campaigns/`, `traps/worktrees/`, `traps/homes/`, `LAST-GATE.md` |

## Device setup (once)

```bash
curl https://cursor.com/install -fsS | bash
export PATH="$HOME/.local/bin:$PATH"
agent login   # or CURSOR_API_KEY
command -v docker jq git bash
bash evals/docker/azg-eval-agent/build.sh
# Real Python 3 for analyze (azg_python — not Windows Store stub)
# Escape: AZG_EVAL_DOCKER=0 (not promote-grade)
```

## Quick links

```bash
# Sole decision path: Preview (r1) → ask → Adopt (r2–r5) @ luna-low
bash evals/traps/run-process-gate.sh

bash tests/test-traps.sh
bash tests/test-eval-isolation.sh
```

**Recommend:** full Behavior Corpus × **R=5** Adopt Ledger at `luna-low` (Preview included). Do not commit under `traps/campaigns/` or `worktrees/`.
