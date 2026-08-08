# Alpha-Zero-G
---

## Project Identity

Outer agent harness installer: templates + `azg` CLI for Cursor and/or Antigravity (`agy`). v4 complete. Spec: `docs/SPEC.md`.

**Stack:** Bash (3.2-safe `lib/`; prefer ≥4.0 locally) · jq · Python 3.x · Git · agy

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

## Key Commands

| Command | When |
|---------|------|
| `bash tests/verify.sh` | Iteration / checkpoint (seconds) |
| `bash tests/run-all.sh` | Pre-PR; CI parity; broad `templates/`/`lib/` (minutes) |
| `AZG_STRICT=1 bash tests/run-all.sh` | Strict CI parity (fails if shellcheck/python3 missing) |
| `shellcheck azg lib/*.sh evals/*.sh tests/*.sh` | Lint edited Bash |
| `bash tests/run-all.sh --list` | Suite order when unsure |
| `bash tests/run-verify-docs.sh` | Docs-only link check (python3 / python / `py -3`) |

**Diff → suite:** setup/common/Cursor device → `test-cursor-device-setup.sh` · scaffold/apply → `test-azg.sh` + `test-phase*.sh` · `templates/project/` → `test-phase10.sh` + `test-mutation-verify.sh` · `evals/traps/` → `test-traps.sh` + `test-eval-isolation.sh` · hooks → `host-contract-smoke.sh` + `test-phase5.sh`

**Commit readiness:** run the smallest applicable checks for the touched area (see Diff → suite); confirm they pass before proposing a commit. Pre-PR / CI parity: `bash tests/run-all.sh` (or `AZG_STRICT=1` when matching CI).

**Windows:** run azg CLI, hooks, and `tests/*.sh` in Git Bash or another Bash-capable shell. App/node commands may use PowerShell.

---

## Safety Rules

- Never commit, print, or paste secret values (from `.env`, credentials, tokens, or chat). App/harness code may read env vars; do not exfiltrate their values.
- `templates/` / `lib/` edits → run matching phase tests after
- No breaking Downstream harness: preserve `AZG:MANAGED` user-zone merge; don't break `azg apply` / hooks contracts without an explicit migration
- Agent harness device changes: implement scalably for current/future devices and new repos

---

## Code Conventions

- `lib/*.sh` sources `lib/common.sh` (`info`/`warn`/`die`, cross-platform helpers)
- Shellcheck clean; inline disables only when necessary

---

## Agent guidance

- Downstream client `AGENTS.md`: hybrid layout (user zone above markers; managed between)
- Keep `AGENTS.md` light; detail → `docs/agents/`

### Eval campaigns — agent owns the watch

When this agent **starts** or **inherits** a Trap Process Gate campaign (setsid, background `run-process-gate` / `run-trap-campaign`):

1. **Do not** leave the user to `tail -f` / poll alone. Agent watches until finish or hard block. Launch long runner with stdout visible and `notify_on_output` matcher `^AZG_TRAP_CAMPAIGN_FINISHED`; do not redirect away completion event. Preview pause may need human `y` or `--yes`.
2. Poll: filled scorecards vs expected · `campaign.log` / `campaign.pid` · terminal artifacts (`LEDGER.md`, `aggregate.json`, `LAST-GATE.md`).
3. Cadence: completion event → report immediately. Without event, fixed 120-second heartbeat: first check at 120s, then every 120s; never stretch interval. On process exit without artifact → diagnose.
4. **On finish:** report outcome (overall + Coverage + recommend) in chat; update `task.md` + `evals/traps/CAMPAIGN.md` and/or `docs/agents/current-state.md` as needed. Do not end the turn with only "watch this path."

Live camps (gitignored): `evals/traps/campaigns/<id>/`.

---

<!-- AZG:MANAGED:START -->
## Placeholder fill

`<!-- AGENT: ... -->` in agent/tracking docs (e.g. `AGENTS.md`, `ROADMAP.md`, `docs/agents/*`):
1. Ask fill or skip; skip → leave comment exact.
2. One section at a time; ≤3 options, recommended first.
3. Done → drop resolved comments + inapplicable sections; telegraphic prose.

---

## Session start

Once per session (not every turn). Continuity from listed files (chat ≠ continuity):

1. `current-state.md` (reality).
2. `task.md` if present (Work Packet). Absent = no active packet (OK).
3. `ROADMAP.md` active phase / first unchecked only.
4. `git status` + `git log -5 --oneline` before edit.
5. Other docs JIT via pointers.

If handoff present or user says continue: read `.agents/session-handoff.md`.

Session start done when: `current-state` + (`task.md` if present) + ROADMAP slice read; git status/log before first edit.

Missing required continuity doc: restore from git if history exists; else ask user.

During work / before Checkpoint: update tracking docs when state changes
(see `docs/agents/progress.md`). Before Checkpoint: refresh Work Packet SFDBN in `task.md`.

JIT (read when task needs): full `CONTEXT.md`, `progress.md`, `issue-tracker.md`, archived ROADMAP, research notes.

---

## Harness Safety

- Safety-hook deny: explain the block; give exact manual command/content; leave hook unchanged (do not execute the blocked action).

---

## Domain Vocabulary

- Ambiguous domain terms: follow `docs/agents/domain.md` (read `CONTEXT.md` / `CONTEXT-MAP.md` + relevant ADRs; use glossary/ADR terms only).
- Glossary/ADR writes: `/grill-with-docs` (uses `/domain-modeling`) after a term is resolved — domain concepts only; glossary-only; lazy create/update per that skill.

---

## Work State & Checkpoints

- Tracker: `docs/agents/issue-tracker.md`. Updates/compaction/archive/cleanup: `docs/agents/progress.md`.
- Code commits: stage updated `task.md` (Work Packet) with code — `commit-gate` enforces. Trivial: minimal packet OK; clear/delete when done same commit if appropriate.
- Handoff / device switch / leave-for-other-agent → follow `docs/agents/progress.md` §Device Handoff (canonical `.agents/session-handoff.md`). Day-to-day same device: `task.md` + `current-state.md`.
- Before Checkpoint / stop with code: refresh `task.md` and/or `current-state.md` and/or handoff as appropriate (hooks accept those).
- Cleanup when task complete: delete `implementation_plan.md` / `walkthrough.md`; delete or empty `task.md` (finished packet — do not re-seed old content). Next task: create a new Work Packet with required SFDBN markers; durable state stays in ROADMAP / current-state / git.
<!-- AZG:MANAGED:END -->
