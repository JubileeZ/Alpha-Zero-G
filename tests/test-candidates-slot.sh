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

section "4. principles-v1 pack"
PACK="${CAND_ROOT}/principles-v1"
assert_file_exists "principles AGENTS" "${PACK}/AGENTS.md"
assert_file_exists "principles stub" "${PACK}/cursor/rules/azg-agent-instructions.mdc"
assert_file_exists "principles NOTICE" "${PACK}/NOTICE"
assert_file_exists "data-analysis skill" "${PACK}/skills/azg-domain-data-analysis/SKILL.md"
assert_file_exists "research skill" "${PACK}/skills/azg-domain-research/SKILL.md"
assert_file_exists "principles stager" "${ROOT}/evals/stage-principles-v1-home.sh"
if grep -q 'TRAP_CANDIDATE_PACK' "${ROOT}/evals/run-trap-cell.sh" \
  && grep -q 'stage-${PACK}-home.sh' "${ROOT}/evals/run-trap-cell.sh"; then
  pass "trap cell generic pack stager"
else
  fail "run-trap-cell missing generic pack dispatch" ""
fi

home_tmp=$(azg_mktemp_d "tmp_azg_pv1-XXXXXX")
if bash "${ROOT}/evals/stage-principles-v1-home.sh" "${home_tmp}/staged" >/dev/null; then
  pass "stage-principles-v1-home exits 0"
else
  fail "stage-principles-v1-home failed" ""
fi
staged="${home_tmp}/staged"
mdc="${staged}/.cursor/rules/azg-agent-instructions.mdc"
if [ -f "${mdc}" ] && grep -q 'Principles Treatment' "${mdc}" \
  && grep -q 'Twin Sweep' "${mdc}" \
  && grep -q 'Intent Tie' "${mdc}" \
  && grep -q 'azg-domain-data-analysis' "${mdc}" \
  && ! grep -qF 'INTENT:' "${mdc}" \
  && ! grep -qE 'Follow literally|Step 0|lazy senior|PONYTAIL' "${mdc}"; then
  pass "staged principles body"
else
  fail "staged principles body unexpected" ""
fi
for sk in azg-domain-data-analysis azg-domain-research; do
  if [ -f "${staged}/.cursor/skills/${sk}/SKILL.md" ] \
    && [ -f "${staged}/.agents/skills/${sk}/SKILL.md" ]; then
    pass "staged skill ${sk}"
  else
    fail "missing staged skill ${sk}" ""
  fi
done
if [ -f "${staged}/.cursor/rules/azg-ponytail.mdc" ]; then
  fail "principles home must not include azg-ponytail.mdc" ""
else
  pass "no ponytail in principles home"
fi

test_summary
