# Agent context engineering for project tracking docs

**Date:** 2026-07-31  
**Question:** Established practices to keep coding-agent context windows from filling with growing roadmap / current-state / glossary / AGENTS.md / progress rituals, while preserving continuity across sessions.  
**Framing:** Alpha-Zero-G outer harness (templates + `azg`); continuity today = Work Packet + ROADMAP + `current-state.md` + glossary + rituals; verify checks existence/markers, not size/relevance. Destination under discussion: ship “relevant context only” design into templates.  
**Method:** Primary / first-party sources only as authority (vendor docs, papers, tool READMEs). Secondary blogs used only to locate primaries, not as claims.

---

## 1. Executive summary

- **Consensus term:** “Context engineering” — curate the smallest high-signal token set each turn; treat context as finite with diminishing returns (“attention budget”). ([Anthropic — Effective context engineering for AI agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents))
- **Context rot is real:** performance degrades as input length grows even when window not full; shown across models. ([Chroma — Context Rot](https://research.trychroma.com/context-rot); [Anthropic context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents); classic position bias: [Liu et al., Lost in the Middle](https://arxiv.org/abs/2307.03172))
- **Dominant product pattern:** hybrid always-on lean instructions + just-in-time (JIT) file/tool retrieval — not “load all project docs every session.” Claude Code: `CLAUDE.md` up front + glob/grep; Cursor: Rules static / Skills dynamic; Anthropic Skills: progressive disclosure. ([Anthropic context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents); [Cursor — customizing agents](https://cursor.com/learn/customizing-agents); [Cursor — Dynamic context discovery](https://cursor.com/blog/dynamic-context-discovery); [Claude Code memory](https://code.claude.com/docs/en/memory.md))
- **Pointers beat inlining:** always-on files should reference paths / canonical examples; avoid copying style guides or full docs into rules. Caveat: Claude `@imports` still expand into context at launch. ([Cursor agent best practices](https://cursor.com/blog/agent-best-practices); [Cursor rules](https://cursor.com/docs/rules); [Claude Code memory — imports](https://code.claude.com/docs/en/memory.md))
- **Soft size targets common; hard lint gates rare:** Claude ~200 lines/CLAUDE.md; Cursor rules &lt;500 lines; Skills body &lt;500 lines guideline; Aider `--map-tokens` default 1k. No first-party harness found that fails CI solely because `CONTEXT.md` / current-state exceeded N lines. ([Claude Help — CLAUDE.md](https://support.claude.com/en/articles/14553240-give-claude-context-claude-md-and-better-prompts); [Cursor rules](https://cursor.com/docs/rules); [Aider repo map](https://aider.chat/docs/repomap.html))
- **Continuity ≠ always-loaded history:** handoff via compacted summary, structured notes / memory files outside window, plan files, nested `AGENTS.md`, session rituals that read on demand. ([Anthropic context engineering — compaction, note-taking](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents); [OpenAI Agents SDK — session memory / compaction](https://developers.openai.com/cookbook/examples/agents_sdk/session_memory); [Cursor — plans + past chats](https://cursor.com/blog/agent-best-practices); [agents.md](https://agents.md/))
- **Glossary / tracking docs:** primary sources push durable “always” facts into lean root instructions; procedures and domain depth into on-demand skills/rules/files. Tracking churn (roadmap checkboxes, progress) fits on-demand / handoff files better than always-on. (Inference from vendor layering guidance; no vendor doc names “ROADMAP.md” specifically.)
- **Mega single AGENTS.md discouraged vs nested/scoped:** agents.md promotes nested files for monorepos; Cursor nested `AGENTS.md`; Claude path-scoped rules + subdirectory CLAUDE.md on demand. ([agents.md](https://agents.md/); [Cursor rules — AGENTS.md](https://cursor.com/docs/rules); [Claude Code memory](https://code.claude.com/docs/en/memory.md))
- **For azg-like harness:** evidence strongest for (1) lean always-on + ritual pointers + compaction of stale state, and/or (2) selective-load (skills / globs / “read when needed”). (3) Hard size fail-gates: useful as optional discipline, not an established industry “best practice” with primary backing.

---

## 2. Approaches found

### 2.1 Doc layering + session ritual only (no new machinery)

**What:** Split docs by always-on vs on-demand. Session start: read small set of pointers / reality snapshot; leave roadmap archive, glossary depth, progress history on disk until needed. Compact completed phases into summary lines.

**Who practices:**
- **Claude Code:** root `CLAUDE.md` always loaded; subdirectory CLAUDE.md on demand; keep root under ~200 lines; move procedures to skills / path-scoped rules; `/clear` between tasks while CLAUDE.md carries durable memory. ([Claude Help — CLAUDE.md](https://support.claude.com/en/articles/14553240-give-claude-context-claude-md-and-better-prompts); [Claude Code memory](https://code.claude.com/docs/en/memory.md))
- **Cursor:** Rules = always-on essentials + file pointers; Skills = on demand; session: plan files in `.cursor/plans/`, `@Past Chats` instead of pasting full history; start new chat when task changes. ([Cursor agent best practices](https://cursor.com/blog/agent-best-practices); [Cursor — customizing agents](https://cursor.com/learn/customizing-agents))
- **AGENTS.md convention:** human README vs agent instructions; nested `AGENTS.md` for subprojects; closest file wins. ([agents.md](https://agents.md/))
- **Aider:** small `CONVENTIONS.md` via `--read` / config; do not dump unrelated files into chat. ([Aider conventions](https://aider.chat/docs/usage/conventions.html); [Aider usage](https://aider.chat/docs/usage.html))
- **Anthropic hybrid model:** CLAUDE.md naively in context; agent navigates filesystem JIT. ([Anthropic context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents))

**Compaction/archive of tracking docs:** Anthropic describes conversation compaction and structured note-taking (e.g. NOTES.md / memory tool) for long-horizon work — pattern maps to “collapse finished roadmap phases; keep current Work Packet.” ([Anthropic context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents); [Anthropic — Managing context](https://www.anthropic.com/news/context-management))

---

### 2.2 Selective-load / retrieval machinery

**What:** Static catalog (names/descriptions) always cheap; full bodies load by task, glob, agent decision, or RAG/@-providers.

**Who practices:**
- **Agent Skills progressive disclosure:** L1 name+description always; L2 SKILL.md on trigger (~&lt;500 lines guidance); L3 references/scripts only when read. ([Claude Code memory / skills guidance via memory doc](https://code.claude.com/docs/en/memory.md); Cursor Skills dynamic load: [Cursor agent best practices](https://cursor.com/blog/agent-best-practices); [Cursor dynamic context discovery](https://cursor.com/blog/dynamic-context-discovery))
- **Cursor dynamic context discovery:** fewer details up front; agent pulls files/skills/MCP tool defs/history as needed; MCP tool-description-as-files A/B: **−46.9%** tokens when MCP used. ([Cursor — Dynamic context discovery](https://cursor.com/blog/dynamic-context-discovery))
- **Continue.dev:** rules with `alwaysApply` / `globs` / `description` (agent-requested); `@` context providers (file, repo map, docs, etc.) — opt-in attachment. ([Continue rules](https://docs.continue.dev/customize/deep-dives/rules); [Continue context providers](https://docs.continue.dev/customize/deep-dives/custom-providers))
- **Aider repo map:** graph-ranked symbol map fitted to `--map-tokens` budget (default 1k); expands when chat has few files. ([Aider repo map](https://aider.chat/docs/repomap.html); [Aider blog — tree-sitter map](https://aider.chat/2023/10/22/repomap.html))
- **Anthropic JIT + progressive disclosure:** lightweight identifiers + tools; agent discovers layer by layer. ([Anthropic context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents))
- **OpenAI Agents SDK:** session trimming/compression; handoff `input_filter` / nested handoff history; Compaction capability + Memory for cross-run lessons. ([OpenAI session memory cookbook](https://developers.openai.com/cookbook/examples/agents_sdk/session_memory); [OpenAI memory & compaction cookbook](https://developers.openai.com/cookbook/examples/agents_sdk/building_reliable_agents_memory_compaction); [Handoffs](https://openai.github.io/openai-agents-python/handoffs/))

**RAG note:** Anthropic observes field shifting from pure pre-inference embedding retrieval toward JIT agentic search (hybrid OK). ([Anthropic context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents))

---

### 2.3 Hard size budgets / lint gates

**What:** Fail verify/CI if tracking docs exceed N lines/tokens.

**Evidence in primary sources:**
- **Soft targets (guidance, not gates):** CLAUDE.md ~200 lines ([Claude Help](https://support.claude.com/en/articles/14553240-give-claude-context-claude-md-and-better-prompts); [Claude Code memory](https://code.claude.com/docs/en/memory.md)); Cursor rules &lt;500 lines ([Cursor rules](https://cursor.com/docs/rules)); Skills body &lt;500 lines as guideline in skills ecosystem docs (treat as vendor-aligned guidance; confirm against current Agent Skills / Claude skills pages when implementing).
- **Runtime budgets (not doc lint):** Aider `--map-tokens` ([Aider repo map](https://aider.chat/docs/repomap.html)); OpenAI compaction thresholds / static policy ([OpenAI Compaction API ref](https://openai.github.io/openai-agents-python/ref/sandbox/capabilities/compaction/); [memory & compaction cookbook](https://developers.openai.com/cookbook/examples/agents_sdk/building_reliable_agents_memory_compaction)); Anthropic context editing clears tool results past token triggers ([Anthropic context editing](https://platform.claude.com/docs/en/build-with-claude/context-editing)).
- **Hard CI fail on CONTEXT.md / current-state size:** **not found** as an established first-party product practice. Closest philosophy: “every always-on line must earn its cost” ([Claude Help](https://support.claude.com/en/articles/14553240-give-claude-context-claude-md-and-better-prompts)).

**Verdict:** Soft budgets + human/agent discipline are established; automated size lint for tracking docs is an **azg-optional innovation**, not a documented industry standard.

---

### 2.4 Other widely used patterns

| Pattern | Practice | Primary source |
| --- | --- | --- |
| Progressive disclosure (skills/rules) | Metadata always; body on need | [Cursor dynamic context discovery](https://cursor.com/blog/dynamic-context-discovery); [Claude Code memory](https://code.claude.com/docs/en/memory.md) |
| Compaction / summarization | Compress history near limit; keep recent files / recoverable history | [Anthropic context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents); [Cursor dynamic context discovery §2](https://cursor.com/blog/dynamic-context-discovery); [OpenAI session memory](https://developers.openai.com/cookbook/examples/agents_sdk/session_memory) |
| Context editing (tool-result clearing) | Drop stale tool I/O; memory tool for durable facts | [Anthropic — Managing context](https://www.anthropic.com/news/context-management); [context editing docs](https://platform.claude.com/docs/en/build-with-claude/context-editing) |
| Structured note-taking / handoff files | NOTES.md / memory / plans outside window; re-read after reset | [Anthropic context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents); [Cursor plans](https://cursor.com/blog/agent-best-practices) |
| Sub-agents | Isolate search/exploration; return short summary | [Anthropic context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents); [Anthropic multi-agent research](https://www.anthropic.com/engineering/multi-agent-research-system) |
| Observation elision | Keep last N env outputs | [SWE-agent history processors](https://swe-agent.com/latest/reference/history_processor_config/); paper [SWE-agent (arXiv:2405.15793)](https://arxiv.org/abs/2405.15793) |
| Nested / scoped instruction files | Per-package AGENTS.md; path globs | [agents.md](https://agents.md/); [Continue rules](https://docs.continue.dev/customize/deep-dives/rules); [Cursor AGENTS.md](https://cursor.com/docs/rules) |
| Prompt caching interplay | Stable always-on prefix good; mid-history mutation breaks cache | [Claude Help — CLAUDE.md caching](https://support.claude.com/en/articles/14553240-give-claude-context-claude-md-and-better-prompts); [SWE-agent cache_control](https://swe-agent.com/latest/config/models/); [Anthropic context editing ↔ cache](https://platform.claude.com/docs/en/build-with-claude/context-editing) |
| “Context engineering” coinage | Industry shift from prompt-only to full-context curation | [Anthropic context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents); [Cursor harness language](https://cursor.com/blog/dynamic-context-discovery) |

**Devin / Cognition:** no durable first-party public doc located in this pass that specifies tracking-doc layering comparable to Claude/Cursor/Aider; treat as **evidence gap**, not absence of practice.

---

## 3. Comparison table (azg-like harness)

| Approach | Strength for azg-like harness | Weakness | Enforcement cost |
| --- | --- | --- | --- |
| Layering + session ritual | Matches current azg model (AGENTS ritual, Work Packet, ROADMAP, current-state); portable across Cursor/Claude/Continue; no new runtime | Relies on agent compliance + human compaction; stale docs still grow on disk; “read all three every session” can itself bloat | Low: template wording + ROADMAP compaction convention |
| Selective-load / skills / globs | Scales as docs multiply; aligns Cursor Skills + Claude skills + Continue `alwaysApply`; keeps always-on AGENTS.md as pointer index | Needs host support (skills/rules); agents under-trigger skills if descriptions weak; import-by-reference may still load full files (Claude `@`) | Medium: skill/rule packaging in templates; description quality; optional verify that always-on files only contain pointers |
| Hard size budgets / lint | Forces discipline; cheap to implement in `verify.sh`; catches silent growth | No primary-source standard for N; false fails on legitimate long glossaries; size ≠ relevance; doesn’t stop agents from reading huge files mid-session | Low–medium to implement; high policy-tuning cost (choosing N, exceptions) |

---

## 4. Pros/cons for product decision (azg)

### Option A — Layering / ritual only

**Pros**
- Already how Claude/Cursor/agents.md tell teams to work: lean always-on, pointers, fresh chats, compact long work. ([Claude Help](https://support.claude.com/en/articles/14553240-give-claude-context-claude-md-and-better-prompts); [Cursor best practices](https://cursor.com/blog/agent-best-practices); [agents.md](https://agents.md/))
- Continuity via files on disk + short session-start checklist — fits installer/templates without host-specific RAG.
- ROADMAP “active-phase compaction” is the same family as Anthropic compaction / note-taking (summarize completed work; keep active state). ([Anthropic context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents))

**Cons**
- Soft; agents may still open large docs if ritual says “read ROADMAP + current-state + CONTEXT.”
- Does not stop context rot from mid-session file accretion (tool results) — that needs host compaction or user `/clear`. ([Anthropic](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents); [Claude Help — /clear](https://support.claude.com/en/articles/14553240-give-claude-context-claude-md-and-better-prompts))

### Option B — Selective-load machinery

**Pros**
- Strongest first-party endorsement for scale: Cursor dynamic discovery; Anthropic progressive disclosure / JIT; Skills as the standard packaging. ([Cursor dynamic context discovery](https://cursor.com/blog/dynamic-context-discovery); [Anthropic context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents))
- Natural home for progress rituals, domain glossary depth, phase playbooks — load when task matches.
- Measurable token wins in Cursor MCP experiment (−46.9%). ([Cursor dynamic context discovery](https://cursor.com/blog/dynamic-context-discovery))

**Cons**
- Template must target multiple hosts (Cursor skills vs Claude skills vs Continue rules) or stay host-agnostic with “pointer + when to read” prose only.
- Under-trigger risk; over-fragmentation risk.
- Claude `@imports` are not free pointers — they still enter context at launch. ([Claude Code memory](https://code.claude.com/docs/en/memory.md))

### Option C — Hard size budgets / lint gates

**Pros**
- Simple gate for “always-on surface area”; complements soft vendor targets (200 / 500 lines).
- Fits existing `verify.sh` culture (existence → also size).

**Cons**
- **Not established** as a primary-source best practice for tracking docs.
- Wrong metric if large archived ROADMAP stays out of always-on path; fails to measure relevance.
- Risk of cargo-cult N that fights real projects.

**Decision-shaped synthesis (evidence-based, not a redesign):** Prefer **A + selective B** (lean AGENTS.md / session ritual with explicit “read only if needed” for glossary/roadmap archive; package heavy rituals as skills/rules where hosts support). Treat **C** as optional guardrail on always-on files only, with soft vendor numbers as starting heuristics — not as the core continuity design.

---

## 5. Open unknowns / what primary sources do NOT settle

- Optimal **N** (lines/tokens) for glossary vs current-state vs Work Packet — vendors give CLAUDE.md/rules heuristics only; no study on project-tracking doc mixtures.
- Whether **hard CI size gates** improve agent task success — no primary eval found.
- **Devin / Cognition** public continuity model for roadmap-like docs — not documented in sources retrieved here.
- How often agents **actually follow** “read on demand” rituals without skills metadata (compliance rates unpublished).
- Interaction of **prompt caching** with frequently edited `current-state.md` / `task.md` if those are always imported (cache invalidation) — mentioned for CLAUDE.md ([Claude Help](https://support.claude.com/en/articles/14553240-give-claude-context-claude-md-and-better-prompts)) but not for azg-style packets.
- Whether embedding **RAG over ROADMAP** beats JIT grep for tracking docs — Anthropic leans JIT for coding agents; no head-to-head on roadmap corpora. ([Anthropic context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents))
- Long-context degradation curves for **instruction-following** (not just retrieval) when always-on rules grow — Chroma/Lost-in-Middle are retrieval/QA-heavy; instruction adherence vs length less settled for agent harness files.

---

## 6. Sources list

### Official / first-party product & engineering

1. Anthropic — *Effective context engineering for AI agents* — https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents  
2. Anthropic — *Managing context on the Claude Developer Platform* — https://www.anthropic.com/news/context-management  
3. Anthropic — *Context editing* (API docs) — https://platform.claude.com/docs/en/build-with-claude/context-editing  
4. Claude Code — *How Claude remembers your project* (memory / CLAUDE.md) — https://code.claude.com/docs/en/memory.md  
5. Claude Help — *Give Claude context: CLAUDE.md and better prompts* — https://support.claude.com/en/articles/14553240-give-claude-context-claude-md-and-better-prompts  
6. Cursor — *Best practices for coding with agents* — https://cursor.com/blog/agent-best-practices  
7. Cursor — *Dynamic context discovery* — https://cursor.com/blog/dynamic-context-discovery  
8. Cursor — *Customizing agents* — https://cursor.com/learn/customizing-agents  
9. Cursor Docs — *Rules* (incl. AGENTS.md, &lt;500 lines) — https://cursor.com/docs/rules  
10. OpenAI — *Context Engineering — Short-Term Memory Management with Sessions* — https://developers.openai.com/cookbook/examples/agents_sdk/session_memory  
11. OpenAI — *Building Reliable Agents with Memory and Compaction* — https://developers.openai.com/cookbook/examples/agents_sdk/building_reliable_agents_memory_compaction  
12. OpenAI Agents SDK — *Handoffs* — https://openai.github.io/openai-agents-python/handoffs/  
13. OpenAI Agents SDK — *Compaction* capability reference — https://openai.github.io/openai-agents-python/ref/sandbox/capabilities/compaction/  
14. Aider — *Repository map* — https://aider.chat/docs/repomap.html  
15. Aider — *Building a better repository map with tree sitter* — https://aider.chat/2023/10/22/repomap.html  
16. Aider — *Specifying coding conventions* — https://aider.chat/docs/usage/conventions.html  
17. Aider — *Usage* (add only needed files) — https://aider.chat/docs/usage.html  
18. Continue Docs — *Rules* — https://docs.continue.dev/customize/deep-dives/rules  
19. Continue Docs — *Context Providers* — https://docs.continue.dev/customize/deep-dives/custom-providers  
20. AGENTS.md (Agentic AI Foundation / Linux Foundation stewardship) — https://agents.md/  
21. SWE-agent — *History processor configuration* — https://swe-agent.com/latest/reference/history_processor_config/  
22. SWE-agent — *Models* (cache_control) — https://swe-agent.com/latest/config/models/

### Papers / research reports

23. Liu et al. — *Lost in the Middle: How Language Models Use Long Contexts* — https://arxiv.org/abs/2307.03172  
24. Hong, Troynikov, Huber (Chroma) — *Context Rot: How Increasing Input Tokens Impacts LLM Performance* — https://research.trychroma.com/context-rot  
25. Yang et al. — *SWE-agent: Agent-Computer Interfaces Enable Automated Software Engineering* — https://arxiv.org/abs/2405.15793  

### Related Anthropic (architecture, not tracking-docs-specific)

26. Anthropic — *How we built our multi-agent research system* — https://www.anthropic.com/engineering/multi-agent-research-system  

---

*End of note. No product/template changes in this research pass.*
