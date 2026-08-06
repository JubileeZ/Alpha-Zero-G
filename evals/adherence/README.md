# Adherence mini-campaign (gate process, not Lite Task Success)

Prove Intent-gate / Domain-adapter **adherence** with a Lite-*shaped* 3-arm layout on a cheap model. **Not** the official Evaluation Suite (ADR 0007 / SWE-bench). Do not use `analyze-lite-promote.sh` for this.

## Arms

| Arm | Treatment |
|-----|-----------|
| `baseline` | Fixture only — no `AZG:AGENT-INSTRUCTIONS`, no azg domain skills |
| `current` | Pre-lever azg @ `2e6ff14` (AGENTS + skills before writing-for-agents pass) |
| `candidate` | Post-lever azg @ campaign candidate ref (default `HEAD`) |

Same 5 frozen prompts × 3 arms = **15 cells**. Same model for all cells.

## Model lock

Default: `gpt-5.6-luna` (lowest-cost GPT-5.6). Override: `ADHERENCE_MODEL`.

```bash
export PATH="$HOME/.local/bin:$PATH"
agent login   # or CURSOR_API_KEY
```

## One-shot

```bash
# stubs
bash evals/prepare-adherence-campaign.sh evals/adherence/campaigns/wfa-lever-luna

# all cells (skips filled scorecards)
ADHERENCE_MODEL=gpt-5.6-luna bash evals/run-adherence-campaign.sh --jobs 3

# one cell
bash evals/run-adherence-cell.sh trivial baseline
bash evals/run-adherence-cell.sh research candidate

# rates (heuristic auto-score; override in scorecard if wrong)
bash evals/analyze-adherence.sh evals/adherence/campaigns/wfa-lever-luna
```

Env: `ADHERENCE_CAMP`, `ADHERENCE_MODEL`, `ADHERENCE_JOBS`, `AZG_CURRENT_REF` (default `2e6ff14`), `AZG_CANDIDATE_REF` (default `HEAD`).

## Scoring

Binary per cell (`task_success` 0|1) via heuristic on agent transcript (see `evals/score-adherence-transcript.sh`). Pass rule for Candidate: rate ≥ Current and ≥ Baseline on total; rows `nontrivial` and `outward` must not regress vs Current.

Human may set `"score_override": 0|1` in `scorecard.json` — analyze prefers override.
