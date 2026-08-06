# Active Task: AGENTS.md grill implement

- **Status:** In Progress
- **Objective:** Ship grill ledger for project AGENTS template + this repo retrofit; retire domain-vocabulary
- **Acceptance:** Template + AGENTS.md match ledger; domain-vocabulary gone; apply retires orphans; phase2/5/10 + test-azg + verify green
- **Issue/Ticket:** grill-with-docs session (no ticket)

## Work Packet (SFDBN)

- **Status:** Implemented; tests green; committing
- **Files:** templates/project/AGENTS.md.tmpl, AGENTS.md, progress.md(+tmpl), lib/apply.sh, tests/test-azg.sh, tests/test-phase2.sh, docs/agents/current-state.md; deleted domain-vocabulary skill/rule
- **Decisions:** User-triggered handoff; Safety Rules merge; Harness Safety = hook-deny only; Domain Vocab = domain.md + grill; restore missing docs via git then ask
- **Blocked:** None
- **Next:** Land commit; Downstream owners run `azg apply` later

## Todo
- [x] Implement template + repo AGENTS
- [x] Retire domain-vocabulary + tests/apply
- [x] Update progress handoff/cleanup
- [ ] Confirm commit succeeds

## Blockers / Notes
- Subagent code-review skipped (device kills Task subagents); in-process review only
