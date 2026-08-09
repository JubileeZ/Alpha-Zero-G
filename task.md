# Execution Protocol v1 Candidate (WIP)

**Objective:** Trap Candidate always-on pack wired at `templates/candidates/execution-protocol-v1/`.

**Acceptance:** Trap Process Gate preview passes with `TRAP_CANDIDATE_PACK=execution-protocol-v1`.

## Work Packet (SFDBN)

**Status:** in_progress — wired + committed; Trap preview next

**Files:**
- `templates/candidates/execution-protocol-v1/` — Candidate pack (AGENTS.md · cursor stub · NOTICE)
- `evals/stage-execution-protocol-v1-home.sh` — Eval Device Home stager
- `evals/run-trap-cell.sh` — `execution-protocol-v1` arm branch
- `wip/execution-protocol-v1/` — lab mirror of candidate AGENTS.md
- `wip/fable-method/compressed/` — reference compress

**Decisions:** Execution Protocol first; cleanup + telegraphic after; no Prove; no domain router

**Blocked:** none

**Next:** `TRAP_CANDIDATE_PACK=execution-protocol-v1 bash evals/traps/run-process-gate.sh --preview-only` → Adopt Ledger R=5
