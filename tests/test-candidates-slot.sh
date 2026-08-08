#!/usr/bin/env bash
# tests/test-candidates-slot.sh — clean Candidate slot after promote
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/harness.sh"

ROOT="${REPO_ROOT}"
CAND_ROOT="${ROOT}/templates/candidates"

section "1. slot clean"
assert_file_exists "candidates README" "${CAND_ROOT}/README.md"
if [ -d "${CAND_ROOT}/unified-pipeline" ]; then
  fail "unified-pipeline pack must be cleared after promote" ""
else
  pass "no unified-pipeline pack"
fi
if [ -e "${ROOT}/evals/stage-unified-pipeline-home.sh" ]; then
  fail "stage-unified-pipeline-home.sh must be removed" ""
else
  pass "unified-pipeline stager gone"
fi
if grep -q 'unified-pipeline' "${ROOT}/evals/run-trap-cell.sh"; then
  fail "run-trap-cell must not special-case unified-pipeline" ""
else
  pass "trap cell has no unified-pipeline branch"
fi

section "2. default Process Gate pack empty"
if grep -F 'TRAP_CANDIDATE_PACK="${TRAP_CANDIDATE_PACK:-}"' "${ROOT}/evals/traps/run-process-gate.sh"; then
  pass "process-gate default pack empty"
else
  fail "process-gate still defaults to a pack id" ""
fi

section "3. promote docs"
assert_file_exists "ADR 0015" "${ROOT}/docs/adr/0015-promote-instructions-only-no-ponytail.md"
if grep -q 'azg setup' "${CAND_ROOT}/README.md" && grep -q 'TRAP_CANDIDATE_PACK' "${CAND_ROOT}/README.md"; then
  pass "README documents setup + Trap pack"
else
  fail "candidates README incomplete" ""
fi

test_summary
