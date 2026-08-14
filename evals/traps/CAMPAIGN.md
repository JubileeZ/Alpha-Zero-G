# Live Campaign — Behavior Corpus

| Field | Value |
|-------|-------|
| Status | **Current** EP v1 (ADR 0016) · Candidate pack **principles-v1** on disk (not promoted) · Behavior Corpus **on disk** (13 Executor Traps, ADR 0019) |
| Device Setup | Execution Protocol v1 + cleanup + telegraphic; `azg setup --force` |
| Candidate slot | `templates/candidates/principles-v1` — Preview: `TRAP_CANDIDATE_PACK=principles-v1` |
| Last historical gate | `gate-execution-protocol-v1` R=5 (fable-format corpus; incomparable) |
| Next | Preview Behavior Corpus with `TRAP_CANDIDATE_PACK=principles-v1` (`run-process-gate.sh --preview-only`) |

Do not commit `campaigns/` / `worktrees/` / `homes/` (gitignored).
