# Session handoff (SFDBN)

**When:** 2026-08-01
**Branch:** main

- **Status:** Wayfinder map [#85](https://github.com/JubileeZ/alpha-zero-g/issues/85) — closed [#86](https://github.com/JubileeZ/alpha-zero-g/issues/86) + [#87](https://github.com/JubileeZ/alpha-zero-g/issues/87); frontier [#88](https://github.com/JubileeZ/alpha-zero-g/issues/88).
- **Files:** `evals/prepare-lite-campaign.sh` (new) · `evals/lite/OPERATOR.md` · `tests/test-lite.sh` · `.gitignore` (`evals/lite/campaigns/`) · `task.md` · `docs/agents/current-state.md` · `ROADMAP.md` Pending Lite status line.
- **Decisions:** Campaign stubs live at `evals/lite/campaigns/adr0009-20260801/` (portable, gitignored); helper prepares all 30 with null `task_success`. No fake scores. Prep host lacked Docker/`swebench`.
- **Blocked:** Cannot execute [#88](https://github.com/JubileeZ/alpha-zero-g/issues/88) on this machine without Docker + `swebench`.
- **Next:** Claim [#88](https://github.com/JubileeZ/alpha-zero-g/issues/88) on a harness-capable clone; OPERATOR.md §2–3 → fill scorecards → [#89](https://github.com/JubileeZ/alpha-zero-g/issues/89) analyze → [#90](https://github.com/JubileeZ/alpha-zero-g/issues/90) adopt/revert.
