# Device Handoff checklist — Cursor-capable Device Setup

Operator drill after `azg setup` on a fresh machine (or clean `HOME`). Complements automated `tests/test-cursor-device-setup.sh`.

## Prep

1. Install Git Bash (Windows), `jq`, clone this repo.
2. Prefer a throwaway user / temp `HOME` for the first dry run: `HOME=/tmp/azg-handoff bash -c './azg setup'`.

## Checks (one sitting)

| # | Check | Pass if |
|---|--------|---------|
| 1 | `./azg setup` exits 0 | Skills + rules reported in summary |
| 2 | Cursor skills present | `~/.cursor/skills/<vendored-name>/SKILL.md` and `AZG-OWNED.md` exist |
| 3 | Built-ins untouched | `~/.cursor/skills-cursor/` unchanged (no azg writes) |
| 4 | Azg global rules | `~/.cursor/rules/azg-ponytail.mdc` + `azg-agent-instructions.mdc` exist with `alwaysApply: true`; bodies derive from marked `templates/global/AGENTS.md` blocks |
| 5 | Foreign rules safe | Pre-existing non-`azg-*.mdc` under `~/.cursor/rules/` still present |
| 6 | Gemini still works | `~/.gemini/config/skills/` has vendored skills; global `AGENTS.md` present |
| 7 | Open harnessed project in Cursor | Project `AGENTS.md` + `.cursor/rules` from apply still load; no manual skill import |
| 8 | Open same project / Antigravity | Global Gemini skills + AGENTS available as before |
| 9 | `./azg uninstall` | Removes owned Cursor skills + `azg-*.mdc` only; foreign rules/skills remain |

## Notes

- Cursor has no user-global `AGENTS.md`; project file via `azg apply` is the documented always-on path for repo instructions.
- `~/.cursor/rules` as user-global is best-effort (product docs contested). If a rule file exists but Cursor UI does not show it, record IDE version under map fog “path drift”.
- Upgrading an older Device Setup: normal `./azg setup` migrates owned global AGENTS.md markers and renders Cursor rules; use `--force` only when existing AGENTS.md cannot be migrated.
