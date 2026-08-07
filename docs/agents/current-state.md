# Current Implementation State

**Read this first** after `docs/AGENT-ONBOARDING.md`. `ROADMAP.md` is plan; this file is **what exists on disk today**. Current truth only — historical dumps → `docs/archive/` (see `docs/agents/progress.md`).

**Active phase:** post-v4 hardening — Eval Isolation landed; concept Candidate **(D) + WFA clarity glosses** (device-global, no CONTEXT.md assumed); Docker Process Gate pending

---

## What exists

| Area | Path | Notes |
|------|------|-------|
| CLI | `azg`, `lib/` | setup (full skills), new, apply, update, selective uninstall |
| Ownership | `azg-ownership.json` under global dir | ADR 0008 |
| Checkpoint Stop | templates `.agents` + `.cursor` | Unified workstate: task.md · current-state · session-handoff |
| Cursor hook launch | `.cursor/hooks/run-hook.cmd` | Polyglot; **must be executable on Unix** (`100755`); hooks.json cites basename only (no `.sh` token) |
| Cursor device setup | `azg setup` → `~/.cursor/skills` + rendered `azg-*.mdc` | ADR 0008; `templates/global/AGENTS.md` canonical prose source; marker validation hard-fails; foreign-safe |
| Intent-gates Candidate | `templates/global/AGENTS.md` `AZG:AGENT-INSTRUCTIONS` | ADR 0009 + **0010**: Think + Prove + Router (domains/method-refs); placeholder fill moved to project `AZG:MANAGED` |
| Azg-owned skills | `templates/global/skills/azg/` | `azg-domain-research` · `azg-domain-data-analysis` · `azg-method-refs` (failure map inlined in `SKILL.md`); always install (not VENDOR.lock-gated); vendor prune skips if source dir exists under this path; Act/orchestrate deferred |
| Trap Suite / Process Gate | `evals/traps/` + `evals/run-agent-isolated.sh` + `evals/docker/azg-eval-agent/` | ADR 0012 + **0013** Eval Isolation; default Docker agent; `TRAP_CANDIDATE_PACK`; traps model `luna-low` |
| Evaluation Suite | `evals/lite/` | SWE-bench Lite **N=5** · 3-arm Task Success (ADR 0007); how-to `README.md` (**Proven automation**); Live Campaign `CAMPAIGN.md`; drivers `evals/run-lite-composer-{cell,campaign}.sh`; prep `prepare-lite-campaign.sh` |
| Aggregate / CI | `tests/run-all.sh`, `.github/workflows/ci.yml` | includes `test-lite.sh`; Windows shellcheck from GitHub zip (not choco) |
| Portable gate | `templates/project/tests/verify.sh` | Harness integrity |
| ADRs | `docs/adr/` | 0004 · 0006 · 0007 Lite · 0008 ownership · 0009 intent-gates **adopted** · **0010** Think+Prove/domains · **0013** Eval Isolation |
| Glossary | `CONTEXT.md` | Current/Candidate Treatment · Eval Isolation |
| Lean continuity | `AGENTS.md` Session start (+ `read-agents-md.mdc`) | Always-on lean set; Cursor duplicate `work-state-continuity.mdc` **retired** — apply removes orphan |
| Project skills | `.agents/skills/progress-updates` + matching `.cursor/rules/*.mdc` | Agent-requestable; mirrors templates/project. Domain consumer = `docs/agents/domain.md`; writes = `/grill-with-docs` |
| Research notes | `docs/research/` | Context engineering 2026-07-31; AGENTS budget 2026-08-05; Unattended tied defaults / loop eng 2026-08-07 |

---

## Grill decisions (done)

| Gap | Done |
|-----|------|
| Trap Suite Process Gate | ADR 0012. Fable no promote. Host smoke triage only. ADR 0013 Eval Isolation. Grill locked **(D)**: Candidate patched (Q6 split + losing-side/Twin sharpen under WFA). Docker Process Gate next |
| writing-for-agents lever pass | Packets 1–2 landed; Candidate prose used WFA levers (thin always-on + JIT; leading words) |
| Ownership | selective setup/uninstall |
| Checkpoint | unified Stop accept set |
| Skills | full vendor only; `--profile` removed |
| Eval | Lite scaffolded; legacy Blind Judge / pilot claim **deleted** |
| Intent-gates form | ADR 0009 — **adopted** 2026-08-01 (`promote=true`); gates in `AZG:AGENT-INSTRUCTIONS` |
| Think+Prove + domains | ADR 0010 — Prove stance + fit/recall + research/data domain skills + method-refs (orchestrate removed until needed) |
| Azg skill prune ownership | Source dir under `templates/global/skills/azg/` (not ANTIGRAVITY-NOTE prose); shared `_install_skill_pair` in setup |
| Project telegraphic policy | Soft-dup removed from project Overrides; global `AZG:AGENT-INSTRUCTIONS` sole always-on source; Placeholder fill how-to word kept |
| AGENTS always-on budget | No invented tok cap; soft vendor line targets + progressive disclosure; absolute lean as windows grow; no template cut 2026-08-05 (`docs/research/2026-08-05-agents-md-always-on-budget.md`); revisit on adherence fail only |

---

## What does NOT exist yet

| Item | Notes |
|------|-------|
| Full SWE-bench Docker wiring | Operator harness via Docker + `.venv-swebench`; drivers automate agent+score |
| Delivery Cost auto-capture | Optional scorecard field; not a promote gate; CLI has no per-cell $ |
| Intent-gates Lite adopt/revert | **Adopted** — [#88](https://github.com/JubileeZ/alpha-zero-g/issues/88)–[#90](https://github.com/JubileeZ/alpha-zero-g/issues/90); map [#85](https://github.com/JubileeZ/alpha-zero-g/issues/85) |
| Fable-method distill + re-gate | **Not needed** — Fable pack lost to current. Azg concept Candidate supersedes distill path |

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
| `bash evals/traps/run-full-first.sh` | Full S1–S14 Process Gate (default Candidate = fable-method pack) |
| `bash evals/analyze-trap.sh <camp>` | `promote-result.json` for trap campaign |

---

## Agent pitfalls

1. Mock `HOME` in tests — setup writes under `~/.gemini/`.
2. Foreign MCP/AGENTS/custom skills skipped unless `--force`.
3. New adopts: Lite 3-arm (except explicit preference exceptions already taken).
4. Subagent fan-out limits are host-default only (spawn-budget retired ADR 0011).
5. Harness counters do not cross Bash subshells.
6. `run-hook.cmd` without `+x` breaks Cursor `commit-verify` on macOS/Linux — restore after checkout/merge.
7. **CI macOS bash 3.2:** GHA `macos-latest` default `bash` is `/bin/bash` 3.2. Do **not** add Bash 4-only builtins in `lib/` (`mapfile`/`readarray`, `declare -A`, `${var,,}`). Recurring main-branch red was `mapfile` in `setup.sh` → exit 127 → phase3/8/9 cascade. Prefer Homebrew bash locally if desired; CI intentionally stays on system bash so regressions surface.
8. **CI Windows shellcheck:** Do not install shellcheck via Chocolatey in GHA (CDN 503 flakes). Workflow downloads `shellcheck-v*.zip` from GitHub Releases into `$RUNNER_TEMP/azg-tools`. Zip already contains `shellcheck.exe` at root — do not `Copy-Item` onto itself after `Expand-Archive`.
9. Smart sync skips **vendor** skill copy when `VENDOR.lock` stamp unchanged — azg-owned skills still refresh; empty `~/.cursor/skills` still needs `./azg setup --force`.
10. **Windows `azg apply`:** may touch harness files with CRLF-only diffs (no content change). `git restore` those paths if working tree is clean aside from line endings.
11. Vendor prune: first-party azg skills identified by `templates/global/skills/azg/<name>/` existing under `AZG_ROOT` — do not rely on note wording.
