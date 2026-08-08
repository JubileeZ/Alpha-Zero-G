# Alpha-Zero-G

The system configuration and runtime harness for building production AI agent environments.

## Language

**Reliable Delivery**:
Completion of a user-requested task that passes explicit acceptance gates and achieves higher task success per cost than an equivalent no-harness run.
_Avoid_: Guaranteed output, good result

**Task Success**:
Delivery where the evaluation task's automated checks pass (industry-bench tests or equivalent hard gates). No human rubric.
_Avoid_: Done, completed run, blind-judge pass

**No-Harness Baseline**:
Evaluation arm using the same task, repository state, model, IDE, permissions, and budget as harness arms, with only Alpha-Zero-G configuration removed.
_Avoid_: Historical baseline, default setup

**Eval Isolation**:
Running eval Agent CLI calls so host Device Setup (`~/.cursor` rules/skills) cannot leak into any arm — default Docker `azg-eval-agent` empty home; required for promote-grade 3-arm Trap campaigns.
_Avoid_: Clean HOME ritual only, trust host ~/.cursor

**Eval Device Home**:
Staged per-arm fake `$HOME` fragment (azg-owned AGENT-INSTRUCTIONS + optional azg skills from a git ref) mounted read-only into the Docker eval agent — mimics Device Setup without host leakage. Baseline omits it. Always-on ponytail not staged (ADR 0015).
_Avoid_: Host ~/.cursor mount, worktree inject of global rules, full vendor skill forest in eval home

**Current Treatment**:
Evaluation arm with the shipped Alpha-Zero-G harness as of the run (no Candidate changes).
_Avoid_: Production harness, old core, control with azg

**Candidate Treatment**:
Evaluation arm with Current Treatment plus one proposed change under test for adoption.
_Avoid_: Experimental profile, feature flag arm, core+addon

**Ponytail**:
On-demand lazy-senior coding skill from vendor catalog (`ponytail-skills`). **Not** Device Setup always-on (ADR 0015) — no `PONYTAIL:MANAGED` in global AGENTS, no `azg-ponytail.mdc`.
_Avoid_: Always-on ponytail rule, nested PONYTAIL in Device Setup AGENTS

**Delivery Cost**:
Native model token usage or spend for a task run when available. Optional on trap notes; **never a Process Gate promote input** (ADR 0012) — promote uses trap pass rates + isolation=docker. Wall time and human interventions are separate reported measures.
_Avoid_: Composite efficiency score, elapsed time as cost

**Long-Horizon Task**:
Task completed across forced fresh-context sessions and a clean-device clone before acceptance (optional continuity drill; not part of the Trap Process Gate).
_Avoid_: Long chat, large task

**Minimal Setup**:
One device command and one project command, with at most one required confirmation of project validation command. Device command installs shared vendor skills for every supported IDE, azg-owned Cursor global rules (`azg-*.mdc`), Gemini/Antigravity global AGENTS.md, and MCP; project command installs repo-local hooks, thin IDE adapters, and project AGENTS.md (Cursor has no user-global AGENTS.md).
_Avoid_: Zero configuration, setup wizard

**Device Setup**:
The one-per-machine install (`azg setup`): shared vendor skill packs into each IDE's user/global skills directory (`~/.cursor/skills` for Cursor; never `skills-cursor`), azg-owned Cursor global rules as `~/.cursor/rules/azg-*.mdc` (foreign rules untouched unless `--force`), Gemini/Antigravity global AGENTS.md, and MCP. Cursor rule prose derives from marked blocks in canonical `templates/global/AGENTS.md`; frontmatter remains Cursor-specific. Not a substitute for project apply; does not require per-repo skill or rules import.
_Avoid_: Manual skill import, Cursor-only ritual, Antigravity-only setup, skills-cursor, wiping ~/.cursor/rules

**Work Packet**:
Canonical Git-synced state for one active task: objective, acceptance criteria, status, files, decisions, blockers, and next action.
_Avoid_: Handoff file, task list

**Checkpoint**:
Git commit pairing in-progress work with a fresh Work Packet so another session can resume from one durable state.
_Avoid_: Autosave, IDE Stop

**Device Handoff**:
Pushed Checkpoint fetched on another device to resume same Work Packet from identical repository state.
_Avoid_: Chat transfer, synchronized folder

**Evaluation Suite**:
Trap Suite Process Gate (ADR 0012) — sole in-repo adopt/eval path after Lite removal (ADR 0007 superseded).
_Avoid_: SWE-bench Lite harness, homemade Blind Judge claim suite

**Trap Suite**:
Vendored Fable-method planted-trap fixtures (S1–S14) plus azg runners; Evaluation Suite / Process Gate corpus.
_Avoid_: Adherence mini-campaign, full Fable product paste as shipped Treatment

**Process Gate**:
3-arm Trap promote when Candidate beats Current and Baseline on the agreed **Adopt Ledger** metrics **and** `isolation=docker`. Sole decision model: `gpt-5.6-luna-low`. Preceded by **Preview Round** (human must consent before more rounds). See ADR 0012.
_Avoid_: Host-isolation promote, luna-xhigh Process Gate, tiered-R promote, 3-id smoke-as-gate

**Preview Round**:
Full Trap corpus (S1–S14) × **R=1** × 3 arms at `gpt-5.6-luna-low`; becomes **r1** of the Adopt Ledger. Always pause for human consent before further rounds. Not a cheap 3-id filter.
_Avoid_: Smoke Filter, s2/s9/s13-only smoke, Preview-as-display-only

**Adopt Ledger**:
Comparable promote dataset for one Candidate: Preview Round (`r1`) plus up to four more full-corpus rounds (`r2`–`r5`) after human consent — uniform **R=5** max, same model/isolation/protocol.
_Avoid_: Mixing xhigh camps, tiered-R history bands, smoke-excluded promote sets

**Adopt Run**:
Spend that extends the Adopt Ledger after Preview consent: four additional full-corpus rounds (`r2`–`r5`) at `gpt-5.6-luna-low`, arm-serial fan-out (candidate → current → baseline).
_Avoid_: Tiered per-id R, auto-continue without consent, run-repeats as sole path

**Trap Family**:
Named scenario group in `evals/traps/relevance-map.json` `change_types`. Informational / selection only — **not** a Process Gate Coverage signal.
_Avoid_: Family-based promote coverage

**Coverage**:
Process Gate secondary signal on an Adopt Ledger: share of scenarios where Candidate mean success ≥ Current mean success (ties count toward Coverage). Board may label per-scenario Cand vs Cur as win / neutral / loss. **Baseline coverage %** (Cand mean ≥ Baseline mean per scenario) is reported only — not a take/not-take input.
_Avoid_: Smoke-only coverage, relevance-map family coverage as gate, Baseline coverage as promote gate

**Recommend Adopt**:
Automated advice when Adopt Ledger is complete (R=5, no nulls, docker): overall majority Cand ≥ Cur ≥ B **and** Coverage win; otherwise human decides (no auto-promote).
_Avoid_: Auto-merge to templates/global, smoke-only recommend

**Live Campaign**:
Candidate Treatment (and arm checkouts / packs) under test for the current Trap run. Recorded in `evals/traps/CAMPAIGN.md`; procedure in `evals/traps/README.md` + `evals/README.md`.
_Avoid_: Operator runbook, map-only eval notes

**Campaign cost envelope**:
Order-of-magnitude operator resources for a trap campaign (e.g. Preview ≈ 42 cells; full Adopt Ledger R=5 ≈ 210 cells). Informational planning only — not a promote input and not Delivery Cost.
_Avoid_: Delivery Cost, promote budget, efficiency score

**Statusline**:
The terminal status bar displayed at the bottom of the Antigravity TUI to show real-time agent execution state and resource usage.
_Avoid_: Status bar, info bar

**Context Rot**:
The degradation of agent instruction-following accuracy and reasoning capabilities that occurs as the active token count approaches model context limits.
_Avoid_: Context bloating, context overflow

**Context Rot Level**:
The classification of the current context window usage severity (Safe, Caution, Degrading, or Critical) calculated dynamically based on active token counts and capacity percentages.
_Avoid_: Warning level, rot severity

**Prompt Credits**:
The user's remaining billing balance for executing model calls, tracked as a currency or token pool.
_Avoid_: Account balance, model credits

**Sprint Quota**:
A short-term rolling rate-limit window that cooldowns every five hours.
_Avoid_: Cooldown quota, hourly limit

**Statusline style**:
Unicode foreground glyphs and separators for the Antigravity statusline (single style; width truncation handles narrow terminals).
_Avoid_: Status bar theme, icon mode, nerd-font preset.

**Safety Hook**:
An interceptor script run automatically before any agent tool call to validate command patterns and file targets, preventing unauthorized alterations or system damage.
_Avoid_: Guardrail, safety command, block policy.

**Prove Stance**:
Always-on discipline that treats a finished report as claims to re-observe (diff, rerun, open artifact) before presenting done, ending in VERIFIED, CAVEATS, or REFUTED.
_Avoid_: fable-judge, blind trust in agent prose, verification theater

**Reversible Default**:
When scope is underspecified and a choice is local, cheap to undo, and nameable: state the assumption, ship, and verify. Ask when irreversible/outward or **Intent Tie**; **Impl-Equivalent Default** → state+ship+verify without asking.
_Avoid_: Always ask on ambiguity, silent guess without stating assumption

**Impl-Equivalent Default**:
Two underspec choices in the same risk class that are local and trivially reversible (naming, format, path under repo). Unattended: pick one, state, ship, verify.
_Avoid_: Coin-flip product behavior, treat format choice as Intent Tie

**Intent Tie**:
Two competent product or requirement readings that code cannot settle. Unattended: labeled blocker — never ask, never coin-flip intent.
_Avoid_: Assume-and-ship on requirement meaning, "equally costly" as always-ask for format/path

**Unattended Session**:
Run where the agent must not ask clarifying questions: prompt says offline / don't ask / unattended, or a known non-interactive runner (`agent -p`, batch, eval). Interactive IDE chat is attended unless that prompt signal is present. Dispatch: see **Impl-Equivalent Default** and **Intent Tie**.
_Avoid_: User went quiet, assume unattended from silence

**Twin Sweep**:
After fixing a defect: search reachable code for the same wrong construct in the same risk class; fix each hit or list it with a leave-reason before claiming done.
_Avoid_: Sibling callers checked (vague), only the failing test site, fake TWINS on already-correct helpers

**Domain Adapter Skill**:
On-demand azg-owned skill that binds a sector’s minimum evidence set, authority order, verify-by-observation meaning, and fraud table without changing the Think/Prove loop.
_Avoid_: fable-domain maker, always-on full domain paste, coding-default duplicate adapters

**Orchestrate Skill**:
On-demand skill for complex/unattended multi-area work (evidence fan-out, plan bookend, main-thread edits, adversarial verifiers). **Parked** — not in current Candidate (instructions-only) nor `templates/global/` (ADR 0014 amend).
_Avoid_: fable-loop as device skill id, Act as always-on default, azg-orchestrate (removed global name)

**Method Naming**:
When shipping method skills/paths: use azg labels (`orchestrate`, `judge`), not `fable-*`. Opaque product name + Claude-ecosystem branding; project is host-agnostic. Credit Sahir619/fable-method when content derives from it.
_Avoid_: fable-method on device, fable-loop, fable-judge as shipped skill ids

