# Active Task: Think/Prove Candidate → Trap re-earn

- **Status:** Candidate shipped on main; Trap campaign pending other device
- **Objective:** Ship Think/Prove Device Setup Candidate (always-on + family skills + block order) ready for Trap Process Gate vs Current
- **Acceptance:** ADR 0014; AGENT-INSTRUCTIONS before Ponytail; setup migrate; azg skills installed by setup; plain global wording; intent-gates/eval-isolation/cursor-device-setup green; pushed for other-device eval
- **Issue/Ticket:** Trap re-earn after clean slate (map distill)

## Work Packet (SFDBN)

- **Status:** Code Candidate done; eval handoff to other device
- **Files:** `templates/global/AGENTS.md` · `templates/global/skills/azg/` · `lib/setup.sh` · `evals/stage-eval-home.sh` · ADR 0014 · tests
- **Decisions:** Crumbs + orchestrate + all 8 domains; denser skills; azg names; beat Current this version; AGENT-INSTRUCTIONS first + setup migrate; no fable product name on device
- **Blocked:** None for commit; Trap run on other device
- **Next:** Other device — Trap campaign with `AZG_EVAL_AZG_SKILLS=1`, Current pin `a9a68ff` (see CAMPAIGN.md / below)

## Eval handoff (other device)

```bash
export TRAP_CAMP="$PWD/evals/traps/campaigns/think-prove-candidate"
export AZG_EVAL_AZG_SKILLS=1
export TRAP_CHANGE_TYPE=intent_gates
export AZG_CURRENT_REF=a9a68ff
# Candidate = HEAD (this commit). Do not set TRAP_CANDIDATE_PACK=fable-method.
bash evals/prepare-trap-campaign.sh
# Prefer: bash evals/traps/run-tier-sweep.sh
# or: bash evals/traps/run-repeats.sh   # R>=3 @ luna-medium
```

## Todo
- [x] Always-on + precedence + block order + setup migrate
- [x] Family pack skills + plain wording
- [x] ADR 0014; tests green
- [ ] Commit + push
- [ ] Trap campaign on other device
