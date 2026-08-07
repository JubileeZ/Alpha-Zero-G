# Trap Suite / Process Gate

Vendored Fable-method trap fixtures + azg 3-arm runner. **Not** the Evaluation Suite (Lite / Task Success). See ADR 0012.

Parent: [`evals/README.md`](../README.md) (device setup + share vs local).

## Layout

| Path | Role | Git |
|------|------|-----|
| `vendor/fable-method/scenarios/` | Upstream fixtures (MIT); strip `GROUND-TRUTH.md` from agent copies | tracked |
| `relevance-map.json` | change-type → preferred scenario IDs | tracked |
| `corpus.json` | Full S1–S14 id list | tracked |
| `campaigns/<id>/` | selection, scorecards, logs, `promote-result.json` | **ignored** |
| `worktrees/` | pristine + per-cell agent trees | **ignored** |
| `../{prepare,run,select,score,analyze}-trap*.sh` | runners (repo `evals/`) | tracked |

## Device prereqs

```bash
export PATH="$HOME/.local/bin:$PATH"
command -v docker jq git python3
agent login   # once on host — auth.json or CURSOR_API_KEY used inside eval container
bash evals/docker/azg-eval-agent/build.sh   # once (or auto-built on first cell)
```

**Eval Isolation (ADR 0013):** default `AZG_EVAL_DOCKER=1` — executor + judge run in `azg-eval-agent` (empty home; no host `~/.cursor`). Cell inject still supplies current/candidate gates into the worktree. `AZG_EVAL_DOCKER=0` = host smoke only; `analyze-trap.sh` refuses promote unless `isolation=docker`.

## Default policy

- **N=5** — relevance map for `TRAP_CHANGE_TYPE` (default `general`), then random-fill; seed + IDs in campaign dir
- **Full corpus** — `TRAP_FULL=1` (first campaign / deep runs)
- **Model** — `TRAP_MODEL` default `gpt-5.6-luna-low`
- **Jobs** — `TRAP_JOBS` / `--jobs N` (parallel cells; default 3)
- **Promote** — Candidate rate ≥ Current and ≥ Baseline **and** `isolation=docker` (Process Gate — not Lite)

## One-shot

```bash
export PATH="$HOME/.local/bin:$PATH"
cd /path/to/alpha-zero-g   # any clone

# routine Process Gate (N=5)
TRAP_CHANGE_TYPE=intent_gates bash evals/prepare-trap-campaign.sh
bash evals/run-trap-campaign.sh --jobs 3
bash evals/analyze-trap.sh

# full corpus (first / deep)
export TRAP_CAMP="$PWD/evals/traps/campaigns/full-first"
export TRAP_FULL=1 TRAP_MODEL=gpt-5.6-luna-low
export AZG_CURRENT_REF=<current-sha> AZG_CANDIDATE_REF=HEAD
bash evals/prepare-trap-campaign.sh "$TRAP_CAMP"
bash evals/run-trap-campaign.sh --jobs 3
# or: bash evals/traps/run-full-first.sh
bash evals/analyze-trap.sh "$TRAP_CAMP"
```

Resume skips cells with `task_success` set; `--force` re-runs all.

Env: `TRAP_CAMP`, `TRAP_MODEL`, `TRAP_N`, `TRAP_FULL`, `TRAP_CHANGE_TYPE`, `TRAP_SEED`, `TRAP_IDS`, `TRAP_JOBS`, `AZG_CURRENT_REF`, `AZG_CANDIDATE_REF`, `TRAP_CANDIDATE_PACK` (`fable-method` = upstream pack; else azg overlay), `AZG_EVAL_DOCKER` (default `1`).

## Cleanup (local)

```bash
rm -rf evals/traps/worktrees
# keep campaigns/<id>/scorecards if you want a local record; safe to delete
rm -rf evals/traps/campaigns/<id>
```
