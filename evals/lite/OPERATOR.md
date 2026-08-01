# Lite 3-arm operator runbook (ADR 0007 / 0009)

Frozen N=10 SWE-bench Lite slice · three arms · Task Success only promote · any clone with Docker + `swebench`.

Map: [#85](https://github.com/JubileeZ/alpha-zero-g/issues/85). Candidate under test: ADR 0009 distilled intent-gates (`AZG:AGENT-INSTRUCTIONS` in `templates/global/AGENTS.md`, commit `d2df37f`).

## Prereqs

| Requirement | Notes |
|-------------|-------|
| Docker | Engine running; Linux post-install steps if needed. ARM Mac: add `--namespace ''` to harness (local image build). |
| `swebench` | Upstream package from [SWE-bench/SWE-bench](https://github.com/SWE-bench/SWE-bench): `pip install swebench` (≥2.0). Entry: `python -m swebench.harness.run_evaluation`. |
| `jq` | Scorecard + promote scripts. |
| `azg` clone | This repo on the machine that runs agents + harness. |
| Disk | Harness env images ~100 GB cached; plan headroom for instance images + logs. |
| Time | First harness pull/build: hours. Per-instance agent + eval: model-dependent. Full N=10 × 3 arms: multi-day wall clock typical. |

No device lock-in — campaign dir must live outside `/tmp` (see Artifacts).

## Frozen slice

`evals/lite/instances.json` — 10 `instance_id`s, dataset `princeton-nlp/SWE-bench_Lite`, split `test`. Do not edit IDs mid-campaign; bump `version` + `locked_at` only in a separate change.

```bash
jq -r '.instance_ids[]' evals/lite/instances.json
```

## Arms (ADR 0009 campaign)

Per `CONTEXT.md` + ADR 0007/0009. Same task, repo base commit, model, IDE, permissions, budget across arms — only harness treatment differs.

| Arm | Harness | ADR 0009 delta |
|-----|---------|----------------|
| `baseline` | **No** `azg setup` / `azg apply`. Bare agent on SWE-bench repo checkout. | n/a |
| `current` | Shipped azg **without** intent-gates Candidate. Device + project harness from commit **`d2df37f^`** (parent of gates landing). | absent |
| `candidate` | Current Treatment **plus** proposed intent-gates in `AZG:AGENT-INSTRUCTIONS`. Device + project harness from **`d2df37f`** or later HEAD. | present (Precedence · Triviality · INTENT/AUTH/TWINS/PENDING · expanded verify · report sweep) |

**Not Current:** “main before any commit today.” **Is Current:** last shipped harness state with Candidate change removed — here, `d2df37f^` for the `AZG:AGENT-INSTRUCTIONS` block only; ponytail + other azg blocks match Candidate checkout.

Between arms: re-run `azg setup` (and `azg apply` per repo) from the matching checkout so device defaults (Cursor `azg-agent-instructions.mdc`, Gemini `AGENTS.md`) match the arm.

```bash
# Current arm device refresh (example)
git checkout 'd2df37f^'
bash azg setup
# Candidate arm device refresh
git checkout main   # or d2df37f+
bash azg setup
```

## Campaign layout

Persistent dir under repo (or sibling path you control). Example:

```
evals/lite/campaigns/adr0009-<YYYYMMDD>/
  <instance_id>/
    baseline/scorecard.json
    current/scorecard.json
    candidate/scorecard.json
    baseline/predictions.jsonl    # optional audit
    ...
  promote-result.json             # written by analyze-lite-promote.sh
```

`/tmp/azg-lite-*` from `run-lite-arm.sh` is machine-local prep only — copy scorecards (+ predictions, harness logs) into campaign dir before switching machines or rebooting. Prior stub layout (`/tmp/azg-lite-adr0009-*`) is a reference shape only, not portable input.

## 1. Prepare

For each `instance_id` × arm:

```bash
bash evals/run-lite-arm.sh <instance_id> <baseline|current|candidate>
# captures WORKDIR= and SCORECARD= from stdout
```

`run-lite-arm.sh` validates ID against frozen list, seeds `scorecard.json` (`task_success` null), writes `INSTANCE.txt` / `ARM.txt`. Harness/current/candidate arms also stub `project/` (real repo comes from SWE-bench checkout).

Copy each scorecard into campaign tree:

```bash
CAMP=evals/lite/campaigns/adr0009-$(date -u +%Y%m%d)
INST=django__django-11001
ARM=current
mkdir -p "${CAMP}/${INST}/${ARM}"
cp "${WORKDIR}/scorecard.json" "${CAMP}/${INST}/${ARM}/"
```

## 2. Agent (per instance × arm)

1. Check out azg at the arm commit (see Arms table); `bash azg setup`.
2. Clone or open the SWE-bench task repo at the harness base commit (from dataset metadata / `swebench` docs).
3. **Baseline:** no `azg apply`.
4. **Current / Candidate:** `bash azg apply <repo_root> --tracker none` (or project-appropriate tracker).
5. Run agent with **fixed** model + IDE + budget across all arms for that instance. Produce a unified-diff patch for the issue.
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

Read per-instance report under harness logs (`logs/run_evaluation/.../report.json` or `evaluation_results/` per installed `swebench` version). Map `resolved: true` → `--task-success 1`, else `0`.

```bash
bash evals/record-lite-score.sh "${CAMP}/${INST}/${ARM}/scorecard.json" \
  --task-success 0 \
  --delivery-cost 12345 \
  --notes "harness run_id=azg-lite-${INST}-${ARM} resolved=false"
```

- `--delivery-cost` optional; informational only (ADR 0007).
- Incomplete harness run (error / timeout) → `task_success 0` + note reason.
- **Never** fill `task_success` without a harness result.

Validate gold once (optional smoke):

```bash
python -m swebench.harness.run_evaluation \
  --predictions_path gold \
  --instance_ids sympy__sympy-20590 \
  --max_workers 1 \
  --run_id validate-gold
```

## 4. Analyze (promote math)

When all 30 scorecards filled (10 instances × 3 arms):

```bash
bash evals/analyze-lite-promote.sh "${CAMP}"
```

Writes `${CAMP}/promote-result.json`. Promote iff `candidate_pass_rate >= current` **and** `>= baseline` (Task Success only). Delivery cost medians reported when present — not a gate.

```bash
jq '{promote, pass_rate, success_pass}' "${CAMP}/promote-result.json"
```

**Do not invent outcomes.** ADR 0009 adopt/revert decision follows this file after a real harness campaign.

## Artifacts / audit

| Artifact | Where |
|----------|-------|
| Filled scorecards | `${CAMP}/<instance>/<arm>/scorecard.json` |
| Predictions | `${CAMP}/<instance>/<arm>/predictions.jsonl` |
| Harness logs | Copy relevant `logs/` or `evaluation_results/` subtree into `${CAMP}/<instance>/<arm>/harness-logs/` |
| Promote decision | `${CAMP}/promote-result.json` |
| azg commits used | Record `current=d2df37f^`, `candidate=<sha>` in campaign README or issue comment |

Commit campaign results to repo, attach to map issue, or gist — pick one path and stick to it for the run. Unfilled `task_success: null` scorecards are stubs, not evidence.

## Quick reference

```bash
# prepare
bash evals/run-lite-arm.sh <id> baseline|current|candidate

# after harness
bash evals/record-lite-score.sh <scorecard.json> --task-success 0|1 [--delivery-cost N]

# after all 30 filled
bash evals/analyze-lite-promote.sh <campaign_dir>

# scaffold self-check (no Docker)
bash tests/test-lite.sh
```

Docs: [SWE-bench evaluation guide](https://www.swebench.com/SWE-bench/guides/evaluation/) · ADR 0007 · ADR 0009 · `evals/lite/README.md`.
