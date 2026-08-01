# Current Implementation State

**Read this first** after `docs/AGENT-ONBOARDING.md`. `ROADMAP.md` is plan; this file is **what exists on disk today**. Current truth only — historical dumps → `docs/archive/` (see `docs/agents/progress.md`).

**Active phase:** post-v4 hardening — Lite gate live; remaining polish optional

---

## What exists

| Area | Path | Notes |
|------|------|-------|
| CLI | `azg`, `lib/` | setup (full skills), new, apply, update, selective uninstall |
| Ownership | `azg-ownership.json` under global dir | ADR 0008 |
| Checkpoint Stop | templates `.agents` + `.cursor` | Unified workstate: task.md · current-state · session-handoff |
| Cursor hook launch | `.cursor/hooks/run-hook.cmd` | Polyglot; **must be executable on Unix** (`100755`); hooks.json cites basename only (no `.sh` token) |
| Cursor device setup | `azg setup` → `~/.cursor/skills` + rendered `azg-*.mdc` | ADR 0008; `templates/global/AGENTS.md` canonical prose source; marker validation hard-fails; foreign-safe |
| Evaluation Suite | `evals/lite/` | SWE-bench Lite N=10 · 3-arm promote on Task Success only (ADR 0007); cost informational |
| Aggregate / CI | `tests/run-all.sh`, `.github/workflows/ci.yml` | includes `test-lite.sh` |
| Portable gate | `templates/project/tests/verify.sh` | Harness integrity |
| ADRs | `docs/adr/` | 0004 · 0006 · 0007 Lite · 0008 ownership · 0009 intent-gates (pending Lite) |
| Glossary | `CONTEXT.md` | Current/Candidate Treatment |
| Lean continuity | `AGENTS.md` Session start · `.cursor/rules/work-state-continuity.mdc` | Always-on lean set; not CONTEXT/progress/archive |
| Project skills | `.agents/skills/{progress-updates,domain-vocabulary}` + matching `.cursor/rules/*.mdc` | Agent-requestable; mirrors templates/project |

---

## Grill decisions (done)

| Gap | Done |
|-----|------|
| Ownership | selective setup/uninstall |
| Checkpoint | unified Stop accept set |
| Skills | full vendor only; `--profile` removed |
| Eval | Lite scaffolded; legacy Blind Judge / pilot claim **deleted** |
| Intent-gates form | ADR 0009 — distill into `AZG:AGENT-INSTRUCTIONS`; no fable vendor; Lite decide |

---

## What does NOT exist yet

| Item | Notes |
|------|-------|
| Full SWE-bench Docker wiring | Scaffold prepares arms; external `swebench` harness still operator-run |
| Delivery Cost auto-capture | Optional scorecard field; not a promote gate; no IDE metering |
| Intent-gates Candidate text + Lite campaign | ADR 0009 pending; draft prose + 3-arm run not done |

---

## Safe commands today

| Command | What it does |
|---------|-------------|
| `bash tests/run-all.sh` | Full aggregate gate |
| `bash tests/test-lite.sh` | Lite suite structural tests |
| `bash evals/run-lite-arm.sh <id> baseline\|current\|candidate` | Prepare Lite arm |
| `./azg setup --dry-run` | Preview global install (needs `jq`) |

---

## Agent pitfalls

1. Mock `HOME` in tests — setup writes under `~/.gemini/`.
2. Foreign MCP/AGENTS/custom skills skipped unless `--force`.
3. New adopts: Lite 3-arm (except explicit preference exceptions already taken).
4. Spawn-budget enforce is PreToolUse (ADR 0006), not SubagentStart.
5. Harness counters do not cross Bash subshells.
6. `run-hook.cmd` without `+x` breaks Cursor `commit-verify` on macOS/Linux — restore after checkout/merge.
7. **CI macOS bash 3.2:** GHA `macos-latest` default `bash` is `/bin/bash` 3.2. Do **not** add Bash 4-only builtins in `lib/` (`mapfile`/`readarray`, `declare -A`, `${var,,}`). Recurring main-branch red was `mapfile` in `setup.sh` → exit 127 → phase3/8/9 cascade. Prefer Homebrew bash locally if desired; CI intentionally stays on system bash so regressions surface.
8. Smart sync skips skill copy when `VENDOR.lock` stamp unchanged — empty `~/.cursor/skills` still needs `./azg setup --force`.
