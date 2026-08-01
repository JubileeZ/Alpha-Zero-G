# Active Task: Lite map #85 — campaign prepare

- **Status:** In Progress (map mid-flight)
- **Objective:** Wayfind ADR 0009 Lite adopt/revert to a real promote decision
- **Acceptance:** `promote-result.json` from filled **N=5×3 (15)** scorecards (ADR 0007 v2); then adopt or revert gates
- **Issue/Ticket:** Map [#85](https://github.com/JubileeZ/alpha-zero-g/issues/85)

## Work Packet (SFDBN)

- **Status:** Docs reshape done (grill). **ADR 0007 v2:** frozen slice **N=5** data-biased (astropy, matplotlib, seaborn, sklearn, sympy). Frontier still [#88](https://github.com/JubileeZ/alpha-zero-g/issues/88) — needs Docker/`swebench`. Rebuild stubs with `prepare-lite-campaign.sh` (15 null).
- **Files:** `evals/lite/instances.json` (N=5 v2) · `docs/adr/0007` (v2 note) · `evals/lite/README.md` (N=5 + Campaign cost envelope) · `evals/lite/CAMPAIGN.md` (Live Campaign) · `CONTEXT.md` · `evals/prepare-lite-campaign.sh` · `tests/test-lite.sh`
- **Decisions:** **ADR 0007 v2:** N=5 data-biased frozen slice (caps agent spend; IDE/CLI agent runs OK; harness still Docker). Evaluation Suite how-to = README; Live Campaign = CAMPAIGN.md; OPERATOR deleted; Campaign cost envelope ≠ Delivery Cost.
- **Blocked:** Full score fill needs host with Docker + `swebench` + agent budget for **N=5×3 (15 runs)**.
- **Next:** On harness host: claim [#88](https://github.com/JubileeZ/alpha-zero-g/issues/88); follow `evals/lite/README.md` + `CAMPAIGN.md` against **N=5** campaign tree; record harness `resolved` only.

## Todo
- [x] [#86](https://github.com/JubileeZ/alpha-zero-g/issues/86) operator runbook → folded into README + CAMPAIGN
- [x] [#87](https://github.com/JubileeZ/alpha-zero-g/issues/87) prepare campaign tree
- [x] Grill: README framework / CAMPAIGN live / delete OPERATOR / cost envelope glossary / **ADR 0007 v2 N=5**
- [ ] [#88](https://github.com/JubileeZ/alpha-zero-g/issues/88) run + record Task Success
- [ ] [#89](https://github.com/JubileeZ/alpha-zero-g/issues/89) analyze promote
- [ ] [#90](https://github.com/JubileeZ/alpha-zero-g/issues/90) adopt or revert

## Blockers / Notes
- Local campaign tree gitignored; copy or rebuild on harness machine.
- Current arm = `d2df37f^` (`fef3e84`); Candidate = `d2df37f`+ (see CAMPAIGN.md).
