# Promote Execution Protocol v1 always-on

Trap Process Gate (`gate-execution-protocol-v1`, R=5 @ `gpt-5.6-luna-low`, docker) **RECOMMEND_ADOPT**. Promote `templates/candidates/execution-protocol-v1/` into `templates/global/AGENTS.md` (`AZG:AGENT-INSTRUCTIONS`): Execution Protocol v1 + cleanup + telegraphic. Maj B/Cur/Cand **79%** tied; mean Cand **77%** ≥ Cur **73%** ≥ B **80%** (mean ranking); Coverage **13/14**. No Prove stance; no fable product name; ponytail stays vendor catalog only (ADR 0015).

**Status:** accepted 2026-08-09

**Consequences:** `azg setup --force` installs expanded agent-instructions rule. Candidate slot cleared. Stager `stage-execution-protocol-v1-home.sh` removed; default Candidate arm = global @ `AZG_CANDIDATE_REF`. Provenance: Sahir619/fable-method MIT ~v1.4 ideas; azg-owned text.

**Amends:** ADR 0009 clean-slate — intent gates re-earned via Trap, not full vendor paste.

**Amended by ADR 0017 (2026-08-09):** Layering — no auto-Orchestrate / no full fraud catalogue in always-on. EP v2 Candidate later killed; Device Setup remains this ADR's EP v1.

**Amended by ADR 0018 (2026-08-13):** Next always-on Device Setup change must pass the Earned Trap gate. EP v1 stays shipped until that gate can run. Planted S1–S14 not a promote input.
