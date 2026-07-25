# Current Implementation State

**Read this first** after `docs/AGENT-ONBOARDING.md`. `ROADMAP.md` is plan; this file is **what exists on disk today**.

**Active phase:** none — v4 complete; reliability claim still false until confirmation+held-out

---

## What exists

| Area | Path | Notes |
|------|------|-------|
| CLI | `azg`, `lib/` | setup, new, apply, update, uninstall |
| Evaluation Suite | `evals/` | 3 fixtures · core/baseline · Blind Judge · Long-Horizon |
| Aggregate / CI | `tests/run-all.sh`, `.github/workflows/ci.yml` | AZG_STRICT matrix; LF + shellcheck -S error |
| Portable gate | `templates/project/tests/verify.sh` | Harness integrity |
| ADRs 0004, 0006 | `docs/adr/` | Repo-native reliability · spawn-budget PreToolUse |
| Glossary | `CONTEXT.md` | Reliable Delivery terms |

---

## What does NOT exist yet

| Item | Notes |
|------|-------|
| Reliability claim | Need confirmation+held-out + `--apply-claim` |
| Delivery Cost capture | Operator has no token/spend tracking yet |

---

## Known hardening gaps (post-v4 audit)

Wholesale revamp not needed. Remaining release blockers:

| Gap | Risk | Next |
|-----|------|------|
| Global MCP/AGENTS/uninstall ownership | Can overwrite or delete foreign config/skills | Ownership manifest + selective uninstall ADR |
| Pilot claim gate provenance | Can mark ready without fixture mix/judge/calibration/real cost | Fail-closed analyzer ADR |
| Ask-matt routes to non-core skills | Dead links in default profile | Overlay truthful 12-skill router |
| Checkpoint adapter mismatch | Cursor Stop vs Antigravity Stop accept different files | Unify Work Packet contract |

---

## Safe commands today

| Command | What it does |
|---------|-------------|
| `bash tests/run-all.sh` | Full aggregate gate |
| `bash evals/run-pair.sh <id> core\|baseline` | Prepare eval workdir |
| `bash tests/test-evals.sh` | Suite structural tests |
| `./azg setup --dry-run` | Preview global install (needs `jq`) |

---

## Agent pitfalls

1. Mock `HOME` in tests — setup writes under `~/.gemini/`.
2. `jq` required for setup/apply; Windows Git Bash may need WinGet Links on `PATH`.
3. GitHub ops auth: see `docs/agents/issue-tracker.md` (gh → git credential token → ask user).
4. Live solves: open `run-pair` WORKDIR, not harness repo root.
5. `azg apply` refreshes AZG-owned files; custom hooks/skills not in template stay.
6. Spawn-budget enforce is PreToolUse (ADR 0006), not SubagentStart.
7. Eval tests set `AZG_PILOT_DIR`; never append synthetic records to tracked pilot logs.
8. Harness counters do not cross Bash subshells; keep `pass`/`fail` calls in parent test shell.
