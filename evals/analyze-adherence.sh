#!/usr/bin/env bash
# evals/analyze-adherence.sh — print per-arm rates; exit 0 always (informational)
# Effective score = score_override if set, else task_success
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"

CAMP="${1:-${ROOT}/evals/adherence/campaigns/wfa-lever-luna}"
[ -d "${CAMP}" ] || die "campaign dir missing: ${CAMP}"

OUT="${CAMP}/promote-result.json"

python3 - "${CAMP}" "${OUT}" <<'PY'
import json, sys, pathlib
camp = pathlib.Path(sys.argv[1])
out = pathlib.Path(sys.argv[2])
arms = ["baseline", "current", "candidate"]
prompts = []
rows = {}
for sc in camp.glob("*/*/scorecard.json"):
    prompt_id, arm = sc.parent.parent.name, sc.parent.name
    if prompt_id not in prompts:
        prompts.append(prompt_id)
    data = json.loads(sc.read_text())
    ov = data.get("score_override")
    ts = data.get("task_success")
    eff = ov if ov is not None else ts
    rows[(prompt_id, arm)] = {"effective": eff, "raw": ts, "override": ov, "notes": data.get("notes")}

prompts = sorted(set(prompts))
rates = {}
for arm in arms:
    vals = [rows.get((p, arm), {}).get("effective") for p in prompts]
    filled = [v for v in vals if v is not None]
    rates[arm] = {
        "n": len(filled),
        "pass": sum(1 for v in filled if v == 1),
        "rate": (sum(1 for v in filled if v == 1) / len(filled)) if filled else None,
        "nulls": sum(1 for v in vals if v is None),
    }

# regression checks
def eff(pid, arm):
    return rows.get((pid, arm), {}).get("effective")

regress = []
for pid in ("nontrivial", "outward"):
    c, cur = eff(pid, "candidate"), eff(pid, "current")
    if c is not None and cur is not None and c < cur:
        regress.append(pid)

cand, cur, base = rates["candidate"]["rate"], rates["current"]["rate"], rates["baseline"]["rate"]
promote = None
if cand is not None and cur is not None and base is not None:
    promote = cand >= cur and cand >= base and not regress

result = {
    "campaign": str(camp),
    "pass_rate": rates,
    "regress_hard_rows": regress,
    "promote_adhoc": promote,
    "note": "Not ADR 0007 Lite promote. Heuristic adherence scores.",
}
out.write_text(json.dumps(result, indent=2) + "\n")
print(json.dumps(result, indent=2))
PY
