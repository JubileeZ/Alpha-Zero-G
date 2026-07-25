#!/usr/bin/env bash
# evals/analyze-lite-promote.sh — strict 3-arm promote decision from scorecard JSON files
# Usage: bash evals/analyze-lite-promote.sh <campaign_dir>
# Expects **/scorecard.json under campaign_dir with treatment + task_success (+ optional delivery_cost).
# Exit 0 always when analysis succeeds; promote flag is in promote-result.json.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"

DIR="${1:-}"
[ -d "${DIR}" ] || die "campaign dir required"

tmp=$(mktemp)
# shellcheck disable=SC2046
if ! find "${DIR}" -name 'scorecard.json' -type f | grep -q .; then
  rm -f "${tmp}"
  die "no scorecard.json under ${DIR}"
fi
# Collect into one JSON array
: > "${tmp}.list"
find "${DIR}" -name 'scorecard.json' -type f -print0 | while IFS= read -r -d '' f; do
  printf '%s\0' "${f}" >> "${tmp}.list"
done
# portable: jq -s from file list
arr_file="${tmp}.arr"
# shellcheck disable=SC2038
find "${DIR}" -name 'scorecard.json' -type f | while read -r f; do
  cat "${f}"
  printf '\n'
done | jq -s '.' > "${arr_file}"

result=$(jq -n --slurpfile rows "${arr_file}" '
  ($rows[0]) as $rows
  | def rate(arm):
      ([ $rows[] | select(.treatment == arm) | .task_success ] | map(select(. != null)) ) as $xs
      | if ($xs|length) == 0 then null
        else (($xs | map(tonumber) | add) / ($xs|length)) end;
  def medcost(arm):
      ([ $rows[] | select(.treatment == arm) | .delivery_cost ]
        | map(select(. != null and . != 0)) | sort) as $xs
      | if ($xs|length) == 0 then null
        elif ($xs|length) % 2 == 1 then $xs[(($xs|length)/2|floor)]
        else ($xs[($xs|length)/2 - 1] + $xs[($xs|length)/2]) / 2 end;
  ($rows | rate("baseline")) as $b
  | ($rows | rate("current")) as $c
  | ($rows | rate("candidate")) as $k
  | ($rows | medcost("current")) as $cc
  | ($rows | medcost("candidate")) as $kc
  | ($b != null and $c != null and $k != null) as $have_rates
  | ($have_rates and ($k >= $c) and ($k >= $b)) as $success_ok
  | (if $cc == null or $kc == null then true else ($kc <= ($cc * 1.25)) end) as $cost_ok
  | {
      n_scorecards: ($rows|length),
      pass_rate: {baseline: $b, current: $c, candidate: $k},
      median_delivery_cost: {current: $cc, candidate: $kc},
      success_pass: $success_ok,
      cost_pass: $cost_ok,
      promote: ($success_ok and $cost_ok),
      rule: "candidate_pass_rate >= current and >= baseline; cost omitted unless both medians present"
    }
')

out="${DIR}/promote-result.json"
printf '%s\n' "${result}" > "${out}"
rm -f "${tmp}" "${tmp}.list" "${arr_file}"
echo "PROMOTE_RESULT=${out}"
jq -r '"promote=" + (.promote|tostring) + " success_pass=" + (.success_pass|tostring) + " cost_pass=" + (.cost_pass|tostring)' "${out}"
