# Live Campaign — Trap Suite

| Field | Value |
|-------|-------|
| Status | **Current Device Setup** EP v1 (ADR 0016) · **Next Candidate** `execution-protocol-v2` (ADR 0017) |
| Device Setup | Execution Protocol v1 + cleanup + telegraphic; `azg setup --force` |
| Candidate slot | `templates/candidates/execution-protocol-v2/` (EP v2 + judge + orchestrate) |
| Last gate | `gate-execution-protocol-v1` R=5 RECOMMEND_ADOPT (ledger on disk, gitignored) |
| Next | Preview `TRAP_CANDIDATE_PACK=execution-protocol-v2` when ready |

Do not commit `campaigns/` / `worktrees/` / `homes/` (gitignored).
