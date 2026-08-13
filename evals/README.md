# Evaluation Suite

**Sole gate:** Earned Trap Process Gate (ADR 0018). Runners/isolation ADR 0012+0013. Planted S1–S14 **not** a promote input. SWE-bench Lite (ADR 0007) **deleted** 2026-08-07. Empty earned corpus → INCOMPLETE.

| Gate | Path | Role | Default models |
|------|------|------|----------------|
| **Earned Traps** | [`traps/`](traps/) | Treatment adopt (earned fixtures only) | `gpt-5.6-luna-low` · Preview+Adopt Ledger R=5 |

Shared isolation: [`docker/azg-eval-agent/`](docker/azg-eval-agent/) + `run-agent-isolated.sh` + `stage-eval-home.sh`.

## Layout (tracked)

```
evals/
  README.md
  docker/azg-eval-agent/          # ADR 0013 image
  traps/                          # corpus, vendor, CAMPAIGN, run-process-gate.sh
  run-agent-isolated.sh  stage-eval-home.sh  trap-fable-pack.sh
  *-trap*.sh                      # prepare / cell / campaign / score / analyze / report / select
  analyze-trap-ledger.sh
```

| Tracked | Ignored |
|---------|---------|
| runners + `traps/{README,CAMPAIGN,corpus,relevance-map,vendor,analyze_ledger.py,run-process-gate.sh}` | `traps/campaigns/`, `traps/worktrees/`, `traps/homes/`, `LAST-GATE.md` |

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

**Recommend:** full S1–S14 × **R=5** Adopt Ledger at `luna-low` (Preview included). Do not commit under `traps/campaigns/` or `worktrees/`.
