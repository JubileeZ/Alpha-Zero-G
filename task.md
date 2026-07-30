# Active Task: Cursor Device Setup

- **Status:** Done (pending merge)
- **Objective:** Device Setup installs Cursor skills + azg-owned global rules without clobbering foreign assets
- **Acceptance:** tests/test-cursor-device-setup.sh green; phase8 green; checklist in docs/agents/device-handoff-cursor-setup.md
- **Issue/Ticket:** https://github.com/JubileeZ/alpha-zero-g/issues/56

## Work Packet (SFDBN)

- **Status:** Implemented on feature/cursor-device-setup; verified
- **Files:** lib/setup.sh, lib/uninstall.sh, lib/common.sh, lib/apply-overlay.sh, templates/global/cursor/, tests/test-cursor-device-setup.sh, docs/adr/0008, docs/agents/device-handoff-cursor-setup.md, CONTEXT.md
- **Decisions:** Copy skills to ~/.cursor/skills; azg-*.mdc rules; cursor_skills/cursor_rules ownership; AZG-OWNED.md sentinel
- **Blocked:** None
- **Next:** Merge PR; run azg setup on devices; close map #56

## Todo
- [x] Cursor Device Setup implementation
- [x] Ownership/uninstall
- [x] Tests + handoff checklist
- [ ] Merge to main

## Blockers / Notes
- Full run-all slow on Windows (~64s per setup × many suites); targeted suites used for gate
