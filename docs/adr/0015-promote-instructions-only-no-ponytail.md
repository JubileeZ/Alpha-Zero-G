# Promote: Device Setup without always-on Ponytail

Trap Process Gate (`gate-instructions-nopony`, R=5 @ `gpt-5.6-luna-low`, docker) **RECOMMEND_ADOPT** for Candidate = Current `AZG:AGENT-INSTRUCTIONS` only (maj B/Cur/Cand **79%** tied; Coverage **14/14**; mean Cand 76% ≥ Cur 74% ≥ B 70%). Promote into `templates/global/`: drop always-on `PONYTAIL:MANAGED` and `azg-ponytail.mdc`. Ponytail remains **vendor catalog** (`templates/global/skills/vendor/ponytail-skills`) — on-demand skill, not Device Setup always-on.

**Status:** accepted 2026-08-08

**Consequences:** `azg setup` installs agent-instructions rule only; prunes retired `azg-ponytail.mdc`; strips legacy PONYTAIL from owned global AGENTS. Eval Device Home Current arm matches. Vendor-sync no longer injects ponytail into AGENTS.md. ADR 0014 Candidate pack = promoted shape.
