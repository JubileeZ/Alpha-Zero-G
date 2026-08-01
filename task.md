# Active Task: Lite map #85 — run N=5×3

- **Status:** In Progress — **Device Handoff** to Docker-capable host
- **Objective:** Wayfind ADR 0009 Lite adopt/revert to a real promote decision
- **Acceptance:** `promote-result.json` from filled **N=5×3 (15)** scorecards (ADR 0007 v2); then adopt or revert gates
- **Issue/Ticket:** Map [#85](https://github.com/JubileeZ/alpha-zero-g/issues/85) · active [#88](https://github.com/JubileeZ/alpha-zero-g/issues/88)

## Work Packet (SFDBN)

- **Status:** [#88](https://github.com/JubileeZ/alpha-zero-g/issues/88) claimed on this account. Prep host (Windows) has stubs + **1/15** local prediction only. Operator continues on **Docker + swebench** device.
- **Files:** Tracked how-to: `evals/lite/README.md` · `CAMPAIGN.md`. Gitignored (copy or rebuild on target): `evals/lite/campaigns/adr0009-20260801-n5/` · `evals/lite/worktrees/`
- **Decisions:** ADR 0007 v2 N=5 data-biased; agent via IDE/CLI; Task Success = harness `resolved` only. Do not invent scores.
- **Blocked:** Cleared on target if Docker/`swebench` present. Prep host remains without Docker.
- **Next (on Docker host):** `git pull` → `bash evals/prepare-lite-campaign.sh evals/lite/campaigns/adr0009-20260801-n5` (or copy campaign tree) → finish 15 agent cells + harness → `record-lite-score.sh` → [#89](https://github.com/JubileeZ/alpha-zero-g/issues/89).

## Todo
- [x] [#86](https://github.com/JubileeZ/alpha-zero-g/issues/86) runbook → README + CAMPAIGN
- [x] [#87](https://github.com/JubileeZ/alpha-zero-g/issues/87) prepare campaign tree
- [x] Grill: README / CAMPAIGN / N=5 ADR 0007 v2
- [ ] [#88](https://github.com/JubileeZ/alpha-zero-g/issues/88) run + record Task Success (handoff → Docker device)
- [ ] [#89](https://github.com/JubileeZ/alpha-zero-g/issues/89) analyze promote
- [ ] [#90](https://github.com/JubileeZ/alpha-zero-g/issues/90) adopt or revert

## Blockers / Notes
- Campaign + worktrees **gitignored** — not in git push; rebuild with `prepare-lite-campaign.sh` on target (optional: copy `predictions.jsonl` for sympy baseline if desired).
- Current = `fef3e84`; Candidate = `d2df37f`+.
