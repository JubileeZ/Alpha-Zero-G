# Research: AGENTS.md always-on budget + growing windows

**Date:** 2026-08-05  
**Question:** Industry standard size for always-on agent instructions? As context windows grow, keep absolute caps, % of window, or other?  
**AZG framing:** Device Setup global `templates/global/AGENTS.md` (~152 lines, ~2.8k tok est) + project `templates/project/AGENTS.md.tmpl` (~122 lines, ~1.3k tok est); stacked ~4k tok when both load.  
**Related prior note:** [`2026-07-31-agent-context-engineering-tracking-docs.md`](./2026-07-31-agent-context-engineering-tracking-docs.md)

---

## Verdict

**No industry-standard token count for AGENTS.md.** Vendors publish soft line/byte targets + layering patterns (always-on lean + JIT skills/rules), not a shared “N tokens” ISO.

**Growing windows ≠ grow always-on.** Context rot / attention budget: more room does not make fat always-on free. Keep absolute lean always-on; put growth into on-demand layers.

---

## Evidence

| Claim | Source | Notes |
|---|---|---|
| No numeric “standard AGENTS.md size” in GitHub Copilot agents.md lessons; quality = specificity, commands, boundaries; start simple, iterate | [GitHub Blog 2025-11](https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/) | Persona `agents.md` analysis; not a tok budget |
| Claude: target **&lt;200 lines per CLAUDE.md**; longer → more context + **reduced adherence**; path-scoped rules / skills for overflow; `@imports` still load at launch | [Claude Code memory](https://code.claude.com/docs/en/memory.md) | Soft target, not hard truncate for CLAUDE.md |
| Claude Help: short + signal-dense; under ~200 lines | [Claude Help — CLAUDE.md](https://support.claude.com/en/articles/14553240-give-claude-context-claude-md-and-better-prompts) | Aligns with memory.md |
| Claude best practices: only broadly applicable always-on; procedures → skills; prune (“would removing cause mistakes?”) | [Claude Code best practices](https://code.claude.com/docs/en/best-practices.md) | |
| Cursor: keep rules **under 500 lines**; split; reference files not copy; avoid stuffing style guides / every command | [Cursor rules](https://cursor.com/docs/rules) | Soft; AGENTS.md = simple always-applied alt |
| Codex: combined project docs stop at **`project_doc_max_bytes` default 32 KiB**; raise or nest when hit | [OpenAI Codex AGENTS.md](https://developers.openai.com/codex/guides/agents-md) | Hard truncate ceiling, not a recommended size |
| Context = finite; **context rot**; smallest high-signal set; do not treat larger windows as free always-on | [Anthropic — Effective context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) | Policy for growing windows |
| Hybrid lean always-on + JIT retrieval dominant pattern | Prior azg research 2026-07-31 + Cursor dynamic context / Anthropic | See prior note |

### AZG local measure (chars÷4 ≈ tok)

| File | Lines | ~tok |
|---|---:|---:|
| `templates/global/AGENTS.md` | 152 | ~2800 |
| `templates/project/AGENTS.md.tmpl` | 122 | ~1300 |
| Stacked empty | 274 | ~4100 |

Global alone under Claude 200-line soft target. Stacked lines &gt;200 if treated as one blob. Far under Codex 32 KiB (~8k–16k tok depending charset).

---

## Growing windows — policy options

| Policy | Idea | Verdict |
|---|---|---|
| **% of window** | Always-on ≤ 5% of 200k → 10k, scales up | **Reject** — attention budget / rot don’t scale linearly; fat instructions still dilute |
| **Absolute soft budget** | Cap always-on lines/tok; move rest to skills | **Prefer** — matches Claude/Cursor soft targets |
| **Absolute hard truncate** | Like Codex 32 KiB | Useful as safety rail, not as “recommended size” |
| **Earn-every-line** | No N; prune when adherence fails | Compatible with soft budget; Claude “would removing cause mistakes?” |

**Recommended policy as windows grow:** keep **absolute** always-on budget (or tighten); expand capability via **skills / path rules / nested AGENTS / session ritual reads** — not by bloating always-on.

---

## Implications for AZG

- ~4k stacked is **not** against Codex ceiling; **borderline** vs Claude “per file &lt;200 lines” if humans mentally merge global+project; fine vs Cursor 500-line rule soft cap (each surface alone).
- Real industry pressure is **signal density + layering**, not matching a magic tok number.
- Biggest AZG always-on mass = intent-gates (~2.1k tok). Cutting below ~3k without demoting gates is polish; ≤2k implies gate split → Lite re-risk (ADR 0009/0010).

---

## Could-not-verify

- Median/p50 AGENTS.md token distribution across public repos (GitHub blog gave qualitative lessons, not size histogram).
- Whether Cursor injects root `AGENTS.md` every Agent turn vs session-start-only (docs say included when applied; exact billing cadence host-specific).
- OpenAI page body re-fetched partially via search; 32 KiB claim confirmed in official guide snippets — re-open if changing product defaults.

---

## Grill recommendation (not user decision)

Prefer **B ≤3k always-on stack**, gates stay; do not scale budget with window size. Tighten project managed + pointer discipline; optional later Prove/method-refs already on-demand.
