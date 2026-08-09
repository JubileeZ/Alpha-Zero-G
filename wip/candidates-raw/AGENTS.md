# Task Execution Protocol

Follow it literally. Steps structure work, never output: do not narrate step numbers or step headers in anything the user reads.

**Pre-Loop Gates**

**Triviality gate (run first).** 
Task trivial only if ALL true:
    one file,
    under about 10 changed lines,
    no new behavior, 
    know exactly what to change without searching. 
If trivial: 
    make change, 
    confirm with one obvious check (re-read changed span, or run build/lint/command it affects), 
    report in one or two sentences.
Everything else, anything unsure:
    Fit gate. then run the loop.

**Fit gate (Run after Triviality gate, before run the loop).** 
Loop turns judgment problems into evidence problems when answer reachable; cannot supply judgment living only in your head. 
first locate where the answer is, and route:
    - **In sources you can open** (spec, file, dataset, check, docs): run the loop. Default.
    - **In established technique you do not yet know:** research first (One round lookups plus one follow-up covers most tasks; third needs stated reason. Two consecutive lookups told nothing new: stop.), then run the loop.
    - **Only in own inference, nothing to open or look up:** say so. Do not dress guess as rigorous process (costume). Attended: ask whether to proceed with flagged low-confidence answer. Unattended: proceed but label low-confidence, never silently.fallback everywhere is honest hand-back.

Whenever gate routes anywhere but "run the loop", name choice in report (what missing, what instead). Silent detour is indistinguishable from skipped step.

**The loop**

# AGENTS.md - [Your Name]

> Portable protocol for any agent/harness. Follow literally.

## Usage
[command list - protocol default / plan mode / audit mode / report mode]

## Triviality gate
[one-line criteria + skip-to-report instruction]

---

## The Protocol

### Step 0 - Classify the ask
[shape table: question / task / plan-first]
[tie-break rules]

### Step 1 - Define done
[per-shape verification requirement]

### Step 2 - Gather evidence
[primary-source rule]
[parallelize rule]
[BACKTRACK EDGE: surprise → back to Step 0/1]

### Step 3 - Decide and commit
[one recommendation rule]
[escalation check: → Orchestrator trigger, see below]

### Step 4 - Act surgically
[intent gate]
[smallest-change rule]

### Step 5 - Verify by observation
[two-halves check]
[RETRY EDGE: mechanical fail → Step 4, surprising fail → Step 2]
[hard bound: 3 cycles → stop]

### Step 6 - Report outcome-first
[format rule]
[AUDITOR trigger, see below]

---

## Escalation triggers (pointers only, logic lives in skills)

- **Unattended run, or task needs subagent fan-out** → invoke `orchestrator` skill
  at Step 3, do not run Steps 4-6 inline
- **After any work (yours or another agent's) is claimed done** → invoke `auditor`
  skill before presenting as finished
- **Domain-specific task (marketing/legal/finance/etc.)** → load matching adapter
  from `references/domains/` at Step 1, before defining done

## Reference index (load on demand, not by default)

| Trigger | File |
|---|---|
| Hit a failure you don't recognize | `references/failure-modes.md` |
| Unsure how to apply a step to this ask-shape | `references/examples.md` |
| Need the branch logic as a diagram | `references/flowcharts.md` |
| Task matches a specific sector | `references/domains/<sector>.md` |

## Modes
[plan / audit / report - one line each, pointing back to which steps they run]


