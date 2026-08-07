# Trap Suite / Process Gate

Vendored Fable-method trap fixtures + azg 3-arm runner. **Sole Evaluation Suite** (Lite deleted; ADR 0007 superseded). See ADR 0012.

Parent: [`evals/README.md`](../README.md) (device setup + share vs local).

## Layout

| Path | Role | Git |
|------|------|-----|
| `vendor/fable-method/scenarios/` | Upstream fixtures (MIT); strip `GROUND-TRUTH.md` from agent copies | tracked |
| `relevance-map.json` | change-type → preferred scenario IDs | tracked |
| `corpus.json` | Full S1–S14 id list | tracked |
| `campaigns/<id>/` | selection, scorecards, logs, `promote-result.json`, **`REPORT.md`** (auto) | **ignored** |
| `homes/` | staged Eval Device Homes (`stage-eval-home.sh`) | **ignored** |
| `LAST-GATE.md` | Pointer copy of latest `REPORT.md` after analyze | **ignored** |
| `worktrees/` | pristine + per-cell agent trees + fable-pack cache | **ignored** |
| `run-{full-first,repeats,tier-sweep}.sh` | operator entrypoints | tracked |
| `../{prepare,run,select,score,analyze,report}-trap*.sh` + `trap-fable-pack.sh` | runners (repo `evals/`) | tracked |

## Device prereqs

```bash
export PATH="$HOME/.local/bin:$PATH"
command -v docker jq git
# Python 3 required for N=5 select + analyze (python3 / python / py -3; not Store stub)
agent login   # once on host — auth.json or CURSOR_API_KEY used inside eval container
bash evals/docker/azg-eval-agent/build.sh   # once (or auto-built on first cell)
```

**Eval Isolation (ADR 0013):** default `AZG_EVAL_DOCKER=1` — executor + judge in `azg-eval-agent` (empty image home; no host `~/.cursor`). **Eval Device Home:** Current/Candidate stage azg-owned rules from the arm git ref (`evals/stage-eval-home.sh`) and mount read-only; Baseline mounts none; worktree = fixture only. Clean slate: distill skills **not** staged unless `AZG_EVAL_AZG_SKILLS=1`. Fable-pack Candidate injects into worktree (no Device Home). `AZG_EVAL_DOCKER=0` = host smoke only; `analyze-trap.sh` refuses promote unless `isolation=docker`.

## Default policy

- **N=5** — relevance map for `TRAP_CHANGE_TYPE` (default `general`), then random-fill; seed + IDs in campaign dir
- **Full corpus** — `TRAP_FULL=1` (first campaign / deep runs); **also default** when `TRAP_CANDIDATE_PACK=fable-method` (adopt-candidate gate) unless `TRAP_FULL` or `TRAP_IDS` is set
- **Model** — `TRAP_MODEL` default `gpt-5.6-luna-medium`
- **Jobs** — `TRAP_JOBS` / `--jobs N` (parallel cells; default 12)
- **Repeats** — `TRAP_REPEATS=3` via `bash evals/traps/run-repeats.sh` (full corpus × R; majority aggregate)
- **Promote** — Candidate rate ≥ Current and ≥ Baseline **and** `isolation=docker` (Process Gate — not Lite)

## One-shot

```bash
export PATH="$HOME/.local/bin:$PATH"
cd /path/to/alpha-zero-g   # any clone

# routine Process Gate (N=5) — azg Candidate overlay
TRAP_CANDIDATE_PACK=none TRAP_CHANGE_TYPE=intent_gates bash evals/prepare-trap-campaign.sh
bash evals/run-trap-campaign.sh --jobs 12

# 3× full corpus gap check (fable pack vs Current Device Home) — durable
export TRAP_CAMP="$PWD/evals/traps/campaigns/fable-medium-r3"
export TRAP_CANDIDATE_PACK=fable-method   # implies TRAP_FULL=1 when unset
export AZG_CURRENT_REF=87b4eda
# or: setsid bash evals/traps/run-repeats.sh --force
bash evals/traps/run-repeats.sh --force
# Auto: $TRAP_CAMP/AGGREGATE.md + evals/traps/LAST-GATE.md
```

Resume skips cells with `task_success` set; `--force` re-runs all.

Env: `TRAP_CAMP`, `TRAP_MODEL`, `TRAP_N`, `TRAP_FULL`, `TRAP_REPEATS`, `TRAP_CHANGE_TYPE`, `TRAP_SEED`, `TRAP_IDS`, `TRAP_JOBS`, `AZG_CURRENT_REF`, `AZG_CANDIDATE_REF`, `TRAP_CANDIDATE_PACK` (`fable-method` = upstream pack + default full corpus; else azg overlay), `AZG_EVAL_DOCKER` (default `1`).

## Cleanup (local)

```bash
rm -rf evals/traps/worktrees
# keep campaigns/<id>/scorecards if you want a local record; safe to delete
rm -rf evals/traps/campaigns/<id>
```
