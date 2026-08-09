# Live Campaign — Trap Suite

| Field | Value |
|-------|-------|
| Status | **Promoted** ADR 0016 · Execution Protocol v1 in global Device Setup |
| Device Setup | Execution Protocol v1 + cleanup + telegraphic; `azg setup --force` |
| Candidate slot | `templates/candidates/` empty (README only) |
| Last gate | `gate-execution-protocol-v1` R=5 RECOMMEND_ADOPT (ledger on disk, gitignored) |
| Next | New pack under `templates/candidates/<id>/` when ready |

Do not commit `campaigns/` / `worktrees/` / `homes/` (gitignored).
