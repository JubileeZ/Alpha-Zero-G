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

## Cursor Rule Source of Truth

`templates/global/AGENTS.md` is canonical for shared rule prose. `azg setup` extracts marked block `AZG:AGENT-INSTRUCTIONS` and composes it with Cursor-only frontmatter stub into `~/.cursor/rules/azg-agent-instructions.mdc`. Missing, duplicated, reversed, or empty marker blocks fail setup instead of installing stale rules. Always-on `PONYTAIL:MANAGED` / `azg-ponytail.mdc` **retired** (ADR 0015); ponytail lives in vendor skills catalog only.
