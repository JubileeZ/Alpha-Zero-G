# Evaluation Suite

**Sole gate:** Trap Suite Process Gate (ADR 0012+0013). SWE-bench Lite (ADR 0007) **deleted** 2026-08-07.

| Gate | Path | Role | Default models |
|------|------|------|----------------|
| **Trap Suite** | [`traps/`](traps/) | Intent/Prove / Treatment adopt | `gpt-5.6-luna-xhigh` × 4 full-corpus repeats; tier sweep optional |

Shared isolation: [`docker/azg-eval-agent/`](docker/azg-eval-agent/) + `run-agent-isolated.sh` + `stage-eval-home.sh`.

## Layout (tracked)

```
evals/
  README.md
  docker/azg-eval-agent/          # ADR 0013 image
  traps/                          # corpus, vendor, CAMPAIGN, operator wrappers
    run-{full-first,repeats,tier-sweep}.sh
  run-agent-isolated.sh  stage-eval-home.sh  trap-fable-pack.sh
  *-trap*.sh                      # prepare / cell / campaign / score / analyze / report / select
```

| Tracked | Ignored |
|---------|---------|
| runners + `traps/{README,CAMPAIGN,corpus,relevance-map,vendor}` | `traps/campaigns/`, `traps/worktrees/`, `traps/homes/`, `LAST-GATE.md` |

## Device setup (once)

```bash
curl https://cursor.com/install -fsS | bash
export PATH="$HOME/.local/bin:$PATH"
agent login   # or CURSOR_API_KEY
command -v docker jq git bash
bash evals/docker/azg-eval-agent/build.sh
# Real Python 3 for N=5 select + analyze (azg_python — not Windows Store stub)
# Escape: AZG_EVAL_DOCKER=0 (not promote-grade)
```

## Quick links

```bash
# Default decision run: full S1–S14 × 4 repeats at luna-xhigh
bash evals/traps/run-repeats.sh

# Optional model-tier diagnostic: full S1–S14 × low/medium/high (R=1)
bash evals/traps/run-tier-sweep.sh

# Routine N=5 Process Gate (single model)
TRAP_CANDIDATE_PACK=none TRAP_CHANGE_TYPE=intent_gates bash evals/prepare-trap-campaign.sh
bash evals/run-trap-campaign.sh --jobs 12
bash evals/analyze-trap.sh

bash tests/test-traps.sh
bash tests/test-eval-isolation.sh
```

**Recommend:** scenarios **14 (full)** × **R=4** at `luna-xhigh` for decision claims; low/medium/high tier sweep remains diagnostic. Do not commit under `traps/campaigns/` or `worktrees/`.
