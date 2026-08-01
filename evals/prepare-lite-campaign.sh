#!/usr/bin/env bash
# evals/prepare-lite-campaign.sh — stub scorecards for frozen Lite N×3 into a portable campaign dir
# Usage: bash evals/prepare-lite-campaign.sh [campaign_dir]
# Default: evals/lite/campaigns/adr0009-YYYYMMDD (UTC date). Leaves task_success null.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"

stamp="$(date -u +%Y%m%d 2>/dev/null || date +%Y%m%d)"
CAMP="${1:-${ROOT}/evals/lite/campaigns/adr0009-${stamp}}"
INST_FILE="${ROOT}/evals/lite/instances.json"

[ -f "${INST_FILE}" ] || die "missing ${INST_FILE}"
mkdir -p "${CAMP}"

count=0
while IFS= read -r id || [ -n "${id}" ]; do
  id="${id%$'\r'}"
  [ -n "${id}" ] || continue
  for arm in baseline current candidate; do
    out="$(bash "${ROOT}/evals/run-lite-arm.sh" "${id}" "${arm}")"
    wd="$(printf '%s\n' "${out}" | sed -n 's/^WORKDIR=//p' | tail -1)"
    sc="$(printf '%s\n' "${out}" | sed -n 's/^SCORECARD=//p' | tail -1)"
    [ -n "${wd}" ] && [ -f "${sc}" ] || die "run-lite-arm failed for ${id} ${arm}: ${out}"
    dest="${CAMP}/${id}/${arm}"
    mkdir -p "${dest}"
    cp "${sc}" "${dest}/scorecard.json"
    # shellcheck disable=SC2086
    for f in INSTANCE.txt ARM.txt BASELINE.txt CANDIDATE.md; do
      [ -f "${wd}/${f}" ] && cp "${wd}/${f}" "${dest}/"
    done
    ts="$(jq -r '.task_success' "${dest}/scorecard.json")"
    [ "${ts}" = "null" ] || die "refusing non-null task_success in ${dest}/scorecard.json"
    count=$((count + 1))
  done
done < <(jq -r '.instance_ids[]' "${INST_FILE}")

ok "Lite campaign prepared (${count} scorecards)"
echo "CAMP=${CAMP}"
echo "SCORECARD_COUNT=${count}"
