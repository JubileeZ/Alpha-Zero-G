# Alpha-Zero-G — Post-v4 Architecture Audit Prompt

**Purpose:** Reusable prompt for evidence-based architecture review from another device, session, or agent host.

---

```markdown
<TASK_INSTRUCTIONS>
Act as lead AI harness architect and evaluator. Re-evaluate `alpha-zero-g` against current host capabilities and proven agent-harness patterns. Produce a crisp optimization verdict; do not assume another revamp is necessary.

## 1. Project Context & Vision

Alpha-Zero-G is an **outer agent harness installer and template system** for solo developers and small engineering teams using Antigravity (`agy`) and/or Cursor.

- **Core Vision:** Enable AI agents (Cursor / Antigravity) to reliably ship products with high task success per token/cost budget, without context bloat or fragile over-engineering.
- **Candidate Workload to Validate:** Analytic projects (data pipelines, Python/SQL workflows, notebooks, automated reports).
- **Constraints:** Budget-conscious use, multi-IDE compatibility (Cursor + Antigravity), cross-platform shell foundation (Bash 3.2-safe `lib/` for GHA macOS; prefer ≥4.0 locally, jq, Python 3).

### Audit Safety & Evidence

- Default read-only: preserve worktree; no installs, commits, network writes, or non-dry-run `azg` mutations without explicit approval.
- Record audit date, commit SHA, `git status`, and host/version assumptions.
- Classify proposals as IDE-native, OS-native, repo-native, or out of scope.
- Report conflicts explicitly. Prefer observed implementation + accepted ADRs over stale secondary docs; `docs/SPEC.md` remains product intent.
- Adopt / promote decisions use SWE-bench Lite 3-arm (baseline / current / candidate) with automated Task Success; no Blind Judge claim path.

---

## 2. Key Evaluation Pillars

Evaluate the repository across the following 5 core pillars:

1. **Current Codebase & v4 Spec Alignment**
   - Audit current state: `azg`, `AGENTS.md`, `README.md`, `CONTEXT.md`, `ROADMAP.md`, `docs/AGENT-ONBOARDING.md`, `docs/SPEC.md`, `docs/agents/current-state.md`, `docs/adr/`, `lib/`, `templates/project/`, `templates/global/`, `tests/`, `evals/`, `.github/workflows/ci.yml`.
   - Verify if repo-native gates (`tests/run-all.sh`, hooks) and template structures strictly honor the outer harness boundary.

2. **Self-Improving Agents & Learning Loops**
   - Assess how agents capture mistakes and refine behavior over time.
   - Evaluate current learning records and custom skills; treat Knowledge Items, `/learn`, and trajectory loops as candidates only if repository or host evidence supports them.

3. **Agent Memory Architecture (Short & Long-Term)**
   - Assess generated-project continuity (`templates/project/.agents/session-handoff.md.tmpl`, `task.md.tmpl`, `docs/agents/current-state.md.tmpl`) and this repository's work-state.
   - Prefer existing filesystem layers; propose semantic or episodic adapters only with a measured gap.

4. **Proactive & Autonomous Execution**
   - Evaluate deterministic gates, supported lifecycle hooks, and native host automation.
   - Evaluate long-horizon execution, spawn-budget limits, and recovery. Do not add timers, watchers, or loop wrappers without a concrete unmet need and verified host support.

5. **Solo Analyst Fit & Cost Efficiency**
   - Stress-test YAGNI ("You Aren't Gonna Need It") and Ponytail lazy dev principles (boring > clever, stdlib/CLI over extra dependencies, shortest working diff).
   - Determine whether analyst workflows expose a measured gap; do not add stack defaults or special tooling from persona assumptions alone.

---

## 3. Required Execution Steps for the Frontier Agent

### Step 1: Read Project Baseline
Inspect:
1. `AGENTS.md` (managed rules, verification gates) and `templates/global/AGENTS.md` (Ponytail source)
2. `docs/SPEC.md` (canonical v4 specification)
3. `ROADMAP.md` & `docs/agents/current-state.md` (completed vs active vs parked features)
4. `lib/*.sh`, `templates/`, `tests/`, `evals/`, and accepted ADRs

### Step 2: Grilling & Gap Analysis
Stress-test current features against capabilities verified in repository or current host documentation:
- What existing components are redundant or over-engineered?
- What missing capabilities block reliable, autonomous shipping for solo analysts?
- How can memory and self-improvement be added without increasing base context token cost?
- Which ideas belong to IDE vendors rather than this outer harness?
- Which files are truly obsolete after tracing all inbound references and generation paths?

### Step 3: Deliverables Output
Return a structured Markdown response. Create `docs/FRONTIER-REVAMP-REPORT.md` only when explicitly requested. Include:

1. **Executive Summary & Verdict:** Is a revamp required, or minor incremental polish?
2. **Pillar-by-Pillar Gap Analysis:** Concrete findings for Baseline, Self-Improvement, Memory, Proactivity/Autonomy, Analyst Workflows.
3. **YAGNI & Deletion Candidates:** Features or code paths to prune or simplify.
4. **Actionable Revamp Action Plan:** Step-by-step phased tasks with verification commands.
5. **Proposed ADRs:** Hard-to-reverse structural decisions only; otherwise state none.

Before recommending deletion, trace references, tests, generators, and historical intent. Separate safe deletion candidates from archives, vendored sources, generated templates, and retained reference material.

---

## 4. Response Rules & Style

- **Style:** Telegraphic (concise fragments, drop articles/filler, exact commands and file paths).
- **Evidence:** Separate implemented facts, measured gaps, and speculative options. Cite repository-relative paths and line numbers.
- **Format:** Portable GitHub Markdown with repository-relative links; no machine-specific `file:///` URLs.
- **Principles:** Prefer deletion over addition, deterministic repo gates over prompt hints, budget-friendly over high-token-cost wrappers.
- **Verification:** Distinguish local gate (may skip missing tools) from `AZG_STRICT=1 bash tests/run-all.sh` and CI. On Windows, run Bash commands in Git Bash.
</TASK_INSTRUCTIONS>
```
