#!/usr/bin/env bash
# Launch full Trap Suite first campaign (durable — run in a real terminal / setsid).
# Usage: bash evals/traps/run-full-first.sh [--force] [--resume]
# Default: resume (skip cells with task_success set). --force re-runs all.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${ROOT}"
export PATH="${HOME}/.local/bin:${PATH}"
export TRAP_FULL=1
export TRAP_MODEL="${TRAP_MODEL:-gpt-5.6-luna-low}"
export TRAP_CAMP="${TRAP_CAMP:-${ROOT}/evals/traps/campaigns/full-first}"
export AZG_CURRENT_REF="${AZG_CURRENT_REF:-87b4eda}"
export TRAP_CANDIDATE_PACK="${TRAP_CANDIDATE_PACK:-fable-method}"
export AZG_CANDIDATE_REF="${AZG_CANDIDATE_REF:-HEAD}"
export TRAP_JOBS="${TRAP_JOBS:-12}"

FORCE_FLAG=""
for a in "$@"; do
  case "$a" in
    --force) FORCE_FLAG=--force ;;
    --resume) FORCE_FLAG="" ;;
  esac
done

bash evals/prepare-trap-campaign.sh "${TRAP_CAMP}"
mkdir -p "${TRAP_CAMP}"
echo $$ >"${TRAP_CAMP}/campaign.pid"
# shellcheck disable=SC2086
exec bash evals/run-trap-campaign.sh --jobs "${TRAP_JOBS}" ${FORCE_FLAG}
