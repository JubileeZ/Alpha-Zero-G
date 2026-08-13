# Current Implementation State

**Read this first** after `docs/AGENT-ONBOARDING.md`. `ROADMAP.md` is plan; this file is **what exists on disk today**. Current truth only — historical dumps → `docs/archive/` (see `docs/agents/progress.md`).

**Active phase:** post-v4 — Lite **deleted**; planted S1–S14 **retired as adopt corpus** (ADR 0018); Earned Trap corpus **empty** (gate INCOMPLETE); EP v1 still shipped

---

## What exists

| Area | Path | Notes |
|------|------|-------|
| CLI | `azg`, `lib/` | setup (curated active core + transitive dependency resolution), skill list/enable/disable, new, apply, update (--vendor), selective uninstall; **`azg_python`** for real Py3 |
| Skills Catalog | `templates/global/skills/vendor/` | `mattpocock-skills` only (VENDOR.lock pin; catalog-only by default) |
| Active Skills Manifest | `${AZG_GLOBAL_DIR}/azg-skills.json` | Declarative active set; automatic transitive dependency resolution into both `~/.gemini/config/skills/` and `~/.cursor/skills/` with 1:1 parity |
| Ownership | `azg-ownership.json` under global dir | ADR 0008 |
| Checkpoint Stop | templates `.agents` + `.cursor` | Unified workstate: task.md · current-state · session-handoff |
| Cursor hook launch | `.cursor/hooks/run-hook.cmd` | Polyglot; **must be executable on Unix** (`100755`); hooks.json cites basename only (no `.sh` token) |
| Cursor device setup | `azg setup` → `~/.cursor/skills` + rendered `azg-*.mdc` | ADR 0008; marker validation hard-fails; foreign-safe |
| Intent-gates Candidate | `templates/candidates/` | **Empty slot** — EP v2 Candidate killed (ADR 0017); live = EP v1 global |
| Azg-owned skills | *(none in global)* | `judge`/`orchestrate` deferred; reference `wip/fable-method/compressed/` |
| Evaluation Suite / Trap | `evals/traps/` + runners + docker + `stage-eval-home` | Machinery ADR 0012+0013; **corpus** ADR 0018 Earned Traps. Planted S1–S14 still on disk, **not** promote input. Empty earned corpus → INCOMPLETE |
| Aggregate / CI | `tests/run-all.sh`, `.github/workflows/ci.yml` | **ubuntu + macos** matrix only (no `windows-latest`); **no** `test-lite`; `azg_python` |
| Portable gate | `templates/project/tests/verify.sh` | Harness integrity |
| ADRs | `docs/adr/` | **0016** EP v1 live; **0017** layering; **0018** Earned Traps **accepted** (planted corpus retired; archive files = follow-up) |
| Glossary | `CONTEXT.md` | Judge/Orchestrate deferred; Method Naming |
| Lean continuity | `AGENTS.md` Session start (+ `read-agents-md.mdc`) | Always-on lean set |
| Project skills | `.agents/skills/progress-updates` + matching `.cursor/rules/*.mdc` | Agent-requestable |
| Research notes | `docs/research/` | Incl. **2026-08-09** auditor/orchestrator vs always-on; **2026-08-13** protocol vs guidance always-on |
| Candidate WIP (git-tracked) | `wip/` | `fable-method/compressed/` reference only |

---

## Grill decisions (done)

| Gap | Done |
|-----|------|
| Trap Suite Process Gate | ADR 0012+0013 machinery. **0018** planted S1–S14 retired as adopt corpus. Earned corpus empty → INCOMPLETE |
| Always-on vs planted Trap | Grill 2026-08-13: Guidance = housekeeping intent; **0018 accepted**. EP v1 stays until earned gate can promote |
| Fable-method distill + re-gate | Gaps from camps; never adopt upstream pack; clean slate shipped |
| Ownership / Checkpoint / Skills | selective uninstall · unified Stop · full vendor |
| Lite adopt gate | **Removed** 2026-08-07 — ADR 0007 superseded |
| Intent-gates form | ADR 0009 — historical Lite adopt; clean slate parked distill |
| AGENTS always-on budget | No invented tok cap; absolute lean |
| EP / judge / orchestrate layering | ADR 0017 — lean always-on; EP v2 Candidate **killed**; keep EP v1 |

---

## What does NOT exist yet

| Item | Notes |
|------|-------|
| Next Candidate Treatment | Guidance Treatment intent only — not a pack until Earned Trap corpus exists (ADR 0018) |
| Earned Trap corpus | **None yet** — first fixture from a live miss + objective scorer |
| `judge` / `orchestrate` Device skills | Deferred — not in global |
| SWE-bench Lite harness | **Deleted** — do not restore without new ADR |

Delivery Cost auto-capture: parked / out of scope for now (never a promote input).

---

## Safe commands today

| Command | What it does |
|---------|-------------|
| `bash tests/run-all.sh` | Full aggregate gate |
| `bash evals/traps/run-process-gate.sh` | Process Gate entrypoint. **Do not** Recommend Adopt from planted S1–S14 (ADR 0018). Empty earned corpus → INCOMPLETE |
| `./azg setup` / `./azg setup --force` | Install Device Setup (AGENT-INSTRUCTIONS; prune retired ponytail rule) |
| `bash evals/analyze-trap-ledger.sh <parent>` | `LEDGER.md` + recommend |
| `bash evals/prepare-trap-campaign.sh` | Stub N×3 scorecards |
| `bash evals/run-trap-campaign.sh --jobs 14 --arm ARM` | Parallel scenarios for one arm |
| `bash evals/analyze-trap.sh <camp>` | `promote-result.json` |
| `./azg setup --dry-run` | Preview global install (needs `jq`) |

---

## Agent pitfalls

1. Mock `HOME` in tests — setup writes under `~/.gemini/`.
2. Foreign MCP/AGENTS/custom skills skipped unless `--force`.
3. Subagent fan-out limits are host-default only (spawn-budget retired ADR 0011).
4. Harness counters do not cross Bash subshells.
5. `run-hook.cmd` without `+x` breaks Cursor `commit-verify` on macOS/Linux — restore after checkout/merge.
6. **CI macOS bash 3.2:** no Bash 4-only builtins in `lib/`.
7. Smart sync skips vendor skill copy when `VENDOR.lock` unchanged — empty skills need `./azg setup --force`.
8. **Windows `azg apply`:** CRLF-only diffs possible — `git restore` if needed.
9. Vendor prune: azg skills = dirs under `templates/global/skills/azg/`.
10. **Windows eval Python:** Store `python3` stub → use `azg_python`. Empty `TRAP_FULL` = unset for fable full default.
11. **Windows jq manifest:** jq may emit `\r` on skill names — `_get_requested_skills` strips CR before lookup/install.
12. **Windows ledger UTF-8:** `analyze_ledger.py` must `write_text(..., encoding="utf-8")` (`≥` in LEDGER.md).
13. **No Lite** — `evals/lite/` gone. Planted S1–S14 not a promote input (ADR 0018). Earned corpus empty → Process Gate INCOMPLETE. Runners still `run-process-gate.sh` @ luna-low.
14. **Eval staged home** — `stage-eval-home.sh` renders EP v1 + cleanup + telegraphic; `test-eval-isolation.sh` asserts that shape (not pre-EP clean-slate that forbids `INTENT:`).
