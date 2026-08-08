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

**Eval Isolation (ADR 0013):** default `AZG_EVAL_DOCKER=1` — executor + judge in `azg-eval-agent` (empty image home; no host `~/.cursor`). **Eval Device Home:** Current/Candidate stage azg-owned rules from the arm git ref (`evals/stage-eval-home.sh`) and mount read-only; Baseline mounts none; worktree = fixture only. Clean slate: distill skills **not** staged unless `AZG_EVAL_AZG_SKILLS=1`. Fable-pack Candidate injects into worktree (no Device Home). `unified-pipeline` Candidate uses `stage-unified-pipeline-home.sh`. `AZG_EVAL_DOCKER=0` = host smoke only; `analyze-trap.sh` refuses promote unless `isolation=docker`.

**Two-tier spend (ADR 0012 amend):** **Smoke Filter** first (`run-smoke-filter.sh`: s2/s9/s13 × R=2) — kill weak Candidates; **not** promote. **Adopt Run** only after smoke pass — promote input; tiered per-id R (policy); stand-in until runner = `run-repeats.sh` full corpus R=4. Tier sweep = diagnostic only.

## Default policy

- **Smoke Filter first** — `bash evals/traps/run-smoke-filter.sh` (s2/s9/s13 × R=2). Not promote.
- **Adopt Run** — only after smoke pass. Policy = tiered per-id R (ADR 0012); **stand-in** = `run-repeats.sh` full corpus R=4 until per-id runner exists.
- **N=5** — legacy relevance subset still available via `prepare-trap-campaign.sh` without Smoke/Adopt helpers
- **Full corpus** — `TRAP_FULL=1`; also default when `TRAP_CANDIDATE_PACK=fable-method` unless `TRAP_FULL`/`TRAP_IDS` set
- **Model** — `TRAP_MODEL` default `gpt-5.6-luna-xhigh`
- **Jobs** — `TRAP_JOBS` / `--jobs N` (parallel cells; default 12)
- **Tier diagnostic** — `bash evals/traps/run-tier-sweep.sh` (R=1) — not promote
- **Promote** — Candidate rate ≥ Current ≥ Baseline on Adopt set **and** `isolation=docker`

## One-shot

```bash
export PATH="$HOME/.local/bin:$PATH"
cd /path/to/alpha-zero-g   # any clone

# 1) Smoke Filter (kill weak Candidates — not promote)
export TRAP_CANDIDATE_PACK=unified-pipeline   # or fable-method / none
bash evals/traps/run-smoke-filter.sh

# 2) Adopt stand-in after smoke pass (full corpus R=4 until tiered-R runner)
export TRAP_CAMP="$PWD/evals/traps/campaigns/adopt-${TRAP_CANDIDATE_PACK}"
bash evals/traps/run-repeats.sh
```

Resume skips cells with `task_success` set; `--force` re-runs all.

Env: `TRAP_CAMP`, `TRAP_MODEL`, `TRAP_N`, `TRAP_FULL`, `TRAP_REPEATS` (default `4`), `TRAP_CHANGE_TYPE`, `TRAP_SEED`, `TRAP_IDS`, `TRAP_JOBS`, `AZG_CURRENT_REF`, `AZG_CANDIDATE_REF`, `TRAP_CANDIDATE_PACK` (`fable-method` = upstream pack + default full corpus; `unified-pipeline` = Candidate from `templates/candidates/unified-pipeline/` via `stage-unified-pipeline-home.sh`; else azg overlay from `stage-eval-home.sh`), `AZG_EVAL_DOCKER` (default `1`).

## Cleanup (local)

```bash
rm -rf evals/traps/worktrees
# keep campaigns/<id>/scorecards if you want a local record; safe to delete
rm -rf evals/traps/campaigns/<id>
```
