# Session handoff (SFDBN)

**When:** 2026-08-01
**Branch:** main (push before switching device)

- **Status:** Map [#85](https://github.com/JubileeZ/alpha-zero-g/issues/85) → [#88](https://github.com/JubileeZ/alpha-zero-g/issues/88) **Device Handoff** to host with Docker + `swebench`. Prep Windows host: stubs recipe ready; **1/15** sympy baseline prediction local-only (gitignored).
- **Files:** `evals/lite/README.md` · `CAMPAIGN.md` · ADR 0007 v2 · `prepare-lite-campaign.sh` · `task.md`
- **Decisions:** N=5 data-biased Lite slice; IDE/CLI agents OK; never invent `task_success`.
- **Blocked:** None on Docker host (assumed). Prep host: no Docker.
- **Next:** On Docker device — pull main, rebuild/copy campaign `adr0009-20260801-n5`, run 15 cells per README + CAMPAIGN, fill scorecards, then [#89](https://github.com/JubileeZ/alpha-zero-g/issues/89).
