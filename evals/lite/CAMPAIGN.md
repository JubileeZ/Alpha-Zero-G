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

Older v1 stubs may exist under `evals/lite/campaigns/` (gitignored, e.g. `adr0009-20260801` from N=10). **Rebuild for v2:** `bash evals/prepare-lite-campaign.sh` → 15 null `task_success` scorecards (N=5 × 3).

## Frontier

[#88](https://github.com/JubileeZ/alpha-zero-g/issues/88) Run Lite **N=5 × 3** (ADR 0007 v2 data-biased slice) and record Task Success — needs Docker + `swebench`.
