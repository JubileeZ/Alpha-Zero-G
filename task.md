# Active Task: Process Gate — full Fable-method Candidate

- **Status:** In Progress
- **Objective:** Run full Trap Suite 3-arm with upstream Fable-method (`AGENTS.md` + skills @ `VENDOR.lock`) as Candidate; compare vs baseline and current (`d5711c2`).
- **Acceptance:** `evals/traps/campaigns/fable-method-full/promote-result.json` from 14×3 cells; `bash tests/test-traps.sh` pass; grill Q1–Q5 settled or defaults recorded.
- **Issue/Ticket:** ROADMAP § Parked — Process Gate vs full Fable-method (ADR 0012)

## Work Packet (SFDBN)

- **Status:** Runner wired; full campaign **running** (`evals/traps/campaigns/fable-method-full/`). Early: s1 3/3 pass; s2 0/3 fail (all arms).
- **Files:** `evals/trap-fable-pack.sh` (new) · `evals/run-trap-cell.sh` · `evals/traps/run-full-first.sh` · `evals/traps/README.md` · `evals/traps/CAMPAIGN.md` · `docs/agents/current-state.md`
- **Decisions:** `TRAP_CANDIDATE_PACK=fable-method` (default in `run-full-first.sh`); four skills injected; current arm `d5711c2`; promote bar `≥` per `analyze-trap.sh`; win → distill to azg gates (ADR 0009), not vendor fable on device; grill Q1–Q5 **defaults** until user answers
- **Blocked:** None — campaign wall-clock (~42 agent cells, `TRAP_JOBS=3`)
- **Next:** Let campaign finish → `bash evals/analyze-trap.sh evals/traps/campaigns/fable-method-full`; report rates; if promote, start distill pass per ROADMAP

## Todo
- [ ] Campaign complete (42 cells scored)
- [ ] `analyze-trap.sh` + promote verdict
- [ ] Grill Q1–Q5 confirmed or revised
- [ ] If promote: distill Candidate → azg `AZG:AGENT-INSTRUCTIONS` + re-gate

## Blockers / Notes
- Monitor: `find evals/traps/campaigns/fable-method-full -name scorecard.json -exec jq -r 'select(.task_success!=null) | "\(.scenario_id)/\(.treatment) \(.task_success)"' {} \; | sort`
- Resume: `TRAP_CAMP=$PWD/evals/traps/campaigns/fable-method-full bash evals/traps/run-full-first.sh --resume`
