#!/usr/bin/env bash
# evals/analyze-trap-repeats.sh <parent_camp>
# Aggregate r1..rN child camps: mean rates + majority vote per cell + flip count.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"

PARENT="${1:-}"
[ -n "${PARENT}" ] || die "usage: analyze-trap-repeats.sh <parent_camp>"
[ -d "${PARENT}" ] || die "missing ${PARENT}"

python3 - "${PARENT}" "${ROOT}/evals/traps/LAST-GATE.md" "${ROOT}/evals/analyze-trap.sh" <<'PY'
import json, pathlib, sys, datetime, statistics, subprocess
parent = pathlib.Path(sys.argv[1])
last_path = pathlib.Path(sys.argv[2])
analyze_sh = sys.argv[3]
arms = ["baseline", "current", "candidate"]
reps = sorted(
    [p for p in parent.iterdir() if p.is_dir() and p.name.startswith("r") and p.name[1:].isdigit()],
    key=lambda p: int(p.name[1:]),
)
if not reps:
    raise SystemExit(f"no rN camps under {parent}")

# (sid, arm) -> list of 0/1/None across reps
cells = {}
scenarios = set()
per_rep_rates = []
for rep in reps:
    pr_path = rep / "promote-result.json"
    if not pr_path.exists():
        subprocess.check_call(["bash", analyze_sh, str(rep)])
    rows = {}
    for sc in rep.glob("*/*/scorecard.json"):
        sid, arm = sc.parent.parent.name, sc.parent.name
        if sid == "cell-logs":
            continue
        scenarios.add(sid)
        data = json.loads(sc.read_text())
        ov, ts = data.get("score_override"), data.get("task_success")
        rows[(sid, arm)] = ov if ov is not None else ts
        cells.setdefault((sid, arm), []).append(rows[(sid, arm)])
    rates = {}
    for arm in arms:
        vals = [v for s in sorted(scenarios) if (v := rows.get((s, arm))) is not None]
        rates[arm] = {
            "n": len(vals),
            "pass": sum(1 for v in vals if v == 1),
            "rate": (sum(1 for v in vals if v == 1) / len(vals)) if vals else None,
        }
    per_rep_rates.append({"rep": rep.name, "pass_rate": rates})

scenarios = sorted(scenarios)

def majority(vals):
    filled = [v for v in vals if v is not None]
    if not filled:
        return None
    ones = sum(1 for v in filled if v == 1)
    zeros = len(filled) - ones
    if ones > zeros:
        return 1
    if zeros > ones:
        return 0
    return None  # tie

def flipped(vals):
    filled = [v for v in vals if v is not None]
    return len(set(filled)) > 1 if filled else False

maj_rows = {}
flip_count = {a: 0 for a in arms}
for sid in scenarios:
    for arm in arms:
        vals = cells.get((sid, arm), [])
        maj_rows[(sid, arm)] = majority(vals)
        if flipped(vals):
            flip_count[arm] += 1

# mean rates across reps
mean_rates = {}
for arm in arms:
    rs = [pr["pass_rate"][arm]["rate"] for pr in per_rep_rates if pr["pass_rate"][arm]["rate"] is not None]
    mean_rates[arm] = {
        "mean_rate": statistics.mean(rs) if rs else None,
        "rates": rs,
        "flipped_cells": flip_count[arm],
    }

# majority-grid rates
maj_rates = {}
for arm in arms:
    vals = [maj_rows.get((s, arm)) for s in scenarios]
    filled = [v for v in vals if v is not None]
    maj_rates[arm] = {
        "n": len(filled),
        "pass": sum(1 for v in filled if v == 1),
        "rate": (sum(1 for v in filled if v == 1) / len(filled)) if filled else None,
        "ties": sum(1 for v in vals if v is None),
    }

# harness-lift: majority baseline == 0
lift = [s for s in scenarios if maj_rows.get((s, "baseline")) == 0]
fable_gaps = [
    s for s in scenarios
    if maj_rows.get((s, "current")) == 0 and maj_rows.get((s, "candidate")) == 1
]
stable_lift = [
    s for s in lift
    if maj_rows.get((s, "current")) == 1
]

meta = {}
mp = parent / "meta.json"
if mp.exists():
    meta = json.loads(mp.read_text())

out = {
    "parent": str(parent),
    "repeats": [r.name for r in reps],
    "model": meta.get("model"),
    "per_rep": per_rep_rates,
    "mean_pass_rate": mean_rates,
    "majority_pass_rate": maj_rates,
    "majority_grid": {
        s: {a: maj_rows.get((s, a)) for a in arms} for s in scenarios
    },
    "harness_lift_ids": lift,
    "current_beats_baseline_majority": stable_lift,
    "fable_gt_current_majority": fable_gaps,
    "note": "Gap check / Process Gate aggregate. Majority vote per cell; not Lite adopt.",
}
(parent / "aggregate.json").write_text(json.dumps(out, indent=2) + "\n")

def pct(x):
    return f"{x*100:.0f}%" if isinstance(x, (int, float)) else "—"

def cell(v):
    if v is None: return "·"
    return "1" if v == 1 else "0"

lines = []
lines.append("# Trap Repeats Aggregate")
lines.append("")
lines.append(f"Updated: {datetime.datetime.now().astimezone().isoformat(timespec='seconds')}")
lines.append(f"Parent: `{parent}`")
lines.append(f"Repeats: {', '.join(r.name for r in reps)} · model: `{meta.get('model', '?')}`")
lines.append("")
lines.append("## Mean pass rate (across repeats)")
lines.append("")
lines.append("| Arm | Mean | Per-rep | Flipped cells |")
lines.append("|-----|------|---------|---------------|")
for arm in arms:
    m = mean_rates[arm]
    per = ", ".join(pct(x) for x in m["rates"])
    lines.append(f"| {arm} | **{pct(m['mean_rate'])}** | {per} | {m['flipped_cells']} |")
lines.append("")
lines.append("## Majority vote (per cell)")
lines.append("")
lines.append("| Arm | Pass | N | Rate | Ties |")
lines.append("|-----|------|---|------|------|")
for arm in arms:
    r = maj_rates[arm]
    lines.append(f"| {arm} | {r['pass']} | {r['n']} | **{pct(r['rate'])}** | {r['ties']} |")
lines.append("")
lines.append(f"- harness-lift (maj B=0): {', '.join(lift) or '(none)'}")
lines.append(f"- Current > Baseline (maj): {', '.join(stable_lift) or '(none)'}")
lines.append(f"- Fable > Current (maj): {', '.join(fable_gaps) or '(none)'}")
lines.append("")
lines.append("## Majority grid")
lines.append("")
lines.append("| ID | B | C | Cand |")
lines.append("|----|---|---|------|")
for sid in scenarios:
    b, c, a = (maj_rows.get((sid, arm)) for arm in arms)
    lines.append(f"| {sid} | {cell(b)} | {cell(c)} | {cell(a)} |")
lines.append("")
lines.append("· = tie / incomplete. Open `aggregate.json` for machine JSON.")
text = "\n".join(lines) + "\n"
(parent / "AGGREGATE.md").write_text(text)
last_path.write_text(text)
print(text)
PY

info "aggregate → ${PARENT}/AGGREGATE.md"
info "aggregate → ${ROOT}/evals/traps/LAST-GATE.md"
