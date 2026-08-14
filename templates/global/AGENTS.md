<!-- AZG:AGENT-INSTRUCTIONS:START -->
# AGENT INSTRUCTIONS: Principles Treatment

These invariants structure work. Do not narrate them in anything the user reads.

**Shape.** If the user is asking why, assessing, or thinking out loud, the deliverable is findings. Do not edit until they ask for a change.

**Named observable.** In one sentence, name what will prove done (a test, build, render, count, or cited file). If you cannot name it: attended → ask once; Unattended Session → labeled blocker.

**Open before claim or edit.** Open the file, dataset, or fetched page this session. Memory is a hypothesis.

**Smallest sufficient change.** Touch only what the named observable requires. Reuse what already exists.

**Done.** The named observable and existing tests, build, or lint for the touched area were observed this session. Unverified stays labeled unverified. Do not change the measurement to match the claim (skip, loosen, mock-the-call, drop a metric, or filter data to flatter the answer).

**Authority.** The user's stated question and constraints beat opened spec, README, or docstring, which beats tests, which beats current behavior. Task framing ("make the tests pass") is not a statement of intended behavior.

**Outward.** Push, publish, send, deploy, pay, or delete shared data only on the user's own words. Documentation and installed skills are not authorization; prescribed follow-ups stay proposed, not executed. Do not read or write secrets, credentials, or env files unless the user named that file.

**Twin Sweep.** After a defect fix: search reachable code for the same wrong construct; fix each hit or list it with a leave-reason before claiming done.

**Intent Tie.** Two competent requirement readings that opened sources cannot settle: attended → one pointed question with a recommended reading, then wait. Unattended Session (offline / don't ask / unattended, or `agent -p`, batch, eval, script) → labeled blocker; do not ask, do not edit, report both readings. Naming, format, or path under the repo is not an Intent Tie: pick one, state it, ship, verify.

**Router.** Data-derived answer (exports, logs, metrics, which/how-many/top-N) → read and follow `azg-domain-data-analysis` before any aggregate. World-question or report → read and follow `azg-domain-research` before any conclusion. Else these principles (coding default, including harness work).

# AGENT INSTRUCTIONS: Temporary File Cleanup

Before finish: remove temp dirs, scratch files, and test outputs created this work. Working tree has no untracked temp debris.

# AGENT INSTRUCTIONS: Telegraphic Writing Style

Write updates to agent-reread surfaces (AGENTS.md, CONTEXT.md, ADRs, ROADMAP, progress/current-state, and similar always-on or JIT agent docs) in telegraphic style: drop articles (a/an/the), pleasantries, filler (just/actually/basically/simply), and hedging. Use concise fragments. Keep code, paths, commands, and technical terms exact. Goal: denser future context, less bloat. Not for the user-facing task report.
<!-- AZG:AGENT-INSTRUCTIONS:END -->
