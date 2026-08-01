# Active Task: Lite map #85 — run N=5×3

- **Status:** In Progress (map mid-flight)
- **Objective:** Wayfind ADR 0009 Lite adopt/revert to a real promote decision
- **Acceptance:** `promote-result.json` from filled **N=5×3 (15)** scorecards (ADR 0007 v2); then adopt or revert gates
- **Issue/Ticket:** Map [#85](https://github.com/JubileeZ/alpha-zero-g/issues/85) · active [#88](https://github.com/JubileeZ/alpha-zero-g/issues/88)

## Work Packet (SFDBN)

- **Status:** [#88](https://github.com/JubileeZ/alpha-zero-g/issues/88) claimed. **1/15** prediction drafted (`sympy__sympy-20590` baseline). All `task_success` still null — scoring needs Docker.
- **Files:** `evals/lite/campaigns/adr0009-20260801-n5/` · `evals/lite/worktrees/sympy` · `RUNBOOK-HITL.md` · `.gitignore` (worktrees)
- **Decisions:** Agent via Cursor/CLI OK; Task Success = harness `resolved` only. ADR 0007 v2 N=5 data-biased slice.
- **Blocked:** Docker absent on this host (`swebench` import also needs Unix `resource` for harness).
- **Next:** Install Docker Desktop **or** keep drafting remaining 14 `predictions.jsonl`, then score on a Docker host → fill scorecards → [#89](https://github.com/JubileeZ/alpha-zero-g/issues/89).

## Todo
- [x] [#86](https://github.com/JubileeZ/alpha-zero-g/issues/86) operator runbook → folded into README + CAMPAIGN
- [x] [#87](https://github.com/JubileeZ/alpha-zero-g/issues/87) prepare campaign tree
- [x] Grill: README / CAMPAIGN / N=5 ADR 0007 v2
- [ ] [#88](https://github.com/JubileeZ/alpha-zero-g/issues/88) run + record Task Success (1/15 preds; 0/15 scored)
- [ ] [#89](https://github.com/JubileeZ/alpha-zero-g/issues/89) analyze promote
- [ ] [#90](https://github.com/JubileeZ/alpha-zero-g/issues/90) adopt or revert

## Blockers / Notes
- Campaign + worktrees gitignored.
- Current = `fef3e84`; Candidate = `d2df37f`+.
