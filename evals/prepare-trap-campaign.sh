#!/usr/bin/env bash
# evals/prepare-trap-campaign.sh [campaign_dir]
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"

CAMP="${1:-${ROOT}/evals/traps/campaigns/default}"
mkdir -p "${CAMP}"

# Adopt candidate (upstream fable pack): full corpus unless TRAP_FULL or TRAP_IDS set.
# Empty TRAP_FULL counts as unset (Windows env -u / blank export quirks).
if [ "${TRAP_CANDIDATE_PACK:-}" = "fable-method" ] && [ -z "${TRAP_FULL:-}" ] && [ -z "${TRAP_IDS:-}" ]; then
  export TRAP_FULL=1
  info "TRAP_CANDIDATE_PACK=fable-method → default TRAP_FULL=1 (override: TRAP_FULL=0)"
fi

# stable seed for this prepare (select reads TRAP_SEED)
if [ -z "${TRAP_SEED:-}" ] && [ "${TRAP_FULL:-0}" != "1" ]; then
  export TRAP_SEED
  TRAP_SEED="$(date +%s)"
fi

LIST="$(mktemp)"
trap 'rm -f "${LIST}"' EXIT
bash "${ROOT}/evals/select-trap-scenarios.sh" >"${LIST}"

# record selection + Eval Isolation (ADR 0013)
ISOLATION=docker
case "${AZG_EVAL_DOCKER:-1}" in
  0|false|FALSE|no|NO|off|OFF) ISOLATION=host ;;
esac

# jq build — strip CR; avoid hand-echo JSON (Windows control-char failures)
SCENARIOS_JSON="$(awk '{ sub(/\r$/, ""); if (NF) print }' "${LIST}" | jq -R -s -c 'split("\n") | map(select(length>0))')"
[ "$(jq 'length' <<<"${SCENARIOS_JSON}")" -gt 0 ] || die "select-trap-scenarios returned no IDs"
jq -n \
  --argjson trap_full "${TRAP_FULL:-0}" \
  --argjson trap_n "${TRAP_N:-5}" \
  --arg trap_change_type "${TRAP_CHANGE_TYPE:-general}" \
  --arg trap_seed "${TRAP_SEED:-}" \
  --arg model_default "${TRAP_MODEL:-gpt-5.6-luna-xhigh}" \
  --arg isolation "${ISOLATION}" \
  --arg candidate_pack "${TRAP_CANDIDATE_PACK:-}" \
  --arg current_ref "${AZG_CURRENT_REF:-87b4eda}" \
  --argjson scenarios "${SCENARIOS_JSON}" \
  '{
    trap_full: $trap_full,
    trap_n: $trap_n,
    trap_change_type: $trap_change_type,
    trap_seed: $trap_seed,
    model_default: $model_default,
    isolation: $isolation,
    candidate_pack: $candidate_pack,
    current_ref: $current_ref,
    scenarios: $scenarios
  }' >"${CAMP}/selection.json"

while IFS= read -r id; do
  id="${id%$'\r'}"
  [ -n "${id}" ] || continue
  for arm in baseline current candidate; do
    dir="${CAMP}/${id}/${arm}"
    mkdir -p "${dir}"
    sc="${dir}/scorecard.json"
    if [ -f "${sc}" ]; then
      continue
    fi
    jq -n --arg id "${id}" --arg arm "${arm}" \
      '{scenario_id:$id, treatment:$arm, task_success:null, score_override:null, correct_action:null, notes:null, model:null}' \
      >"${sc}"
  done
done <"${LIST}"

info "trap stubs ready under ${CAMP} ($(jq '.scenarios|length' "${CAMP}/selection.json") scenarios × 3)"
