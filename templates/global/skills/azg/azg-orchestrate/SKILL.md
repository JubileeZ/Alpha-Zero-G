---
name: azg-orchestrate
description: Orchestrate complex or offline multi-area work — parallel evidence gatherers, one plan, main-thread edits, attacker checks. Use when user says "/azg-orchestrate", "orchestrate this", or needs subagent fan-out / offline multi-step. Prefer always-on agent instructions for ordinary single-area work.
---

# azg-orchestrate

Says **who** does the work (main thread vs subagents). Always-on agent instructions say **what** to check (`INTENT:` / `AUTH:` / `TWINS:` / verify / claim re-check). Does not replace that claim re-check.

**Gate first.** Trivial per always-on triviality: do it, one check, 1–2 sentences. No stages.

## Stage 1 — Plan

1. Classify → define done → load-bearing assumptions (always-on agent instructions).
2. **Evidence fan-out** — spawn Explore/research subagents in **one** parallel batch. Distilled findings + citations only. One batch + one follow-up; third needs stated reason.
3. **Plan artifact:** classification; done + verification; cited evidence; ONE approach (dismissed alternatives one line each); exact file/surface scope; risks; execution checklist.
4. **Decision gate.** Task + reversible → Stage 2. Plan-first (ambiguous, irreversible outward, or user asked plan) → present plan and **STOP** for approval.

## Stage 2 — Execute

1. Work checklist on **main thread**. Deciding and editing stay here.
2. Every behavior change: `INTENT:` (X/Y/Z). Recall gate before unopened facts. Smallest correct change (Ponytail during act, after evidence).
3. Independent mechanical items across many files may fan out once; isolate if same files could collide.
4. Surprise → say it; update plan or return Stage 1. Never force plan through contradiction.
5. Outward checklist items need `AUTH:` quote; else `PENDING:` / proposed next step.
6. Mid-item ignorance → pause; research; resume. Do not invent from memory.

## Stage 3 — Verify (adversarial)

1. Named verification yourself: done criterion observed + surrounding health.
2. Consequential changes → spawn 1–3 **attacker** subagents, distinct lenses (diff wrong/incomplete; runtime break; spec contradiction; scope creep).
3. Surviving findings → Stage 2. Hard bound: 3 failed cycles or external block → hand back.

## Stage 4 — Audit and report

1. Self-audit: which always-on steps were followed, skipped, or claimed without observation; fix one pass of unverified claims.
2. Report outcome-first per always-on rules; include owed INTENT/AUTH/TWINS/PENDING and `VERIFIED:` / `CAVEATS:` / `REFUTED:` when owed. No stage names in the user report.

## When not to use

- Trivial edits; pure questions; already inside another orchestrator.
- Ordinary single-area tasks — always-on agent instructions are enough.

Provenance: Fable Method loop/orchestration ideas (MIT); azg-owned wording.
