# Active Task: Spawn-budget teardown (ADR 0011)

- **Status:** In Progress
- **Objective:** Remove spawn-budget hook system (plan B)
- **Acceptance:** No spawn files/wires; tests green; ADR 0011; apply strips Downstream orphans
- **Issue/Ticket:** AGENTS grill spawn-budget decision

## Work Packet (SFDBN)

- **Status:** Implemented; landing commit
- **Files:** lib/apply.sh, lib/scaffold.sh, hooks.json, tests/*, docs/adr/0011
- **Decisions:** Full teardown; host owns subagent limits; ADR 0006 superseded
- **Blocked:** None
- **Next:** Downstream `azg apply` on client repos

## Todo
- [x] Delete spawn-budget runtime + template
- [x] apply/scaffold retirement + jq strip
- [x] Tests + docs + ADR 0011
- [ ] Downstream client reapply (operator)

## Blockers / Notes
- None
