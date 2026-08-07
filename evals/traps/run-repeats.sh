#!/usr/bin/env bash
# evals/traps/run-repeats.sh — R full Trap Suite loops, then majority aggregate.
# Usage: bash evals/traps/run-repeats.sh [--force]
# Env: TRAP_REPEATS (default 3), TRAP_CAMP (parent dir), TRAP_MODEL, TRAP_CANDIDATE_PACK, …
# Durable: run via setsid; each repeat is a child camp under $TRAP_CAMP/rN.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${ROOT}"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"

export PATH="${HOME}/.local/bin:${PATH}"
REPEATS="${TRAP_REPEATS:-3}"
export TRAP_FULL="${TRAP_FULL:-1}"
export TRAP_MODEL="${TRAP_MODEL:-gpt-5.6-luna-medium}"
export TRAP_JOBS="${TRAP_JOBS:-12}"
export AZG_CURRENT_REF="${AZG_CURRENT_REF:-87b4eda}"
export TRAP_CANDIDATE_PACK="${TRAP_CANDIDATE_PACK:-fable-method}"
export AZG_CANDIDATE_REF="${AZG_CANDIDATE_REF:-HEAD}"
export AZG_EVAL_DOCKER="${AZG_EVAL_DOCKER:-1}"
PARENT="${TRAP_CAMP:-${ROOT}/evals/traps/campaigns/fable-medium-r${REPEATS}}"

FORCE_FLAG=""
for a in "$@"; do
  case "$a" in
    --force) FORCE_FLAG=--force ;;
  esac
done

mkdir -p "${PARENT}"
{
  echo "{"
  echo "  \"trap_repeats\": ${REPEATS},"
  echo "  \"model\": \"${TRAP_MODEL}\","
  echo "  \"candidate_pack\": \"${TRAP_CANDIDATE_PACK}\","
  echo "  \"current_ref\": \"${AZG_CURRENT_REF}\","
  echo "  \"isolation\": \"docker\","
  echo "  \"trap_full\": 1"
  echo "}"
} >"${PARENT}/meta.json"

echo $$ >"${PARENT}/campaign.pid"
info "trap repeats=${REPEATS} model=${TRAP_MODEL} parent=${PARENT}"

i=1
while [ "${i}" -le "${REPEATS}" ]; do
  export TRAP_CAMP="${PARENT}/r${i}"
  info "=== repeat ${i}/${REPEATS} camp=${TRAP_CAMP} ==="
  bash "${ROOT}/evals/prepare-trap-campaign.sh" "${TRAP_CAMP}"
  # shellcheck disable=SC2086
  bash "${ROOT}/evals/run-trap-campaign.sh" --jobs "${TRAP_JOBS}" ${FORCE_FLAG}
  i=$((i + 1))
done

bash "${ROOT}/evals/analyze-trap-repeats.sh" "${PARENT}"
info "trap repeats finished → ${PARENT}/AGGREGATE.md"
rm -f "${PARENT}/campaign.pid"
