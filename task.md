# Unified-pipeline Candidate (eval-staged)

**Objective:** Rebuild `templates/candidates/unified-pipeline/` from caveman-compressed fable-method content (byte-preserve + exact-dedupe into pipeline skeleton), wire `TRAP_CANDIDATE_PACK=unified-pipeline` Eval Device Home staging, draft ADR superseding 0009/0010. Do **not** promote into `templates/global/` until Trap tests.

**Acceptance:** Candidate package has single always-on rule path (pipeline + nested ponytail), `orchestrate`+`judge`+compressed refs, no `fable-*` skill names; `stage-unified-pipeline-home.sh` stages that home; trap cell routes pack; structural tests pass; ADR 0014 + CONTEXT naming pointer + NOTICE; `templates/global/` unchanged for Device Setup prose.

## Work Packet (SFDBN)

**Status:** done — Candidate + eval glue landed; global promote deferred

**Files:**
- `templates/candidates/unified-pipeline/**` (+ `_build/` assemble)
- `evals/stage-unified-pipeline-home.sh`, `evals/run-trap-cell.sh`
- `tests/test-unified-pipeline-candidate.sh`, `tests/run-all.sh`
- `docs/adr/0014-unified-pipeline-candidate.md`, `0009`/`0010` superseded notes
- `CONTEXT.md`, `docs/agents/current-state.md`, `evals/traps/{README,CAMPAIGN}.md`

**Decisions:**
- Q14=B: staged only; no `templates/global` promote
- Light caveman local (no `claude` CLI); mechanical `fable-*` → azg id renames
- Eval: `TRAP_CANDIDATE_PACK=unified-pipeline`

**Blocked:** none

**Next:** Run Trap with `TRAP_CANDIDATE_PACK=unified-pipeline`; promote to global only if Process Gate passes
