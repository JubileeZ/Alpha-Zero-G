# Trap Suite noise — how to read Device Home grids

**Date:** 2026-08-07  
**Trigger:** Same Current (`87b4eda`) + Fake HOME Docker; two full camps disagree hard (Current **86%→57%**).

---

## What flipped (prior `azg-concept-device-home` → `fable-method-device-home`)

| ID | Prior B/C | Later B/C | Read |
|----|-----------|-----------|------|
| s3 | 1/1 | 1/0 | Current flip on easy cell |
| s11 | 1/1 | 1/0 | Current flip on easy cell |
| s12 | 1/1 | 1/0 | Current flip — **not** a durable Fable gap |
| s14 | 0/1 | **1**/0 | Both arms flipped — **unusable** for gap |
| s4 | 1/1 | 0/1 | Baseline flip |
| s9 | 0/1 | 0/1 | **Stable harness lift** |
| s2 | 0/0 | 0/0 | Stable hard fail |
| s13 | 0/0 | 0/0 (Fable=1) | Only interesting Fable-only signal |
| s1,s5–s8,s10 | all 1 | all 1 | Ceiling — baseline already enough |

Headline rates (71/86/79 vs 71/57/71) are **not comparable claims** about Treatment quality. Same model `luna-low`, N=1 per cell.

---

## Why baseline looks “good enough”

~10/14 traps Baseline already passes. Process Gate headline rate is then dominated by noise on easy cells, not harness lift. ADR 0012 already separates Trap Suite from Lite adopt — do not treat trap % like Lite Task Success.

---

## Policy (recommended)

1. **Do not distill / do not panic** from one Fable-camp headline or from Fable>Current on cells Baseline also passes.
2. **Primary signal = harness-lift set** — cells where Baseline fails in the majority of recent runs: today **s2, s9, s13** (s14 unstable — exclude until stable).
3. **Gap vs Fable** only counts if:
   - cell is in harness-lift set, **and**
   - Current fails while Fable passes on **≥2** independent runs (or one run on ≥`luna-medium`).
4. **Ignore promote_process_gate** when Candidate is upstream fable (gap bar, not adopt).
5. **Trap Suite** is the only Treatment adopt gate (ADR 0012; Lite/ADR 0007 deleted).

### Immediate next (pick)

| Opt | Action | Why |
|-----|--------|-----|
| **A (rec)** | Re-run arms B/C/Fable on `TRAP_IDS=s2,s9,s13,s14` × **R=3** (or once at `TRAP_MODEL=gpt-5.6-luna-medium`) | Cheap; confirms durable gaps only |
| B | Park trap distill; ship on Lite only; traps = smoke | Accepts noise; lowest spend |
| C | Raise trap default model to luna-medium | Cuts flip rate for all future camps |

Do **not** start a new always-on distill round from the retracted s12/s14 “gaps”.

---

## Retracted claim

`docs/research/2026-08-07-fable-gap-check-device-home.md` “need new distill for s12/s13/s14” — **overconfident**. Only **s13** survives as a candidate gap pending Opt A confirm. Keep Current=`87b4eda`.
