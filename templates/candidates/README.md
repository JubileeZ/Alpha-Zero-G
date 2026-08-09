# Candidate Treatments (Trap Process Gate)

Empty slot. Live Device Setup = Execution Protocol v1 (`templates/global/`, ADR 0016). EP v2 Candidate killed (ADR 0017). Next Candidate: new dir under `templates/candidates/` per below → Trap → promote.

## Add a Candidate

1. Create `templates/candidates/<pack-id>/` with at least:
   - `AGENTS.md` — managed block(s) for always-on rules (usually `AZG:AGENT-INSTRUCTIONS`)
   - `cursor/rules/azg-*.mdc` — frontmatter stubs matching those blocks
   - `NOTICE` — origin / license if derived content
2. Add `evals/stage-<pack-id>-home.sh` (copy pattern from git history `stage-execution-protocol-v1-home.sh` or mirror `stage-eval-home.sh`).
3. Wire `evals/run-trap-cell.sh` candidate arm: `TRAP_CANDIDATE_PACK=<pack-id>` → your stager.
4. Optional skills under `skills/`.
5. Run Process Gate:

```bash
TRAP_CANDIDATE_PACK=<pack-id> \
  TRAP_CAMP=$PWD/evals/traps/campaigns/gate-<pack-id> \
  bash evals/traps/run-process-gate.sh --preview-only
# then --continue --yes for Adopt Ledger R=5
```

## After Trap promote

1. Merge Candidate content into `templates/global/` (ADR).
2. Delete or empty this pack (clean slate again).
3. Operators: `azg setup --force` so Device Setup matches new Current.
4. Default Trap with no pack = Candidate arm stages Current global (`stage-eval-home` @ `AZG_CANDIDATE_REF`) — same as Current until a new pack is set.
