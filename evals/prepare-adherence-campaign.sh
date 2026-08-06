#!/usr/bin/env bash
# evals/prepare-adherence-campaign.sh — stub scorecards for 5 prompts × 3 arms
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"

CAMP="${1:-${ROOT}/evals/adherence/campaigns/wfa-lever-luna}"
mkdir -p "${CAMP}"
PROMPTS="${ROOT}/evals/adherence/prompts.json"

jq -r '.prompts[].id' "${PROMPTS}" | while IFS= read -r id; do
  for arm in baseline current candidate; do
    dir="${CAMP}/${id}/${arm}"
    mkdir -p "${dir}"
    sc="${dir}/scorecard.json"
    if [ -f "${sc}" ]; then
      continue
    fi
    jq -n \
      --arg id "${id}" \
      --arg arm "${arm}" \
      '{prompt_id:$id, treatment:$arm, task_success:null, score_override:null, notes:null, model:null}' \
      >"${sc}"
  done
done

info "stubs ready under ${CAMP} (15 scorecards)"
