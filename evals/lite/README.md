# SWE-bench Lite — Evaluation Suite (ADR 0007)

Official adopt gate. Automated **Task Success** only — no Blind Judge / humans.

**Before a run:** read [`CAMPAIGN.md`](CAMPAIGN.md) for the **Live Campaign** (Candidate under test + arm checkouts). This file is the durable how-to; that file is overwritten per campaign.

Parent index: [`evals/README.md`](../README.md). Glossary: Evaluation Suite · Live Campaign · Campaign cost envelope · Delivery Cost (`CONTEXT.md`).

## Campaign cost envelope

Order-of-magnitude **operator** cost to run a full Lite campaign (**N=5 × 3 arms = 15 runs**, ADR 0007 v2). Planning only — **not** a promote input and **not** Delivery Cost (per-task token/spend on scorecards).

| Resource | Expect |
|----------|--------|
| Disk | SWE-bench harness env images ~**100 GB** cached; plus instance images, logs, campaign tree headroom |
| Wall-clock | First harness pull/build: **hours**. Per instance × arm (agent + eval): **model-dependent**. Full N=5 × 3: **hours to days** wall clock (vs multi-day at N=10) |
| Compute | Docker engine required for harness; agent host separate or same |
| Agent spend | Roughly **15** agent runs (5 × 3) at your fixed model/budget — **half** the v1 N=10 envelope; IDE/CLI/subagent workflows allowed; order-of-magnitude only; do not invent a dollar gate |

No device lock-in — any clone with Docker + `swebench`. Campaign artifacts must live outside `/tmp` (see layout).

## Prereqs

| Requirement | Notes |
|-------------|-------|
| Docker | Engine running; Linux post-install if needed. ARM Mac: add `--namespace ''` to harness (local image build). |
| `swebench` | [SWE-bench/SWE-bench](https://github.com/SWE-bench/SWE-bench): venv + `pip install 'swebench>=2.0'`. Entry: `python -m swebench.harness.run_evaluation`. |
| Cursor Agent CLI | `curl https://cursor.com/install -fsS \| bash` → `agent login` (or `CURSOR_API_KEY`). Proven path for automation. |
| `jq` | Scorecard + promote scripts. |
| `azg` clone | Repo on the machine that runs agents + harness. |

## Proven automation (preferred)

**Locked for ADR 0009 N=5 campaign (2026-08-01):** model `composer-2.5`, Cursor Agent CLI, Docker scoring, parallel cells.

### Isolation (do not mix arms)

| Arm | Rule |
|-----|------|
| `baseline` | Worktree `evals/lite/worktrees/cells/<id>/baseline/` — **no** `azg apply`; fail if harness files appear |
| `current` | Own worktree — `azg apply` from `azg@fef3e84` (or Live Campaign current ref) **into that tree only** |
| `candidate` | Own worktree — `azg apply` from `azg@d2df37f` (or Live Campaign candidate ref) **into that tree only** |

- One directory per `instance × arm` — never reuse another arm’s tree.
- **No global `azg setup` while running arms in parallel** (avoids `~/.cursor` bleed). Treatment = project apply in the cell worktree.
- Same model + budget for all 15 cells. Task Success = harness `resolved` only — never invent scores.

### One-shot recipe

```bash
# 0) Host
export PATH="$HOME/.local/bin:$PATH"
agent login                                    # once
python3 -m venv .venv-swebench && .venv-swebench/bin/pip install 'swebench>=2.0'
# Docker engine up; user in docker group (or score path uses newgrp)

# 1) Stubs
bash evals/prepare-lite-campaign.sh evals/lite/campaigns/<campaign-id>

# 2) Optional gold smoke (harness wiring)
.venv-swebench/bin/python -m swebench.harness.run_evaluation \
  --dataset_name princeton-nlp/SWE-bench_Lite \
  --predictions_path gold --instance_ids sympy__sympy-20590 \
  --max_workers 1 --run_id validate-gold

# 3) All cells (parallel; skips already-scored scorecards)
bash evals/run-lite-composer-campaign.sh --score --jobs 6
# one cell: bash evals/run-lite-composer-cell.sh <instance_id> <arm> --score

# 4) Promote
bash evals/analyze-lite-promote.sh evals/lite/campaigns/<campaign-id>
jq '{promote, pass_rate, success_pass}' evals/lite/campaigns/<campaign-id>/promote-result.json
```

Drivers: `evals/run-lite-composer-cell.sh` · `evals/run-lite-composer-campaign.sh`.  
Env: `LITE_MODEL` (default `composer-2.5`), `LITE_CAMP`, `LITE_JOBS`, `AZG_CURRENT_REF`, `AZG_CANDIDATE_REF`.

### Cleanup after a run

Keep: campaign scorecards, `predictions.jsonl`, `promote-result.json`, cell `harness-report.json`.  
Safe to delete: `evals/lite/worktrees/` (mirrors/cells), root `*.azg-lite-*.json` / `gold.*.json`, `logs/run_evaluation/`, old `CAMPAIGN*.log` copies. Re-create worktrees on next run.

---

## Manual / alternate agent path

Operator may still use IDE HITL instead of Agent CLI; keep model lock and isolation rules above. Steps below are the manual equivalent of what the drivers automate.

## Frozen slice

`instances.json` — **N=5** Lite `instance_id`s (data/numerical-Python bias), dataset `princeton-nlp/SWE-bench_Lite`, split `test`. Do not edit IDs mid-campaign; bump `version` + `locked_at` only in a separate change.

```bash
jq -r '.instance_ids[]' evals/lite/instances.json
```

## Arms

Per `CONTEXT.md` + ADR 0007. Same task, repo base commit, model, IDE, permissions, budget across arms — only harness treatment differs. **Which commits / Candidate text:** [`CAMPAIGN.md`](CAMPAIGN.md).

| Arm | Meaning |
|-----|---------|
| `baseline` | **No-Harness Baseline** — no `azg setup` / `azg apply` |
| `current` | **Current Treatment** — shipped azg without the Candidate change |
| `candidate` | **Candidate Treatment** — Current + proposed change under test |

**Not Current:** “main before any commit today.” **Is Current:** last shipped harness state with the Candidate change removed (see Live Campaign checkouts).

Between arms: re-run `azg setup` (and `azg apply` per repo) from the matching checkout so device defaults match the arm.

## Campaign layout

Persistent dir under repo (or sibling path you control). Example:

```
evals/lite/campaigns/<campaign-id>/
  <instance_id>/
    baseline/scorecard.json
    current/scorecard.json
    candidate/scorecard.json
    baseline/predictions.jsonl    # optional audit
    ...
  promote-result.json             # written by analyze-lite-promote.sh
```

**15 scorecards total (N=5 × 3).** `/tmp/azg-lite-*` from `run-lite-arm.sh` is machine-local prep only — copy scorecards (+ predictions, harness logs) into the campaign dir before switching machines. Campaign trees under `evals/lite/campaigns/` are gitignored by default.

## 1. Prepare

Bulk (preferred):

```bash
bash evals/prepare-lite-campaign.sh   # → evals/lite/campaigns/adr0009-YYYYMMDD/
# or: bash evals/prepare-lite-campaign.sh path/to/campaign
```

Builds all frozen IDs × three arms; leaves `task_success` null. Strips Windows jq CRLF on IDs.

Per arm (manual):

```bash
bash evals/run-lite-arm.sh <instance_id> <baseline|current|candidate>
# captures WORKDIR= and SCORECARD= from stdout
```

Copy into campaign tree if not using bulk prep:

```bash
CAMP=evals/lite/campaigns/<campaign-id>
INST=sympy__sympy-20590
ARM=current
mkdir -p "${CAMP}/${INST}/${ARM}"
cp "${WORKDIR}/scorecard.json" "${CAMP}/${INST}/${ARM}/"
```

## 2. Agent (per instance × arm)

1. Check out azg at the arm commit ([`CAMPAIGN.md`](CAMPAIGN.md)); `bash azg setup`.
2. Clone or open the SWE-bench task repo at the harness base commit (dataset metadata / `swebench` docs).
3. **Baseline:** no `azg apply`.
4. **Current / Candidate:** `bash azg apply <repo_root> --tracker none` (or project-appropriate tracker).
5. Run agent with **fixed** model + IDE + budget across all arms for that instance. Produce a unified-diff patch.
6. Write prediction JSONL (one line per instance run):

```json
{"instance_id":"<id>","model_name_or_path":"<arm>-<model>","model_patch":"<diff string>"}
```

Save as `${CAMP}/<instance_id>/<arm>/predictions.jsonl`. Agent runtime (Cursor IDE vs SDK vs other) is operator choice — keep constant within a campaign.

## 3. Score (harness → scorecard)

**Task Success = harness `resolved` only.** No human rubric, no guessed pass/fail.

```bash
python -m swebench.harness.run_evaluation \
  --dataset_name princeton-nlp/SWE-bench_Lite \
  --predictions_path "${CAMP}/${INST}/${ARM}/predictions.jsonl" \
  --instance_ids "${INST}" \
  --max_workers 1 \
  --run_id "azg-lite-${INST}-${ARM}"
```

Read per-instance report under harness logs (`logs/run_evaluation/.../report.json` or `evaluation_results/` per `swebench` version). Map `resolved: true` → `--task-success 1`, else `0`.

```bash
bash evals/record-lite-score.sh "${CAMP}/${INST}/${ARM}/scorecard.json" \
  --task-success 0 \
  --delivery-cost 12345 \
  --notes "harness run_id=azg-lite-${INST}-${ARM} resolved=false"
```

- `--delivery-cost` optional; **Delivery Cost** informational only (ADR 0007) — not a promote gate.
- Incomplete harness run (error / timeout) → `task_success 0` + note reason.
- **Never** fill `task_success` without a harness result.

Optional gold smoke:

```bash
python -m swebench.harness.run_evaluation \
  --predictions_path gold \
  --instance_ids sympy__sympy-20590 \
  --max_workers 1 \
  --run_id validate-gold
```

## 4. Analyze (promote math)

When all 15 scorecards filled (5 × 3):

```bash
bash evals/analyze-lite-promote.sh "${CAMP}"
```

Writes `${CAMP}/promote-result.json`. Promote iff `candidate_pass_rate >= current` **and** `>= baseline` (Task Success only). Delivery Cost medians reported when present — not a gate.

```bash
jq '{promote, pass_rate, success_pass}' "${CAMP}/promote-result.json"
```

**Do not invent outcomes.** Adopt/revert follows this file after a real harness campaign.

## Artifacts / audit

| Artifact | Where |
|----------|-------|
| Filled scorecards | `${CAMP}/<instance>/<arm>/scorecard.json` |
| Predictions | `${CAMP}/<instance>/<arm>/predictions.jsonl` |
| Harness logs | `${CAMP}/<instance>/<arm>/harness-logs/` (copy from harness output) |
| Promote decision | `${CAMP}/promote-result.json` |
| Arm commits | Record in Live Campaign file + campaign-dir README or issue comment |

Unfilled `task_success: null` scorecards are stubs, not evidence.

## Quick reference

```bash
# Live Campaign (Candidate + checkouts + last result)
# → evals/lite/CAMPAIGN.md

# prepare (15 stubs)
bash evals/prepare-lite-campaign.sh

# proven parallel Composer run + score
bash evals/run-lite-composer-campaign.sh --score --jobs 6

# prepare (single arm stub only)
bash evals/run-lite-arm.sh <id> baseline|current|candidate

# after harness (manual)
bash evals/record-lite-score.sh <scorecard.json> --task-success 0|1 [--delivery-cost N]

# after all 15 filled
bash evals/analyze-lite-promote.sh <campaign_dir>

# scaffold self-check (no Docker)
bash tests/test-lite.sh
```

Docs: [SWE-bench evaluation guide](https://www.swebench.com/SWE-bench/guides/evaluation/) · ADR 0007 · [`CAMPAIGN.md`](CAMPAIGN.md).
