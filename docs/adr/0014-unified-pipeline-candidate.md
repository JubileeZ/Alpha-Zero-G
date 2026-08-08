# Unified-pipeline Candidate (compressed method + skills)

Device Setup Candidate Treatment stages from `templates/candidates/unified-pipeline/` (not `templates/global/` until Trap promote): one resident pipeline AGENTS (Think→Act→Shape/ponytail→Verify→Prove gate), nested `PONYTAIL:MANAGED`, on-demand `orchestrate` + `judge` skills, lazy compressed `references/`. Content path: caveman-compress rules on Sahir619/fable-method pin (Claude CLI absent → light local filler/hedge pass in `_build/caveman_local.py`), then rearrange + exact-dedupe into pipeline skeleton; compressed instructional blocks kept; mechanical device-name renames (`fable-*` → azg ids) allowed for Method Naming; azg wrappers (router, inherit/overrides) outside fences. Supersedes ADR 0009 + 0010 for this Candidate approach. Promote still solely via Trap Process Gate (ADR 0012) + Eval Isolation docker (ADR 0013).

**Method naming:** Device paths and skill names must not use `fable-*`. Reason: opaque to users (needs explaining) and Claude-ecosystem branded; this project is host-agnostic and not Claude-centric. Rename ≠ disrespect — credit Sahir619/fable-method (MIT) in Candidate `NOTICE`, §7 appendix, and this ADR. Do not “correct” names back to upstream product strings.

**Status:** accepted (Candidate staged; global promote deferred until Trap).

**Out:** domain-factory skill · separate method skill (loop lives in AGENTS) · `BEGIN VENDORED` ponytail chrome · promote into `templates/global/` before Trap.

**Amends / supersedes:** ADR 0009, ADR 0010 (parked distill / deferred orchestrate). Eval wiring: `TRAP_CANDIDATE_PACK=unified-pipeline` → `evals/stage-unified-pipeline-home.sh` (single `.mdc`, nested ponytail).
