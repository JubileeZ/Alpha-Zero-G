#!/usr/bin/env bash
# evals/run-trap-campaign.sh [--jobs N] [--arm ARM] [--force]
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"

FORCE=0
ONLY_ARM=""
JOBS="${TRAP_JOBS:-12}"
while [ $# -gt 0 ]; do
  case "$1" in
    --force) FORCE=1; shift ;;
    --arm) ONLY_ARM="$2"; shift 2 ;;
    --jobs) JOBS="$2"; shift 2 ;;
    *) die "unknown arg: $1" ;;
  esac
done

CAMP="${TRAP_CAMP:-${ROOT}/evals/traps/campaigns/default}"
mkdir -p "${CAMP}"
CAMP="$(cd "${CAMP}" && pwd)"
[ -f "${CAMP}/selection.json" ] || die "missing ${CAMP}/selection.json — run prepare-trap-campaign.sh"
LOGDIR="${CAMP}/cell-logs"
mkdir -p "${LOGDIR}"

ARMS="baseline current candidate"
[ -n "${ONLY_ARM}" ] && ARMS="${ONLY_ARM}"

info "trap campaign jobs=${JOBS} model=${TRAP_MODEL:-gpt-5.6-luna-low} camp=${CAMP}"

run_one() {
  local id="$1" arm="$2"
  local log="${LOGDIR}/${id}__${arm}.log"
  local args=("${id}" "${arm}")
  [ "${FORCE}" -eq 1 ] && args+=(--force)
  if bash "${ROOT}/evals/run-trap-cell.sh" "${args[@]}" >"${log}" 2>&1; then
    echo "ok ${id}/${arm}"
  else
    echo "FAIL ${id}/${arm} (see ${log})" >&2
    return 1
  fi
}

list="$(mktemp)"
trap 'rm -f "${list}"' EXIT
jq -r '.scenarios[]' "${CAMP}/selection.json" | while IFS= read -r id; do
  for arm in ${ARMS}; do
    echo "${id} ${arm}"
  done
done >"${list}"

fail=0
pids=()
flush_batch() {
  local pid wec=0
  for pid in "${pids[@]+"${pids[@]}"}"; do
    set +e
    wait "${pid}"
    wec=$?
    set -e
    [ "${wec}" -eq 0 ] || fail=1
  done
  pids=()
}

while IFS= read -r line; do
  id="${line%% *}"
  arm="${line#* }"
  # stdin must not be the scenario list FD — background cells would consume it (early EOF)
  run_one "${id}" "${arm}" </dev/null &
  pids+=("$!")
  if [ "${#pids[@]}" -ge "${JOBS}" ]; then
    flush_batch
  fi
done <"${list}"
flush_batch

bash "${ROOT}/evals/analyze-trap.sh" "${CAMP}" || true
[ "${fail}" -eq 0 ] || warn "some cells failed — see ${LOGDIR}"
info "trap campaign finished"
