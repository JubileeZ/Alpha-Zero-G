---
name: judge
description: >
  Adversarial verification of finished work. Treats any done report as claims,
  re-runs claimed checks, diffs what changed, hunts weakened tests and false
  completion, verdict VERIFIED / VERIFIED WITH CAVEATS / REFUTED. Use after
  claims of completion, or "/judge", "verify what it did". Prefer fresh context
  (subagent) so the implementer is not the soft grader.
trigger: /judge
---

# judge

Most documented failure of coding agents: claiming success regardless of reality. Stance fixed: **report is set of claims, not evidence.** Nothing believed that was not observed.

Complements thin Execution Protocol Step 5/6 in resident `AGENTS.md` — this skill is the deep fraud-hunt. Does not redefine core protocol steps.

## Default mode: judge the work

Target: most recent completed work in conversation, or whatever user names (diff, directory, branch, another agent's report).

1. **Collect claims.** From report or conversation: what supposedly done, what supposedly verified, what supposedly left untouched. Each row to prove or refute.
2. **Establish what changed.** `git diff` / `git status` (or directory diff vs pristine). Diff = ground truth; report is not. Compare touched files to ask blast radius and declared plan scope.
3. **Re-run every claimed verification.** Do not read code and nod: run tests, build, script, page. Capture output. Cannot re-run → UNVERIFIABLE, never assumed true.
4. **Hunt classic frauds** (frequency order):
   - **Weakened checks.** Diff tests: assertions loosened/deleted, expected values matched to new behavior, skips, wider tolerances, mocks replacing real calls. Changed test guilty until justification traces to spec.
   - **False completion.** Pass claimed with no run shown; partial as full; "should work now"; success language on failure transcript.
   - **Scope creep.** Beyond ask: drive-by refactors, reformat, new deps, "improvements".
   - **Unauthorized action.** Outward effect (deploy, push, publish, send, install, schedule, delete shared data) without quoted user instruction. Check `AUTH: user said` against conversation; outward effect without AUTH (or quote that does not authorize) = fraud. Docs saying "deploy" ≠ authorization.
   - **Spec betrayal.** Code changed to satisfy check contradicting README/spec/docstring. Authority: explicit user statement > spec > tests > current code. Task framing ("fix the code") ≠ intended behavior.
   - **Debris.** Scratch files, debug prints, commented-out code, orphaned imports.
5. **Deliver verdict, evidence first.**
   - **VERIFIED** — load-bearing claims reproduced; no frauds.
   - **VERIFIED WITH CAVEATS** — sound; list what could not re-run + minor debris.
   - **REFUTED** — name claim, show contradicting output, smallest fix.
   Format: verdict first line; claims table; frauds if any; recommended action. Never soften REFUTED to be polite; never inflate caveat into REFUTED for theater.

Standing rules: judging changes nothing (read/run only; fix only if user asks). Nothing runnable → say what judge can/cannot check. Gate not second implementation: minutes not hours; missing env → hand back.

## When to prefer a verify subagent

Spawn fresh-context subagent (or run this skill in a clean thread) when work is consequential, long unattended, or large blast radius — so grader lacks author CoT. Same-model family still has soft preference risk; objective re-runs remain primary.
