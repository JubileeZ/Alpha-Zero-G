#!/usr/bin/env bash
# evals/analyze-trap-tiers.sh <parent_camp>
# Side-by-side rates + grids for low/medium/high (or whatever child dirs exist).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"

PARENT="${1:-}"
[ -n "${PARENT}" ] || die "usage: analyze-trap-tiers.sh <parent_camp>"
[ -d "${PARENT}" ] || die "missing ${PARENT}"

azg_python - "${PARENT}" "${ROOT}/evals/traps/LAST-GATE.md" "${ROOT}/evals/analyze-trap.sh" <<'PY'
import json, pathlib, sys, datetime, subprocess
parent = pathlib.Path(sys.argv[1])
last_path = pathlib.Path(sys.argv[2])
analyze_sh = sys.argv[3]
arms = ["baseline", "current", "candidate"]
# Prefer known order
order = ["low", "medium", "high"]
kids = []
for name in order:
    p = parent / name
    if p.is_dir() and (p / "selection.json").exists():
        kids.append(p)
for p in sorted(parent.iterdir()):
    if p.is_dir() and p.name not in order and (p / "selection.json").exists():
        kids.append(p)
if not kids:
    raise SystemExit(f"no tier camps under {parent}")

def load_camp(camp: pathlib.Path):
    pr = camp / "promote-result.json"
    if not pr.exists():
        subprocess.check_call(["bash", analyze_sh, str(camp)])
    prj = json.loads(pr.read_text())
    rows = {}
    for sc in camp.glob("*/*/scorecard.json"):
        sid, arm = sc.parent.parent.name, sc.parent.name
        if sid == "cell-logs":
            continue
        data = json.loads(sc.read_text())
        ov, ts = data.get("score_override"), data.get("task_success")
        rows[(sid, arm)] = ov if ov is not None else ts
    return prj, rows

loaded = [(k.name, *load_camp(k)) for k in kids]
scenarios = sorted({s for _, _, rows in loaded for (s, _) in rows})

meta = {}
mp = parent / "meta.json"
if mp.exists():
    meta = json.loads(mp.read_text())

out = {
    "parent": str(parent),
    "tiers": [n for n, _, _ in loaded],
    "meta": meta,
    "pass_rate": {n: pr.get("pass_rate") for n, pr, _ in loaded},
    "grids": {
        n: {s: {a: rows.get((s, a)) for a in arms} for s in scenarios}
        for n, _, rows in loaded
    },
}
(parent / "tiers.json").write_text(json.dumps(out, indent=2) + "\n")

def pct(rate):
    return f"{rate*100:.0f}%" if isinstance(rate, (int, float)) else "—"

def cell(v):
    if v is None: return "-"
    return "1" if v == 1 else "0"

lines = []
lines.append("# Trap Tier Sweep")
lines.append("")
lines.append(f"Updated: {datetime.datetime.now().astimezone().isoformat(timespec='seconds')}")
lines.append(f"Parent: `{parent}`")
lines.append(f"Current: `{meta.get('current_ref', '?')}` · Candidate pack: `{meta.get('candidate_pack', '?')}` · azg skills staged: `{meta.get('azg_eval_azg_skills', '?')}`")
lines.append("")
lines.append("## Pass rates (B / Current / Fable)")
lines.append("")
hdr = "| Tier | Baseline | Current | Candidate |"
sep = "|------|----------|---------|-----------|"
lines.append(hdr)
lines.append(sep)
for n, pr, _ in loaded:
    rates = pr.get("pass_rate") or {}
    def r(arm):
        x = (rates.get(arm) or {})
        p, nn = x.get("pass"), x.get("n")
        rate = x.get("rate")
        return f"{p}/{nn} ({pct(rate)})" if nn else "—"
    lines.append(f"| {n} | {r('baseline')} | {r('current')} | {r('candidate')} |")
lines.append("")
lines.append("## Grids by tier (B/C/Cand)")
lines.append("")
for n, _, rows in loaded:
    lines.append(f"### {n}")
    lines.append("")
    lines.append("| ID | B | C | Cand |")
    lines.append("|----|---|---|------|")
    for sid in scenarios:
        b, c, a = (rows.get((sid, arm)) for arm in arms)
        lines.append(f"| {sid} | {cell(b)} | {cell(c)} | {cell(a)} |")
    lines.append("")
lines.append("Clean-slate Current = Ponytail + cleanup + telegraphic only. Fable = upstream pack. Not an adopt gate.")
text = "\n".join(lines) + "\n"
(parent / "TIERS.md").write_text(text)
last_path.write_text(text)
print(text)
PY

info "tiers → ${PARENT}/TIERS.md"
info "tiers → ${ROOT}/evals/traps/LAST-GATE.md"
