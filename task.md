# Active Task: Lite map #85 — campaign prepare

- **Status:** In Progress (map mid-flight)
- **Objective:** Wayfind ADR 0009 Lite adopt/revert to a real promote decision
- **Acceptance:** `promote-result.json` from filled N=10×3 scorecards; then adopt or revert gates
- **Issue/Ticket:** Map [#85](https://github.com/JubileeZ/alpha-zero-g/issues/85)

## Work Packet (SFDBN)

- **Status:** Docs reshape done (grill). Frontier still [#88](https://github.com/JubileeZ/alpha-zero-g/issues/88) — needs Docker/`swebench`. Prep stubs exist locally (gitignored).
- **Files:** `evals/lite/README.md` (general how-to + Campaign cost envelope) · `evals/lite/CAMPAIGN.md` (Live Campaign) · deleted `OPERATOR.md` · `CONTEXT.md` (Live Campaign, Campaign cost envelope) · `evals/prepare-lite-campaign.sh`
- **Decisions:** Evaluation Suite how-to = README; Live Campaign = CAMPAIGN.md (overwrite per Candidate); delete OPERATOR; Campaign cost envelope ≠ Delivery Cost.
- **Blocked:** Full score fill needs host with Docker + `swebench` + agent budget for N=10×3.
- **Next:** On harness host: claim [#88](https://github.com/JubileeZ/alpha-zero-g/issues/88); follow `evals/lite/README.md` + `CAMPAIGN.md` against campaign tree; record harness `resolved` only.

## Todo
- [x] [#86](https://github.com/JubileeZ/alpha-zero-g/issues/86) operator runbook → folded into README + CAMPAIGN
- [x] [#87](https://github.com/JubileeZ/alpha-zero-g/issues/87) prepare campaign tree
- [x] Grill: README framework / CAMPAIGN live / delete OPERATOR / cost envelope glossary
- [ ] [#88](https://github.com/JubileeZ/alpha-zero-g/issues/88) run + record Task Success
- [ ] [#89](https://github.com/JubileeZ/alpha-zero-g/issues/89) analyze promote
- [ ] [#90](https://github.com/JubileeZ/alpha-zero-g/issues/90) adopt or revert

## Blockers / Notes
- Local campaign tree gitignored; copy or rebuild on harness machine.
- Current arm = `d2df37f^` (`fef3e84`); Candidate = `d2df37f`+ (see CAMPAIGN.md).
