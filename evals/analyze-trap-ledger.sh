#!/usr/bin/env bash
# evals/analyze-trap-ledger.sh <parent_camp>
# Aggregate Adopt Ledger r1..rN → LEDGER.md + aggregate.json + recommend.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"

PARENT="${1:-}"
[ -n "${PARENT}" ] || die "usage: analyze-trap-ledger.sh <parent_camp>"
[ -d "${PARENT}" ] || die "missing ${PARENT}"

azg_python "${ROOT}/evals/traps/analyze_ledger.py" "${PARENT}" \
  --last-gate "${ROOT}/evals/traps/LAST-GATE.md" \
  --analyze-sh "${ROOT}/evals/analyze-trap.sh" \
  --expected-r "${TRAP_EXPECTED_R:-5}"

info "ledger → ${PARENT}/LEDGER.md"
info "ledger → ${ROOT}/evals/traps/LAST-GATE.md"
