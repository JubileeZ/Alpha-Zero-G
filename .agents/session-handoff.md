# Session handoff

**When:** 2026-07-30
**Branch:** main (`37d7217` — committed and pushed)

## Done this session

1. Agreed sync-by-design model: `templates/global/AGENTS.md` canonical; Cursor prose derived at setup.
2. Added `PONYTAIL:MANAGED` and `AZG:AGENT-INSTRUCTIONS` extraction markers.
3. Reduced `templates/global/cursor/rules/azg-*.mdc` to Cursor frontmatter stubs.
4. Added strict extraction/rendering in `lib/common.sh` + `lib/setup.sh`.
5. Added equality, ownership, foreign-safety, uninstall, malformed-marker, and legacy AGENTS migration tests.
6. Updated CONTEXT, ADR 0008, current-state, and device handoff docs.

## Verify

- `bash tests/test-cursor-device-setup.sh` → 34/34
- IDE diagnostics clean for changed files
- Shellcheck unavailable: `shellcheck: command not found`
- Device: `./azg setup` migrated AGENTS markers and rendered both Cursor rules

- Full `bash tests/run-all.sh` gate passed: 16 suites, 2 skipped
- Portable `bash tests/verify.sh` passed: 32/32
- Device refreshed with `./azg setup`

## Next

- Delete merged `feature/cursor-device-setup` (local + remote)
- Operator: `./azg setup` on device to refresh rendered Cursor rules
