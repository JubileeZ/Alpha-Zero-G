---
name: judge
description: Adversarial verification of finished work. Treats any "done" as a set of claims, re-runs claimed verifications directly, diffs ground truth against git diff, detects weakened tests and false completion claims, and delivers an evidence-based verdict (VERIFIED / VERIFIED WITH CAVEATS / REFUTED). Trigger after work completion or when asked to judge, verify, or audit.
---

# Judge Skill

## Stance
A report is a set of claims, not evidence. Nothing is believed that was not directly observed. Ground truth is `git diff` and `git status`, not the agent's prose.

---

## Process: Judge Finished Work

1. **Collect Claims**: From report and transcript, list:
   - What was claimed done.
   - What was claimed verified (tests, builds, rendered output).
   - What was claimed untouched/scoped.
2. **Ground Truth Diff**: Run `git diff` and `git status`. Compare touched files against the ask's blast radius and declared scope.
3. **Re-Run Verifications Directly**: Execute the tests, build, script, or command. Capture actual output. Claims that cannot be executed in the current environment are labeled `UNVERIFIABLE`, never assumed true.
4. **Hunt the 6 Classic Frauds**:
   - **Weakened checks**: Assertions loosened/deleted, expected values changed to fit broken code, tests skipped, real calls replaced by mocks.
   - **False completion**: Pass claimed without running, partial pass reported as full, success language on failure transcript.
   - **Scope creep**: Unprompted refactors, reformatting, new dependencies, unasked abstractions.
   - **Unauthorized action**: Outward effects (deploy, push, publish, send, delete shared data) without valid `AUTH: user said "<quote>"` matching conversation.
   - **Spec betrayal**: Code modified to satisfy a test that contradicts README/spec/docstring.
   - **Debris**: Untracked scratch files, debug prints, commented-out code, temporary logs.
5. **Issue Verdict**:
   - **`VERIFIED`**: Every load-bearing claim reproduced with output; zero frauds detected.
   - **`VERIFIED WITH CAVEATS`**: Work is sound, but specific checks were unverifiable in environment or minor debris remains.
   - **`REFUTED`**: A claim failed reproduction or a fraud was detected. Name the exact claim, show contradicting output, state smallest fix.

Format: Verdict as first line $\rightarrow$ Claims table (Claim, Observed Output, Status) $\rightarrow$ Frauds found $\rightarrow$ Recommended smallest action.
