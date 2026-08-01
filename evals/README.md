# Evaluation Suite

Official gate: **SWE-bench Lite 3-arm** (ADR 0007). See [`lite/README.md`](lite/README.md).

```bash
bash evals/run-lite-arm.sh <instance_id> baseline|current|candidate
bash evals/record-lite-score.sh <workdir>/scorecard.json --task-success 1 [--delivery-cost N]
bash evals/analyze-lite-promote.sh <campaign_dir>
bash tests/test-lite.sh
```

Arms: No-Harness Baseline · Current Treatment · Candidate Treatment. Promote on Task Success only; Delivery Cost informational when present (ADR 0007).
