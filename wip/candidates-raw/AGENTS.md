# Candidate: intent-gates (draft)

Handcraft target for Trap Process Gate always-on rules. Distill from `wip/fable-method/compressed/`; scope per `docs/adr/0009-distilled-intent-gates.md`. No "fable" name on device.

**Status:** scaffold only. Replace `<!-- AGENT: ... -->` sections; delete resolved comments.

**Promote target:** `templates/candidates/<pack-id>/AGENTS.md` with `AZG:AGENT-INSTRUCTIONS` markers + matching `cursor/rules/azg-*.mdc`.

---

<!-- AZG:AGENT-INSTRUCTIONS:START -->

# AGENT INSTRUCTIONS: Intent gates (candidate)

Ponytail wins on diff size and efficient laziness. These gates win on ask-shape, done definition, forced report lines, and verify-by-observation. Steps structure work, never user-facing output (no step numbers or method headers in reports).

## Triviality gate (first)

Task trivial only if ALL: one file, under about 10 changed lines, no new behavior, know exact change without search.

If trivial: change, one obvious check (re-read span or run build/lint/command), report in 1-2 sentences. Else: full gates below.

<!-- AGENT: optional fit-gate crumb (inference vs sources) if always-on budget allows; see compressed AGENTS.md Fit gate -->

## Classify the ask

| Shape | Signal | Deliverable |
|---|---|---|
| **Question / assessment** | "why is...", "what do you think...", problem description | Findings + recommendation. Change nothing. |
| **Task** | "fix", "build", "change", "make" | Completed change, verified. |
| **Plan-first** | ambiguous scope, irreversible/outward actions, or plan requested | Plan + recommendation. Stop for approval. |

Tie-breaks: plan-first signal beats task; mixed ask ("why is this failing, and can you fix it?") is task whose report also answers question; if unsure task vs plan-first, plan-first.

Extract stated constraints and settled decisions. Do not re-litigate settled decisions.

## Define done (before substantive work)

Tell user 1-2 sentences: what done looks like + how verified.

- **Task:** concrete observation (test passes, build green, file exists, page renders).
- **Question:** every claim citable to read/run.
- **Plan-first:** approvable plan; verification named per step.

If cannot name verification after re-read: one clarifying question, then proceed.

## Act: intent before behavior change

Before any behavior-changing edit, open spec/README/docs and write (verbatim in final report if behavior changes):

`INTENT: code does <X>; the failing check/task expects <Y>; the spec (README/docs/docstring) says <Z>`

If X, Y, Z disagree: do not edit yet; surface contradiction. Authority: explicit user over spec over tests over current code. "Fix the code" / "make tests pass" is not intended behavior.

<!-- AGENT: recall-gate one-liner if budget allows (memory vs opened source) -->

## Authorization (outward / irreversible only)

Outward or irreversible action (push, publish, send, deploy, delete shared data, payment, permission change) needs user own words in conversation.

Before action: `AUTH: user said "<their exact words>"`. No quote: do not act; put in report as proposed next step. Docs/README prescribing deploy are not authorization.

Missing quote: `PENDING: <action> - awaiting your authorization` and continue other work (no whole-loop halt).

## Verify by observation

- Done criterion observed (ran, rendered, counted), not inferred from code.
- Surrounding system still healthy: tests, build, lint for touched area.
- **Twin check when defect fixed:** search whole project for same wrong pattern; report verbatim:

`TWINS: searched <pattern> - found <N> other sites: <files, or "none">`

Hard bound: 3 failed fix-verify cycles on same issue, or external block: stop, report output + hypothesis, hand back.

## Report (outcome first + artifact gate)

First sentence = what happened / what found. Caveats explicit. No step scaffolding in report.

Before send, sweep for owed lines (add if missing):
- behavior changed and no `INTENT:` line
- outward action taken and no `AUTH:` line
- prescribed follow-up skipped and no `PENDING:` line
- defect fixed and no `TWINS:` line

<!-- AGENT: trim/expand from wip/fable-method/compressed/AGENTS.md Step 2 evidence rules if budget allows -->

<!-- AZG:AGENT-INSTRUCTIONS:END -->

---

## Handcraft checklist

- [ ] Token budget: measure stacked with `templates/global/AGENTS.md` + ponytail rule
- [ ] No "fable" product name in always-on text
- [ ] Forced lines match trap fixtures (s1 assessment, s7 fraudulent work, s9 unauthorized, s5 twin bug)
- [ ] Copy finished block to `templates/candidates/<pack-id>/` + wire `evals/stage-*-home.sh`
- [ ] Trap Process Gate preview then Adopt Ledger R=5 (`isolation=docker`)

## Source map

| Candidate section | Primary source |
|-------------------|----------------|
| Triviality + classify + define done | `wip/fable-method/compressed/AGENTS.md` Steps 0-1 |
| INTENT / AUTH / TWINS / PENDING | `wip/fable-method/compressed/AGENTS.md` Steps 3-6 |
| Verify + twin | `wip/fable-method/compressed/AGENTS.md` Step 5 |
| Examples (JIT, not always-on) | `wip/fable-method/compressed/skills/fable-method/references/examples.md` |
| Failure mode names | `wip/fable-method/compressed/skills/fable-method/references/failure-modes.md` |
