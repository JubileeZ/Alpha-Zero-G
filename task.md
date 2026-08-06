# Active Task: Downstream azg apply & template alignment

- **Status:** Complete
- **Objective:** Reapply azg v4 harness and align AGENTS.md User Zone sections across downstream repos
- **Acceptance:** azg apply executed; retired files removed; AGENTS.md aligned; tests/verify.sh green across all repos
- **Issue/Ticket:** Downstream harness retrofit

## Work Packet (SFDBN)

- **Status:** Complete
- **Files:** AGENTS.md, .agents/hooks/checkpoint-scan.sh, .cursor/hooks/commit-verify.sh
- **Decisions:** User Zone sections aligned to template canonical sequence across alpha-zero-g, fpl-jubilee-ascent, career-agent, and jubilees-gambit
- **Blocked:** None
- **Next:** Push changes to GitHub remotes

## Todo
- [x] Align AGENTS.md User Zone section headers
- [x] Run azg apply across local downstream repos
- [x] Prune retired spawn-budget and domain-vocabulary files
- [x] Verify tests/verify.sh passing on all repos

## Blockers / Notes
- None
