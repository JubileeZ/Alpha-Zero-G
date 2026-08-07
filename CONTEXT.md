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

**Current Treatment**:
Evaluation arm with the shipped Alpha-Zero-G harness as of the run (no Candidate changes).
_Avoid_: Production harness, old core, control with azg

**Candidate Treatment**:
Evaluation arm with Current Treatment plus one proposed change under test for adoption.
_Avoid_: Experimental profile, feature flag arm, core+addon

**Delivery Cost**:
Native model token usage or spend for a task run when available. Reported on Lite scorecards when present; **never a 3-arm promote gate** (ADR 0007) — promote uses Task Success only. Wall time and human interventions are separate reported measures, not blended into this value.
_Avoid_: Composite efficiency score, elapsed time as cost

**Long-Horizon Task**:
Task completed across forced fresh-context sessions and a clean-device clone before acceptance (optional continuity drill; not part of the Lite adopt gate).
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
Frozen SWE-bench Lite instance list scored by automated tests; adoption runs three arms (No-Harness Baseline, Current Treatment, Candidate Treatment) and promotes only on hard quantitative rules.
_Avoid_: Homemade fixtures as claim, blind-rubric suite, human-calibrated judge, full SWE-bench Verified by default, Trap Suite as adopt gate

**Trap Suite**:
Vendored Fable-method planted-trap fixtures (S1–S14) plus azg runners; Process Gate corpus. Not Task Success.
_Avoid_: Evaluation Suite, adherence mini-campaign, full Fable product paste

**Process Gate**:
3-arm trap campaign promoting Intent/Prove/Domain Candidates when Candidate pass rate ≥ Current and ≥ Baseline on the selected scenario subset (default N=5; relevance map + random-fill).
_Avoid_: Lite promote, always-run-all-traps as default

**Live Campaign**:
The Candidate Treatment (and arm checkouts) under test for the current Evaluation Suite run. Recorded in `evals/lite/CAMPAIGN.md`; procedure stays in `evals/lite/README.md`.
_Avoid_: Operator runbook, map-only eval notes, OPERATOR.md as framework

**Campaign cost envelope**:
Order-of-magnitude operator resources to run a Lite campaign (disk, wall-clock, Docker compute, approximate agent spend). Informational planning only — not a promote input and not Delivery Cost.
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
When scope is underspecified and a choice is local, cheap to undo, and nameable: state the assumption, ship, and verify — ask only when irreversible/outward or two defaults are equally costly to reverse.
_Avoid_: Always ask on ambiguity, silent guess without stating assumption

**Unattended Session**:
Run where the agent must not ask clarifying questions: prompt says offline / don't ask / unattended, or a known non-interactive runner (`agent -p`, batch, eval). Interactive IDE chat is attended unless that prompt signal is present.
_Avoid_: User went quiet, assume unattended from silence

**Twin Sweep**:
After fixing a defect: search reachable code for the same wrong construct in the same risk class; fix each hit or list it with a leave-reason before claiming done.
_Avoid_: Sibling callers checked (vague), only the failing test site, fake TWINS on already-correct helpers

**Domain Adapter Skill**:
On-demand azg-owned skill that binds a sector’s minimum evidence set, authority order, verify-by-observation meaning, and fraud table without changing the Think/Prove loop.
_Avoid_: fable-domain maker, always-on full domain paste, coding-default duplicate adapters

**Orchestrate Skill** *(deferred — not shipped)*:
Future on-demand Act skill for complex/unattended multi-area work (evidence fan-out, plan bookend, main-thread edits, attackers). Not in Device Setup until needed.
_Avoid_: azg-orchestrate (removed), azg-loop, fable-loop, Act as always-on default

