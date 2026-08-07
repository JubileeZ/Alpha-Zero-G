#!/usr/bin/env bash
# evals/analyze-trap.sh [campaign_dir]
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"

CAMP="${1:-${ROOT}/evals/traps/campaigns/default}"
OUT="${CAMP}/promote-result.json"

python3 - "${CAMP}" "${OUT}" <<'PY'
import json, pathlib, sys
camp = pathlib.Path(sys.argv[1])
out = pathlib.Path(sys.argv[2])
arms = ["baseline", "current", "candidate"]
rows = {}
scenarios = set()
for sc in camp.glob("*/*/scorecard.json"):
    sid, arm = sc.parent.parent.name, sc.parent.name
    if sid in ("cell-logs",): continue
    scenarios.add(sid)
    data = json.loads(sc.read_text())
    ov = data.get("score_override")
    ts = data.get("task_success")
    eff = ov if ov is not None else ts
    rows[(sid, arm)] = eff

scenarios = sorted(scenarios)
rates = {}
for arm in arms:
    vals = [rows.get((s, arm)) for s in scenarios]
    filled = [v for v in vals if v is not None]
    rates[arm] = {
        "n": len(filled),
        "pass": sum(1 for v in filled if v == 1),
        "rate": (sum(1 for v in filled if v == 1) / len(filled)) if filled else None,
        "nulls": sum(1 for v in vals if v is None),
    }

cand, cur, base = rates["candidate"]["rate"], rates["current"]["rate"], rates["baseline"]["rate"]
promote = None
if all(x is not None for x in (cand, cur, base)):
    promote = cand >= cur and cand >= base

selection = {}
sel_path = camp / "selection.json"
if sel_path.exists():
    selection = json.loads(sel_path.read_text())
isolation = selection.get("isolation") or "host"
# ADR 0013: host isolation is not promote-grade
promote_blocked = isolation != "docker"
note = "Process Gate (ADR 0012). Not Lite Evaluation Suite promote."
if promote_blocked:
    promote = False
    note += f" Eval Isolation={isolation} (ADR 0013) — promote requires isolation=docker."

result = {
    "campaign": str(camp),
    "scenarios": scenarios,
    "pass_rate": rates,
    "isolation": isolation,
    "promote_process_gate": promote,
    "promote_blocked_by_isolation": promote_blocked,
    "note": note,
}
out.write_text(json.dumps(result, indent=2) + "\n")
print(json.dumps(result, indent=2))
PY
