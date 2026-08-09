# Fable-method candidate handcraft (WIP)

**Objective:** Azg-owned intent-gates Candidate draft from fable-method compress; git-tracked under `wip/`.

**Acceptance:** `wip/` tracked in git; `wip/candidates-raw/AGENTS.md` distill-ready for `AZG:AGENT-INSTRUCTIONS`; compress snapshots in `wip/fable-method/`; Trap Process Gate when wired.

## Work Packet (SFDBN)

**Status:** in_progress — candidate `AGENTS.md` expanded to full Steps 0–6 (~120 lines, uncommitted); writing-for-agents review + grill R1 done; hybrid distill pending user pick

**Files:**
- `wip/README.md` — WIP root (not session temp)
- `wip/candidates-raw/AGENTS.md` — Execution Protocol draft (de-branded; Steps 0–6; no `AZG:` markers yet)
- `wip/candidates-raw/Olddraft.md` — prior azg distill (~1.2k words; Prove + precedence + router)
- `wip/candidates-raw/NOTICE` · `README.md`
- `wip/fable-method/compressed/` — Execution Protocol SoT; `references/` at root; skills orchestrator · auditor · adapter-builder
- `wip/fable-method/compressed/CHANGELOG.md` — rename entry
- `wip/fable-method/upstream/` — raw pin `88b5cf36` (old names; untouched)
- `task.md` · `docs/agents/current-state.md` · `.agents/session-handoff.md`

**Decisions:**
- Renamed `.tmp/` → `wip/` (agent temp-cleanup safe)
- ADR 0009 scope: always-on gates only; no fable vendor paste on device
- Compress v3: `AGENTS.md` sole Execution Protocol source; `references/` at compressed root
- Terminology: loop→core protocol; whole method→Execution Protocol; fable-loop→orchestrator; fable-judge→auditor; fable-domain→adapter-builder
- Candidate fork: near-full compressed copy minus Usage/Modes/examples/references pointers; ponytail ladder inlined Step 4.3
- Grill R1 recommended: hybrid distill (compress Step 2 + method-refs pointer), Prove closing line, precedence block, fit router to `azg-domain-*`, fix typos before Trap

**Blocked:** grill Q1–Q6 answers (or "go with recommendations")

**Next:** Apply chosen distill path → `AZG:AGENT-INSTRUCTIONS` wrapper → fix formatting defects → commit `wip/` → wire `templates/candidates/<pack-id>/` + Trap Process Gate
