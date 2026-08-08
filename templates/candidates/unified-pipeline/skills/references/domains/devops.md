# Domain adapter: devops and infrastructure

Applies when deliverable changes how system runs: IaC (Terraform, K8s), CI/CD pipelines, deploy/rollback scripts, alerts, runbooks. Loop unchanged; definitions replace coding defaults.

## Minimum evidence set (binding, before change)
1. **Live state**: actual running config, deployed version, infra state (`kubectl get`, plan output).
2. **Governing runbook/policy**: change-management doc, SLO, runbook.
3. **Live platform reference**: current provider docs/CLI fetched now.

## Evidence and primary sources
Observed live state/plan/metric is primary; IaC file is a claim. Green pipeline exiting 0 is not evidence system is healthy.

## Authority order
Explicit user instruction > runbook/policy > observed live behavior > IaC stated intent > assumptions.

## Verification by observation
- Change confirmed applied to target (plan output, live resource read, metric).
- Blast radius named; rollback path reviewed.
- Post-change health verified (error rates/latency unregressed, alerts not silenced).
- Outward/shared infra changes require quoted user authorization (`AUTH:` gate).

## Fraud table
| Fraud | Symptom |
|---|---|
| Big-bang deploy | pushed to all traffic without canary or blast radius |
| Silenced alerting | threshold widened or check disabled instead of fixing root cause |
| Untested rollback | deploy with unverified/missing rollback path |
| Config drift denial | claiming system matches repo without checking live state |
| Secret in clear | credentials/tokens committed to configs/logs |
| Unauthorized prod touch | apply/restart against shared infra without quoted user auth |

## Done, by example
"Staging deploy done" means: plan reviewed, change confirmed live, health checked post-change, rollback stated, prod steps marked PENDING user auth. Not: "pipeline green."

## Sources
- Google SRE Workbook Canarying: https://sre.google/workbook/canarying-releases/ (2026-07-11)
- AWS Operational Excellence OPS05-BP09: https://docs.aws.amazon.com/wellarchitected/latest/operational-excellence-pillar/ops_dev_integ_freq_sm_rev_chg.html (2026-07-11)
