# Active Task: vendor-mattpocock-pin

- **Status:** In Progress
- **Objective:** Pin mattpocock/skills to upstream `3cca18b` and reinstall Device Setup on this machine
- **Acceptance:** `VENDOR.lock` commit `3cca18b368ae95cdbdebbff572ccafa662551015`; `bash tests/test-phase3.sh` pass; `./azg setup --force` copies active skills
- **Issue/Ticket:** none

## Work Packet (SFDBN)

- **Status:** Pin pushed; prereq scanner missed quoted Skill-tool names; device needs re-setup
- **Files:** `templates/global/skills/vendor/mattpocock-skills/` `VENDOR.lock` `lib/setup.sh`
- **Decisions:** Same skill set (18+7). Adopt pin. Scanner must treat `"grilling"` as a prereq, not only `/grilling`. Do not vendor `in-progress/`. Leave `continuity-hooks` unstaged.
- **Blocked:** None
- **Next:** Commit scanner fix, push, `./azg setup --force`

## Todo
- [x] `./azg update --vendor` → pin `3cca18b`
- [x] `bash tests/test-phase3.sh`
- [x] `./azg setup --force` this device (first pass pruned grilling/domain-modeling)
- [x] Fix `_scan_skill_prereqs` for quoted Skill-tool names
- [ ] Re-run `./azg setup --force` after scanner fix

## Blockers / Notes
- Upstream 34 commits since `8b78b53`. No new engineering/productivity skills.
