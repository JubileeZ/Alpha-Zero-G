#!/usr/bin/env python3
"""Assemble unified-pipeline Candidate from compressed upstream + ponytail + azg wrappers."""
from __future__ import annotations

import re
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
CAND = Path(__file__).resolve().parents[1]
COMP = Path(__file__).resolve().parent / "compressed"
GLOBAL_AGENTS = ROOT / "templates" / "global" / "AGENTS.md"
PIN = "88b5cf36b10ee3679e08ee0f0181b9774d481508"


def extract_block(text: str, start: str, end: str) -> str:
    a = text.index(start)
    b = text.index(end, a) + len(end)
    return text[a:b]


def section_after(text: str, heading: str, next_headings: list[str]) -> str:
    start = text.index(heading)
    end = len(text)
    for h in next_headings:
        i = text.find(h, start + len(heading))
        if i != -1:
            end = min(end, i)
    return text[start:end].rstrip() + "\n"


def mech_rename(s: str) -> str:
    """Identifier renames for device naming (not prose rewrite)."""
    reps = [
        ("/fable-domain", "/domain-factory"),
        ("/fable-method", "/orchestrate"),
        ("fable-domain", "domain-factory"),
        ("fable-method", "agent-harness-pipeline"),
        ("fable-loop", "orchestrate"),
        ("fable-judge", "judge"),
        ("The Fable Loop", "Orchestrate"),
        ("The Fable Method", "Agent Harness Pipeline"),
        ("fable-method's", "pipeline"),
        ("`skills/fable-method/`", "`skills/references/` sibling"),
        ("~/.claude/skills/fable-method/", "resident AGENTS.md pipeline / "),
    ]
    for a, b in reps:
        s = s.replace(a, b)
    # Factory is Out of Candidate — annotate leftover generate-adapter routing
    s = s.replace(
        "Make a skill (domain-factory)",
        "Domain factory (out of Candidate)",
    )
    return s


def build_agents() -> str:
    src = (COMP / "AGENTS.md").read_text(encoding="utf-8")
    pony = extract_block(
        GLOBAL_AGENTS.read_text(encoding="utf-8"),
        "<!-- PONYTAIL:MANAGED:START -->",
        "<!-- PONYTAIL:MANAGED:END -->",
    )
    # Keep original azg misc — filler compress self-damages parenthetical examples
    misc_src = Path(__file__).resolve().parent / "azg-misc.src.md"
    misc = (
        misc_src.read_text(encoding="utf-8").strip()
        if misc_src.exists()
        else (COMP / "azg-misc.md").read_text(encoding="utf-8").strip()
    )

    intro = section_after(
        src,
        "**Triviality gate (run first).**",
        ["## Step 0 - Classify the ask"],
    )
    # Drop Usage / title / portable blurb — not shipping method skill commands
    step0 = section_after(src, "## Step 0 - Classify the ask", ["## Step 1 - Define done"])
    step1 = section_after(src, "## Step 1 - Define done", ["## Step 2 - Gather evidence"])
    step2 = section_after(src, "## Step 2 - Gather evidence", ["## Step 3 - Decide and commit"])
    step3 = section_after(src, "## Step 3 - Decide and commit", ["## Step 4 - Act surgically"])
    step4 = section_after(src, "## Step 4 - Act surgically", ["## Step 5 - Verify by observation"])
    step5 = section_after(src, "## Step 5 - Verify by observation", ["## Step 6 - Report outcome-first"])
    step6 = section_after(src, "## Step 6 - Report outcome-first", ["## Compressed examples"])
    # Artifact gate lives at end of step6 — split prove vs terminal
    artifact = ""
    if "**Artifact gate" in step6:
        idx = step6.index("**Artifact gate")
        prove = step6[:idx].rstrip() + "\n"
        artifact = step6[idx:].rstrip() + "\n"
    else:
        prove = step6
        artifact = (
            "**Artifact gate, last check before sending.** Sweep report for owed lines; "
            "add missing `INTENT:` / `AUTH:` / `PENDING:` / `TWINS:`.\n"
        )

    # Exact-dedupe: examples+modes live in references / skills — omit from resident
    refs_ptr = (
        "Lazy refs (on demand): `skills/references/failure-modes.md`, "
        "`examples.md`, `flowcharts.md`, `domains/`.\n"
    )

    body = f"""<!-- AZG:AGENT-INSTRUCTIONS:START -->
# Agent Harness Pipeline

## §0 ROUTER
Process decisions are §1/§4/§5. Code-shape decisions are §3. §3 never decides whether or in what order, only how much code.
Escalate to `orchestrate` skill: ambiguous scope, irreversible outward actions, parallel evidence fan-out, or unattended runs.
Deep adversarial audit: invoke `judge` skill (fresh context). Resident §5/§6 = pre-send gate only.
{refs_ptr}
{intro}

## §1 THINK (Steps 0–3)
{step0}
{step1}
{step2}
{step3}

## §2 ACT (Step 4)
Before choosing a §3 rung, confirm §1 named verification is not a candidate for reduction.
{step4}
2.9 **Solution selection:** apply §3 to size implementation only.

## §3 SHAPE — solution selection
Applies during §2 only, after §1 evidence gathered.
Product code only. Never applies to: named verification, tests, artifact lines, or report.
Rung 1 applies to product code only. Never applies to §6 owed lines.
Off-limits regardless of rung: trust-boundary validation, data-loss handling, security, accessibility, and the §1 named check.

{pony}

## §4 VERIFY (Step 5)
{step5}

## §5 PROVE (Step 6)
Any shortcut marker added in §2/§3 (`ponytail:`) appears here as caveat.
{prove}

## §6 TERMINAL GATE
{artifact}

## §7 APPENDIX: provenance + pins
- Method provenance: Sahir619/fable-method MIT — https://github.com/Sahir619/fable-method (pin `{PIN[:12]}`)
- Ponytail: DietrichGebert/ponytail via `PONYTAIL:MANAGED` (byte-clean; `azg update --vendor`)
- Compress: caveman rules via `_build/caveman_local.py` (Claude CLI unavailable); rearrange + exact-dedupe only
- Policy: device paths/skills use azg names — see ADR 0014 Method naming

## §8 ADDENDA (azg-owned; outside method fences)
{misc}
<!-- AZG:AGENT-INSTRUCTIONS:END -->
"""
    return body


def build_orchestrate() -> str:
    raw = (COMP / "fable-loop.md").read_text(encoding="utf-8")
    # Drop YAML; rebuild
    body = raw.split("---", 2)[-1].strip()
    body = mech_rename(body)
    gate = body.find("**Gate first.**")
    if gate == -1:
        raise SystemExit("orchestrate body missing Gate first")
    body = (
        "# Orchestrate\n\n"
        "This skill orchestrates the resident AGENTS.md pipeline; those rules govern every stage. "
        "Method says WHAT to check; this loop says WHO does the work: main thread vs subagent fan-out "
        "vs adversarial verify before delivery.\n\n"
        + body[gate:]
    )
    body = body.replace(
        "plain agent-harness-pipeline covers the shape.",
        "resident AGENTS.md pipeline covers the shape.",
    )
    body = body.replace(
        "Self-audit per agent-harness-pipeline audit mode",
        "Self-audit per resident pipeline audit mode",
    )
    return f"""---
name: orchestrate
description: >
  Orchestrates complex multi-step work inside the resident AGENTS.md pipeline —
  parallel evidence subagents, plan artifact + approval stop, surgical execute,
  adversarial verifier subagents, outcome-first report. Invoke when scope is
  ambiguous, actions are irreversible, evidence needs parallel fan-out, or the
  run is unattended.
---

## Inherits
This skill runs inside the resident AGENTS.md pipeline.
It does not redefine §1–§6. It only replaces HOW §1.3 evidence and §4 verification
are executed: via subagents instead of inline.

## Entry conditions
Invoke when: scope is ambiguous · actions are irreversible ·
evidence needs parallel fan-out · the run is unattended.

## Subagent Rule Overrides
- evidence subagents: inherit §1, IGNORE §3
- verifier subagents: inherit §4/§5, IGNORE §3
- implementation subagents: inherit all sections

---

{body}
"""


def build_judge() -> str:
    raw = (COMP / "fable-judge.md").read_text(encoding="utf-8")
    body = raw.split("---", 2)[-1].strip()
    # Drop suite mode (upstream plugin eval/) — azg Trap Suite is separate Process Gate
    if "## suite mode" in body:
        body = body[: body.index("## suite mode")].rstrip() + "\n"
    body = mech_rename(body)
    body = body.replace("# judge", "# Judge")
    body = re.sub(
        r"`agent-harness-pipeline`'s\s*`references/",
        "`skills/references/",
        body,
    )
    body = body.replace("`agent-harness-pipeline`'s", "pipeline")
    return f"""---
name: judge
description: >
  Adversarial verification of finished work. Treats any done report as claims,
  re-runs claimed checks, diffs what changed, hunts weakened tests and false
  completion, verdict VERIFIED / VERIFIED WITH CAVEATS / REFUTED. Use after
  claims of completion, or "/judge", "verify what it did".
---

## Inherits
Fresh-context audit for the resident pipeline. Does not redefine §1–§4.
Complements thin resident §5/§6 gate — this skill is the deep prove.

{body}
"""


def main() -> None:
    # re-copy refs
    refs_dst = CAND / "skills" / "references"
    if refs_dst.exists():
        shutil.rmtree(refs_dst)
    shutil.copytree(COMP / "refs", refs_dst)
    # mechanical rename inside refs
    for p in refs_dst.rglob("*.md"):
        t = mech_rename(p.read_text(encoding="utf-8"))
        t = t.replace("/orchestrate audit", "judge / orchestrate audit")
        t = t.replace("`/orchestrate audit`", "audit via `judge` or orchestrate")
        p.write_text(t, encoding="utf-8")

    (CAND / "AGENTS.md").write_text(build_agents(), encoding="utf-8")
    (CAND / "skills" / "orchestrate").mkdir(parents=True, exist_ok=True)
    (CAND / "skills" / "judge").mkdir(parents=True, exist_ok=True)
    (CAND / "skills" / "orchestrate" / "SKILL.md").write_text(build_orchestrate(), encoding="utf-8")
    (CAND / "skills" / "judge" / "SKILL.md").write_text(build_judge(), encoding="utf-8")

    stub = CAND / "cursor" / "rules" / "azg-agent-instructions.mdc"
    stub.parent.mkdir(parents=True, exist_ok=True)
    stub.write_text(
        "---\n"
        "description: Candidate agent harness pipeline — think, act, shape (ponytail), verify, prove, terminal gate\n"
        "alwaysApply: true\n"
        "---\n",
        encoding="utf-8",
    )

    (CAND / "NOTICE").write_text(
        f"""Unified-pipeline Candidate — method content derived from Sahir619/fable-method (MIT).
Source: https://github.com/Sahir619/fable-method
Pin: {PIN}
Device paths/skills renamed (orchestrate, judge, Agent Harness Pipeline) for clarity and host-agnostic setup — not a claim of original authorship. Full credit to upstream authors.
Ponytail block: DietrichGebert/ponytail (separate upstream; PONYTAIL:MANAGED).
Trap Suite corpus NOTICE remains under evals/traps/vendor/fable-method/NOTICE.
""",
        encoding="utf-8",
    )
    print("assembled", CAND)


if __name__ == "__main__":
    main()
