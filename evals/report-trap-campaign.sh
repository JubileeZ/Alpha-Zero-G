#!/usr/bin/env bash
# evals/report-trap-campaign.sh [campaign_dir]
# After analyze: write human/agent REPORT.md + pointer LAST-GATE.md (no manual jq).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"

CAMP="${1:-${ROOT}/evals/traps/campaigns/default}"
PR="${CAMP}/promote-result.json"
[ -f "${PR}" ] || die "missing ${PR} — run analyze-trap.sh first"

REPORT="${CAMP}/REPORT.md"
LAST="${ROOT}/evals/traps/LAST-GATE.md"

python3 - "${CAMP}" "${PR}" "${REPORT}" "${LAST}" <<'PY'
import json, pathlib, sys, datetime
camp, pr_path, report_path, last_path = map(pathlib.Path, sys.argv[1:])
pr = json.loads(pr_path.read_text())
arms = ["baseline", "current", "candidate"]
scenarios = pr.get("scenarios") or sorted({
    p.parent.parent.name
    for p in camp.glob("*/*/scorecard.json")
    if p.parent.parent.name != "cell-logs"
})
rows = {}
for sc in camp.glob("*/*/scorecard.json"):
    sid, arm = sc.parent.parent.name, sc.parent.name
    if sid == "cell-logs":
        continue
    data = json.loads(sc.read_text())
    ov = data.get("score_override")
    ts = data.get("task_success")
    rows[(sid, arm)] = ov if ov is not None else ts

def cell(v):
    if v is None: return "-"
    return "1" if v == 1 else "0"

lines = []
lines.append("# Trap Gate Report")
lines.append("")
lines.append(f"Updated: {datetime.datetime.now().astimezone().isoformat(timespec='seconds')}")
lines.append(f"Campaign: `{camp}`")
lines.append("")
rates = pr.get("pass_rate") or {}
lines.append("| Arm | Pass | N | Rate | Nulls |")
lines.append("|-----|------|---|------|-------|")
for arm in arms:
    r = rates.get(arm) or {}
    rate = r.get("rate")
    rate_s = f"{rate*100:.0f}%" if isinstance(rate, (int, float)) else "—"
    lines.append(f"| {arm} | {r.get('pass', 0)} | {r.get('n', 0)} | **{rate_s}** | {r.get('nulls', 0)} |")
lines.append("")
lines.append(f"- isolation: `{pr.get('isolation')}`")
lines.append(f"- promote_process_gate: **{pr.get('promote_process_gate')}**")
if pr.get("promote_blocked_by_isolation"):
    lines.append("- promote blocked by isolation (need docker)")
note = pr.get("note") or ""
if note:
    lines.append(f"- note: {note}")
lines.append("")
lines.append("## Grid (task_success)")
lines.append("")
lines.append("| ID | B | C | Cand |")
lines.append("|----|---|---|------|")
for sid in scenarios:
    b, c, a = (rows.get((sid, arm)) for arm in arms)
    lines.append(f"| {sid} | {cell(b)} | {cell(c)} | {cell(a)} |")
lines.append("")
lines.append("Open `promote-result.json` for machine JSON. This file is auto-written when a trap campaign finishes.")
text = "\n".join(lines) + "\n"
report_path.write_text(text)
last_path.write_text(text)
print(text)
PY

info "trap report → ${REPORT}"
info "trap report → ${LAST}"
