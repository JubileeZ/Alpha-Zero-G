# Fable-method compress reference (WIP)

Source: [Sahir619/fable-method](https://github.com/Sahir619/fable-method) @ `88b5cf36b10ee3679e08ee0f0181b9774d481508` (matches `evals/traps/vendor/fable-method/VENDOR.lock`).

**Reference only** — not Device Setup. Live always-on = EP v1 in `templates/global/` (ADR 0016). If shipping method skills later: azg ids **`judge`** / **`orchestrate`** (CONTEXT Method Naming); credit this upstream in NOTICE/README. No `fable-*` on device.

## Layout

| Path | Role |
|------|------|
| `compressed/` | Telegraphic reference: Execution Protocol source, `references/`, skills |

## Files

**Core**
- `AGENTS.md` — portable Execution Protocol (Usage, Modes, examples)
- `references/` — failure modes, examples, flowcharts, domain adapters

**Skills** (`skills/`) — upstream-shaped names in this tree only
- `orchestrator/SKILL.md` → azg ship id **`orchestrate`** (if ever shipped)
- `auditor/SKILL.md` → azg ship id **`judge`** (if ever shipped)
- `adapter-builder/SKILL.md` — domain adapter generator (not Device Setup)
