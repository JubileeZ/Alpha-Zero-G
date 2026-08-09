# Session Handoff (SFDBN)

- **Status:** execution-protocol-v1 Candidate wired (`templates/candidates/` + stager + trap cell); block order fixed (protocol → cleanup → telegraphic)
- **Files:** `templates/candidates/execution-protocol-v1/`; `evals/stage-execution-protocol-v1-home.sh`; `evals/run-trap-cell.sh`; `wip/execution-protocol-v1/AGENTS.md`
- **Decisions:** grill Q1–Q5 settled; Trap pack id `execution-protocol-v1`
- **Blocked:** none
- **Next:** Trap Process Gate preview then Adopt Ledger R=5

## Trap preview command

```bash
TRAP_CANDIDATE_PACK=execution-protocol-v1 \
  TRAP_CAMP="$PWD/evals/traps/campaigns/gate-execution-protocol-v1" \
  bash evals/traps/run-process-gate.sh --preview-only
```
