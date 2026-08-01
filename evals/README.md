# Evaluation Suite

Official gate: **SWE-bench Lite 3-arm** (ADR 0007).

- How to run: [`lite/README.md`](lite/README.md)
- Live Campaign (Candidate + checkouts): [`lite/CAMPAIGN.md`](lite/CAMPAIGN.md)

```bash
bash evals/prepare-lite-campaign.sh
bash evals/run-lite-arm.sh <instance_id> baseline|current|candidate
bash evals/record-lite-score.sh <workdir>/scorecard.json --task-success 1 [--delivery-cost N]
bash evals/analyze-lite-promote.sh <campaign_dir>
bash tests/test-lite.sh
```

Arms: No-Harness Baseline · Current Treatment · Candidate Treatment. Promote on Task Success only; Delivery Cost informational when present (ADR 0007). See **Campaign cost envelope** in `lite/README.md` for operator disk/time/spend planning.
