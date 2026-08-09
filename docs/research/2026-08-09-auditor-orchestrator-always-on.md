# Research: Auditor / Orchestrator vs always-on Execution Protocol

**Date:** 2026-08-09  
**Question:** For azg Device Setup always-on Execution Protocol — (A) fold auditor “Hunt classic frauds” into core verify + spawn verify subagent; (B) auto-run Orchestrator after triviality for non-trivial work vs raise trigger bar. Industry practice on separate judges, orchestration triggers, always-on vs skills, pitfalls.  
**AZG framing:** Lean always-on AGENTS policy already (“absolute lean”); EP v1 promoted (ADR 0016); fable `auditor` / `orchestrator` live as on-demand WIP skills (`wip/fable-method/compressed/`). Prior size note: [`2026-08-05-agents-md-always-on-budget.md`](./2026-08-05-agents-md-always-on-budget.md).

---

## Findings

### 1. Separate judge / adversarial verifier vs same-thread self-check

| Claim | Source | Notes |
|---|---|---|
| Official Claude Code: give Claude **way to verify**; second opinion = verification subagent / workflow so **“agent doing the work isn't the one grading it”** | [Claude Code best practices](https://code.claude.com/docs/en/best-practices) | Primary product guidance, not paper |
| Same docs: **Writer/Reviewer** across sessions — “fresh context improves code review since Claude won't be biased toward code it just wrote” | [Claude Code best practices](https://code.claude.com/docs/en/best-practices) | Fresh **context** emphasized |
| Same docs: **adversarial review step** before treating unattended work done — subagent sees **diff + criteria**, not author reasoning; bundled `/code-review` skill | [Claude Code best practices](https://code.claude.com/docs/en/best-practices) | Also: don't chase every finding → over-engineering |
| Anthropic product: long single-context work hits **self-preferential bias** (prefer own results when verify/judge), plus agentic laziness + goal drift; workflows spawn separate contexts to combat | [Dynamic workflows in Claude Code](https://claude.com/blog/a-harness-for-every-task-dynamic-workflows-in-claude-code) | Named failure mode; multi-agent = remedy for *that* class |
| Same blog: **Adversarial verification** pattern = for each spawn, separate agent verifies against rubric; “when not”: most traditional coding **does not need panel of 5 reviewers**; workflows use more tokens, for complex/high-value | [Dynamic workflows](https://claude.com/blog/a-harness-for-every-task-dynamic-workflows-in-claude-code) | Explicit anti-always-orchestrate |
| Cursor ships **separate** PR reviewer (Bugbot), not same-thread self-grade; in-IDE `/review-bugbot` / `/review` before push | [Cursor Bugbot docs](https://cursor.com/docs/bugbot) | Product pattern: review as distinct surface |
| Cursor docs example: custom **verifier** subagent (“validate completed work… report what passed vs incomplete”) | [Cursor subagents](https://cursor.com/docs/subagents) | Encouraged pattern; not mandated every turn |
| OpenAI Agents SDK: evaluator loop in **code** orchestration — task agent then **evaluator agent** until pass; also “let it critique itself” as tactic — both listed | [Agent orchestration](https://openai.github.io/openai-agents-python/multi_agent/) | Separate evaluator = supported pattern; self-critique also OK |
| OpenAI API agents guide: **start with one agent**; add specialists only when contract changes (capability / policy / prompt clarity) | [Orchestration and handoffs](https://developers.openai.com/api/docs/guides/agents/orchestration) | Anti premature multi-agent |
| Lab evidence: LLM-as-judge **self-preference** — models score own generations higher (self-recognition correlates) | [Panickssery et al. arXiv:2404.13076](https://arxiv.org/abs/2404.13076) | Judge bias; not coding-agent-specific |
| Lab evidence: GPT-4 self-preference measurable; mechanism tied partly to familiarity/perplexity | [Wataoka et al. arXiv:2410.21819](https://arxiv.org/abs/2410.21819) | |
| Caveat paper: some self-preference measurements confounded; sanity baseline cuts reported bias magnitude | [arXiv:2601.22548](https://arxiv.org/abs/2601.22548) | Bias real but easy to overstate |
| SWE-agent / SWE-bench lineage: **ground truth = tests / ACI**, not LLM self-judge as gate; evaluate PR via eval harness | [SWE-agent](https://github.com/SWE-agent/SWE-agent/) · [paper](https://arxiv.org/abs/2405.15793) | External objective check > model opinion |
| Aider: conventions always-on optional; **no** separate judge product — human-in-loop + tests | [Aider conventions](https://aider.chat/docs/usage/conventions.html) | Single-agent + small always-read |

**Synthesis of §1:** Industry coding-agent vendors **do** recommend separate reviewers for consequential / unattended work (Claude Code strongest; Cursor Bugbot as productized separate judge). Mechanism they emphasize for coding is often **fresh context / no author CoT**, not necessarily a different model family. Self-preference literature supports skepticism of same-model soft self-grade, with measurement caveats. Objective checks (tests, builds, diffs) remain primary gate; LLM judge is second opinion.

---

### 2. When to orchestrate multi-agent vs single-agent structured protocol

| Claim | Source | Notes |
|---|---|---|
| Multi-agent ~**15×** tokens vs chat; agents ~**4×**; only when task value pays; **most coding** fewer parallelizable tasks + weak real-time coordination → **not good fit today** | [Anthropic multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system) | Hard constraint for always-on Orchestrator |
| Multi-agent shine: heavy parallelization, info > single window, many complex tools | Same | Research-shaped, not edit-shaped |
| OpenAI: start single agent; split only when specialists earn isolation cost; early split → more prompts/traces/approvals without gain | [Orchestration and handoffs](https://developers.openai.com/api/docs/guides/agents/orchestration) | |
| Claude dynamic workflows: **not for every task**; ask “does it really need more compute?”; multi-agent vs single = parallelism/specialization must **earn coordination cost** | [Dynamic workflows](https://claude.com/blog/a-harness-for-every-task-dynamic-workflows-in-claude-code) | |
| Claude Code default harness already plan+execute in one context — “highly effective” for many coding tasks; custom harnesses for Research, security, agent teams, Code Review | Same | Orchestration = escalation, not default |
| Cursor: Agent uses built-in subagents **when appropriate**; user can force; custom subagents via description (“always use for…”) | [Cursor subagents](https://cursor.com/docs/subagents) | Host-gated, not always-on full pipeline |
| Triggers in practice: user invoke (`/orchestrator`, workflows, Bugbot), complexity/value, unattended length — **not** “every non-trivial” | Claude best practices + workflows + Bugbot | Convergent |

**Token/cost/latency:** Anthropic 15× multi-agent vs chat is the clearest primary number. Separate verify subagent = at least another context fill + tool loop (latency + $). Fan-out evidence gatherers similar. Structured single-agent protocol (EP) spends tokens in **one** window — cheaper than full orchestrator stages.

---

### 3. Always-on system prompts vs on-demand skills / subagents

| Claim | Source | Notes |
|---|---|---|
| Claude: CLAUDE.md every session; **only broadly applicable**; procedures → **skills**; target **&lt;200 lines**; longer → more context + **reduced adherence** | [Claude Code memory / CLAUDE.md](https://code.claude.com/docs/en/memory) · [best practices](https://code.claude.com/docs/en/best-practices) | Soft budget + layering |
| Claude Help: short, signal-dense, under ~200 lines | [CLAUDE.md help](https://support.claude.com/en/articles/14553240-give-claude-context-claude-md-and-better-prompts) | |
| Cursor: rules **under 500 lines**; split; Always / Intelligent / Files / Manual; AGENTS.md = simple always alt | [Cursor rules](https://cursor.com/docs/rules) | Layering by activation mode |
| Codex: combined project docs stop at **`project_doc_max_bytes` default 32 KiB**; nest or raise | [Codex AGENTS.md](https://developers.openai.com/codex/guides/agents-md) | Hard truncate ceiling |
| Aider: small CONVENTIONS.md; optional always-load via config | [Aider conventions](https://aider.chat/docs/usage/conventions.html) | Tiny always-on |
| GitHub: great AGENTS.md = commands, boundaries, stack, examples; **start simple, iterate** — no tok standard | [GitHub Blog agents.md lessons](https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/) | Quality ≠ length |
| Context rot: attention budget finite; growing windows ≠ free always-on; smallest high-signal set | [Anthropic effective context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) | |
| System prompts: Goldilocks altitude — avoid brittle if-else laundry lists of every edge case; prefer heuristics + JIT retrieval | Same Anthropic post | Anti “fraud catalog in always-on” |
| Claude: rules that CLAUDE.md keeps missing → **workflow with verifier agents per rule**, not fatter CLAUDE.md | [Dynamic workflows](https://claude.com/blog/a-harness-for-every-task-dynamic-workflows-in-claude-code) | Explicit demotion of always-on for hard rules |

**Vendors put full fraud-hunt / multi-stage orchestration in:** on-demand skills, subagents, workflows, PR bots — **not** root always-on. Always-on gets: verify-by-observation, hostile reread, when to escalate.

---

### 4. Pitfalls (nesting, always-spawn verify, fraud lists in always-on)

| Pitfall | Evidence | Implication for azg |
|---|---|---|
| **Token burn** if multi-agent default | Anthropic 15×; workflows “use more tokens” | Auto-Orchestrator after every non-trivial = cost cliff |
| **Coding poor multi-agent fit** (shared context, dependencies) | Anthropic multi-agent research | Orchestrator as always default contradicts lab guidance |
| **False-positive reviewers → over-engineering** | Claude Code adversarial review caveat | Fraud list + “prove wrong” every task → drive-by defenses |
| **Coordination / nested orchestrators** | Anthropic: agents not yet great at real-time delegate; workflows warn architecture layer must earn cost | Nest Orchestrator inside GSD/orchestrator = telephone + spend |
| **Always-spawn verify** | Claude: independent check matters more as **unattended length** grows; “most traditional coding” no 5-reviewer panel | Threshold by consequence / duration, not “non-trivial” |
| **Fat always-on → adherence drop** | Claude &lt;200 lines; context rot | Baking full auditor fraud table + orchestrator stages into AGENTS.md fights lean budget |
| **Eval-trap-shaped always-on lists** | Anthropic: avoid laundry-list edge cases in system prompt; Claude: hard-to-follow rules → separate verifier workflow | Trap catalogue in always-on teaches checklist costume + dilutes signal; keep traps in **eval harness** (azg Trap Process Gate), not Device Setup prose |
| **Same-family blind spots** | Self-preference / family-bias papers (e.g. Play Favorites PDF) | Subagent same model ≠ full independence; still helps via **fresh context**; objective tests remain ground truth |

---

## Synthesis for azg (decision-shaped)

### Idea A — fold auditor into core verify + always spawn verify subagent

| Piece | Verdict |
|---|---|
| Thin verify discipline already in EP (observe done + surrounding health + hostile reread / artifact gates) | **Keep / strengthen slightly** in always-on — matches Claude “give way to verify” + evidence-over-assertion |
| Full **“Hunt classic frauds”** catalogue (weakened checks, false completion, scope creep, AUTH fraud, …) | **Do not** paste into always-on. Keep as **on-demand auditor skill** (or agent-requestable rule). Matches vendor layering + Anthropic anti-laundry-list |
| Spawn **verify subagent** | **Conditional**, not every task. Triggers that match primary sources: consequential change, long unattended run, user `/auditor` or `/review`, plan-vs-diff check. Prefer **fresh context + distinct lens**; readonly if host allows |
| Expectation: subagent kills self-bias | **Partial.** Fixes author-CoT / path dependency well (Claude). Model self-preference literature still applies if same model family. Ground truth stays tests/diff/re-run |

**Lean A recommendation:** always-on = short pointer (“for consequential/unattended: spawn adversarial verify subagent or invoke auditor”); fraud catalogue + suite mode stay skill. Do **not** make every Step 5 a subagent fan-out.

### Idea B — always Orchestrator after triviality vs raise bar

| Piece | Verdict |
|---|---|
| Always Orchestrator for all non-trivial | **Reject.** Contradicts Anthropic (coding ≠ multi-agent sweet spot; 15× tokens) + OpenAI (start one agent) + Claude workflows (“not every task”) |
| Raise bar / user-invoke / consequential only | **Prefer.** Aligns with fable skill triggers today (`/orchestrator`) and host patterns (Bugbot, `/code-review`, workflows) |
| Plain core protocol as default for non-trivial | **Prefer.** Single structured agent is industry default for coding; fan-out evidence/verify only when parallelism or independence earns cost |
| Complexity gate design | If gate exists: multi-area evidence, long unattended, high blast radius, user ask — **not** “failed triviality” alone |

**Lean B recommendation:** Orchestrator remains **skill / on-demand** (optionally agent-requestable with high bar description). Triviality → core protocol; non-trivial → core protocol; escalate to Orchestrator when user asks or when task is parallel/breadth/unattended-heavy.

### Combined posture (what makes sense)

```
Always-on AGENTS: lean EP (classify, done, evidence, intent, verify-by-observation, honest report)
                 + short escalate hooks (when to auditor / orchestrator / subagent verify)
On-demand:       auditor (fraud hunt + optional suite)
                 orchestrator (fan-out evidence → plan → execute → adversarial verify)
Eval harness:    Trap Process Gate owns trap-shaped fraud detection — not Device Setup
```

Does **not** make sense: always-on fraud encyclopedia; always-spawn verify; auto-Orchestrator on every non-trivial; nesting orchestrators; treating same-model subagent as perfect unbiased judge.

---

## Open questions

1. **Host enforceability:** Cursor/Claude can *suggest* verify subagents; will Device Setup always-on reliably trigger them without hooks? (May need Stop/checkpoint hook or skill description “always use for…”, not prose alone.)
2. **Cross-model verify:** Worth azg recommending different model for attacker subagents when host allows (Claude workflows: model routing)? Cost vs bias reduction unmeasured for azg Trap gate.
3. **Quantitative gate:** What concrete threshold (files touched, unattended minutes, blast radius) for auto-verify — no vendor publishes coding-agent N; need Trap A/B if adopting.
4. **Same-thread hostile reread vs subagent:** EP already has hostile reread; incremental gain of subagent-only on medium tasks unknown — candidate for Trap arm, not speculation.
5. **Devin-style products:** limited public primary engineering writeups on always-on vs skill layering comparable to Anthropic/Cursor/OpenAI — treat as under-documented here.

---

## Could-not-verify / exclusions

- Devin internal harness always-on contents (no trustworthy public primary).
- Exact Cursor billing cadence for nested AGENTS.md (forum/secondary only; omitted as load-bearing).
- Secondary blogs (ClaudeKit, DevGENT, etc.) not used as citations; Claude official best practices + Anthropic blogs used instead.
