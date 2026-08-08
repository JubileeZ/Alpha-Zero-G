---
name: orchestrate
description: Orchestrates complex or multi-step tasks within the AGENTS.md pipeline. Dispatches parallel evidence subagents, creates an approved plan artifact, executes with intent/recall gates, and deploys adversarial verifier subagents. Trigger when scope is ambiguous, actions are irreversible, evidence needs parallel fan-out, or the run is unattended.
---

# Orchestrate Skill

## Inherits
This skill runs inside the resident `AGENTS.md` pipeline. It does not redefine §0–§6. It replaces HOW §1.3 evidence and §4 verification are executed: via subagents instead of inline.

## Subagent Rule Overrides
- **Evidence subagents**: Inherit §1, IGNORE §3.
- **Verifier subagents**: Inherit §4/§5, IGNORE §3.
- **Implementation subagents**: Inherit all sections.

---

## Stage 1: Plan (The First Bookend)
1. **Classify & Define Done**: Follow §1.1 and §1.2. State load-bearing assumptions.
2. **Parallel Evidence Fan-Out**: Spawn independent lookups in ONE parallel batch:
   - Codebase exploration subagents (distinct subsystems/callers).
   - Research subagents (docs/web lookups).
   - Max 2 lookup batches.
3. **Plan Artifact**: Deliver: classification, done criteria + named verification, cited evidence, 1 recommended approach (alternatives 1 line each), declared scope, risks, execution checklist.
4. **Decision Gate**:
   - Task-shaped & reversible: proceed to Stage 2.
   - Plan-first (ambiguous scope, irreversible outward actions, or requested plan): present plan and STOP for user approval.

---

## Stage 2: Execute
1. **Main Thread Checklist**: Work checklist sequentially in main thread. Deciding and editing stay in main thread.
2. **Surgical Edits**: Follow §2. Enforce `INTENT:` line before behavior edits and recall gate before unopened symbols.
3. **Parallel Isolated Edits**: Independent mechanical changes across disjoint files may fan out to subagents with worktree isolation.
4. **Surprises & Ignorance**: Mid-work surprise re-routes to Stage 1. Unopened recall gap pauses item to fan out 1 research subagent.
5. **Authorization Gate**: Outward items strictly require quoted user authorization; without quote, defer to report.

---

## Stage 3: Verify (Adversarial)
1. **Direct Verification**: Main thread executes named done verification and surrounding health checks (tests, build, lint).
2. **Attacker Subagents**: For consequential changes, spawn 1–3 parallel attackers with distinct refutation lenses:
   - *Lens A (Diff completeness)*: Prove change is incomplete or introduces edge-case defects.
   - *Lens B (Runtime stress)*: Find an input or condition that breaks the behavior.
   - *Lens C (Spec contradiction)*: Prove change contradicts README/spec/docstring.
   - *Lens D (Scope creep)*: Prove unasked files or abstractions were touched.
3. **Hard Bound**: Attacker finding surviving check returns to Stage 2. Max 3 failed fix-verify cycles on same issue -> stop and report output + hypothesis.

---

## Stage 4: Audit & Report (The Second Bookend)
1. **Pre-Send Self-Audit**: Grade run against §6 terminal gate checklist. Relabel any unobserved claim as explicit caveat.
2. **Outcome-First Delivery**: First sentence answers what happened. Complete sentences, load-bearing quotes only. Sweep and enforce `INTENT:`, `AUTH:`, `TWINS:`, `PENDING:` lines.
