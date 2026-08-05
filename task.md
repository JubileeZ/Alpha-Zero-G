# Active Task: AGENTS.md always-on budget grill

- **Status:** In progress — research done; budget decision pending
- **Objective:** Decide whether/how to shrink always-on global+project AGENTS load (token budget)
- **Acceptance:** Shared grill decisions locked; optional follow-up plan for template cuts (no silent AGENTS rewrite)
- **Issue/Ticket:** none yet

## Work Packet (SFDBN)

- **Status:** In progress
- **Files:** `docs/research/2026-08-05-agents-md-always-on-budget.md` · grill on `templates/global/AGENTS.md` + `templates/project/AGENTS.md.tmpl`
- **Decisions:** Optimize for token/context (A). Caveman / caveman-compress not default vendor. Industry: no standard tok#; Claude <~200 lines soft; Cursor <500 lines soft; Codex 32 KiB hard trunc; windows grow → keep absolute lean always-on + JIT. Research recommends budget B (≤3k) + no auto-scale with window — user not confirmed yet.
- **Blocked:** Waiting user pick on Q2 budget (A≤2k / B≤3k / C≤3.5k / D none)
- **Next:** Lock Q2 → which surfaces eligible to cut (project managed vs gates) → mechanism → shared understanding before any template edit

## Todo
- [x] Assess caveman / caveman-compress vs ponytail + AZG telegraphic
- [x] Primary-source research always-on budgets + growing windows
- [x] Write research note under `docs/research/`
- [ ] User confirms Q2 budget
- [ ] Finish grill (cut targets + mechanism)
- [ ] If approved: plan-first template changes (Lite risk if gates move)

## Blockers / Notes
- Prior task (SubagentStart apply strip) Done; fpl Checkpoint still PENDING AUTH/downstream
- Duplicate archive research note removed — canonical = `docs/research/2026-08-05-agents-md-always-on-budget.md`
