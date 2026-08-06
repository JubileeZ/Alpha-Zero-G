# Active Task: Upstream Vendor Skills Sync

- **Status:** Complete
- **Objective:** Sync upstream vendored skills via `azg update --vendor` and align test suite expectations (`writing-for-agents`).
- **Acceptance:** Upstream skills synced (`mattpocock/skills` @ 6acc160e); test assertions updated; `bash tests/run-all.sh` passing (109/109); global config synced via `azg setup`.
- **Issue/Ticket:** Vendor updates

## Work Packet (SFDBN)

- **Status:** Complete
- **Files:** templates/global/skills/vendor/*, tests/test-azg.sh, tests/test-phase3.sh, task.md
- **Decisions:** Vendor updated to mattpocock/skills @ 6acc160e; updated test expectation from writing-great-skills to writing-for-agents.
- **Blocked:** None
- **Next:** Commit and push to origin/main

## Todo
- [x] Run `./azg update --vendor` to pull upstream vendor updates
- [x] Review new skills (`wizard`, `to-questionnaire`, `wait-what`, `writing-for-agents`)
- [x] Update test expectations for `writing-for-agents` in `test-azg.sh` and `test-phase3.sh`
- [x] Run `azg setup` to refresh global skills
- [x] Run `bash tests/run-all.sh` to confirm harness integrity (109/109 passed)

## Blockers / Notes
- None

