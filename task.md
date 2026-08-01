# Active Task: Lite map #85 — campaign prepare

- **Status:** In Progress (map mid-flight)
- **Objective:** Wayfind ADR 0009 Lite adopt/revert to a real promote decision
- **Acceptance:** `promote-result.json` from filled N=10×3 scorecards; then adopt or revert gates
- **Issue/Ticket:** Map [#85](https://github.com/JubileeZ/alpha-zero-g/issues/85)

## Work Packet (SFDBN)

- **Status:** Frontier after closed [#87](https://github.com/JubileeZ/alpha-zero-g/issues/87) → open [#88](https://github.com/JubileeZ/alpha-zero-g/issues/88) (agent + harness). Prep host had no Docker/`swebench`.
- **Files:** `evals/prepare-lite-campaign.sh` · `evals/lite/OPERATOR.md` · `evals/lite/campaigns/` (gitignored; local `adr0009-20260801` = 30 null stubs) · `tests/test-lite.sh` · `.gitignore`
- **Decisions:** Portable campaign under `evals/lite/campaigns/adr0009-*` (not `/tmp`). Bulk prep via `prepare-lite-campaign.sh` (CRLF strip for Windows jq). Stubs never invent `task_success`.
- **Blocked:** Full score fill needs host with Docker + `swebench` + agent budget for N=10×3.
- **Next:** On harness host: claim [#88](https://github.com/JubileeZ/alpha-zero-g/issues/88); follow `evals/lite/OPERATOR.md` §2–3 against `evals/lite/campaigns/adr0009-20260801/` (or re-run `prepare-lite-campaign.sh` there); record harness `resolved` only.

## Todo
- [x] [#86](https://github.com/JubileeZ/alpha-zero-g/issues/86) operator runbook
- [x] [#87](https://github.com/JubileeZ/alpha-zero-g/issues/87) prepare campaign tree
- [ ] [#88](https://github.com/JubileeZ/alpha-zero-g/issues/88) run + record Task Success
- [ ] [#89](https://github.com/JubileeZ/alpha-zero-g/issues/89) analyze promote
- [ ] [#90](https://github.com/JubileeZ/alpha-zero-g/issues/90) adopt or revert

## Blockers / Notes
- Local campaign tree gitignored; copy or rebuild on harness machine.
- Current arm = `d2df37f^` (`fef3e84`); Candidate = `d2df37f`+.
