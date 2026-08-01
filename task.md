# Active Task: none (Lite map #85 complete)

- **Status:** Idle — last milestone closed
- **Objective:** —
- **Acceptance:** —
- **Issue/Ticket:** Map [#85](https://github.com/JubileeZ/alpha-zero-g/issues/85) closed via [#90](https://github.com/JubileeZ/alpha-zero-g/issues/90) adopt

## Work Packet (SFDBN)

- **Status:** Idle — ADR 0009 adopted. **2026-08-01:** Windows prep host device refresh (`git pull` → `cefbdc9`, `azg setup`, `azg apply`, `verify.sh` green).
- **Files:** `templates/global/AGENTS.md` (gates kept) · `docs/adr/0009-*.md` · `evals/lite/README.md` Proven automation · `evals/run-lite-composer-*.sh` · `.agents/session-handoff.md`
- **Decisions:** Adopt (not revert). Composer 2.5 Lite recipe canonical. Device setup migrates via normal `azg setup` (no `--force` needed).
- **Blocked:** None on repo; prep host lacks Docker/`swebench`.
- **Next:** Pick new work from ROADMAP / issues when ready.

## Todo
- [x] [#86](https://github.com/JubileeZ/alpha-zero-g/issues/86)–[#90](https://github.com/JubileeZ/alpha-zero-g/issues/90) Lite map complete
- [x] Docs + drivers + adopt

## Blockers / Notes
- Campaign artifacts remain gitignored under `evals/lite/campaigns/adr0009-20260801-n5/` (local audit).
