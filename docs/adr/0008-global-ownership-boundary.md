# Global Ownership Boundary

`azg setup` / `azg uninstall` must only create, refresh, or delete assets Alpha-Zero-G owns. Foreign MCP configs, custom skills (no vendor sentinel), and unmanaged AGENTS.md must be left alone unless the operator passes `--force`. Ownership is recorded in a small manifest under the global azg dir so uninstall is selective rather than `rm -rf` of shared `~/.gemini` trees.

## Cursor Device Setup (map #56)

Same manifest (`azg-ownership.json`) also tracks:

| Key | Assets |
|-----|--------|
| `cursor_skills` | Copies under `~/.cursor/skills/<name>/` with `AZG-OWNED.md` sentinel |
| `cursor_rules` | Files named `~/.cursor/rules/azg-*.mdc` only |

Never write into `~/.cursor/skills-cursor/`. Never delete the whole `~/.cursor/rules/` directory — remove only owned `azg-*.mdc` entries. Foreign Cursor skills (no `AZG-OWNED.md`) and foreign rules (non-owned / non-azg names) require `--force` to overwrite.

Gemini skills keep `ANTIGRAVITY-NOTE.md`. Cursor skills use `AZG-OWNED.md` (neutral sentinel).
