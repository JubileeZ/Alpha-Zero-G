# Execution Protocol v2 Candidate

Trap Candidate Treatment (ADR 0017): lean EP v2 always-on + on-demand **`judge`** + **`orchestrate`**.

| Path | Role |
|------|------|
| `AGENTS.md` | `AZG:AGENT-INSTRUCTIONS` — EP v2 + escalate pointers |
| `cursor/rules/azg-agent-instructions.mdc` | Frontmatter stub for eval/Device render |
| `skills/judge/` | Deep fraud-hunt / adversarial verify |
| `skills/orchestrate/` | Multi-agent fan-out when high bar or user invoke |

**Not** Device Setup until Trap Process Gate promote (ADR 0012). Live global remains EP v1 (ADR 0016).

## Provenance / credit

Azg-owned adaptation of ideas from [Sahir619/fable-method](https://github.com/Sahir619/fable-method) (MIT, ~v1.4 provenance; see `evals/traps/vendor/fable-method/VENDOR.lock` / `wip/fable-method/`). Upstream portable protocol + auditor/orchestrator skill shapes distilled into azg labels **`judge`** / **`orchestrate`** — **no `fable-*` skill ids on device** (CONTEXT Method Naming). Not a vendor bundle; do not paste upstream product name into Device Setup.

Handcraft reference compress (not shipped): `wip/fable-method/compressed/`.

## Trap

```bash
TRAP_CANDIDATE_PACK=execution-protocol-v2 \
  TRAP_CAMP=$PWD/evals/traps/campaigns/gate-execution-protocol-v2 \
  bash evals/traps/run-process-gate.sh --preview-only
```

Stager: `evals/stage-execution-protocol-v2-home.sh`.
