#!/usr/bin/env bash
# Launch full Trap Suite adopt-candidate gate (durable — real terminal / setsid).
# Default Candidate = upstream fable-method pack; Current = azg Eval Device Home.
# Usage: bash evals/traps/run-full-first.sh [--force] [--resume]
# Default: resume (skip cells with task_success set). --force re-runs all.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${ROOT}"
export PATH="${HOME}/.local/bin:${PATH}"
export TRAP_FULL=1
export TRAP_MODEL="${TRAP_MODEL:-gpt-5.6-luna-medium}"
# Device Home–era camp (pre-isolation fable-method-full is not comparable)
export TRAP_CAMP="${TRAP_CAMP:-${ROOT}/evals/traps/campaigns/fable-method-device-home}"
export AZG_CURRENT_REF="${AZG_CURRENT_REF:-87b4eda}"
export TRAP_CANDIDATE_PACK="${TRAP_CANDIDATE_PACK:-fable-method}"
export AZG_CANDIDATE_REF="${AZG_CANDIDATE_REF:-HEAD}"
export TRAP_JOBS="${TRAP_JOBS:-12}"
export AZG_EVAL_DOCKER="${AZG_EVAL_DOCKER:-1}"

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
