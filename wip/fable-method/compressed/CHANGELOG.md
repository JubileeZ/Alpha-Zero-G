# Changelog

## Unreleased

### Renamed (terminology only; no behavior change)

- **the loop** (8-step procedure with backtrack/retry edges) → **the protocol**
- **fable-loop** skill → **orchestrator** (`/orchestrator`)
- **fable-judge** skill → **auditor** (`/auditor`)
- **fable-domain** skill → **adapter-builder** (`/adapter-builder`)
- **fable-method** skill removed; **AGENTS.md** is single source of truth (no Claude Code plugin packaging in this snapshot)
- Backtrack edge (Step 2 rule 7) and retry edge (Step 5) named explicitly in AGENTS.md
- `references/` moved from `skills/fable-method/references/` to repo root
