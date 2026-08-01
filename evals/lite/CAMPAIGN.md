# Live Campaign

Overwrite this file when the Candidate under test changes. Procedure: [`README.md`](README.md).

## Under test

| Field | Value |
|-------|-------|
| Candidate | ADR 0009 distilled intent-gates (`AZG:AGENT-INSTRUCTIONS` in `templates/global/AGENTS.md`) |
| Map | [#85](https://github.com/JubileeZ/alpha-zero-g/issues/85) Lite 3-arm: adopt or revert ADR 0009 intent-gates |
| Promote rule | Task Success only: `candidate_pass_rate >= current` and `>= baseline` (ADR 0007 / 0009) |

## Arm checkouts

| Arm | azg checkout for `setup` / `apply` | Notes |
|-----|-------------------------------------|-------|
| `baseline` | n/a | No azg |
| `current` | `d2df37f^` (= `fef3e84`) | Shipped harness **without** intent-gates Candidate |
| `candidate` | `d2df37f` or later HEAD | Gates present (Precedence · Triviality · INTENT/AUTH/TWINS/PENDING · expanded verify · report sweep) |

Between arms: re-run `azg setup` from the matching checkout.

## Campaign tree (this host)

Prepared stubs (gitignored): `evals/lite/campaigns/adr0009-20260801-n5/` — **15** null `task_success` scorecards (ADR 0007 v2). Older `adr0009-20260801` was N=10 v1 — ignore. Rebuild anytime: `bash evals/prepare-lite-campaign.sh`.

## Frontier

[#88](https://github.com/JubileeZ/alpha-zero-g/issues/88) Run Lite **N=5 × 3** (ADR 0007 v2 data-biased slice) and record Task Success — needs Docker + `swebench`.
