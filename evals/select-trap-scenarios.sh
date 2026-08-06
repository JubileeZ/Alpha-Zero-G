#!/usr/bin/env bash
# evals/select-trap-scenarios.sh — print selected scenario IDs (one per line)
# Env: TRAP_FULL=1 | TRAP_IDS=a,b | TRAP_CHANGE_TYPE=general TRAP_N=5 TRAP_SEED=...
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CORPUS="${ROOT}/evals/traps/corpus.json"
MAP="${ROOT}/evals/traps/relevance-map.json"

if [ "${TRAP_FULL:-0}" = "1" ]; then
  jq -r '.scenarios[]' "${CORPUS}"
  exit 0
fi

if [ -n "${TRAP_IDS:-}" ]; then
  echo "${TRAP_IDS}" | tr ',' '\n' | sed '/^$/d'
  exit 0
fi

N="${TRAP_N:-5}"
CTYPE="${TRAP_CHANGE_TYPE:-general}"
SEED="${TRAP_SEED:-}"
if [ -z "${SEED}" ]; then
  SEED="$(date +%s)"
fi
export TRAP_SEED_EFFECTIVE="${SEED}"

python3 - "${CORPUS}" "${MAP}" "${CTYPE}" "${N}" "${SEED}" <<'PY'
import json, random, sys
corpus = json.load(open(sys.argv[1]))["scenarios"]
amap = json.load(open(sys.argv[2]))
ctype, n, seed = sys.argv[3], int(sys.argv[4]), sys.argv[5]
preferred = list(amap.get("change_types", {}).get(ctype, amap["change_types"]["general"]))
# keep only known ids
preferred = [p for p in preferred if p in corpus]
rng = random.Random(seed)
chosen = []
for p in preferred:
    if p not in chosen:
        chosen.append(p)
    if len(chosen) >= n:
        break
rest = [c for c in corpus if c not in chosen]
rng.shuffle(rest)
while len(chosen) < n and rest:
    chosen.append(rest.pop())
print(f"# seed={seed} change_type={ctype} n={len(chosen)}", file=sys.stderr)
for c in chosen[:n]:
    print(c)
PY
