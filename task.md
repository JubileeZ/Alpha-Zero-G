# Fable-method candidate handcraft (WIP)

**Objective:** Azg-owned intent-gates Candidate draft from fable-method compress; git-tracked under `wip/`.

**Acceptance:** `wip/` tracked in git; `wip/candidates-raw/AGENTS.md` scaffold ready; compress snapshots in `wip/fable-method/`.

## Work Packet (SFDBN)

**Status:** in_progress (compressed terminology rename done; handcraft + Trap gate next)

**Files:**
- `wip/README.md` — WIP root (not session temp)
- `wip/candidates-raw/AGENTS.md` — candidate starter (`AZG:AGENT-INSTRUCTIONS` scaffold)
- `wip/candidates-raw/NOTICE` · `README.md`
- `wip/fable-method/compressed/` — Execution Protocol SoT `AGENTS.md`; `references/` at root; skills `orchestrator` · `auditor` · `adapter-builder` (no `fable-method` skill dup)
- `wip/fable-method/compressed/CHANGELOG.md` — rename entry
- `wip/fable-method/upstream/` — raw pin `88b5cf36` (old names; untouched)
- `task.md` · `docs/agents/current-state.md`

**Decisions:**
- Renamed `.tmp/` to `wip/` so agent temp-cleanup rules do not target it
- Git-track `wip/` (commit when ready)
- ADR 0009 scope: always-on gates only; no fable vendor paste on device
- Compress v3: preserve quoted examples; references pulled
- **Packaging:** no Claude Code plugin in compressed snapshot → `AGENTS.md` sole Execution Protocol source; `references/` moved out of deleted `skills/fable-method/`
- **Terminology:** loop→core protocol; whole method (gates included)→Execution Protocol; fable-loop→orchestrator; fable-judge→auditor; fable-domain→adapter-builder; backtrack/retry edges named in AGENTS.md

**Blocked:** none

**Next:** Handcraft `wip/candidates-raw/AGENTS.md` from renamed `compressed/AGENTS.md`; commit `wip/`; Trap Process Gate when pack wired
