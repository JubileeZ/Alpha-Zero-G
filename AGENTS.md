# Alpha-Zero-G
# Read by all AI agents (Claude, Gemini, Cursor, Copilot, etc.) working in this repo.
---

## Project Identity

Outer agent harness installer: templates + `azg` CLI for Cursor and/or Antigravity (`agy`). v4 complete. Spec: `docs/REVAMP-SPEC.md`.

**Stack:** Bash (3.2-safe `lib/`; prefer ≥4.0 locally) · jq · Python 3.x · Git · agy

**Monorepo:** no

---

## Repo Structure

```
.agents/          # hooks, skills
docs/             # ADR, agent guides, architect refs
lib/              # azg CLI scripts
templates/        # global/ + project/ scaffolds
tests/            # verify, run-all, phase suites
azg               # CLI entrypoint
CONTEXT.md        # glossary
VERSION           # release version
```

---

## Commands & testing

| Command | When |
|---------|------|
| `bash tests/verify.sh` | Iteration / checkpoint (seconds) |
| `bash tests/run-all.sh` | Pre-PR; CI parity; broad `templates/`/`lib/` (minutes) |
| `AZG_STRICT=1 bash tests/run-all.sh` | Strict CI parity (fails if shellcheck/python3 missing) |
| `shellcheck azg lib/*.sh evals/*.sh tests/*.sh` | Lint edited Bash |
| `bash tests/run-all.sh --list` | Suite order when unsure |
| `python3 tests/verify_docs.py` | Docs-only |

**Diff → suite:** setup/common/Cursor device → `test-cursor-device-setup.sh` · scaffold/apply → `test-azg.sh` + `test-phase*.sh` · `templates/project/` → `test-phase10.sh` + `test-mutation-verify.sh` · `evals/lite/` → `test-lite.sh` · hooks → `host-contract-smoke.sh` + `test-phase5.sh`

Pre-commit: lint + affected tests green. `run-all` slow by design (isolated suites; overlap OK). Windows: Git Bash only. Onboarding: `docs/AGENT-ONBOARDING.md`. Lite arm: `bash evals/run-lite-arm.sh <id> baseline|current|candidate`.

---

## Off-Limits

- Secrets / `.env` / credentials
- DB migrations (flag only; never auto-apply)
- Production config
- `# DO NOT EDIT` / `# GENERATED` files

---

## Project-Specific Safety

- `templates/` / `lib/` edits → run matching phase tests after
- No breaking backward compat of retrofitted client workspaces

---

## Code Conventions

- `lib/*.sh` sources `lib/common.sh` (`info`/`warn`/`die`, cross-platform helpers)
- Shellcheck clean; inline disables only when necessary

---

## Agent Behavior Overrides

- Docs telegraphic: fragments, no filler
- Downstream client `AGENTS.md`: hybrid layout (user zone above markers; managed between)
- Keep `AGENTS.md` light; detail → `docs/agents/`

---

<!-- AZG:MANAGED:START -->
## Session start

1. Read `docs/agents/current-state.md` (if unfamiliar with repo state).
2. Read `ROADMAP.md` (first unchecked item in active phase).
3. Read `task.md` Work Packet / open issues (if present).
4. Run `git log -5 --oneline` + `git status` (to sync history).
5. Do not rely on chat history.

Before Checkpoint (git commit of in-progress work): update Work Packet SFDBN fields in `task.md`.

---

## Universal Safety Rules

- No secrets/tokens/credentials in any file.
- Destructive ops (delete/overwrite/truncate/drop): inline `# DESTRUCTIVE: <reason>`.
- No new top-level dependencies without flagging in response.
- Agent harness device changes: implement scalably for current/future devices and new repos.
- Prefer reversible actions. If irreversible, state clearly before executing.
- Tool blocked by safety hook? Explain block, suggest exact command/content to write manually.
- Windows: run CLI/hooks only inside Git Bash.

---

## Domain Vocabulary

- Ambiguous terminology? Read `docs/agents/domain.md`.
- New terms? Create `CONTEXT.md` at root from `docs/agents/CONTEXT.md.tmpl` to register glossary.

---

## Progress & Issues

- Progress workflow: read `docs/agents/progress.md`.
- Issue tracker setup: read `docs/agents/issue-tracker.md`.
- Compaction: collapse completed phase checklists in `ROADMAP.md` to a single header/summary line (Active-Phase Compaction).
- Cleanup: delete transient session files (`task.md`, `implementation_plan.md`, `walkthrough.md`) once milestone/task is complete.
<!-- AZG:MANAGED:END -->
