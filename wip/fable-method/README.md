# Fable-method compress snapshots (WIP)

Source: [Sahir619/fable-method](https://github.com/Sahir619/fable-method) @ `88b5cf36b10ee3679e08ee0f0181b9774d481508` (matches `evals/traps/vendor/fable-method/VENDOR.lock`).

Fetched 2026-08-08. v3: lighter compression + full references + example preservation. Git-tracked under `wip/`; handcraft draft in `wip/candidates-raw/AGENTS.md`.

## Layout

| Path | Role |
|------|------|
| `upstream/` | Raw upstream copies (unmodified) |
| `compressed/` | Telegraphic drafts for handcraft candidate |

## Files

**Core**
- `AGENTS.md` — the protocol (single source of truth)
- `references/` — failure modes, examples, flowcharts, domain adapters

**Skills** (`skills/`)
- `orchestrator/SKILL.md` — multi-agent orchestrator (was fable-loop)
- `auditor/SKILL.md` — adversarial re-verification (was fable-judge)
- `adapter-builder/SKILL.md` — domain adapter generator (was fable-domain)

## Compression rules (v3)

Same base as `caveman-compress`: drop articles/filler/hedging; preserve code blocks, inline code, artifact lines (`INTENT:`/`AUTH:`/`TWINS:`/`PENDING:`), paths, URLs; keep heading text + structure.

**v3 additions:**
- No arrow/em-dash symbols in prose; use words
- **Keep quoted examples verbatim** (attacker lens prompts, Explore agent prompts, mixed-ask quotes, report outputs)
- **Keep worked example sections**; compress connective prose only
- **Keep fraud tables, minimum evidence sets, mermaid blocks** exact
- Domain adapters kept full upstream (reference density; handcraft from complete material)

**After Trap promote:** archive or trim `wip/fable-method/` if no longer needed; candidate moves to `templates/candidates/`.
