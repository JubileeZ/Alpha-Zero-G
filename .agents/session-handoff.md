# Session handoff

**When:** 2026-07-30
**Branch:** main (local uncommitted → Checkpoint)

## Done this session

1. Removed npx-installed `mattpocock/skills` from `~/.agents/skills`; left `find-skills`.
2. Ran `./azg setup` — vendored skills → Gemini + Cursor; `azg-ponytail.mdc`.
3. Gap: AGENTS.md lines 36–61 (placeholders / cleanup / telegraphic) only in Gemini global AGENTS; Cursor needed `.mdc`.
4. Added `templates/global/cursor/rules/azg-agent-instructions.mdc`; tests + handoff updated; re-ran `azg setup` (rule on device).

## Verify

- `bash tests/test-cursor-device-setup.sh` → 20/20
- Device: `~/.cursor/rules/azg-agent-instructions.mdc` present

## Next

- Checkpoint commit of rule + tests + continuity
- New Cursor agent session to load new alwaysApply rule
