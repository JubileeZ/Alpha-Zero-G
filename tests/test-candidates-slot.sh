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
if [ -d "${CAND_ROOT}/principles-v1" ]; then
  fail "principles-v1 pack must be cleared after promote" ""
else
  pass "no principles-v1 pack"
fi
if [ -e "${ROOT}/evals/stage-principles-v1-home.sh" ]; then
  fail "stage-principles-v1-home.sh must be removed" ""
else
  pass "principles-v1 stager gone"
fi
if [ -d "${CAND_ROOT}/principles-v2" ]; then
  fail "principles-v2 pack must be cleared after promote" ""
else
  pass "no principles-v2 pack"
fi
if [ -e "${ROOT}/evals/stage-principles-v2-home.sh" ]; then
  fail "stage-principles-v2-home.sh must be removed" ""
else
  pass "principles-v2 stager gone"
fi

section "2. default Process Gate pack empty"
if grep -F 'TRAP_CANDIDATE_PACK="${TRAP_CANDIDATE_PACK:-}"' "${ROOT}/evals/traps/run-process-gate.sh"; then
  pass "process-gate default pack empty"
else
  fail "process-gate still defaults to a pack id" ""
fi

section "3. promote docs"
assert_file_exists "ADR 0020" "${ROOT}/docs/adr/0020-promote-principles-treatment.md"
assert_file_exists "ADR 0021" "${ROOT}/docs/adr/0021-promote-principles-v2.md"
if grep -q 'azg setup' "${CAND_ROOT}/README.md" && grep -q 'TRAP_CANDIDATE_PACK' "${CAND_ROOT}/README.md"; then
  pass "README documents setup + Trap pack"
else
  fail "candidates README incomplete" ""
fi

section "4. generic pack dispatch kept"
if grep -q 'TRAP_CANDIDATE_PACK' "${ROOT}/evals/run-trap-cell.sh" \
  && grep -q 'stage-${PACK}-home.sh' "${ROOT}/evals/run-trap-cell.sh"; then
  pass "trap cell generic pack stager"
else
  fail "run-trap-cell missing generic pack dispatch" ""
fi

test_summary
