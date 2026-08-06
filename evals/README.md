# Evaluation Suite

Official adopt gate: **SWE-bench Lite 3-arm** (ADR 0007). Default agent model: `gpt-5.6-luna-medium` (`LITE_MODEL`).

- How to run: [`lite/README.md`](lite/README.md)
- Live Campaign: [`lite/CAMPAIGN.md`](lite/CAMPAIGN.md)

**Process Gate** (Intent/Prove Candidates — not Lite): [`traps/README.md`](traps/README.md) (ADR 0012).

```bash
bash evals/prepare-lite-campaign.sh
bash evals/run-lite-arm.sh <instance_id> baseline|current|candidate
bash evals/record-lite-score.sh <workdir>/scorecard.json --task-success 1 [--delivery-cost N]
bash evals/analyze-lite-promote.sh <campaign_dir>
bash tests/test-lite.sh
```

Arms: No-Harness Baseline · Current Treatment · Candidate Treatment. Promote on Task Success only; Delivery Cost informational when present (ADR 0007). See **Campaign cost envelope** in `lite/README.md` for operator disk/time/spend planning.
