# Active Task: vendor-mattpocock-pin

- **Status:** In Progress
- **Objective:** Pin mattpocock/skills to upstream `3cca18b` and reinstall Device Setup on this machine
- **Acceptance:** `VENDOR.lock` commit `3cca18b368ae95cdbdebbff572ccafa662551015`; `bash tests/test-phase3.sh` pass; `./azg setup --force` copies active skills
- **Issue/Ticket:** none

## Work Packet (SFDBN)

- **Status:** Catalog refreshed; device setup after push
- **Files:** `templates/global/skills/vendor/mattpocock-skills/` `VENDOR.lock`
- **Decisions:** Same skill set (18+7). Adopt pin (Skill-tool phrasing, YAML quotes, no auto-invoke user-invoked skills). Do not vendor `in-progress/` (`retro`, `implement-spec`). Leave `continuity-hooks` unstaged.
- **Blocked:** None
- **Next:** After push, `./azg setup --force`

## Todo
- [x] `./azg update --vendor` → pin `3cca18b`
- [x] `bash tests/test-phase3.sh`
- [ ] `./azg setup --force` this device

## Blockers / Notes
- Upstream 34 commits since `8b78b53`. No new engineering/productivity skills.
