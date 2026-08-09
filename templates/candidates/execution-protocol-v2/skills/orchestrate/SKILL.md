---
name: orchestrate
description: >
  Orchestrates complex multi-step work under resident AGENTS.md Execution Protocol —
  parallel evidence subagents, plan artifact + approval stop, surgical execute,
  adversarial verifier subagents, outcome-first report. Use for "/orchestrate",
  multi-area evidence, long unattended/multi-phase, or large blast radius — not
  for every non-trivial task (core protocol is the default).
trigger: /orchestrate
---

# orchestrate

Orchestrates the Execution Protocol in resident `AGENTS.md`: protocol says WHAT to check; this skill says WHO does the work (main thread vs fan-out vs adversarial verify). Does not redefine core protocol steps.

**Gate first.** Trivial per protocol triviality gate: do it, one obvious check, report in two sentences. No stages, no subagents.

**Entry (high bar).** Invoke when user asks (`/orchestrate`) **or** any of: multi-area evidence needed · long unattended / multi-phase · large blast radius. Do **not** escalate merely because triviality failed.

## Stage 1 - PLAN

1. Apply protocol Steps 0–3: classify, define done + named verification, state assumptions.
2. **Evidence fan-out.** Parallel subagents in ONE message: Explore per distinct area; research agent for library/docs/web. Distilled findings with citations. One batch + one follow-up; third needs stated reason.
3. **Plan artifact:** classification; done + verification; evidence (cited); ONE approach (alternatives one line each); scope (exact files/surfaces); risks/assumptions; execution checklist.
4. **Decision gate.** Task-shaped + reversible → Stage 2 without asking. Plan-first → present plan, STOP for approval.

## Stage 2 - EXECUTE

1. Checklist in **main thread** (todo tool if available). Decide/edit main thread; search/verify may fan out.
2. Every edit: protocol Step 4 (intent, recall, smallest change, precise edits).
3. Independent mechanical items may fan out in one message; worktree isolation if shared files.
4. Surprise → protocol Step 2 rule 7; update plan or return Stage 1. Never force plan through surprise.
5. Mid-item memory fact → pause; research subagent; resume.
6. Outward checklist items → authorization gate; no quote → proposed next step in report.

## Stage 3 - VERIFY (adversarially)

1. Named verification yourself: done criterion observed + surrounding health (build/tests/lint).
2. **Consequential changes:** spawn 1–3 attacker subagents with distinct lenses (diff wrong/incomplete; runtime break; spec contradiction; scope creep vs plan). Prefer `judge` skill for deep fraud-hunt.
3. Surviving finding → Stage 2. Hard bound: 3 failed fix-verify cycles or external blocker → stop, hand back with output + hypothesis.

## Stage 4 - AUDIT and REPORT

1. Self-audit: each protocol step followed / skipped / faked; fix what one pass can (verify now or caveat).
2. Deliver per protocol Step 6: outcome first; evidence; honest caveats; INTENT/AUTH/PENDING/TWINS when owed. No stage names in user report.

## When NOT to use

- Trivial tasks.
- Pure questions / assessments with no multi-step work — core protocol enough.
- Already inside an orchestrated outer workflow — do not nest orchestrate loops.
- Ordinary single-area coding that fits one context — core protocol default.

## Model economy

Evidence/attacker subagents: cheaper models OK. Main thread (decide/edit): strongest available. Attackers: higher effort than gatherers when choice exists.
