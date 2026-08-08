#!/usr/bin/env bash
# evals/traps/run-process-gate.sh — sole Process Gate entrypoint (ADR 0012).
# Preview Round (r1, full corpus) → show ledger → ask → Adopt Run r2..r5.
# Arm-serial: candidate → current → baseline; scenarios parallel within arm.
# Usage: bash evals/traps/run-process-gate.sh [--force] [--yes] [--preview-only] [--continue]
# Env: TRAP_CAMP, TRAP_MODEL (default gpt-5.6-luna-low), TRAP_JOBS, TRAP_CANDIDATE_PACK,
#      AZG_CURRENT_REF, AZG_CANDIDATE_REF, AZG_EVAL_DOCKER, TRAP_ADOPT_YES=1
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${ROOT}"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"

export PATH="${HOME}/.local/bin:${PATH}"
export TRAP_MODEL="${TRAP_MODEL:-gpt-5.6-luna-low}"
export TRAP_JOBS="${TRAP_JOBS:-14}"
export AZG_CURRENT_REF="${AZG_CURRENT_REF:-HEAD}"
export TRAP_CANDIDATE_PACK="${TRAP_CANDIDATE_PACK:-}"
export AZG_CANDIDATE_REF="${AZG_CANDIDATE_REF:-HEAD}"
export AZG_EVAL_DOCKER="${AZG_EVAL_DOCKER:-1}"
export TRAP_CHANGE_TYPE="${TRAP_CHANGE_TYPE:-process_gate}"
export TRAP_FULL=1
export TRAP_IDS="${TRAP_IDS:-}"
EXPECTED_R="${TRAP_EXPECTED_R:-5}"
PACK_LABEL="${TRAP_CANDIDATE_PACK:-current}"
PARENT="${TRAP_CAMP:-${ROOT}/evals/traps/campaigns/gate-${PACK_LABEL}}"

FORCE_FLAG=""
YES=0
PREVIEW_ONLY=0
CONTINUE=0
for a in "$@"; do
  case "$a" in
    --force) FORCE_FLAG=--force ;;
    --yes) YES=1 ;;
    --preview-only) PREVIEW_ONLY=1 ;;
    --continue) CONTINUE=1 ;;
  esac
done
[ "${TRAP_ADOPT_YES:-0}" = "1" ] && YES=1

mkdir -p "${PARENT}"
{
  echo "{"
  echo "  \"trap_tier\": \"process_gate\","
  echo "  \"promote_input\": true,"
  echo "  \"expected_r\": ${EXPECTED_R},"
  echo "  \"model\": \"${TRAP_MODEL}\","
  echo "  \"candidate_pack\": \"${TRAP_CANDIDATE_PACK}\","
  echo "  \"current_ref\": \"${AZG_CURRENT_REF}\","
  echo "  \"isolation\": \"docker\","
  echo "  \"arm_order\": [\"candidate\", \"current\", \"baseline\"],"
  echo "  \"trap_full\": 1"
  echo "}"
} >"${PARENT}/meta.json"

echo $$ >"${PARENT}/campaign.pid"
info "PROCESS GATE model=${TRAP_MODEL} pack=${PACK_LABEL} parent=${PARENT} expected_r=${EXPECTED_R}"

run_round() {
  local i="$1"
  export TRAP_CAMP="${PARENT}/r${i}"
  export TRAP_FULL=1
  info "=== ledger r${i}/${EXPECTED_R} camp=${TRAP_CAMP} ==="
  bash "${ROOT}/evals/prepare-trap-campaign.sh" "${TRAP_CAMP}"
  local arm
  for arm in candidate current baseline; do
    info "=== r${i} arm=${arm} (all scenarios, jobs=${TRAP_JOBS}) ==="
    # shellcheck disable=SC2086
    bash "${ROOT}/evals/run-trap-campaign.sh" --jobs "${TRAP_JOBS}" --arm "${arm}" ${FORCE_FLAG}
  done
}

# determine start round
start=1
if [ "${CONTINUE}" -eq 1 ]; then
  corpus_n="$(jq '.scenarios|length' "${ROOT}/evals/traps/corpus.json")"
  expect=$((corpus_n * 3))
  while [ "${start}" -le "${EXPECTED_R}" ] && [ -d "${PARENT}/r${start}" ]; do
    scored="$(find "${PARENT}/r${start}" -path '*/scorecard.json' 2>/dev/null | wc -l | tr -d ' ')"
    if [ "${scored}" -ge "${expect}" ]; then
      start=$((start + 1))
    else
      break
    fi
  done
  info "continue from r${start}"
fi

if [ "${start}" -eq 1 ]; then
  run_round 1
  TRAP_EXPECTED_R="${EXPECTED_R}" bash "${ROOT}/evals/analyze-trap-ledger.sh" "${PARENT}"
  info "Preview Round (r1) complete — see ${PARENT}/LEDGER.md"
  if [ "${PREVIEW_ONLY}" -eq 1 ]; then
    info "preview-only: stopping before Adopt Run"
    rm -f "${PARENT}/campaign.pid"
    printf 'AZG_TRAP_CAMPAIGN_FINISHED parent=%s artifact=%s phase=preview\n' "${PARENT}" "${PARENT}/LEDGER.md"
    exit 0
  fi
  if [ "${YES}" -ne 1 ]; then
    if [ ! -t 0 ]; then
      die "Preview done; non-interactive — re-run with --yes or TRAP_ADOPT_YES=1 to continue Adopt (r2–r${EXPECTED_R}), or --preview-only to stop"
    fi
    printf '\nRun Adopt (r2–r%s)? [y/N] ' "${EXPECTED_R}"
    read -r ans || ans=
    case "${ans}" in
      y|Y|yes|YES) ;;
      *)
        info "declined — Preview kept at ${PARENT}/r1 (resume with --continue --yes)"
        rm -f "${PARENT}/campaign.pid"
        printf 'AZG_TRAP_CAMPAIGN_FINISHED parent=%s artifact=%s phase=preview-declined\n' "${PARENT}" "${PARENT}/LEDGER.md"
        exit 0
        ;;
    esac
  fi
  start=2
fi

i="${start}"
while [ "${i}" -le "${EXPECTED_R}" ]; do
  run_round "${i}"
  i=$((i + 1))
done

TRAP_EXPECTED_R="${EXPECTED_R}" bash "${ROOT}/evals/analyze-trap-ledger.sh" "${PARENT}"
info "Process Gate finished → ${PARENT}/LEDGER.md"
rm -f "${PARENT}/campaign.pid"
printf 'AZG_TRAP_CAMPAIGN_FINISHED parent=%s artifact=%s\n' "${PARENT}" "${PARENT}/LEDGER.md"
