# Fable-method compress reference (WIP)

Source: [Sahir619/fable-method](https://github.com/Sahir619/fable-method) @ `88b5cf36b10ee3679e08ee0f0181b9774d481508` (matches `evals/traps/vendor/fable-method/VENDOR.lock`).

v3 compress for handcraft reference. Candidate always-on text: `wip/execution-protocol-v2/AGENTS.md`.

## Layout

| Path | Role |
|------|------|
| `compressed/` | Telegraphic reference: Execution Protocol source, `references/`, skills |

## Files

**Core**
- `AGENTS.md` — portable Execution Protocol (Usage, Modes, examples)
- `references/` — failure modes, examples, flowcharts, domain adapters

**Skills** (`skills/`)
- `orchestrator/SKILL.md` — multi-agent orchestrator (was fable-loop)
- `auditor/SKILL.md` — adversarial re-verification (was fable-judge)
- `adapter-builder/SKILL.md` — domain adapter generator (was fable-domain)

**After Trap promote:** archive or trim `wip/fable-method/` if no longer needed; candidate moves to `templates/candidates/`.
