---
name: azg-method-refs
description: Failure-mode to rule map, fraud how-tos, and compressed ask-shape examples for always-on agent instructions. Open when diagnosing freestyle failures, hunting fraud, or ask-shape unclear. Not a substitute for claim re-check before done.
---

# azg-method-refs

On-demand depth for always-on agent instructions (classify, done, evidence, `INTENT:` / `AUTH:` / `TWINS:` / `PENDING:`, verify, claim re-check).

## Failure modes → rule

| # | Failure | Symptom | Prevented by |
|---|---------|---------|--------------|
| 1 | Unprompted fixing | User asked why; agent edited | Classify: question → findings only |
| 2 | Wrong-deliverable guess | Built A; user meant B | Ambiguous-scope test; one pointed question |
| 3 | Re-litigating settled | Reopens user decisions | Extract settled decisions |
| 4 | Fake done | No named verification | Define done before work |
| 5 | Invented APIs | Endpoints/signatures from memory | Primary sources; recall gate |
| 6 | Sequential crawling | One lookup at a time | Parallel independent lookups |
| 7 | Context flooding | Whole files/logs dumped | Read narrow; quote load-bearing only |
| 8 | Analysis paralysis | Research after it stopped changing plan | Two rounds then stop |
| 9 | Plowing surprises | Forced plan through contradiction | State surprise; re-route |
| 10 | Option-dump | A/B/C with no recommendation | One recommendation |
| 11 | Scope creep | Drive-by refactors | Declared scope; smallest change |
| 12 | Silent step-drop | Checklist item never ran | Written checklist; audit vs ask |
| 13 | Retry thrash | Same fix forever | 3-cycle hard bound → hand back |
| 14 | Verification theater | "Should work" with nothing run | Observed verify both halves |
| 15 | Unauthorized outward | Deploy/push because README said so | AUTH quote; docs ≠ authorization |
| 16 | Dropped follow-up | Prescribed deploy never mentioned | PENDING line |
| 17 | Missed siblings | Fixed one site; copies remain | TWINS search whole project |
| 18 | Guess dressed as rigor | Thorough shape, no search behind | Fit gate; named TWINS search |

Also open `references/failure-modes.md` for the extended catalogue.

## Classic frauds (claim re-check)

| Fraud | Hunt |
|---|---|
| Weakened checks | Diff tests: loosened asserts, skips, wider tolerances |
| False completion | Re-run claimed checks; success language on failure transcript |
| Scope creep | Diff vs ask + declared scope |
| Unauthorized outward | Outward effect without AUTH quote |
| Spec betrayal | Code satisfies check that contradicts spec — INTENT + authority |
| Missed siblings | Same wrong construct elsewhere; no TWINS line |
| Debris | Scratch/debug left after "clean" |

## Compressed examples

**Task: "Fix the failing date test."**
Done = suite (incl. date test) green. Evidence: test + function; surprise: test right, function drops timezone. One edit; verify; report outcome-first.

**Question: "Why is the dashboard slow?"**
Shape = assessment; change nothing. Done = citable cause. Evidence: profile + fetch code. Report cause + one recommendation; ask before fix.

Provenance: Fable Method failure catalogue / judge frauds (MIT); azg-owned wording.
