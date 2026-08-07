# Evaluation Suite

Two gates, one tree. **Clone + Cursor Agent CLI** is enough to run on any device; campaign artifacts stay local (gitignored).

| Gate | Path | Role | Default model |
|------|------|------|----------------|
| **Lite** (adopt) | [`lite/`](lite/) | SWE-bench Task Success — ADR 0007 | `gpt-5.6-luna-medium` |
| **Trap Suite** (process) | [`traps/`](traps/) | Intent/Prove traps — ADR 0012 | `gpt-5.6-luna-medium` |

## Shared vs local

| Tracked (share) | Ignored (per-device) |
|-----------------|----------------------|
| `evals/*.sh` runners | `lite/campaigns/`, `lite/worktrees/` |
| `lite/{README,CAMPAIGN,instances,scorecard tmpl}` | `traps/campaigns/`, `traps/worktrees/` |
| `traps/{README,CAMPAIGN,corpus,relevance-map}` | `.venv-swebench/` (Lite harness) |
| `traps/vendor/fable-method/` (MIT fixtures) | |

## Device setup (once per machine)

```bash
# Cursor Agent CLI — required for trap + Lite agent cells
curl https://cursor.com/install -fsS | bash
export PATH="$HOME/.local/bin:$PATH"
agent login          # or export CURSOR_API_KEY=...

# Repo tooling
command -v jq git bash
# Trap Suite + Lite agent cells: Docker Eval Isolation (ADR 0013)
command -v docker
bash evals/docker/azg-eval-agent/build.sh
# Lite SWE-bench scoring: separate Docker + swebench venv — see lite/README.md
# Escape hatch (not promote-grade): AZG_EVAL_DOCKER=0
```

Then follow gate README. Do **not** commit under `*/campaigns/` or `*/worktrees/`.

## Quick links

```bash
# Trap Process Gate (N=5 default)
bash evals/prepare-trap-campaign.sh
bash evals/run-trap-campaign.sh --jobs 12
bash evals/analyze-trap.sh

# Lite adopt gate — see lite/README.md
bash evals/prepare-lite-campaign.sh evals/lite/campaigns/<id>
bash evals/run-lite-composer-campaign.sh --score --jobs 12

bash tests/test-traps.sh
bash tests/test-lite.sh
```
