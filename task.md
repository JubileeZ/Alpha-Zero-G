# Drop Windows from CI matrix

**Objective:** CI aggregate gate on ubuntu + macos only; keep Windows local/Git Bash support in code.

**Acceptance:** `.github/workflows/ci.yml` matrix has no `windows-latest`; continuity docs match.

## Work Packet (SFDBN)

**Status:** done

**Files:**
- `.github/workflows/ci.yml` — remove `windows-latest` + Windows deps step
- `lib/setup.sh` · `evals/traps/analyze_ledger.py` — Windows-local fixes kept (jq `\r`, UTF-8 ledger)
- `task.md` · `docs/agents/current-state.md`

**Decisions:**
- No GHA Windows runner; devs still use Git Bash per AGENTS.md
- Prior Windows CI fixes remain — help local Windows, not CI

**Blocked:** none

**Next:** Commit + push when asked
