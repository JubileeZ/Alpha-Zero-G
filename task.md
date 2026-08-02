# Active Task: ADR 0010 follow-up — prune/setup efficiency

- **Status:** Done — Checkpoint
- **Objective:** Harden azg skill prune ownership; compress always-on Router; share skill install helper; inline method-refs
- **Acceptance:** phase9 + cursor-device-setup + run-all green; device re-setup applied
- **Issue/Ticket:** ADR 0010 follow-up

## Work Packet (SFDBN)

- **Status:** Done
- **Files:** `lib/apply-overlay.sh` · `lib/setup.sh` · `templates/global/AGENTS.md` · `templates/global/skills/azg/azg-method-refs/` · `tests/test-phase9.sh` · `tests/test-cursor-device-setup.sh` · `docs/adr/0010-*.md`
- **Decisions:** Prune ownership = source dir under `templates/global/skills/azg/` (not note prose). Keep empty `overlay/azg/tool-map.json`. Leave `work-state-continuity.mdc` (repo + project template) for later. Router stays one line naming all four skills.
- **Blocked:** None
- **Next:** Optional: drop duplicate `work-state-continuity.mdc` (repo + `templates/project/`) once tests/docs updated; other devices run `azg setup`

## Todo
- [x] Prune guard → directory test + phase9 fixture
- [x] Compress Router; keep skill names
- [x] `_install_skill_pair` shared helper
- [x] Inline method-refs table; delete `references/`
- [x] run-all / device setup / re-setup this host
- [x] Continuity docs + Checkpoint

## Blockers / Notes
- Shellcheck not installed locally — aggregate skips lint; CI still runs it
- Continuity delete (#2) deferred pending explicit choice (this-repo rule vs project template)
