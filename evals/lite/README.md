# SWE-bench Lite adoption gate (ADR 0007)

Official Evaluation Suite. Automated Task Success only — no Blind Judge / humans.

## Arms

| Arm | Meaning |
|-----|---------|
| `baseline` | No-Harness Baseline |
| `current` | Current Treatment (shipped azg) |
| `candidate` | Candidate Treatment (current + proposed change) |

## Frozen slice

`instances.json` — N=10 Lite `instance_id`s. Bump `version` + `locked_at` to change the list.

## Operator flow

```bash
# Prepare scorecard stubs for one instance × three arms
bash evals/run-lite-arm.sh astropy__astropy-12907 baseline
bash evals/run-lite-arm.sh astropy__astropy-12907 current
bash evals/run-lite-arm.sh astropy__astropy-12907 candidate

# After agent runs + SWE-bench harness marks pass/fail, fill scorecards:
bash evals/record-lite-score.sh <workdir>/scorecard.json --task-success 1 --delivery-cost 12345

# Aggregate a campaign dir of scorecards → promote decision
bash evals/analyze-lite-promote.sh path/to/campaign/
```

Promote (strict): Candidate pass rate ≥ Current **and** ≥ Baseline. Delivery Cost is informational when present — **not** a promote gate (ADR 0007).

## Scaffold note

This tree prepares workdirs + promote math. Full SWE-bench Docker evaluation is external (`swebench` harness); wire predictions into scorecards after that run.
