# Active Task: Canonical AGENTS.md → Cursor rule rendering

- **Status:** Complete; checkpoint `37d7217` on `main`
- **Objective:** Derive Cursor global rule prose from marked blocks in canonical `templates/global/AGENTS.md`
- **Acceptance:** Frontmatter-only Cursor stubs; `azg setup` renders matching bodies; malformed/empty markers fail; affected tests green
- **Issue/Ticket:** Follow-on to https://github.com/JubileeZ/alpha-zero-g/issues/56

## Work Packet (SFDBN)

- **Status:** Complete; targeted suite green (34/34); full gate + portable gate passed; committed `37d7217`
- **Files:** `templates/global/AGENTS.md`, `templates/global/cursor/rules/`, `lib/common.sh`, `lib/setup.sh`, `tests/test-cursor-device-setup.sh`, `CONTEXT.md`, `docs/adr/0008-global-ownership-boundary.md`, `docs/agents/current-state.md`, `docs/agents/device-handoff-cursor-setup.md`, `task.md`, `.agents/session-handoff.md`
- **Decisions:** `templates/global/AGENTS.md` canonical; `PONYTAIL:MANAGED` + `AZG:AGENT-INSTRUCTIONS` markers; Cursor stubs frontmatter-only; setup renders bodies; installed owned AGENTS.md migrates markers transactionally; missing/duplicate/reversed/empty markers hard-fail
- **Blocked:** Shellcheck unavailable in Git Bash (`shellcheck: command not found`); Python verifier unavailable; IDE lints clean
- **Next:** Delete merged `feature/cursor-device-setup`; operator `azg setup` on device

## Todo
- [x] Add explicit AGENTS.md marker pair
- [x] Reduce Cursor rule templates to frontmatter stubs
- [x] Add setup extraction, validation, and rendering
- [x] Add body equality and malformed-marker tests
- [x] Update architecture and handoff docs
- [x] Run full gate
- [x] Code review
- [x] Checkpoint commit (`37d7217`)

## Blockers / Notes
- Operator device requires `azg setup` after commit to refresh rendered rules
- No new dependencies
