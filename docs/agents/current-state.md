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
| Intent-gates Candidate | `templates/global/AGENTS.md` `AZG:AGENT-INSTRUCTIONS` | ADR 0009 distilled gates (precedence · triviality · INTENT/AUTH/TWINS/PENDING · expanded verify · sweep); setup smoke green |
| Evaluation Suite | `evals/lite/` | SWE-bench Lite **N=5** · 3-arm Task Success (ADR 0007); how-to `README.md` (**Proven automation**); Live Campaign `CAMPAIGN.md`; drivers `evals/run-lite-composer-{cell,campaign}.sh`; prep `prepare-lite-campaign.sh` |
| Aggregate / CI | `tests/run-all.sh`, `.github/workflows/ci.yml` | includes `test-lite.sh` |
| Portable gate | `templates/project/tests/verify.sh` | Harness integrity |
| ADRs | `docs/adr/` | 0004 · 0006 · 0007 Lite · 0008 ownership · 0009 intent-gates **adopted** |
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
| Intent-gates form | ADR 0009 — **adopted** 2026-08-01 (`promote=true`); gates in `AZG:AGENT-INSTRUCTIONS` |

---

## What does NOT exist yet

| Item | Notes |
|------|-------|
| Full SWE-bench Docker wiring | Operator harness via Docker + `.venv-swebench`; drivers automate agent+score |
| Delivery Cost auto-capture | Optional scorecard field; not a promote gate; CLI has no per-cell $ |
| Intent-gates Lite adopt/revert | **Adopted** — [#88](https://github.com/JubileeZ/alpha-zero-g/issues/88)–[#90](https://github.com/JubileeZ/alpha-zero-g/issues/90); map [#85](https://github.com/JubileeZ/alpha-zero-g/issues/85) |

---

## Safe commands today

| Command | What it does |
|---------|-------------|
| `bash tests/run-all.sh` | Full aggregate gate |
| `bash tests/test-lite.sh` | Lite suite structural tests |
| `bash evals/run-lite-arm.sh <id> baseline\|current\|candidate` | Prepare one Lite arm workdir |
| `bash evals/prepare-lite-campaign.sh [dir]` | Stub all N×3 scorecards into portable campaign dir |
| `bash evals/run-lite-composer-campaign.sh --score --jobs 6` | Proven parallel Composer Lite campaign (skips filled scorecards) |
| `bash evals/analyze-lite-promote.sh <camp>` | Write `promote-result.json` |
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
