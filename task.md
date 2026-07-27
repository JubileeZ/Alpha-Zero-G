# Active Task: Device vendor sync + setup

- **Status:** Done
- **Objective:** Refresh Alpha-Zero-G repo, re-vendor upstream skills, and reinstall global config on this device
- **Acceptance:** `azg update`, `azg update --vendor`, and `azg setup --force` succeed; VENDOR.lock dates current; 28 skills in `~/.gemini/antigravity-cli`
- **Issue/Ticket:** —

## Work Packet (SFDBN)

- **Status:** Done — repo pulled, vendor synced, device setup forced
- **Files:** `templates/global/skills/vendor/mattpocock-skills/VENDOR.lock`, `templates/global/skills/vendor/ponytail-skills/VENDOR.lock`
- **Decisions:** Ran full maintenance sequence (`update` → `update --vendor` → `setup --force`); skill trees unchanged (commits pinned); only `date_vendored` refreshed to 2026-07-27
- **Blocked:** None
- **Next:** None — maintenance complete; discard or commit VENDOR.lock if keeping checkpoint

## Todo
- [x] `azg update` (repo → `a615f79`)
- [x] `azg update --vendor` (mattpocock `ed37663`, ponytail `16f2980`)
- [x] `azg setup --force` (28 skills → `~/.gemini/antigravity-cli`)

## Blockers / Notes
- Device global install is live; repo has unstaged VENDOR.lock date bumps until Checkpoint
