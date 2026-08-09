# Work Packet: EP v2 Candidate + ADR 0017

**Objective:** Layer Device Setup: lean EP always-on; on-demand `judge` + `orchestrate`; Candidate pack ready for Trap.

**Acceptance:**
- [x] Grill Round 1–2 settled
- [x] ADR 0017 + amend 0010/0016
- [x] Candidate `execution-protocol-v2` + stager wired
- [x] Naming `judge`/`orchestrate` aligned; credit README; no `fable-*` ship ids
- [ ] Trap Preview when operator ready

## Work Packet (SFDBN)

- **Status:** Grill closed · Candidate pack + ADR 0017 landed · Preview pending
- **Files:** `docs/adr/0017-ep-judge-orchestrate-layering.md`; `templates/candidates/execution-protocol-v2/`; `evals/stage-execution-protocol-v2-home.sh`; `evals/run-trap-cell.sh`; `CONTEXT.md`; `docs/research/2026-08-09-auditor-orchestrator-always-on.md`
- **Decisions:** ADR 0017. Fraud-hunt = `judge` on-demand. Orchestrate = invoke or high bar (multi-area · long unattended · large blast). Conditional verify subagent. Ship names `judge`/`orchestrate`. Credit fable-method in Candidate README/NOTICE.
- **Blocked:** none for docs/pack; Trap Preview needs docker + operator consent
- **Next:** Optional `bash tests/verify.sh`; when ready Preview `TRAP_CANDIDATE_PACK=execution-protocol-v2`
