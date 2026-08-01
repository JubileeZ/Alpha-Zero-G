# Active Task: spawn-budget residual risks (grill package)

- **Status:** Implemented — awaiting commit if desired
- **Objective:** Assert residual audit risks; fix gitignore + slot-lifecycle smoke; accept RMW race + finish-without-id with ADR/ponytail docs; glossary Spawn Budget
- **Acceptance:** `bash tests/host-contract-smoke.sh` + `bash tests/verify.sh` green; `.agents/spawn-state.json` gitignored
- **Issue/Ticket:** —

## Work Packet (SFDBN)

- **Status:** Done locally — not committed
- **Files:** `.gitignore` · `templates/project/.gitignore` · `lib/scaffold.sh` · `.agents/hooks/spawn-budget.sh` · `templates/project/.agents/hooks/spawn-budget.sh` · `tests/host-contract-smoke.sh` · `docs/adr/0006-spawn-budget-pretooluse.md` · `CONTEXT.md`
- **Decisions:** gitignore state; automate allow→deny→finish→reuse; ponytail no-flock; finish needs id (ADR); Spawn Budget glossary term
- **Blocked:** None
- **Next:** Commit on request

## Todo
- [x] Grill package implemented + verified

## Blockers / Notes
- `azg apply` does not yet append spawn-state ignore to existing project `.gitignore` (scaffold/`azg new` only)
