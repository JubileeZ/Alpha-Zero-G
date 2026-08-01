#!/usr/bin/env bash
# evals/run-lite-composer-campaign.sh — parallel Composer 2.5 Lite cells
# Isolation (no mix): each cell = worktrees/cells/<instance>/<arm>/
#   baseline  → no azg apply (hard-fail if harness files appear)
#   current   → apply from azg@fef3e84 only (into that worktree)
#   candidate → apply from azg@d2df37f only (into that worktree)
# No global azg setup while parallel (avoids ~/.cursor bleed across arms).
#
# Usage:
#   bash evals/run-lite-composer-campaign.sh [--score] [--jobs N] [--arm ARM] [--force]
# Env: LITE_JOBS (default 6)

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"

SCORE=0
FORCE=0
ONLY_ARM=""
JOBS="${LITE_JOBS:-6}"
while [ $# -gt 0 ]; do
  case "$1" in
    --score) SCORE=1; shift ;;
    --force) FORCE=1; shift ;;
    --arm) ONLY_ARM="$2"; shift 2 ;;
    --jobs) JOBS="$2"; shift 2 ;;
    --from) shift 2 ;; # compat no-op
    *) die "unknown arg: $1" ;;
  esac
done

CAMP="${LITE_CAMP:-${ROOT}/evals/lite/campaigns/adr0009-20260801-n5}"
WT="${ROOT}/evals/lite/worktrees"
LOGDIR="${CAMP}/cell-logs"
mkdir -p "${WT}" "${LOGDIR}"

ensure_azg_wt() {
  local arm="$1" ref="$2"
  local dest="${WT}/azg-${arm}"
  if [ ! -e "${dest}/.git" ]; then
    git -C "${ROOT}" worktree add --detach "${dest}" "${ref}"
  else
    git -C "${dest}" checkout -f "${ref}"
  fi
  local got want
  got="$(git -C "${dest}" rev-parse HEAD)"
  want="$(git -C "${ROOT}" rev-parse "${ref}^{commit}")"
  [ "${got}" = "${want}" ] || die "azg-${arm} HEAD mismatch (${got} != ${want})"
  info "azg-${arm} ready @ ${ref}"
}

mapfile -t IDS < <(jq -r '.instance_ids[]' "${ROOT}/evals/lite/instances.json")
ARMS=(baseline current candidate)
if [ -n "${ONLY_ARM}" ]; then
  ARMS=("${ONLY_ARM}")
fi

for arm in "${ARMS[@]}"; do
  case "${arm}" in
    current) ensure_azg_wt current fef3e84 ;;
    candidate) ensure_azg_wt candidate d2df37f ;;
  esac
done

info "Parallel: jobs=${JOBS} score=${SCORE} model=${LITE_MODEL:-composer-2.5}"
info "No-mix: per-cell worktrees; baseline≠harness; current/candidate apply from separate azg checkouts"

run_cell() {
  local id="$1" arm="$2"
  local sc="${CAMP}/${id}/${arm}/scorecard.json"
  local log="${LOGDIR}/${id}__${arm}.log"
  if [ "${FORCE}" -eq 0 ] && [ -f "${sc}" ] && [ "$(jq -r '.task_success' "${sc}")" != "null" ]; then
    echo "[azg] skip ${id}/${arm}"
    return 0
  fi
  local args=("${id}" "${arm}")
  [ "${SCORE}" -eq 1 ] && args+=(--score)
  [ "${FORCE}" -eq 1 ] && args+=(--force)
  echo "[azg] START ${id}/${arm}"
  if bash "${ROOT}/evals/run-lite-composer-cell.sh" "${args[@]}" >"${log}" 2>&1; then
    echo "[azg] DONE  ${id}/${arm}"
    return 0
  fi
  echo "[azg] FAIL  ${id}/${arm} → ${log}"
  # Leave task_success null on infra failure so --force / retry can redo
  return 1
}

FAILS=0
for arm in "${ARMS[@]}"; do
  for id in "${IDS[@]}"; do
    while [ "$(jobs -rp | wc -l)" -ge "${JOBS}" ]; do
      wait -n 2>/dev/null || wait "$(jobs -rp | head -1)" || true
    done
    run_cell "${id}" "${arm}" &
  done
done
# Drain
for pid in $(jobs -rp); do
  if ! wait "${pid}"; then
    FAILS=$((FAILS + 1))
  fi
done

info "Scoreboard:"
find "${CAMP}" -name scorecard.json \
  -exec jq -r '[.fixture_id,.treatment,.task_success] | @tsv' {} \; | sort

nulls="$(find "${CAMP}" -name scorecard.json -exec jq -r 'select(.task_success==null)|[.fixture_id,.treatment]|join("/")' {} \; | wc -l)"
info "nulls=${nulls} fails=${FAILS}"
[ "${FAILS}" -eq 0 ] && [ "${nulls}" -eq 0 ] || { warn "incomplete"; exit 1; }
ok "Parallel campaign complete"
