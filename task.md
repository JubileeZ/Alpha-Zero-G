# Clean Candidate slot + default setup after promote

**Objective:** Clear promoted pack; document default Device Setup + next-Candidate path.

**Acceptance:** `templates/candidates/` README-only; no unified-pipeline stager; tests green.

## Work Packet (SFDBN)

**Status:** done

**Files:**
- `templates/candidates/README.md` (pack removed)
- `evals/run-trap-cell.sh` · `evals/traps/run-process-gate.sh`
- `tests/test-candidates-slot.sh` (replaces test-unified-pipeline-candidate)
- docs/current-state · CAMPAIGN · ADR 0014 · task.md

**Decisions:**
- Default Trap pack empty → Candidate arm = Current global
- Operators refresh Device Setup with `azg setup --force`

**Blocked:** none

**Next:** Commit when asked
