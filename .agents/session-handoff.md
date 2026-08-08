# Session Handoff (SFDBN)

- **Status:** Fable-method candidate WIP committed under `wip/`; scaffold in `wip/candidates-raw/AGENTS.md` ready; handcraft + Trap gate next
- **Files:** `wip/` (README, candidates-raw, fable-method upstream+compressed+references); `task.md`; `docs/agents/current-state.md`
- **Decisions:** Renamed `.tmp/` → `wip/` (git-tracked, not agent temp cleanup); ADR 0009 always-on gates only; compress v3 keeps quoted examples + pulled references; fable-method pin `88b5cf36`
- **Blocked:** none
- **Next:** Handcraft `wip/candidates-raw/AGENTS.md` from `wip/fable-method/compressed/`; copy to `templates/candidates/<pack-id>/` when ready; Trap Process Gate (`bash evals/traps/run-process-gate.sh`) before global promote
