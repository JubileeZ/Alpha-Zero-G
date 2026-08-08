#!/usr/bin/env python3
"""Adopt Ledger analyze + recommend (ADR 0012).

CLI:
  analyze_ledger.py <parent_camp> [--last-gate PATH] [--expected-r 5]

Self-check:
  analyze_ledger.py --self-test
"""
from __future__ import annotations

import argparse
import datetime
import json
import pathlib
import statistics
import subprocess
import sys
from typing import Any

ARMS = ("baseline", "current", "candidate")


def majority(vals: list) -> int | None:
    filled = [v for v in vals if v is not None]
    if not filled:
        return None
    ones = sum(1 for v in filled if v == 1)
    zeros = len(filled) - ones
    if ones > zeros:
        return 1
    if zeros > ones:
        return 0
    return None


def mean_success(vals: list) -> float | None:
    filled = [v for v in vals if v is not None]
    if not filled:
        return None
    return sum(1 for v in filled if v == 1) / len(filled)


def board_label(cand: float | None, cur: float | None) -> str | None:
    """Win / neutral / loss for display (strict > for win)."""
    if cand is None or cur is None:
        return None
    if cand > cur:
        return "win"
    if cand == cur:
        return "neutral"
    return "loss"


def coverage_ge(cand: float | None, other: float | None) -> bool:
    """Coverage hit: Cand mean >= other mean (ties count)."""
    return cand is not None and other is not None and cand >= other


def overall_ranking_win(maj_rates: dict[str, dict]) -> bool:
    c = (maj_rates.get("candidate") or {}).get("rate")
    cur = (maj_rates.get("current") or {}).get("rate")
    b = (maj_rates.get("baseline") or {}).get("rate")
    return (
        isinstance(c, (int, float))
        and isinstance(cur, (int, float))
        and isinstance(b, (int, float))
        and c >= cur >= b
    )


def coverage_win(hit_count: int, scenario_count: int) -> bool:
    if scenario_count <= 0:
        return False
    return hit_count >= (scenario_count * 0.5)


def recommend(
    *,
    overall: bool,
    coverage: bool,
    nulls: int,
    r_count: int,
    isolation: str | None,
    expected_r: int = 5,
) -> str:
    if isolation != "docker" or nulls > 0 or r_count < expected_r:
        return "INCOMPLETE"
    if overall and coverage:
        return "RECOMMEND_ADOPT"
    if not overall and not coverage:
        return "RECOMMEND_REJECT"
    return "USER_DECIDES"


def load_cells(parent: pathlib.Path, analyze_sh: pathlib.Path | None) -> tuple[list[pathlib.Path], dict, set[str]]:
    reps = sorted(
        [p for p in parent.iterdir() if p.is_dir() and p.name.startswith("r") and p.name[1:].isdigit()],
        key=lambda p: int(p.name[1:]),
    )
    cells: dict[tuple[str, str], list] = {}
    scenarios: set[str] = set()
    for rep in reps:
        pr = rep / "promote-result.json"
        if not pr.exists() and analyze_sh is not None and analyze_sh.exists():
            subprocess.check_call(["bash", str(analyze_sh), str(rep)])
        for sc in rep.glob("*/*/scorecard.json"):
            sid, arm = sc.parent.parent.name, sc.parent.name
            if sid == "cell-logs" or arm not in ARMS:
                continue
            scenarios.add(sid)
            data = json.loads(sc.read_text())
            ov, ts = data.get("score_override"), data.get("task_success")
            cells.setdefault((sid, arm), []).append(ov if ov is not None else ts)
    return reps, cells, scenarios


def analyze_parent(
    parent: pathlib.Path,
    *,
    analyze_sh: pathlib.Path | None = None,
    expected_r: int = 5,
) -> dict[str, Any]:
    reps, cells, scenarios_set = load_cells(parent, analyze_sh)
    if not reps:
        raise SystemExit(f"no rN camps under {parent}")
    scenarios = sorted(scenarios_set)
    meta: dict[str, Any] = {}
    mp = parent / "meta.json"
    if mp.exists():
        meta = json.loads(mp.read_text())

    isolation = meta.get("isolation")
    if isolation is None:
        for rep in reps:
            pr = rep / "promote-result.json"
            if pr.exists():
                isolation = json.loads(pr.read_text()).get("isolation")
                break

    # nulls: missing or None across expected grid
    r_count = len(reps)
    nulls = 0
    for sid in scenarios:
        for arm in ARMS:
            vals = cells.get((sid, arm), [])
            # pad to r_count if short
            while len(vals) < r_count:
                vals.append(None)
                cells[(sid, arm)] = vals
            nulls += sum(1 for v in vals[:r_count] if v is None)

    maj_rows: dict[tuple[str, str], int | None] = {}
    mean_rows: dict[tuple[str, str], float | None] = {}
    counts: dict[tuple[str, str], dict[str, int]] = {}
    for sid in scenarios:
        for arm in ARMS:
            vals = cells.get((sid, arm), [])[:r_count]
            maj_rows[(sid, arm)] = majority(vals)
            mean_rows[(sid, arm)] = mean_success(vals)
            filled = [v for v in vals if v is not None]
            counts[(sid, arm)] = {
                "pass": sum(1 for v in filled if v == 1),
                "fail": sum(1 for v in filled if v == 0),
                "null": sum(1 for v in vals if v is None),
                "r": r_count,
            }

    maj_rates: dict[str, dict] = {}
    mean_rates: dict[str, dict] = {}
    for arm in ARMS:
        maj_vals = [maj_rows.get((s, arm)) for s in scenarios]
        filled = [v for v in maj_vals if v is not None]
        maj_rates[arm] = {
            "n": len(filled),
            "pass": sum(1 for v in filled if v == 1),
            "rate": (sum(1 for v in filled if v == 1) / len(filled)) if filled else None,
            "ties": sum(1 for v in maj_vals if v is None),
        }
        means = [mean_rows.get((s, arm)) for s in scenarios]
        ok = [m for m in means if m is not None]
        mean_rates[arm] = {
            "mean_rate": statistics.mean(ok) if ok else None,
            "n": len(ok),
        }

    per_scenario = []
    cov_hits = 0
    base_hits = 0
    for sid in scenarios:
        cm = mean_rows.get((sid, "candidate"))
        curm = mean_rows.get((sid, "current"))
        bm = mean_rows.get((sid, "baseline"))
        label = board_label(cm, curm)
        hit = coverage_ge(cm, curm)
        bhit = coverage_ge(cm, bm)
        if hit:
            cov_hits += 1
        if bhit:
            base_hits += 1
        per_scenario.append(
            {
                "id": sid,
                "counts": {a: counts.get((sid, a), {}) for a in ARMS},
                "mean": {a: mean_rows.get((sid, a)) for a in ARMS},
                "majority": {a: maj_rows.get((sid, a)) for a in ARMS},
                "cand_vs_cur": label,
                "coverage_ge_cur": hit,
                "coverage_ge_baseline": bhit,
            }
        )

    # Coverage denom = scenarios present on ledger (full corpus = 14)
    denom = len(scenarios)
    cov_ok = coverage_win(cov_hits, denom)
    ov_ok = overall_ranking_win(maj_rates)
    baseline_dominates = False
    br = (maj_rates.get("baseline") or {}).get("rate")
    cr = (maj_rates.get("current") or {}).get("rate")
    ar = (maj_rates.get("candidate") or {}).get("rate")
    if all(isinstance(x, (int, float)) for x in (br, cr, ar)):
        baseline_dominates = br > cr and br > ar  # type: ignore[operator]

    rec = recommend(
        overall=ov_ok,
        coverage=cov_ok,
        nulls=nulls,
        r_count=r_count,
        isolation=isolation if isinstance(isolation, str) else None,
        expected_r=expected_r,
    )

    return {
        "parent": str(parent),
        "repeats": [r.name for r in reps],
        "r_count": r_count,
        "model": meta.get("model"),
        "isolation": isolation,
        "nulls": nulls,
        "majority_pass_rate": maj_rates,
        "mean_pass_rate": mean_rates,
        "per_scenario": per_scenario,
        "coverage": {
            "cand_ge_cur": cov_hits,
            "denom": denom,
            "rate": cov_hits / denom if denom else None,
            "win": cov_ok,
        },
        "baseline_coverage": {
            "cand_ge_baseline": base_hits,
            "denom": denom,
            "rate": base_hits / denom if denom else None,
            "note": "informational only — not a take/not-take input",
        },
        "overall_win": ov_ok,
        "baseline_dominates": baseline_dominates,
        "recommend": rec,
        "meta": meta,
    }


def pct(x: Any) -> str:
    return f"{x * 100:.0f}%" if isinstance(x, (int, float)) else "—"


def render_md(out: dict[str, Any]) -> str:
    lines = [
        "# Adopt Ledger",
        "",
        f"Updated: {datetime.datetime.now().astimezone().isoformat(timespec='seconds')}",
        f"Parent: `{out['parent']}`",
        f"Rounds: {', '.join(out['repeats'])} · model: `{out.get('model') or '?'}` · isolation: `{out.get('isolation') or '?'}`",
        f"Nulls: {out['nulls']} · recommend: **{out['recommend']}**",
        "",
    ]
    if out.get("baseline_dominates"):
        lines.append("> Warning: Baseline dominates overall majority rates — revise Candidate.")
        lines.append("")
    lines += [
        "## Overall majority rates",
        "",
        "| Arm | Pass | N | Rate | Ties |",
        "|-----|------|---|------|------|",
    ]
    for arm in ARMS:
        r = out["majority_pass_rate"][arm]
        lines.append(f"| {arm} | {r['pass']} | {r['n']} | **{pct(r['rate'])}** | {r['ties']} |")
    lines += [
        "",
        f"Overall ranking win (Cand≥Cur≥B): **{out['overall_win']}**",
        "",
        "## Overall mean rates (consistency)",
        "",
        "| Arm | Mean |",
        "|-----|------|",
    ]
    for arm in ARMS:
        m = out["mean_pass_rate"][arm]
        lines.append(f"| {arm} | **{pct(m['mean_rate'])}** |")
    cov = out["coverage"]
    bcov = out["baseline_coverage"]
    lines += [
        "",
        f"## Coverage (Cand mean ≥ Cur mean): {cov['cand_ge_cur']}/{cov['denom']} ({pct(cov['rate'])}) · win={cov['win']}",
        f"Baseline coverage % (display only): {bcov['cand_ge_baseline']}/{bcov['denom']} ({pct(bcov['rate'])})",
        "",
        "## Per scenario",
        "",
        "| ID | B p/f/n | Cur p/f/n | Cand p/f/n | Cand vs Cur |",
        "|----|---------|-----------|------------|-------------|",
    ]
    for row in out["per_scenario"]:
        def pfn(arm: str) -> str:
            c = row["counts"][arm]
            return f"{c.get('pass', 0)}/{c.get('fail', 0)}/{c.get('null', 0)}"

        lines.append(
            f"| {row['id']} | {pfn('baseline')} | {pfn('current')} | {pfn('candidate')} | {row['cand_vs_cur'] or '·'} |"
        )
    lines += ["", f"**Recommend:** {out['recommend']}", ""]
    return "\n".join(lines)


def self_test() -> None:
    # majority
    assert majority([1, 1, 0, 0, 1]) == 1
    assert majority([1, 1, 0, 0]) is None
    assert mean_success([1, 0, 1, 0, 1]) == 0.6
    assert board_label(0.6, 0.4) == "win"
    assert board_label(0.5, 0.5) == "neutral"
    assert board_label(0.2, 0.4) == "loss"
    assert coverage_ge(0.5, 0.5) is True
    assert coverage_win(7, 14) is True
    assert coverage_win(6, 14) is False
    maj = {
        "candidate": {"rate": 0.8},
        "current": {"rate": 0.7},
        "baseline": {"rate": 0.6},
    }
    assert overall_ranking_win(maj) is True
    maj2 = {
        "candidate": {"rate": 0.5},
        "current": {"rate": 0.7},
        "baseline": {"rate": 0.8},
    }
    assert overall_ranking_win(maj2) is False
    assert (
        recommend(overall=True, coverage=True, nulls=0, r_count=5, isolation="docker")
        == "RECOMMEND_ADOPT"
    )
    assert (
        recommend(overall=False, coverage=False, nulls=0, r_count=5, isolation="docker")
        == "RECOMMEND_REJECT"
    )
    assert (
        recommend(overall=True, coverage=False, nulls=0, r_count=5, isolation="docker")
        == "USER_DECIDES"
    )
    assert (
        recommend(overall=True, coverage=True, nulls=1, r_count=5, isolation="docker")
        == "INCOMPLETE"
    )
    assert (
        recommend(overall=True, coverage=True, nulls=0, r_count=1, isolation="docker")
        == "INCOMPLETE"
    )
    assert (
        recommend(overall=True, coverage=True, nulls=0, r_count=5, isolation="host")
        == "INCOMPLETE"
    )
    print("analyze_ledger self-test OK")


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser()
    p.add_argument("parent", nargs="?", help="parent camp with r1..rN")
    p.add_argument("--last-gate", default="", help="write copy of LEDGER.md here")
    p.add_argument("--expected-r", type=int, default=5)
    p.add_argument("--analyze-sh", default="", help="path to analyze-trap.sh for missing promote-result")
    p.add_argument("--self-test", action="store_true")
    args = p.parse_args(argv)
    if args.self_test:
        self_test()
        return 0
    if not args.parent:
        p.error("parent camp required (or --self-test)")
    parent = pathlib.Path(args.parent)
    analyze_sh = pathlib.Path(args.analyze_sh) if args.analyze_sh else None
    out = analyze_parent(parent, analyze_sh=analyze_sh, expected_r=args.expected_r)
    (parent / "aggregate.json").write_text(json.dumps(out, indent=2) + "\n")
    text = render_md(out)
    (parent / "LEDGER.md").write_text(text)
    if args.last_gate:
        pathlib.Path(args.last_gate).write_text(text)
    print(text)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
