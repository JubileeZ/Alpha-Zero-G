#!/usr/bin/env bash
# evals/run-lite-arm.sh — prepare a Lite instance workdir for one treatment arm
# Usage: bash evals/run-lite-arm.sh <instance_id> <baseline|current|candidate>

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"

INSTANCE="${1:-}"
ARM="${2:-}"

if [ -z "${INSTANCE}" ] || [ -z "${ARM}" ]; then
  die "usage: run-lite-arm.sh <instance_id> <baseline|current|candidate>"
fi

case "${ARM}" in
  baseline|current|candidate) ;;
  *) die "arm must be baseline|current|candidate" ;;
esac

INST_FILE="${ROOT}/evals/lite/instances.json"
if ! jq -e --arg id "${INSTANCE}" '.instance_ids | index($id) != null' "${INST_FILE}" >/dev/null; then
  die "instance_id not in frozen lite list: ${INSTANCE}"
fi

stamp="$(date -u +%Y%m%dT%H%M%SZ 2>/dev/null || date +%Y%m%d%H%M%S)"
workdir="${TMPDIR:-/tmp}/azg-lite-${INSTANCE//\//_}-${ARM}-${stamp}"
mkdir -p "${workdir}"

cp "${ROOT}/evals/lite/scorecard.json.tmpl" "${workdir}/scorecard.json"
tmp="${workdir}/scorecard.json.azg.tmp"
jq --arg id "${INSTANCE}" --arg arm "${ARM}" \
  '.fixture_id = $id | .treatment = $arm | .task_success = null | .delivery_cost = null' \
  "${workdir}/scorecard.json" > "${tmp}" && mv "${tmp}" "${workdir}/scorecard.json"

printf 'INSTANCE=%s\n' "${INSTANCE}" > "${workdir}/INSTANCE.txt"
printf 'ARM=%s\n' "${ARM}" > "${workdir}/ARM.txt"

case "${ARM}" in
  current|candidate)
    # Apply harness into workdir copy of a stub project so agent has azg context.
    # ponytail: stub only — real SWE-bench repos come from external harness later.
    mkdir -p "${workdir}/project"
    if [ -x "${ROOT}/azg" ]; then
      "${ROOT}/azg" apply "${workdir}/project" --tracker none >/dev/null 2>&1 || \
        warn "azg apply skipped/failed in stub project (jq/agy optional for scaffold)"
    fi
    if [ "${ARM}" = "candidate" ]; then
      printf '%s\n' "candidate overlay: document proposed change in CANDIDATE.md" > "${workdir}/CANDIDATE.md"
    fi
    ;;
  baseline)
    mkdir -p "${workdir}/project"
    printf '%s\n' "baseline: no azg apply" > "${workdir}/BASELINE.txt"
    ;;
esac

ok "Lite arm prepared"
echo "WORKDIR=${workdir}"
echo "SCORECARD=${workdir}/scorecard.json"
