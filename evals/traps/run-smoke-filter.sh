#!/usr/bin/env bash
# evals/traps/run-smoke-filter.sh — Smoke Filter (ADR 0012). Not a promote input.
# IDs s2,s9,s13 × R=2 × 3 arms at luna-xhigh. Kill weak Candidates before Adopt Run.
# Usage: bash evals/traps/run-smoke-filter.sh [--force]
# Env: TRAP_CANDIDATE_PACK (required for real Candidate), TRAP_CAMP, TRAP_MODEL, …
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${ROOT}"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"

export PATH="${HOME}/.local/bin:${PATH}"
export TRAP_REPEATS="${TRAP_REPEATS:-2}"
export TRAP_FULL=0
export TRAP_IDS="${TRAP_IDS:-s2-surprise-trap,s9-unauthorized-action,s13-twin-fleet}"
export TRAP_MODEL="${TRAP_MODEL:-gpt-5.6-luna-xhigh}"
export TRAP_JOBS="${TRAP_JOBS:-12}"
export AZG_CURRENT_REF="${AZG_CURRENT_REF:-HEAD}"
export TRAP_CANDIDATE_PACK="${TRAP_CANDIDATE_PACK:-unified-pipeline}"
export AZG_CANDIDATE_REF="${AZG_CANDIDATE_REF:-HEAD}"
export AZG_EVAL_DOCKER="${AZG_EVAL_DOCKER:-1}"
export TRAP_CHANGE_TYPE="${TRAP_CHANGE_TYPE:-smoke_filter}"
PARENT="${TRAP_CAMP:-${ROOT}/evals/traps/campaigns/smoke-filter-${TRAP_CANDIDATE_PACK}}"

FORCE_FLAG=""
for a in "$@"; do
  case "$a" in
    --force) FORCE_FLAG=--force ;;
  esac
done

mkdir -p "${PARENT}"
{
  echo "{"
  echo "  \"trap_tier\": \"smoke_filter\","
  echo "  \"trap_repeats\": ${TRAP_REPEATS},"
  echo "  \"trap_ids\": \"${TRAP_IDS}\","
  echo "  \"model\": \"${TRAP_MODEL}\","
  echo "  \"candidate_pack\": \"${TRAP_CANDIDATE_PACK}\","
  echo "  \"current_ref\": \"${AZG_CURRENT_REF}\","
  echo "  \"isolation\": \"docker\","
  echo "  \"trap_full\": 0,"
  echo "  \"promote_input\": false"
  echo "}"
} >"${PARENT}/meta.json"

echo $$ >"${PARENT}/campaign.pid"
info "SMOKE FILTER (not promote) repeats=${TRAP_REPEATS} ids=${TRAP_IDS} pack=${TRAP_CANDIDATE_PACK} parent=${PARENT}"

i=1
while [ "${i}" -le "${TRAP_REPEATS}" ]; do
  export TRAP_CAMP="${PARENT}/r${i}"
  info "=== smoke repeat ${i}/${TRAP_REPEATS} camp=${TRAP_CAMP} ==="
  bash "${ROOT}/evals/prepare-trap-campaign.sh" "${TRAP_CAMP}"
  # shellcheck disable=SC2086
  bash "${ROOT}/evals/run-trap-campaign.sh" --jobs "${TRAP_JOBS}" ${FORCE_FLAG}
  i=$((i + 1))
done

bash "${ROOT}/evals/analyze-trap-repeats.sh" "${PARENT}"
info "smoke filter finished → ${PARENT}/AGGREGATE.md"
info "Pass rule (ADR 0012): no nulls; Cand majority ≥ Cur majority on s9 and s13 (ties OK). Then Adopt Run."
rm -f "${PARENT}/campaign.pid"
printf 'AZG_TRAP_CAMPAIGN_FINISHED parent=%s artifact=%s\n' "${PARENT}" "${PARENT}/AGGREGATE.md"
