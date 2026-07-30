# Active Task: Fix macOS CI Bash 3.2 mapfile failure

- **Status:** Done — committing and pushing to re-run CI
- **Objective:** Stop recurring main-branch macOS CI red; document trap so it does not recur
- **Acceptance:** `azg setup` works under `/bin/bash` 3.2; phase0/3/8/9 + cursor-device-setup green; docs + CI guard for Bash 4-only builtins
- **Issue/Ticket:** CI main macos-latest (run 30566753405 et al.)

## Work Packet (SFDBN)

- **Status:** Done — replaced `mapfile` with two `read`s; CI/docs/tests guard Bash 3.2 safety
- **Files:** `lib/setup.sh`, `lib/common.sh`, `.github/workflows/ci.yml`, `tests/test-phase0.sh`, `docs/agents/current-state.md`, `docs/AGENT-ONBOARDING.md`, `docs/agents/device-handoff-cursor-setup.md`, `AGENTS.md`, `docs/FRONTIER-REVAMP-EVAL-PROMPT.md`, `task.md`
- **Decisions:** Keep `lib/` Bash 3.2-safe (match GHA macos-latest); do not brew-install bash in CI (would hide regressions); ubuntu/windows were already green
- **Blocked:** None
- **Next:** Watch Actions run 30568500528 for macos-latest green

## Todo
- [x] Diagnose macos-only aggregate failures across recent main runs
- [x] Replace `mapfile` in `lib/setup.sh`
- [x] Add CI + phase0 regression guard
- [x] Update docs / onboarding pitfall
- [x] Re-verify under `/bin/bash` 3.2

## Blockers / Notes
- Root cause: `lib/setup.sh` used Bash 4 `mapfile` → exit 127 on macOS 3.2 → phase3/8/9 cascade
- Older all-OS reds (shellcheck warnings as errors) already fixed by `14a460a`
