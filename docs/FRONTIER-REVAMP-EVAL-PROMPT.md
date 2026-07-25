# Alpha-Zero-G — Frontier Agent Re-Evaluation & Revamp Prompt

**File location:** `docs/FRONTIER-REVAMP-EVAL-PROMPT.md`  
**Purpose:** Copy-paste this prompt to any frontier AI agent (Antigravity `agy`, Cursor, Claude, Gemini, etc.) running on another device or session to conduct a comprehensive architectural re-evaluation and revamp analysis of `alpha-zero-g`.

---

```markdown
<TASK_INSTRUCTIONS>
You are acting as a Lead AI Harness Architect and Frontier Agent Evaluator. Your goal is to re-evaluate the `alpha-zero-g` project architecture, assess its current implementation against state-of-the-art (SOTA) agent harness patterns, and produce a crisp Revamp & Optimization Plan.

## 1. Project Context & Vision

Alpha-Zero-G is an **outer agent harness installer and template system** designed for solo developers, data/AI analysts, and small engineering teams using Antigravity (`agy`) and/or Cursor.

- **Core Vision:** Enable AI agents (Cursor / Antigravity) to reliably ship products with high task success per token/cost budget, without context bloat or fragile over-engineering.
- **Primary Workloads:** Analytic projects (data pipelines, python/SQL workflows, automated reports) and AI agent harness projects.
- **Constraints:** Solo analyst budget-conscious ($ / token limits), multi-IDE compatibility (Cursor + Antigravity), cross-platform shell script foundation (Bash >= 4.0, jq, Python 3).

---

## 2. Key Evaluation Pillars

Evaluate the repository across the following 5 core pillars:

1. **Current Codebase & v4 Spec Alignment**
   - Audit current state: `AGENTS.md`, `ROADMAP.md`, `docs/REVAMP-SPEC.md`, `docs/agents/current-state.md`, `lib/`, `templates/`, `tests/`.
   - Verify if repo-native gates (`tests/run-all.sh`, hooks) and template structures strictly honor the outer harness boundary.

2. **Self-Improving Agents & Learning Loops**
   - Assess how agents capture mistakes and refine behavior over time.
   - Evaluate mechanisms for auto-updating Knowledge Items (KIs), custom skills (`.agents/skills/`), `/learn` patterns, and trajectory feedback loops without bloating context windows.

3. **Agent Memory Architecture (Short & Long-Term)**
   - Assess cross-session memory and continuity (`.agents/session-handoff.md`, `task.md`, `current-state.md`).
   - Determine optimal, token-efficient memory structures (file-based indexing, semantic/episodic memory adapters, context window compaction).

4. **Proactive & Autonomous Execution**
   - Evaluate proactive capabilities: background timers (`schedule` / cron), file-watch event hooks, proactive linting/verification before error cascade.
   - Evaluate long-horizon autonomous execution (`/goal` patterns), subagent delegation limits (`spawn-budget.json`), and fail-safe recovery.

5. **Solo Analyst Specialization & Cost Efficiency**
   - Stress-test YAGNI ("You Aren't Gonna Need It") and Ponytail lazy dev principles (boring > clever, stdlib/CLI over extra dependencies, shortest working diff).
   - Ensure specific optimization for data/AI analyst workflows (Python script validation, SQL/data checks, notebook cleanups, artifact generation).

---

## 3. Required Execution Steps for the Frontier Agent

### Step 1: Read Project Baseline
Execute code exploration and inspect:
1. `AGENTS.md` (managed rules, ponytail ladder, verification gates)
2. `docs/REVAMP-SPEC.md` (canonical v4 specification)
3. `ROADMAP.md` & `docs/agents/current-state.md` (completed vs active vs parked features)
4. `lib/*.sh` (azg CLI commands) and `templates/project/` (harness templates)

### Step 2: Grilling & Gap Analysis
Stress-test current project features against frontier LLM capabilities (2026 era extended reasoning, background tasks, proactive timers, structured tool use):
- What existing components are redundant or over-engineered?
- What missing capabilities block reliable, autonomous shipping for solo analysts?
- How can memory and self-improvement be added without increasing base context token cost?

### Step 3: Deliverables Output
Produce a Markdown document titled `docs/FRONTIER-REVAMP-REPORT.md` (or print structured response if in interactive session) containing:

1. **Executive Summary & Verdict:** Is a revamp required, or minor incremental polish?
2. **Pillar-by-Pillar Gap Analysis:** Concrete findings for Baseline, Self-Improvement, Memory, Proactivity/Autonomy, Analyst Workflows.
3. **YAGNI & Deletion Candidates:** Features or code paths to prune or simplify.
4. **Actionable Revamp Action Plan:** Step-by-step phased tasks with verification commands.
5. **Proposed ADRs:** Any structural architectural decision records needed for approval.

---

## 4. Response Rules & Style

- **Style:** Telegraphic (concise fragments, drop articles/filler, exact commands and file paths).
- **Format:** Standard GitHub Markdown with file links (`file:///path/to/file`).
- **Principles:** Prefer deletion over addition, deterministic repo gates over prompt hints, budget-friendly over high-token-cost wrappers.
</TASK_INSTRUCTIONS>
```
