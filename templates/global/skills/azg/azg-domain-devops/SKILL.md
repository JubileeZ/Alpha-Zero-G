---
name: azg-domain-devops
description: Infra-as-code, CI/CD, deploy/rollback, monitoring, runbooks, incident postmortems. Open before apply: bind live state and blast radius.
---

# azg-domain-devops

Applies when deliverable changes how system runs (IaC, CI/CD, deploy/rollback, monitoring, runbooks, postmortems). Always-on coding rules for file logic; this skill when correctness depends on live state, blast radius, or irreversible action.

## Minimum evidence set (binding, before any change applied)

1. **Current live state** — plan/diff, kubectl get, dashboard — never assume repo matches runtime.
2. **Governing runbook/policy** — change-mgmt, SLO, on-call. None → say so + assumption.
3. **One live platform reference** — current provider docs/CLI fetched now.

## Evidence and primary sources

Observed system state / plan / metric / log = primary. IaC = claim about what should run. Green pipeline / exit 0 ≠ health evidence.

## Authority order

Explicit user/owner > runbook/policy > platform observed behavior > IaC stated intent > "should be fine." Repo vs live conflict: live wins diagnosis; fix targets named cause of drift.

## Verification by observation

- Change confirmed live (post-change read/metric), not inferred from exit 0.
- Blast radius named before irreversible/shared action; rollback/dry-run path reviewed.
- Health checked after change; no silent alert loosening.
- Outward/irreversible steps follow AUTH gate.

## Fraud table (claim re-check)

| Fraud | Symptom |
|---|---|
| Big-bang deploy | all traffic/hosts with no canary/blast radius |
| Silenced alerting | threshold widened / check disabled instead of fix |
| Untested rollback | no path, or claimed but never dry-run |
| Config drift denial | claim match without checking live |
| Fabricated postmortem | root cause never reproduced; timeline ≠ logs |
| Secret in the clear | creds in IaC/configs/logs |
| Unauthorized production touch | apply/deploy/restart shared/prod without AUTH |

## Done, by example

"Staging deploy done" = plan/diff reviewed, change confirmed live, health post-check, rollback stated, prod/shared steps PENDING if not authorized. Not: "pipeline green."

## Sources

- Google SRE Workbook canarying: https://sre.google/workbook/canarying-releases/
- Google SRE postmortem culture: https://sre.google/sre-book/postmortem-culture/
- AWS Well-Architected OPS05-BP09 small reversible changes
- OWASP Secrets Management Cheat Sheet
- CIS Benchmarks

Provenance: Fable Method sector skill ideas (MIT); azg-owned wording.
