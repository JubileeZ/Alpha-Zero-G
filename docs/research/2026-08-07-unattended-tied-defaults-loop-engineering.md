# Research: Unattended tied defaults (agentic + loop engineering)

**Date:** 2026-08-07  
**Ask:** On Unattended Session, when two reversible defaults tie — proceed (pick one) or labeled blocker? Framed for agentic focus + loop engineering.

## Sources opened

| Source | Role |
|--------|------|
| [Osmani — Loop Engineering](https://addyo.substack.com/p/loop-engineering) (2026-06-08) | Outer loop: replace human prompter; human gate for judgment |
| [agentpatterns — Interactive Clarification](https://agentpatterns.ai/patterns/agent-design/interactive-clarification-underspecified-tasks/) | Reversibility table; explore-first; informational vs navigational |
| [Vijayvargiya et al. Ambig-SWE / ICLR 2026](https://arxiv.org/abs/2502.13069) (via agentpatterns) | Underspec detection; interactivity gains when ask available |
| [Anthropic — Building effective agents](https://www.anthropic.com/engineering/building-effective-agents) | Pause at blockers; env ground truth; stop conditions |
| [agents-never-sleep skill docs](https://www.awesomeskills.dev/es/skill/tokonomix-agents-never-sleep) | Unattended ASK forbidden; PROCEED vs PARK by blast radius |
| [Loop Engineering Handbook](https://vibeengines.com/handbook/loop-engineering) | Mechanical stop conditions; maker≠checker |

## Findings

1. **Loop engineering** (Osmani): design system that prompts agent (trigger → triage → verify → state → next). Soft-halt on clarifying question wastes unattended run. Route only judgment / irreversible to human inbox; keep loop moving otherwise.

2. **Harness vs loop:** harness = one run tools/sandbox/context; loop = retry/stop/next. Azg Unattended Session rule sits at **inner-run policy** the outer loop depends on (never ASK mid-run).

3. **Reversibility heuristic** (agentpatterns): easily reversible → state assumption + proceed; costly reverse → ask; irreversible → block. Matches azg Reversible Default when attended.

4. **Informational vs navigational** (Ambig-SWE): explore resolves navigational; only user-held intent is informational. Coin-flip on **requirement meaning** = assumption propagation (wrong problem, looks correct).

5. **Unattended three-way** (agents-never-sleep): never ASK. **PROCEED** = assume+log for equivalent local impls / trivially-toggled defaults. **PARK** = high blast radius or unclassifiable requirement meaning (record candidates + human next-action). **HALT** = irreversible danger / no safety net. Explicit: wrongly parked small item cheap; wrongly assumed big item burns run.

6. **Anthropic agents:** once task clear, operate independently; pause at blockers; env feedback each step; iteration caps.

## Synthesis for azg Q6

Do **not** treat every “tie” as one rule.

| Tie type | Unattended action | Why |
|----------|-------------------|-----|
| **Impl-equivalent** (two local reversible choices, same risk class — naming, format, path under repo, trivially toggled) | **PROCEED:** pick one, state assumption, ship, verify | Loop must not stall; blast radius low; ANS “equivalent local implementations” |
| **Intent / requirement meaning** (two competent product readings; code cannot settle; wrong pick solves wrong problem) | **PARK / labeled blocker** (never ask, never coin-flip intent) | Informational gap; assumption propagation; human gate in loop engineering |
| **Irreversible / outward / high blast** | Blocker or AUTH path (existing azg) | Reversibility table + AUTH |

**Attended:** Reversible Default unchanged — ask only when irreversible/outward **or** two defaults **equally costly to reverse** *and* the cost is real (intent-class or hard undo), not cosmetic impl ties.

## Recommendation (Process Gate Candidate prose)

Unattended: never ask. Impl-equivalent tie → state + ship + verify. Intent-tie or no named default → labeled blocker. Keep thin always-on pointer; depth in `azg-method-refs` (WFA progressive disclosure).

## Could not verify

- No single industry RFC for “tied reversible defaults.”
- ClarifyGPT Pass@1 uplift cited in secondary blogs; primary paper not re-opened this pass (recommendation does not hinge on that figure).
- agents-never-sleep primary design doc beyond aggregator page — treated as practitioner pattern, not peer-reviewed.

## Fraud check

| Fraud | Status |
|-------|--------|
| Fabricated citations | Opened URLs above |
| Stale as current | Sources 2024–2026; loop eng June 2026 |
| Option-dump | Recommendation table stated |
| Narrative as evidence | Empirical Ambig-SWE via agentpatterns summary; ANS = design pattern not RCT |
