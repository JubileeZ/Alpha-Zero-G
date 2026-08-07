# Live Campaign

Overwrite this file when the Candidate under test changes. Procedure: [`README.md`](README.md) (**Proven automation**).

## Under test

| Field | Value |
|-------|-------|
| Candidate | ADR 0009 distilled intent-gates (`AZG:AGENT-INSTRUCTIONS` in `templates/global/AGENTS.md`) |
| Map | [#85](https://github.com/JubileeZ/alpha-zero-g/issues/85) Lite 3-arm: adopt or revert ADR 0009 intent-gates |
| Promote rule | Task Success only: `candidate_pass_rate >= current` and `>= baseline` (ADR 0007 / 0009) |

## Arm checkouts

| Arm | azg checkout for `apply` (into cell worktree) | Notes |
|-----|-----------------------------------------------|-------|
| `baseline` | n/a | No azg |
| `current` | `d2df37f^` (= `fef3e84`) | Shipped harness **without** intent-gates Candidate |
| `candidate` | `d2df37f` or later HEAD | Gates present (Precedence · Triviality · INTENT/AUTH/TWINS/PENDING · expanded verify · report sweep) |

Parallel runs: **apply-only** into `worktrees/cells/<id>/<arm>/` — do **not** global `azg setup` across arms at once (see README isolation).

## Campaign tree

**Path:** `evals/lite/campaigns/adr0009-20260801-n5/` (gitignored):

```bash
bash evals/prepare-lite-campaign.sh evals/lite/campaigns/adr0009-20260801-n5
bash evals/run-lite-composer-campaign.sh --score --jobs 12
bash evals/analyze-lite-promote.sh evals/lite/campaigns/adr0009-20260801-n5
```

## Result (Composer 2.5 · 2026-08-01)

| Arm | Pass rate |
|-----|-----------|
| baseline | 5/5 (1.0) |
| current | 5/5 (1.0) |
| candidate | 5/5 (1.0) |

**`promote=true`** — `evals/lite/campaigns/adr0009-20260801-n5/promote-result.json` (local). Model lock: Composer 2.5 · Agent CLI parallel · Docker harness.

## Frontier

[#85](https://github.com/JubileeZ/alpha-zero-g/issues/85)/[#88](https://github.com/JubileeZ/alpha-zero-g/issues/88)–[#90](https://github.com/JubileeZ/alpha-zero-g/issues/90) **closed** — intent-gates **adopted** (`promote=true`). Next Live Campaign: overwrite this file when Candidate under test changes.
