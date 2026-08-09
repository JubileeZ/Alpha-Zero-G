# Fable-method compress reference (WIP)

Source: [Sahir619/fable-method](https://github.com/Sahir619/fable-method) @ `88b5cf36b10ee3679e08ee0f0181b9774d481508` (matches `evals/traps/vendor/fable-method/VENDOR.lock`).

**Reference only** — not Device Setup. Azg ships adapted text under Candidate pack with skill ids **`judge`** / **`orchestrate`** (see `templates/candidates/execution-protocol-v2/README.md`, ADR 0017). Do not copy `fable-*` names onto device.

## Layout

| Path | Role |
|------|------|
| `compressed/` | Telegraphic reference: Execution Protocol source, `references/`, skills |

## Files

**Core**
- `AGENTS.md` — portable Execution Protocol (Usage, Modes, examples)
- `references/` — failure modes, examples, flowcharts, domain adapters

**Skills** (`skills/`) — upstream-shaped names in this tree only
- `orchestrator/SKILL.md` → azg ship id **`orchestrate`**
- `auditor/SKILL.md` → azg ship id **`judge`**
- `adapter-builder/SKILL.md` — domain adapter generator (not in EP v2 Candidate)

**After Trap promote:** archive or trim `wip/fable-method/` if no longer needed.
