# Current Implementation State

**Read this first** after `docs/AGENT-ONBOARDING.md`. `ROADMAP.md` is plan; this file is **what exists on disk today**. Current truth only — historical dumps → `docs/archive/` (see `docs/agents/progress.md`).

**Active phase:** post-v4 — Lite suite **deleted**; Trap Process Gate = sole Evaluation Suite (ADR 0012); clean slate + tier sweep done; re-earn TBD

---

## What exists

| Area | Path | Notes |
|------|------|-------|
| CLI | `azg`, `lib/` | setup (curated active core + transitive dependency resolution), skill list/enable/disable, new, apply, update (--vendor), selective uninstall; **`azg_python`** for real Py3 |
| Skills Catalog | `templates/global/skills/vendor/` | `mattpocock-skills`, `ponytail-skills`, `caveman-skills` (at VENDOR.lock pin; catalog-only by default) |
| Active Skills Manifest | `${AZG_GLOBAL_DIR}/azg-skills.json` | Declarative active set; automatic transitive dependency resolution into both `~/.gemini/config/skills/` and `~/.cursor/skills/` with 1:1 parity |
| Ownership | `azg-ownership.json` under global dir | ADR 0008 |
| Checkpoint Stop | templates `.agents` + `.cursor` | Unified workstate: task.md · current-state · session-handoff |
| Cursor hook launch | `.cursor/hooks/run-hook.cmd` | Polyglot; **must be executable on Unix** (`100755`); hooks.json cites basename only (no `.sh` token) |
| Cursor device setup | `azg setup` → `~/.cursor/skills` + rendered `azg-*.mdc` | ADR 0008; marker validation hard-fails; foreign-safe |
| Intent-gates Candidate | `templates/global/AGENTS.md` `AZG:AGENT-INSTRUCTIONS` | **Clean slate:** cleanup + telegraphic only; distill **parked** (re-earn from traps) |
| Azg-owned skills | *(deleted)* | Distill skills removed clean slate 2026-08-07; re-create under `templates/global/skills/azg/` only when Trap Suite re-earns |
| Evaluation Suite / Trap | `evals/traps/` + flat `evals/*trap*` + docker + `stage-eval-home` + `run-{repeats,tier-sweep,full-first}.sh` | **Sole gate** ADR 0012+0013; default decision path = **4× full corpus at luna-xhigh** with majority; tier sweep = optional diagnostic; promote needs `isolation=docker` |
| Aggregate / CI | `tests/run-all.sh`, `.github/workflows/ci.yml` | **no** `test-lite`; Windows shellcheck zip; jq fallback; `azg_python` |
| Portable gate | `templates/project/tests/verify.sh` | Harness integrity |
| ADRs | `docs/adr/` | 0007 Lite **superseded**; **0012** sole Trap gate; **0013** Trap-only isolation |
| Glossary | `CONTEXT.md` | Evaluation Suite = Trap Process Gate; Global Core vs Vendor Catalog |
| Lean continuity | `AGENTS.md` Session start (+ `read-agents-md.mdc`) | Always-on lean set |
| Project skills | `.agents/skills/progress-updates` + matching `.cursor/rules/*.mdc` | Agent-requestable |
| Research notes | `docs/research/` | Incl. Device Home / noise / tier notes (Lite adopt claims historical) |

---

## Grill decisions (done)

| Gap | Done |
|-----|------|
| Trap Suite Process Gate | ADR 0012+0013. Sole eval after Lite delete. Default **4× full corpus at luna-xhigh** + majority; tier sweep optional diagnostic |
| Fable-method distill + re-gate | Gaps from camps; never adopt upstream pack; clean slate shipped |
| Ownership / Checkpoint / Skills | selective uninstall · unified Stop · full vendor |
| Lite adopt gate | **Removed** 2026-08-07 — ADR 0007 superseded |
| Intent-gates form | ADR 0009 — historical Lite adopt; clean slate parked distill |
| AGENTS always-on budget | No invented tok cap; absolute lean |

---

## What does NOT exist yet

| Item | Notes |
|------|-------|
| Fable-method distill + re-gate | Re-earn from durable gaps only; or park |
| SWE-bench Lite harness | **Deleted** — do not restore without new ADR |

Delivery Cost auto-capture: parked / out of scope for now (never a promote input).

---

## Safe commands today

| Command | What it does |
|---------|-------------|
| `bash tests/run-all.sh` | Full aggregate gate |
| `bash evals/traps/run-repeats.sh` | 4× full S1–S14 at luna-xhigh → `AGGREGATE.md` |
| `bash evals/traps/run-tier-sweep.sh` | Optional full S1–S14 × low/medium/high diagnostic → `TIERS.md` |
| `bash evals/traps/run-full-first.sh` | Single full S1–S14 loop |
| `bash evals/prepare-trap-campaign.sh` | Stub N×3 scorecards |
| `bash evals/run-trap-campaign.sh --jobs 12` | Parallel trap cells |
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
7. **CI Windows shellcheck:** GitHub zip — not Chocolatey.
8. Smart sync skips vendor skill copy when `VENDOR.lock` unchanged — empty skills need `./azg setup --force`.
9. **Windows `azg apply`:** CRLF-only diffs possible — `git restore` if needed.
10. Vendor prune: azg skills = dirs under `templates/global/skills/azg/`.
11. **Windows eval Python:** Store `python3` stub → use `azg_python`. Empty `TRAP_FULL` = unset for fable full default.
12. **No Lite** — `evals/lite/` gone; Trap only.
