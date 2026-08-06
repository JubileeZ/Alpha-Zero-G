#!/usr/bin/env bash
# evals/run-adherence-campaign.sh — parallel adherence cells
# Usage: bash evals/run-adherence-campaign.sh [--jobs N] [--arm ARM] [--force]
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"

FORCE=0
ONLY_ARM=""
JOBS="${ADHERENCE_JOBS:-3}"
while [ $# -gt 0 ]; do
  case "$1" in
    --force) FORCE=1; shift ;;
    --arm) ONLY_ARM="$2"; shift 2 ;;
    --jobs) JOBS="$2"; shift 2 ;;
    *) die "unknown arg: $1" ;;
  esac
done

CAMP="${ADHERENCE_CAMP:-${ROOT}/evals/adherence/campaigns/wfa-lever-luna}"
PROMPTS="${ROOT}/evals/adherence/prompts.json"
LOGDIR="${CAMP}/cell-logs"
mkdir -p "${LOGDIR}"
[ -d "${CAMP}" ] || die "missing campaign — run prepare-adherence-campaign.sh"

ARMS="baseline current candidate"
if [ -n "${ONLY_ARM}" ]; then
  ARMS="${ONLY_ARM}"
fi

info "adherence campaign jobs=${JOBS} model=${ADHERENCE_MODEL:-gpt-5.6-luna} camp=${CAMP}"

run_one() {
  local id="$1" arm="$2"
  local log="${LOGDIR}/${id}__${arm}.log"
  local args=("${id}" "${arm}")
  [ "${FORCE}" -eq 1 ] && args+=(--force)
  if bash "${ROOT}/evals/run-adherence-cell.sh" "${args[@]}" >"${log}" 2>&1; then
    echo "ok ${id}/${arm}"
  else
    echo "FAIL ${id}/${arm} (see ${log})" >&2
    return 1
  fi
}

# bash 3.2-safe sequential batches
fail=0
list="$(mktemp)"
trap 'rm -f "${list}"' EXIT
jq -r '.prompts[].id' "${PROMPTS}" | while IFS= read -r id; do
  for arm in ${ARMS}; do
    echo "${id} ${arm}"
  done
done >"${list}"

batch=0
while IFS= read -r line; do
  id="${line%% *}"
  arm="${line#* }"
  run_one "${id}" "${arm}" &
  batch=$((batch + 1))
  if [ "${batch}" -ge "${JOBS}" ]; then
    if ! wait; then fail=1; fi
    batch=0
  fi
done <"${list}"
if [ "${batch}" -gt 0 ]; then
  if ! wait; then fail=1; fi
fi

bash "${ROOT}/evals/analyze-adherence.sh" "${CAMP}" || true
[ "${fail}" -eq 0 ] || die "some cells failed — inspect ${LOGDIR}"
info "adherence campaign finished"
