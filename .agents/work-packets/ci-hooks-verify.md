# Active Task: ci-hooks-verify

- **Status:** In Progress
- **Objective:** Make CI `run-all` green on ubuntu + macos after Work Packet / Cursor adapter landing
- **Acceptance:** `bash tests/test-phase4.sh`, `test-phase5.sh`, `test-phase2.sh`, `test-mutation-verify.sh`, `host-contract-smoke.sh` pass; Cursor adapter `100755`
- **Issue/Ticket:** none

## Work Packet (SFDBN)

- **Status:** Local failing suites green; push next
- **Files:** `tests/verify.sh` `templates/project/tests/verify.sh` `tests/test-phase5.sh` `.cursor/hooks/block-destructive-ops.sh`
- **Decisions:** Guard empty `_azg_packets[@]` for Bash 3.2 `set -u`. Git mode `100755` on Cursor safety adapter. Phase5 copies sibling `commit-scan.sh`. Leave `continuity-hooks` unstaged.
- **Blocked:** None
- **Next:** Push; watch CI

## Todo
- [x] Diagnose CI logs
- [x] Apply fixes + local failing suites
- [ ] Push

## Blockers / Notes
- Root cause is Stop/Work-Packet landing (`adc8dbd`), not the vendor pin.
