# Active Task: Cursor global agent-instructions rule

- **Status:** Checkpoint ready
- **Objective:** Mirror Gemini global AGENTS.md agent-instruction blocks into Cursor `azg-*.mdc` (device setup)
- **Acceptance:** `azg-agent-instructions.mdc` installed by `azg setup`; `tests/test-cursor-device-setup.sh` green
- **Issue/Ticket:** Follow-on to https://github.com/JubileeZ/alpha-zero-g/issues/56

## Work Packet (SFDBN)

- **Status:** Implemented; verified on device (`azg setup` + suite)
- **Files:** `templates/global/cursor/rules/azg-agent-instructions.mdc`, `tests/test-cursor-device-setup.sh`, `docs/agents/device-handoff-cursor-setup.md`, `docs/agents/current-state.md`, `task.md`, `.agents/session-handoff.md`
- **Decisions:** Cursor has no user-global AGENTS.md — agent-instruction sections (placeholders, temp cleanup, telegraphic) ship as `azg-agent-instructions.mdc` alongside `azg-ponytail.mdc`; ownership via existing `azg-*.mdc` path
- **Blocked:** None
- **Next:** Commit; optional merge/PR; keep `find-skills` (npx) unless user wants it removed

## Todo
- [x] Add `azg-agent-instructions.mdc` template
- [x] Extend device-setup tests + handoff checklist
- [x] Run `azg setup` on this device
- [x] Update Work Packet / continuity
- [x] Checkpoint commit

## Blockers / Notes
- Operator already uninstalled npx `mattpocock/skills`; device uses `azg setup` for skills + rules
