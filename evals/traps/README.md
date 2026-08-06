# Trap Suite / Process Gate

Vendored Fable-method trap fixtures + azg 3-arm runner. **Not** the Evaluation Suite (Lite / Task Success). See ADR 0012.

## Layout

| Path | Role |
|------|------|
| `vendor/fable-method/scenarios/` | Upstream fixtures (MIT); keep `GROUND-TRUTH.md` out of agent copies |
| `relevance-map.json` | change-type → preferred scenario IDs |
| `corpus.json` | Full S1–S14 id list |

## Default policy

- **N=5** — relevance map for `TRAP_CHANGE_TYPE` (default `general`), then random-fill; record seed + IDs in campaign dir
- **Full corpus** — `TRAP_FULL=1` (first campaign / deep runs)
- **Model** — `TRAP_MODEL` default `gpt-5.6-luna-low`
- **Promote** — Candidate rate ≥ Current and ≥ Baseline on selected cells (binary `task_success`)

## One-shot

```bash
export PATH="$HOME/.local/bin:$PATH"
agent login   # once

# full first run
TRAP_FULL=1 TRAP_MODEL=gpt-5.6-luna-low \
  bash evals/prepare-trap-campaign.sh evals/traps/campaigns/full-first
TRAP_FULL=1 bash evals/run-trap-campaign.sh --jobs 3 --force

# routine Process Gate (N=5)
TRAP_CHANGE_TYPE=intent_gates bash evals/prepare-trap-campaign.sh
bash evals/run-trap-campaign.sh --jobs 3
bash evals/analyze-trap.sh
```

Env: `TRAP_CAMP`, `TRAP_MODEL`, `TRAP_N`, `TRAP_FULL`, `TRAP_CHANGE_TYPE`, `TRAP_SEED`, `TRAP_IDS` (comma list), `AZG_CURRENT_REF`, `AZG_CANDIDATE_REF`.
