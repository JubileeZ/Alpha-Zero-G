# Live Campaign — Behavior Corpus

| Field | Value |
|-------|-------|
| Status | **Current** EP v1 (ADR 0016) · Candidate slot **empty** · Behavior Corpus **on disk** (13 Executor Traps, ADR 0019) |
| Device Setup | Execution Protocol v1 + cleanup + telegraphic; `azg setup --force` |
| Candidate slot | empty — Guidance Treatment is intent only until a Behavior Corpus gate promotes |
| Last historical gate | `gate-execution-protocol-v1` R=5 (fable-format corpus; incomparable) |
| Next | Preview Behavior Corpus (`run-process-gate.sh --preview-only`) |

Do not commit `campaigns/` / `worktrees/` / `homes/` (gitignored).
