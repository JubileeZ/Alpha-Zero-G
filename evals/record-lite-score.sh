#!/usr/bin/env bash
# evals/record-lite-score.sh — fill a Lite scorecard
# Usage: record-lite-score.sh scorecard.json --task-success 0|1 [--delivery-cost N] [--notes "..."]

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"

SC="${1:-}"
shift || true
[ -f "${SC}" ] || die "scorecard not found: ${SC}"

ts=""
cost=""
notes=""
while [ $# -gt 0 ]; do
  case "$1" in
    --task-success) ts="$2"; shift 2 ;;
    --delivery-cost) cost="$2"; shift 2 ;;
    --notes) notes="$2"; shift 2 ;;
    *) die "unknown arg: $1" ;;
  esac
done

[ -n "${ts}" ] || die "--task-success required"

tmp="${SC}.azg.tmp"
jq --argjson ts "${ts}" --arg notes "${notes}" \
  --arg cost "${cost}" '
    .task_success = $ts
    | .notes = $notes
    | if ($cost | length) > 0 then .delivery_cost = ($cost|tonumber) else . end
  ' "${SC}" > "${tmp}" && mv "${tmp}" "${SC}"

ok "Updated ${SC}"
