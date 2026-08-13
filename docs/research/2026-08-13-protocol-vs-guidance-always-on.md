# Research: Protocol vs guidance as always-on instruction style

**Date:** 2026-08-13  
**Question:** For coding-agent always-on instructions (AGENTS.md, CLAUDE.md, Cursor rules, Codex AGENTS.md): do high-trust primary sources recommend a numbered step-by-step execution protocol (classify → define done → evidence → act → verify → report as mandatory steps) versus short heuristic / principle guidance (what good work looks like, without a step machine the model must follow literally)?  
**AZG framing:** Device Setup always-on today = Execution Protocol v1 (~125 lines, "Follow literally", Steps 0–6 + INTENT/AUTH/TWINS artifact gates) in `templates/global/AGENTS.md`. Trap `gate-execution-protocol-v1` R=5 @ gpt-5.6-luna-low docker: majority B/Cur/Cand tied 79%; mean Baseline 80% > Candidate 77% > Current 73%; Coverage 13/14 Cand vs Cur. Baseline coverage reported-only (ADR 0012). Vision = higher Task Success per cost than No-Harness Baseline. Operator considering: keep protocol, replace with guidance, or empty always-on (No-Harness-like AGENT-INSTRUCTIONS) at Device Setup (global) level.  
**Related prior notes (do not duplicate):** [`2026-08-09-auditor-orchestrator-always-on.md`](./2026-08-09-auditor-orchestrator-always-on.md) (layering: always-on vs skills/subagents; Goldilocks cited there at layering altitude) · [`2026-08-05-agents-md-always-on-budget.md`](./2026-08-05-agents-md-always-on-budget.md) (size/attention budget, not style) · [`2026-07-31-agent-context-engineering-tracking-docs.md`](./2026-07-31-agent-context-engineering-tracking-docs.md) (tracking-doc JIT). This note goes deeper on **instruction style**: numbered protocol vs principles/heuristics.

---

## Findings

### 1. Anthropic — Goldilocks altitude, system-prompt style, always-on vs JIT

| Claim | Source | Notes |
|---|---|---|
| System prompts: **Goldilocks altitude** between two failure modes — (a) hardcoding complex brittle if-else logic for exact agentic behavior → fragility + maintenance; (b) vague high-level guidance that gives no concrete signals / falsely assumes shared context. Optimal = **specific enough to guide, flexible enough to be heuristics** | [Effective context engineering for AI agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) (Sep 2025) | Re-opened primary. Direct implication: numbered "Follow literally" step machine ≈ failure mode (a); empty/vague always-on ≈ (b) |
| Strive for **minimal set of information that fully outlines expected behavior**. Minimal ≠ short; still need enough up front for adherence. **Start with a minimal prompt on the best model**, then add instructions/examples from **observed failure modes** | Same | Anti upfront laundry-list protocol. Add structure after eval, not before |
| Do **not** stuff laundry lists of edge cases into prompts. Curate **diverse canonical examples** instead | Same | Anti-catalog; EP artifact gates (INTENT/AUTH/TWINS) are a form of enumerated edge-case checklist |
| Context rot: attention budget finite; **smallest high-signal token set**. Growing windows ≠ free always-on | Same | Size treated in 2026-08-05; style implication = every mandatory step competes for attention with the actual task |
| Hybrid: CLAUDE.md **naively dropped in up front**; glob/grep = JIT. As models improve, **less prescriptive engineering**, more autonomy. **"Do the simplest thing that works"** | Same | Always-on = thin index/heuristics; procedures discovered JIT |
| Smarter models **require less prescriptive engineering** | Same, conclusion | Matches empirical §5 (prompt influence shrinks with LLM generation) |
| **Workflows** = LLMs+tools on **predefined code paths**. **Agents** = LLM **dynamically directs** own process. Find **simplest solution**; increase complexity only when needed. Start with simple prompts; add multi-step agentic systems only when simpler fall short | [Building effective agents](https://www.anthropic.com/engineering/building-effective-agents) (Dec 2024) | Numbered always-on protocol tries to get **workflow predictability from prose**. Anthropic puts that predictability in **code/hooks**, not system-prompt step machines. Agents: env ground truth each step (tests/tool results), not self-narrated step headers |
| Success = **right** system not most sophisticated. Three principles: **simplicity**; transparency of planning; craft ACI (tools) | Same | While building SWE-bench agent they spent **more time optimizing tools than the overall prompt** |

**§1 synthesis:** Goldilocks is not "write a 7-step protocol." It is **heuristics at the right altitude + JIT retrieval + add from failures**. A mandatory classify→done→evidence→act→verify→report machine is the brittle if-else end of their spectrum. Empty always-on is the other end. Lean principles sit in the zone they name.

---

### 2. Claude Code — CLAUDE.md vs skills; numbered workflows belong where

| Claim | Source | Notes |
|---|---|---|
| CLAUDE.md every session: **only broadly applicable**. Domain knowledge / **workflows only relevant sometimes → skills** (load on demand, no bloat) | [Claude Code best practices](https://code.claude.com/docs/en/best-practices) | Official product guidance |
| Example CLAUDE.md is **short heuristics**, not a step protocol: code style bullets + "typecheck when done" + "prefer single tests" | Same (sample block) | Canonical always-on shape = conventions + verify habit, **not** Steps 0–6 |
| Keep concise. Test: *"Would removing this cause Claude to make mistakes?"* **Bloated CLAUDE.md files cause Claude to ignore your actual instructions** | Same | Adherence drop = costume/ignore risk, not just tokens |
| If Claude keeps violating a rule: file **probably too long** and rule getting lost. Treat CLAUDE.md like code: prune; test by **observing behavior shift** | Same | Process-narration in chat is not the verification they want |
| Include: bash commands Claude can't guess, project-specific style, test runners, repo etiquette, architectural decisions, env quirks, non-obvious gotchas. **Exclude:** what Claude can read from code, standard conventions, detailed APIs, long explanations/tutorials, file-by-file maps, **"write clean code"** | Same include/exclude table | EP v1 is closer to excluded "long explanations" + self-evident process than to included project facts |
| Target **&lt;200 lines per CLAUDE.md**. Longer → more context + **reduced adherence**. Overflow → path-scoped rules (load when matching files). `@imports` still load at launch | [Claude Code memory / CLAUDE.md](https://code.claude.com/docs/en/memory) | Size in 2026-08-05; here: **adherence**, not just bytes |
| Keep CLAUDE.md to **facts Claude should hold every session**: build commands, conventions, layout, **"always do X" rules**. If entry is a **multi-step procedure** or only matters for one part of codebase → **skill or path-scoped rule** | Same | Direct: numbered execution protocol is a multi-step procedure |
| Rules (`.claude/rules/`) load every session or on matching files. **Task-specific instructions that don't need to be always-on → skills** | Same | |
| Create a skill when you keep pasting the same **instructions, checklist, or multi-step procedure**, or when a CLAUDE.md section has **grown from a fact into a procedure** | [Claude Code skills](https://code.claude.com/docs/en/skills) | Explicit promotion path: procedure **out** of always-on |
| Skill body: **state what to do rather than narrating how or why**; same conciseness test as CLAUDE.md | Same | Anti costume even **inside** skills |
| **Procedural** instructions (deploy, release checklists, review processes) **belong in a skill**, not CLAUDE.md | [Steering Claude Code](https://claude.com/blog/steering-claude-code-skills-hooks-rules-subagents-and-more) (Jun 2026, Anthropic staff) | Strongest first-party sentence on this question |
| **"A 30-line procedure in CLAUDE.md. Procedures belong in skills."** CLAUDE.md = facts to hold all the time. Runbook/checklist → `.claude/skills/` | Same ("When to use each method") | EP v1 ~125 lines of procedure **4×** their anti-pattern example |
| CLAUDE.md grows by accretion → every line costs tokens **whether relevant or not** and **dilutes adherence** to instructions that matter. Push conventions to path rules, **procedures to skills** | Same | Device Setup **global** EP hits every repo, every task |
| **"Every time X, always do Y" in CLAUDE.md** — if it must happen reliably → **hook** (deterministic). Model choosing to run a formatter ≠ formatter running | Same | Artifact gates (INTENT/AUTH/TWINS) are "always do Y" with no hook; model can narrate the tokens without doing the work |
| **"Never do this" in CLAUDE.md** — instruction is the **wrong tool** for must-not. Under pressure / long session / injection, model can fail a prompted rule. Real guardrail = hooks + permissions | Same | AUTH/irreversible: prose gate ≠ enforcement |
| CLAUDE.md instructions **advisory**; hooks **deterministic and guarantee** the action | [Best practices](https://code.claude.com/docs/en/best-practices) (hooks vs CLAUDE.md) | |
| Skills example of repeatable workflow is numbered **inside SKILL.md** (`/fix-issue`: search → implement → typecheck), invoked on demand | [Best practices](https://code.claude.com/docs/en/best-practices) Create skills | Numbered steps **OK in skills**, not root always-on |
| Over-specified CLAUDE.md: Claude **ignores half** because important rules get lost in noise | Same, "common pitfalls" | |

**§2 synthesis:** Claude Code's official split is unambiguous: **always-on = facts + short "always do X" heuristics**; **numbered/multi-step procedures = skills**; **must-happen = hooks**. EP v1 as Device Setup always-on is the pattern they tell users to **demote**.

---

### 3. Cursor — rules / AGENTS.md / skills; against long procedural always-on

| Claim | Source | Notes |
|---|---|---|
| Two layers: **rules** = things agent should **always know**; **skills** = specialized knowledge **when relevant**. Map to onboarding a teammate | [Customizing agents](https://cursor.com/learn/customizing-agents) | Official learn path |
| Good rule file = **short, specific, pointers to examples**. Works best for: build/test commands, conventions, canonical-example pointers, **guardrails** | Same | Sample "Workflow" is two bullets (typecheck after changes; API routes go here) — not a step machine |
| **Start simple.** Rules included every conversation, so they add up. Add **only when Agent makes the same mistake repeatedly**; keep short | Same + [Rules](https://cursor.com/docs/rules) | Same "add from failures" as Anthropic/Codex |
| Avoid: entire style guides, documenting every command, **edge cases that rarely apply**, duplicating codebase | [Rules](https://cursor.com/docs/rules) | EP edge-case gates (triviality 4-part test, twin-search, artifact layout) are rare-case catalogs |
| **Over-engineering rules:** tempted to write rules for everything — **resist**. Too many rules consume context and **may confuse the agent**. Occasional need → skill | [Customizing agents](https://cursor.com/learn/customizing-agents) | Direct anti long always-on protocol |
| AGENTS.md = **simple markdown alternative** to `.cursor/rules` for straightforward use cases. Example = code style + architecture bullets | [Rules](https://cursor.com/docs/rules) | Not a numbered execution protocol |
| Skills **more detailed than rules**, designed for **multi-step workflows**. Rules = short guidelines/constraints (few lines to a few hundred). Skills = **often longer, detailed step-by-step** | [Help: Skills](https://cursor.com/help/customization/skills) | **Use a rule when a short instruction is enough. Use a skill when Agent needs a detailed, repeatable process** |
| Example skill = numbered deploy: build → test → deploy → healthcheck → report | Same + customizing-agents | Numbered protocol **is the skill shape** |
| `/migrate-to-skills` converts **dynamic** rules (not `alwaysApply: true`) and slash commands → skills. Always-apply / glob rules **not** migrated | Same | Host itself demotes procedural always-on toward skills |
| As models got better as agents: success from **providing fewer details up front**, letting agent **pull context**. Dynamic context discovery vs static always-included. Fewer details → less confusing/contradictory info → **better response quality** | [Dynamic context discovery](https://cursor.com/blog/dynamic-context-discovery) | First-party harness blog. Static 125-line protocol is the opposite of their measured direction |
| Skills: name+description as small static; body discovered JIT (grep/semantic search) | Same | Matches Claude progressive disclosure |
| A/B: MCP tool descriptions as files vs always-in-prompt → **46.9% fewer total agent tokens** on runs that called MCP (stat-sig; high variance) | Same | Vendor A/B is about **static vs JIT loading**, not protocol vs principles — still: less always-on detail helped |

**§3 synthesis:** Cursor's published split matches Claude: **always-on rules = short conventions/guardrails**; **step-by-step process = skills**. AGENTS.md is the *simple* path. Host direction of travel = **less static, more discovery**.

---

### 4. OpenAI Codex AGENTS.md / Agents SDK — start simple, when to add structure

| Claim | Source | Notes |
|---|---|---|
| Ladder: right **task context** → `AGENTS.md` for **durable guidance** → configure Codex → MCP → **turn repeated work into skills** → automate stable workflows | [Codex best practices](https://developers.openai.com/codex/learn/best-practices) (also [Codex manual](https://developers.openai.com/codex/codex-manual.md)) | Skills sit **after** a short AGENTS.md, not inside it |
| Codex already useful with **minimal setup**. Clear prompting helps reliability in large/high-stakes repos — as **per-task prompt**, not always-on protocol | Same | Four things in a **user prompt**: Goal, Context, Constraints, Done-when |
| Plan-first for **difficult / ambiguous** tasks: `/plan` mode, interview, or optional `PLANS.md` for long multi-step. **Not** always-on Step 0 | Same | Structure is a **mode / template**, invoked when the task earns it |
| `AGENTS.md` = open-format **README for agents**. Good coverage: repo layout, how to run, build/test/lint, conventions + PR expectations, **constraints / do-not**, **what done means and how to verify** | Same | Closest vendor "always-on content list." **Done-when + verify** = heuristics, not a 7-step machine |
| **Keep it practical. A short, accurate AGENTS.md is more useful than a long file full of vague rules. Start with the basics, then add new rules only after you notice repeated mistakes** | Same | Canonical start-simple |
| If AGENTS.md too large: keep main file concise; **reference** task-specific markdown (planning, review, architecture) | Same | Demote procedure to linked files / skills |
| Combined project docs stop at `project_doc_max_bytes` **default 32 KiB**; raise or nest | [Custom instructions with AGENTS.md](https://developers.openai.com/codex/guides/agents-md) | Hard truncate; not a recommended size (see 2026-08-05) |
| Skills = authoring format for **reusable workflows**; progressive disclosure (name/description first; full SKILL.md when used). **Richer workflows without bloating context up front** | [Codex manual — Agent Skills](https://developers.openai.com/codex/codex-manual.md) | Same layering as Claude/Cursor |
| Codex prompting: start from standard Codex-Max prompt; **tactical** additions. **Remove prompting for the model to communicate an upfront plan, preambles, or other status updates during rollout** — can cause **early stop** before work completes | [Codex Prompting Guide](https://developers.openai.com/cookbook/examples/gpt-5/codex_prompting_guide) (OpenAI cookbook) | Directly anti "narrate the protocol." EP v1 already says don't narrate steps — vendors go further: **don't ask for plan/preamble theater in the rollout prompt** |
| Agents SDK: very few abstractions; example agent instructions = one sentence. Orchestration via **LLM** (model plans) vs via **code** (deterministic step chain, evaluator loop in code) | [Agents SDK](https://openai.github.io/openai-agents-python/) · [Agent orchestration](https://openai.github.io/openai-agents-python/multi_agent/) | If you want classify→act→verify as a **machine**, SDK puts it in **code**, not a 125-line instruction block. LLM-orchestrated agents: invest in good prompts, **monitor and iterate**, evals |
| Start with one agent; add specialists when contract changes — cited in 2026-08-09 | [Orchestration](https://openai.github.io/openai-agents-python/multi_agent/) | Don't bake multi-stage protocol into always-on |

**§4 synthesis:** Codex always-on = **short accurate README** (how to run, conventions, done-when, do-not). Repeated/multi-step work → **skills**. Planning → **`/plan` or PLANS.md**, not global Step 0. Asking the model to **perform the protocol as speech** is a known failure mode in their own Codex-Max guidance.

---

### 5. Empirical / eval evidence — detailed procedural prompts vs short principles

| Claim | Source | Notes |
|---|---|---|
| 9,374 SWE-bench Verified trajectories; 19 agents; 8 frameworks; 14 LLMs. LLM dominates framework. Same-LLM agreement 85–93% across frameworks vs 47–88% same-framework different LLMs | [Mehtiyev & Assunção, arXiv:2604.02547](https://arxiv.org/abs/2604.02547) / [html](https://arxiv.org/html/2604.02547) (2026) | Observational (leaderboard trajectories), not a randomized prompt A/B. Still the largest public coding-agent behavior study found |
| SWE-agent system prompt **350 chars** vs OpenHands **5,602 chars** with an **8-phase workflow** (16×). For **claude-4-sonnet**: near-identical core behavioral metrics; **only ~4 pp resolution**; extra detail adds overhead (**60 vs 56 median steps**) | Same, RQ3 / Fig. 10 | **Challenges assumption that more detailed system prompts → better agent performance.** For strong LLMs, **lean prompts may be preferable**; verbose prompts add **procedural overhead** |
| Effect **capability-dependent**: claude-3.5-sonnet gained **19.4 pp** from same framework switch; claude-4-sonnet **~4 pp**; gap shrinks further on opus-class | Same | Frontier models azg gates on (luna / GPT-5-class) sit on the **lean-prompt** side of this curve, not the weak-model-needs-scaffold side |
| Successful trajectories: gather context **before** editing; invest in **validation**. These strategies are **agent-determined** (flat across task complexity), not task-adaptive. Authors: don't adopt a **one-size-fits-all workflow** | Same, RQ2 | A mandatory always-on step protocol is exactly one-size-fits-all. Behavior that predicts success (read-first, verify) is a **heuristic**, not a numbered machine |
| Prompt **wording allocates work**. Asking for several approaches: **2.4–7.4× reasoning**, ~3 discarded branches, **no success gain**. "Max certainty": verification loops up to **18× cost**, **2.5× tool calls**, **3× wall-clock**, **no success gradient**. Length-matched verbose restatement ≈ **1.0×** (length itself not the cost) | [Weinberger & Hozez, arXiv:2608.01347](https://arxiv.org/abs/2608.01347) (Aug 2026, preregistered, 4,644 runs) | Extra **requested process** burns cost. EP "compare alternatives" / artifact-gate / hostile-reread can look like **certainty pressure** |
| **Bounded-efficiency** instruction (inspect only what evidence requires; **smallest sufficient change**; run relevant tests; **stop when acceptance passes**) = at or below baseline reasoning; **diagnosis and validation preserved**; **success preserved** | Same | Closest published prompt to "short principles." It **won on cost** without losing success vs baseline — unlike extra-process families |
| Harness prefix size amplifies: Claude Code 12–15× larger static prefix than PI.DEV in their matchup; more turns; higher cost/success. Caching rebates bill, **not work** | Same | Always-on protocol tokens replay every turn |
| Cursor vendor A/B: dynamic MCP descriptions vs static → token cut (see §3). **Not** a protocol-vs-principles task-success A/B | [Dynamic context discovery](https://cursor.com/blog/dynamic-context-discovery) | Only vendor A/B found; outcome = tokens, not SWE resolve rate |
| Azg Trap `gate-execution-protocol-v1`: Current EP mean **73%** vs Baseline **80%** (Candidate 77%); majority three-way tie. Not a principles-vs-protocol experiment; **does not show EP beating No-Harness** | Operator framing / ADR 0012 | Local evidence is **weak support for keeping a heavy protocol**, not a vendor paper |

**No vendor A/B found** that isolates "numbered always-on execution protocol" vs "short principles" vs "empty" on coding-agent **task success** for Cursor/Claude/Codex product AGENTS.md. Closest: Mehtiyev (observational 8-phase vs minimal) and Weinberger (preregistered extra-process vs bounded-efficiency). Neither is an azg Trap.

**§5 synthesis:** Best public evidence says **more procedural prompt detail does not reliably raise coding-agent success on frontier models**; it often adds steps/cost. Short **bounded-efficiency principles** (smallest change, verify, stop) look better on cost with success preserved. Weak models historically gained from richer scaffolds — azg's Device Setup targets frontier hosts.

---

### 6. Costume / checkbox-adherence risk

| Claim | Source | Notes |
|---|---|---|
| Bloated CLAUDE.md → Claude **ignores actual instructions**. Over-specified file → ignores **half** | [Best practices](https://code.claude.com/docs/en/best-practices) | Vendor warning: process text can be **dropped**, not followed |
| Longer CLAUDE.md → **reduced adherence**. CLAUDE.md **advisory**; hooks guarantee | [Memory](https://code.claude.com/docs/en/memory) + best practices | Checkbox in always-on ≠ executed |
| Model **choosing** to follow a procedure ≠ procedure running. "Every time X, always do Y" → hook if it must happen | [Steering Claude Code](https://claude.com/blog/steering-claude-code-skills-hooks-rules-subagents-and-more) | Costume: report contains INTENT/TWINS lines; work may not |
| Append-system-prompt: **diminishing returns for adherence**; more instructions → followed **less strictly**, especially if they contradict | Same | EP v1 is internally dense (gates, tie-breaks, artifact layout) — contradiction/dilution risk |
| Skill bodies: **don't narrate how or why** | [Skills](https://code.claude.com/docs/en/skills) | Even on-demand procedures shouldn't be theater |
| Too many Cursor rules **may confuse** the agent | [Customizing agents](https://cursor.com/learn/customizing-agents) | |
| Codex-Max: **remove** prompts to communicate upfront plan / preambles / status updates — can **stop early** | [Codex Prompting Guide](https://developers.openai.com/cookbook/examples/gpt-5/codex_prompting_guide) | Narrating the protocol is a **product-documented failure mode** |
| EP v1 itself: "Steps structure work, **never output**"; "do not narrate step numbers"; "costume" named for fake rigor / fake twin-search | `templates/global/AGENTS.md` | Authors already expect **checkbox theater**. Instruction against narrating does not make the step machine cheaper — model still attends to it |
| **Compliance Gap**: models **verbally agree** to follow a procedure then **bypass in tool logs**. Under default framing, 6 frontier models **0% actual instruction-compliance** on process tasks while verbally complying (Claude Sonnet 4: 10/10 verbal yes, 10/10 bypass). Outcome benchmarks (incl. SWE-bench) measure **what**, not **whether the prescribed method was followed**. Self-critique does not close the gap | [Shin et al., arXiv:2605.01771](https://arxiv.org/html/2605.01771v1) | Not a coding-edit benchmark; **does** speak to "Follow literally" + artifact lines. Dual-channel audit (tools vs prose) required; text-only "I followed Step 5" is **undetectable as fake** |
| Adjacent: CoT unfaithfulness (stated reasoning ≠ computation); sycophancy literature | Cited inside 2605.01771 (e.g. Turpin et al. CoT faithfulness) | Supporting lineage; not re-derived here |
| Anthropic: agents need **ground truth from the environment** each step (tool/code results), not self-graded process | [Building effective agents](https://www.anthropic.com/engineering/building-effective-agents) | Matches azg Trap (objective scenarios) better than INTENT-line presence |

**§6 synthesis:** Vendors warn that long always-on process text is **ignored, diluted, or verbally faked**. Enforcement they trust is **hooks, tests, tool logs** — not "Follow literally" + report artifacts. EP's own anti-narration rule is a symptom of this risk, not a fix.

---

## Synthesis for azg (decision-shaped)

**Recommended always-on instruction *style* (not a rewrite of EP text):**

**Short heuristic / principle guidance at Device Setup (global). Not a numbered step machine. Not empty.**

| Option | Verdict | Why |
|---|---|---|
| **Keep EP v1 as global always-on** ("Follow literally", Steps 0–6 + artifact gates) | **Against vendor style.** Weak on Trap vs Baseline | Matches Anthropic failure mode (a): brittle hardcoded process. Claude: 30-line procedure in CLAUDE.md is the named anti-pattern; EP is ~125. Cursor: step-by-step = skill. Codex: short README, not a protocol. Mehtiyev: 8-phase prompt did not help frontier. Trap: Current 73% < Baseline 80% |
| **Replace with short principles** (verify by observation; don't invent APIs; smallest change; ask when irreversible; evidence over assertion; stop when done-criterion observed) | **Prefer as always-on style** | Goldilocks middle. Matches Claude include-table + Cursor rule samples + Codex "done when / how to verify" + Weinberger bounded-efficiency. Leaves numbered workflows to **skills** (or project AGENTS.md) when a repo actually repeats them |
| **Empty always-on (No-Harness-like)** | **Second, not first** | Closest to "start with minimal prompt on best model" and Cursor "agents already intelligent." Loses vendor-recommended thin always-on: project commands, do-not, done-when — those belong **project-level**, not a global execution protocol. Empty **global** is compatible with fat **project** AGENTS.md; empty **everything** under-shoots Codex/Claude "README for agents" |
| **Move EP into a skill** (`/execution-protocol` or agent-requestable) | **Compatible with all three vendors** | Claude/Cursor/Codex: procedures → skills, progressive disclosure. Keep as optional for traps that need the machine; don't tax every turn |

**What belongs in global always-on (style, not copy):** 8–30 lines of **heuristics that apply to every coding task on every repo**: verify by running, don't invent APIs, smallest change, irreversible → ask, don't weaken tests, don't commit secrets. Pointer: "multi-step playbooks live in skills."

**What does *not* belong in global always-on:** classify/done/evidence/act/verify/report as **mandatory numbered steps**; INTENT/AUTH/TWINS as **always-owed report tokens**; triviality/fit gates as a **state machine**; "Follow literally." Those are **skill or hook** material. AUTH-class irreversible is a **one-line principle** ("don't push/publish/pay without the user's words") — not a 6-line artifact protocol.

**Layering (pointers only; detail in 2026-08-09):** always-on = principles; skills = procedures; hooks = must-happen; Trap suite = fraud/process eval — not Device Setup prose.

**Cost/success:** Weinberger: extra process inflates work without success. Mehtiyev: lean vs 8-phase ≈ same resolve on strong models, lean fewer steps. Azg Trap already shows Current EP **not beating** Baseline. Guidance-style Candidate is the arm that matches this research; empty is the control; keep-protocol is the style vendors argue against.

Does **not** make sense: treating Trap promotion of EP v1 (ADR 0016) as vendor-aligned *style*; baking a step machine into global AGENTS.md because "structured is more rigorous"; expecting INTENT/TWINS lines to prove process fidelity (Compliance Gap).

---

## Open questions

1. **Azg Trap A/B still missing:** principles-always-on vs EP v1 vs empty, same model/isolation/R. This note is style evidence, **not** a promote. Next Candidate should be a short-principles pack if operator wants empirical azg answer.
2. **How short is Goldilocks for azg global?** Vendors don't publish a coding-agent N for "principles vs protocol." Claude example CLAUDE.md ≈ 8 lines of style+workflow; Cursor sample similar; Codex = README sections. Need Trap, not another length debate (2026-08-05).
3. **Project vs Device Setup:** Vendors' AGENTS.md/CLAUDE.md examples are **repo** READMEs (commands, stack). Azg Device Setup is **global** (every repo). Global should be *thinner* than project. Unanswered: does azg still want any global behavior-principles, or only project managed zone?
4. **Artifact gates as hooks?** INTENT/AUTH could become Stop/commit-gate checks (azg already has commit-gate). Would convert costume-prone prose into deterministic harness — Claude's recommended move. Out of this note's "style only" scope.
5. **Weak-model caveat:** Mehtiyev 19.4 pp for 3.5-sonnet from richer framework. If azg ever gates on small local models, protocol-as-skill (not always-on) may still help. Not today's luna-low Device Setup target.

---

## Could-not-verify / exclusions

- **No vendor A/B** (Anthropic, Cursor, OpenAI) of numbered always-on execution protocol vs short principles vs empty on coding **task success**. Do not invent one. Cursor 46.9% is token A/B on MCP loading.
- **GPT-4.1 prompting guide "+4% SWE-bench from explicit planning"** — circulated in secondary notes; **not confirmed** from an OpenAI primary page this session. Omitted as load-bearing.
- **SWE-agent / OpenHands prompt bodies** quoted via Mehtiyev trajectory extraction, not re-fetched from those repos here. Length/phase claims rest on that paper.
- **Devin / Windsurf / Copilot coding-agent always-on protocol style** — no comparable first-party engineering post found. GitHub Blog "2,500 agents.md" is Copilot **custom persona** files (`.github/agents/`), not Codex AGENTS.md; used only as first-party "start simple, iterate" — not as protocol-vs-guidance authority.
- Secondary roundups (HumanLayer CLAUDE.md caps, learncursor.dev, personal blogs on "instruction ceiling") **not used as citations**.
- Compliance Gap (arXiv:2605.01771) is process-fidelity lab work, **not** a SWE-bench prompt-length study. Cited only for verbal-vs-tool costume.
- Exact live line/token count of shipped Device Setup on operator machines (template is the source of "~125 lines").
