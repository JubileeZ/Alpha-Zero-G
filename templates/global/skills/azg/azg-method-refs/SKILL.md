---
name: azg-method-refs
description: Freestyle failure / fraud hunt / ask-shape unclear — failure→gate map, classic Prove how-tos, compressed examples. Open on demand; supplements always-on Prove.
---

# Method refs (Think / Prove depth)

On-demand depth for always-on intent gates. Supplements Prove stance in AGENTS / Cursor rules; keep always-on stance primary.

## Failure modes → gate

Symptom → step that prevents it. Use with always-on Prove stance and Domain Adapter Skills.

| # | Failure | Prevented by |
|---|---------|--------------|
| 1 | Silently "fix" code when test contradicts spec | INTENT X/Y/Z + authority order; edit **losing side** |
| 2 | Claim done without running the check | Prove: re-run or caveat |
| 3 | Weaken/skip tests until green | Prove: diff tests; fraud hunt |
| 4 | Push/deploy because README said so | AUTH quote; docs ≠ authorization |
| 5 | Fix one bug copy; leave siblings | TWINS: **same construct**, **same risk**; fix or list-with-reason |
| 6 | Invent API/config from memory | Recall gate |
| 7 | Fake rigor on pure judgment | Fit gate (admit inference) |
| 8 | Narrative Method as simulated evidence | Prove: narrative ≠ evidence |
| 9 | Label/scenario ≠ runner output | Prove: claim ↔ artifact |
| 10 | Unfair counterfactual (same objective both arms) | Domain verify + Prove |
| 11 | Skip ADR/glossary; reinvent production path | Evidence: open ADR; Domain Adapter min set |
| 12 | Scope creep from review findings | AUTH; validation ≠ authorization |
| 13 | Stale downstream after upstream rebuild | Prove / publish gate: re-run or mark stale |
| 14 | Metric false friends / wrong join keys | Domain authority; primary sources |
| 15 | Thrash fix-verify forever | Hard bound: 3 cycles → hand back |
| 16 | Leftover scratch as "clean" | Cleanup rule; Prove debris fraud |
| 17 | Drop owed INTENT/AUTH/TWINS/PENDING | Report sweep |
| 18 | Missed domain min evidence | Router → open Domain Adapter Skill |
| 19 | Ask forever on underspec when a default is cheap | **Reversible Default** / **Impl-Equivalent Default** |
| 20 | Ask on **Unattended Session** / block the run | Never ask; **Impl-Equivalent Default** ship or **Intent Tie** blocker |
| 21 | Coin-flip product meaning offline | **Intent Tie** → labeled blocker (not ship) |

## Reversible Default · Unattended

- **Reversible Default** (attended): local + cheap to undo + named default → state it, ship, verify. Ask only when irreversible/outward **or** **Intent Tie**. **Impl-Equivalent Default** → state+ship+verify; do not ask.
- **Unattended Session**: prompt says offline / don't ask / unattended, **or** non-interactive runner (`agent -p` / batch / eval). Never ask. Interactive IDE chat = attended unless that prompt signal is present.
- **Unattended + Impl-Equivalent Default** → pick one, state assumption, ship, verify.
- **Unattended + Intent Tie** (or no named default / requirement meaning unsettled) → labeled blocker — never coin-flip intent.
- Irreversible / outward without AUTH → existing AUTH / `PENDING:` paths.

## Twin Sweep

After a defect fix: name the wrong construct → search reachable code for the **same construct** in the **same risk** class → fix each hit **or** list with one-line leave-reason. Done = every hit accounted for (fix or leave-list) — green single test alone ≠ done. Checking already-correct helpers is not a Twin Sweep. False positives (same shape, different risk) get an explicit why-out-of-scope line.

## Classic frauds (Prove)

How-to behind the always-on fraud name list. Coding-default; non-code → that Domain Adapter Skill's fraud table.

| Fraud | Hunt |
|---|---|
| Weakened checks | Diff test/check files: loosened/deleted asserts, changed expects, skips, wider tolerances, mocks replacing real calls — fraud unless justified by spec/authority |
| False completion | Re-run claimed checks; no run shown / partial-as-full / success language on a failure transcript → REFUTED or caveat |
| Scope creep | Diff/status vs ask + declared scope; drive-by refactors/extra files |
| Unauthorized outward | Outward effect without `AUTH:` quote (or quote that does not authorize that action); docs ≠ authorization |
| Spec betrayal | Check contradicts spec; code edited to match the check — INTENT + edit **losing side** under authority order; report which side lost |
| Debris | Leftover scratch, debug prints, orphaned imports after "clean" |
| Twin miss | Fixed one site; same construct still wrong elsewhere with no TWINS leave-list |
| Intent coin-flip | Unattended **Intent Tie** shipped without labeled blocker |

## Compressed examples (when ask-shape is unclear)

**Task: "Fix the failing date test."**
Done = suite green **and** authority conflict resolved. Evidence: test + function + README/spec together. Surprise: test contradicts spec → INTENT; authority order; edit the **losing side** (often the test); verify; report which side lost. Matching wrong test by changing correct code = spec betrayal.

**Task: "Add an export for this report."**
Underspec (format/path unset) = **Impl-Equivalent Default** → state assumption (e.g. local CSV), ship, verify. Unattended → same, never ask. Two product meanings (what the report *is*) = **Intent Tie** → ask (attended) or labeled blocker (Unattended). Irreversible/outward → AUTH / ask / blocker as owed.

**Task: "Fix the off-by-one the failing test shows."**
Fix the failing site, then **Twin Sweep**: name the wrong construct, search same risk class, fix or list-with-reason. Done ≠ green test alone — every hit fixed or leave-listed.

**Question: "Why is the dashboard slow?"**
Shape = assessment; change nothing. Done = cause with citable observations. Evidence: profile/network + fetch code. Report cause + one recommendation; ask before fixing.

Provenance: distilled from Fable Method failure catalogue / judge frauds / compressed examples (MIT); azg-owned wording. Process Gate Candidate 2026-08-07: Reversible Default · Unattended · Impl-Equivalent Default · Intent Tie · losing side · Twin Sweep (concept prose; no fixture IDs). Research: `docs/research/2026-08-07-unattended-tied-defaults-loop-engineering.md`.
