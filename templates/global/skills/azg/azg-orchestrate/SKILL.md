---
name: azg-orchestrate
description: Orchestrate a complex or unattended multi-area task — parallel evidence gatherers, one plan, main-thread edits, then attacker checks. Use when the user says "/azg-orchestrate", "orchestrate this", or "run the full orchestrated path". Prefer always-on intent gates for ordinary work.
---

# azg-orchestrate

Orchestrates the always-on Think gates (classify, done, evidence, INTENT/AUTH, verify, Prove). This skill says **who** does the work: main thread vs subagents. It does not replace Prove stance in always-on AGENTS / Cursor rules.

**Gate first.** Trivial per always-on triviality: do it, one check, two sentences. No stages.

## Stage 1 — Plan

1. Apply classify → define done → load-bearing assumptions.
2. **Evidence fan-out** — spawn Explore/research subagents in **one** parallel batch (code areas, docs, data). Distilled findings with citations only. One batch + one follow-up; third needs a stated reason.
3. **Plan artifact:** classification; done + verification; cited evidence; ONE approach (dismissed alternatives in one line each); exact file/surface scope; risks; execution checklist.
4. **Decision gate.** Task + reversible → Stage 2. Plan-first (ambiguous, irreversible outward, or user asked for a plan) → present plan and **STOP** for approval.

## Stage 2 — Execute

1. Work the checklist on the **main thread**. Deciding and editing stay here.
2. Every behavior change: `INTENT:` (X/Y/Z). Recall gate before unopened facts. Smallest correct change.
3. Independent mechanical items across many files may fan out once, with isolation if same files could collide.
4. Surprise → say it; update plan or return to Stage 1. Never force the plan through a contradiction.
5. Outward checklist items need `AUTH:` quote; else convert to `PENDING:` / proposed next step.

## Stage 3 — Verify (adversarial)

1. Run named verification yourself (done criterion + surrounding health).
2. For consequential changes, spawn 1–3 **attacker** subagents with distinct lenses (diff wrong/incomplete; runtime break; spec contradiction; scope creep).
3. Surviving findings → Stage 2. Hard bound: 3 failed cycles or external block → hand back.

## Stage 4 — Audit and report

1. Quick self-audit: which Think steps followed, skipped, or faked; fix one pass of unverified claims (verify or caveat).
2. Report outcome-first per always-on rules; include owed INTENT/AUTH/TWINS/PENDING and Prove verdict. No stage names in the user-facing report.

## When not to use

- Trivial edits; pure questions; already inside another orchestrator.
- Ordinary single-area tasks — always-on gates are enough.
