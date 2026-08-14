# Process Gate

Azg 3-arm runner + docker isolation. **Adopt corpus = Behavior Corpus (ADR 0019)**. Task Success = Observable Outcome. Report Evidence = equivalent prose on `correct_action`, not the pass bit. Machinery: ADR 0012+0013.

Parent: [`evals/README.md`](../README.md) (device setup + share vs local).

## Layout

| Path | Role | Git |
|------|------|-----|
| `scenarios/` | Behavior Corpus Executor Traps + format-free GROUND-TRUTH | tracked |
| `score_outcome.py` | Objective Outcome scorer | tracked |
| `relevance-map.json` | change-type → scenario IDs (selection only) | tracked |
| `corpus.json` | Behavior Corpus id list | tracked |
| `campaigns/<id>/` | Adopt Ledger `r1`–`r5`, scorecards, `LEDGER.md`, `aggregate.json` | **ignored** |
| `homes/` | staged Eval Device Homes (`stage-eval-home.sh`) | **ignored** |
| `LAST-GATE.md` | Pointer copy of latest `LEDGER.md` after analyze | **ignored** |
| `worktrees/` | pristine + per-cell agent trees | **ignored** |
| `run-process-gate.sh` | **sole** operator entrypoint (Preview → ask → Adopt) | tracked |
| `analyze_ledger.py` | Recommend + Coverage math | tracked |
| `../{prepare,run,select,score,analyze,report}-trap*.sh` | runners (repo `evals/`) | tracked |

## Device prereqs

```bash
export PATH="$HOME/.local/bin:$PATH"
command -v docker jq git
# Python 3 required for analyze + Outcome scorer (python3 / python / py -3; not Store stub)
agent login   # once on host — auth.json or CURSOR_API_KEY used inside eval container
bash evals/docker/azg-eval-agent/build.sh   # once (or auto-built on first cell)
```

**Eval Isolation (ADR 0013):** default `AZG_EVAL_DOCKER=1` — executor in `azg-eval-agent` (empty image home; no host `~/.cursor`). **Eval Device Home:** Current/Candidate stage azg-owned rules from the arm git ref (`evals/stage-eval-home.sh`) and mount read-only; Baseline mounts none; worktree = fixture only. Custom Candidate packs: `templates/candidates/<pack>/` + stager. `AZG_EVAL_DOCKER=0` = host smoke only; analyze refuses promote unless `isolation=docker`.

## Default policy (ADR 0019)

- **Model** — `gpt-5.6-luna-low` only
- **Corpus** — Behavior Corpus (`evals/traps/scenarios/`). Objective Outcome scorers
- **Preview Round** — full corpus × R=1 × 3 arms; becomes ledger `r1`; **always ask** before Adopt
- **Adopt Run** — `r2`–`r5` (Preview included → R=5); sole recommend input with docker
- **Concurrency** — all scenarios parallel **per arm**; arms serial: candidate → current → baseline
- **Recommend** — overall maj Cand≥Cur≥B **and** Coverage (Cand mean≥Cur on ≥50% scenarios); else USER_DECIDES / REJECT / INCOMPLETE
- **Jobs** — `TRAP_JOBS` (default 14)

## One-shot

```bash
export PATH="$HOME/.local/bin:$PATH"
cd /path/to/alpha-zero-g

export TRAP_CANDIDATE_PACK=   # empty = Candidate arm stages Current global; or <pack-id>
export TRAP_CAMP="$PWD/evals/traps/campaigns/gate-${TRAP_CANDIDATE_PACK}"
bash evals/traps/run-process-gate.sh
# after Preview: answer y to continue, or:
#   bash evals/traps/run-process-gate.sh --continue --yes
# preview only:
#   bash evals/traps/run-process-gate.sh --preview-only
```

Resume skips filled rounds when `--continue`; `--force` re-runs cells.

Env: `TRAP_CAMP`, `TRAP_MODEL`, `TRAP_JOBS`, `TRAP_ADOPT_YES`, `TRAP_CHANGE_TYPE`, `AZG_CURRENT_REF`, `AZG_CANDIDATE_REF`, `TRAP_CANDIDATE_PACK`, `AZG_EVAL_DOCKER` (default `1`).

## Cleanup (local)

```bash
rm -rf evals/traps/worktrees
rm -rf evals/traps/campaigns/<id>
```
