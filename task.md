# Active Task

**Objective:** Vendor caveman skills catalog, establish selective active skills with automatic transitive dependency resolution across Gemini and Cursor.

**Acceptance:**
1. `vendor-sync.sh` vendors all `JuliusBrussee/caveman` skills into `templates/global/skills/vendor/caveman-skills/` with `VENDOR.lock`.
2. `caveman-skills` remains in the catalog without being auto-installed to global directories by default.
3. Declarative active skills supported via `${AZG_GLOBAL_DIR}/azg-skills.json` and `azg skill [list|enable|disable]`.
4. Automatic transitive dependency resolution (`_resolve_active_skills`) resolves all sub-skills for requested sets (e.g. `grill-with-docs`, `implement`, `wayfinder`, `writing-for-agents`).
5. 1:1 cross-IDE parity between `~/.gemini/config/skills/` and `~/.cursor/skills/`.
6. Portable gate `tests/verify.sh` and full gate `tests/run-all.sh` pass cleanly.

## Work Packet (SFDBN)

**Status:** Completed

**Files:**
- `azg`
- `lib/apply-overlay.sh`
- `lib/setup.sh`
- `lib/vendor-sync.sh`
- `templates/global/skills/overlay/caveman-skills/tool-map.json`
- `templates/global/skills/vendor/caveman-skills/`
- `tests/test-selective-skills.sh`
- `tests/test-phase3.sh`
- `tests/run-all.sh`
- `docs/agents/current-state.md`

**Decisions:**
- Default unmanaged install keeps lean curated core; catalog skills like caveman enabled on-demand.
- Manifest stored at `${AZG_GLOBAL_DIR}/azg-skills.json` (`~/.gemini/antigravity-cli/azg-skills.json`) maintaining 1:1 parity with Cursor.
- Automatic transitive scanner parses `/skill-name` calls from `SKILL.md` to compute closure.

**Blocked:** None

**Next:** Commit and push to main.
