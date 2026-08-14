#!/usr/bin/env bash
# evals/score-trap-cell.sh <scenario_id> <fixture_dir> <agent.log>
# Prints task_success 0|1. Sets correct_action via SCORER_OUT (ADR 0019 Outcome scorer).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"
azg_python "${ROOT}/evals/traps/score_outcome.py" "${1:?}" "${2:?}" "${3:?}"
