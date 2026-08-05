# Active Task: Apply spawn-budget fix to downstream

- **Status:** Done — Checkpoint now
- **Objective:** Make `azg apply` strip SubagentStart; refresh fpl-jubilee-ascent
- **Acceptance:** phase10 asserts strip; fpl hooks.json has no SubagentStart
- **Issue/Ticket:** downstream apply follow-up

## Work Packet (SFDBN)

- **Status:** Done
- **Files:** `lib/apply.sh` · `tests/test-phase10.sh` · fpl apply (separate repo)
- **Decisions:** `del(.\"safety-gate\".SubagentStart)` on merge; only local client was fpl-jubilee-ascent
- **Blocked:** None
- **Next:** career-agent / jubilees-gambit absent locally — PENDING paths; push AUTH

## Todo
- [x] Fix apply merge del SubagentStart
- [x] phase10 regression
- [x] phase10 32 + host-contract 14
- [x] azg apply fpl-jubilee-ascent (SubagentStart false)
- [x] Checkpoint alpha-zero-g
- [ ] Commit fpl (downstream)

## Blockers / Notes
- Prior template-only fix `55f6a45` insufficient alone — apply merge kept left-only key
