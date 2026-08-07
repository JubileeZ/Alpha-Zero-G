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
command -v agent jq git python3
agent login   # once per machine
```

No Docker. Cells call Cursor Agent CLI (`agent -p`). Current/candidate arms inject azg instructions from `AZG_CURRENT_REF` / `AZG_CANDIDATE_REF` into the cell worktree only (no global `azg setup` required for the gate).

## Default policy

- **N=5** — relevance map for `TRAP_CHANGE_TYPE` (default `general`), then random-fill; seed + IDs in campaign dir
- **Full corpus** — `TRAP_FULL=1` (first campaign / deep runs)
- **Model** — `TRAP_MODEL` default `gpt-5.6-luna-low`
- **Jobs** — `TRAP_JOBS` / `--jobs N` (parallel cells; default 3)
- **Promote** — Candidate rate ≥ Current and ≥ Baseline (`task_success` binary; Process Gate — not Lite)

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

Env: `TRAP_CAMP`, `TRAP_MODEL`, `TRAP_N`, `TRAP_FULL`, `TRAP_CHANGE_TYPE`, `TRAP_SEED`, `TRAP_IDS`, `TRAP_JOBS`, `AZG_CURRENT_REF`, `AZG_CANDIDATE_REF`, `TRAP_CANDIDATE_PACK` (`fable-method` = upstream `AGENTS.md` + four skills at `VENDOR.lock`; default for `run-full-first.sh`; else candidate arm uses `AZG_CANDIDATE_REF` azg overlay).

## Cleanup (local)

```bash
rm -rf evals/traps/worktrees
# keep campaigns/<id>/scorecards if you want a local record; safe to delete
rm -rf evals/traps/campaigns/<id>
```
