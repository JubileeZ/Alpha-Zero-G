# Session handoff

**When:** 2026-07-31
**Branch:** main (vendor locks dirty → checkpoint)

## Done this session

1. Verified merge `4ead327` was intentional pull of `origin/main` (7 upstream Cursor-device commits) + local `1749bfc` vendor maintenance — not a random branch merge.
2. Installed Homebrew Bash 5.3 (macOS system bash 3.2 breaks `azg setup` via `mapfile`).
3. `./azg update --vendor` — mattpocock `2ab9580`, ponytail unchanged commit; both `date_vendored: 2026-07-30` (UTC).
4. `./azg setup --force` — 28 Gemini + 28 Cursor skills, 2 `azg-*.mdc` rules.

## Verify

- `VENDOR.lock` dates ≠ `2026-07-27`
- `~/.cursor/skills/*/AZG-OWNED.md` count = 28
- `~/.cursor/rules/azg-ponytail.mdc` + `azg-agent-instructions.mdc` present

## Next

- Push checkpoint when ready
- Reload Cursor for global rules/skills
- Optional: fix stale `azg-upgrade` alias in `~/.zshrc`
