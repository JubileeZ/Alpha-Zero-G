#!/usr/bin/env bash
# tests/test-intent-gates-candidate.sh — structural checks for Process Gate Candidate
# (authority conflict · Reversible Default / Unattended · twin-sweep). Concept prose only.
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/harness.sh"

AGENTS="${REPO_ROOT}/templates/global/AGENTS.md"
REFS="${REPO_ROOT}/templates/global/skills/azg/azg-method-refs/SKILL.md"
CTX="${REPO_ROOT}/CONTEXT.md"

extract_instructions() {
  awk '/<!-- AZG:AGENT-INSTRUCTIONS:START -->/{f=1; next} /<!-- AZG:AGENT-INSTRUCTIONS:END -->/{f=0; next} f' "${AGENTS}"
}

section "1. always-on Candidate concepts"
INST="$(extract_instructions)"
if printf '%s\n' "${INST}" | grep -q 'Reversible Default'; then pass "Reversible Default"; else fail "missing Reversible Default" ""; fi
if printf '%s\n' "${INST}" | grep -q 'Unattended'; then pass "Unattended"; else fail "missing Unattended" ""; fi
if printf '%s\n' "${INST}" | grep -qi 'losing side'; then pass "authority losing side"; else fail "missing losing side" ""; fi
if printf '%s\n' "${INST}" | grep -qi 'same construct'; then pass "TWINS same construct"; else fail "missing same construct" ""; fi
# D/Q9 sharpen: thin always-on completion bars + Q6 tie leading words
if printf '%s\n' "${INST}" | grep -qi 'Impl-Equivalent Default'; then pass "Impl-Equivalent Default pointer"; else fail "missing Impl-Equivalent Default" ""; fi
if printf '%s\n' "${INST}" | grep -q 'Intent Tie'; then pass "Intent Tie pointer"; else fail "missing Intent Tie" ""; fi
if printf '%s\n' "${INST}" | grep -qi 'which side lost'; then pass "INTENT which side lost bar"; else fail "missing which side lost" ""; fi
if printf '%s\n' "${INST}" | grep -qiE 'fix(-| )or(-| )list|fixed or leave'; then pass "TWINS fix-or-list bar"; else fail "missing TWINS fix-or-list bar" ""; fi
# Anti-memorization: no Trap Suite scenario IDs in Candidate prose surfaces
for surf in "${AGENTS}" "${REFS}"; do
  if grep -Eiq 's[0-9]+-(surprise|ambiguous|twin-fleet|assessment)|GROUND-TRUTH' "${surf}"; then
    fail "fixture leak in $(basename "${surf}")" ""
  else
    pass "no trap fixture IDs in $(basename "${surf}")"
  fi
done
# always-on still names leading words (thin pointer OK)
if printf '%s\n' "${INST}" | grep -q 'Reversible Default'; then :; else fail "INST lost Reversible Default after thin" ""; fi

section "2. method-refs JIT depth"
assert_file_exists "azg-method-refs" "${REFS}"
if grep -q 'Reversible Default' "${REFS}"; then pass "refs Reversible Default"; else fail "refs missing Reversible Default" ""; fi
if grep -q 'Unattended' "${REFS}"; then pass "refs Unattended"; else fail "refs missing Unattended" ""; fi
if grep -qi 'same construct' "${REFS}"; then pass "refs same construct"; else fail "refs missing same construct" ""; fi
if grep -qi 'losing side' "${REFS}"; then pass "refs losing side"; else fail "refs missing losing side" ""; fi
if grep -q 'Impl-Equivalent Default' "${REFS}"; then pass "refs Impl-Equivalent Default"; else fail "refs missing Impl-Equivalent Default" ""; fi
if grep -q 'Intent Tie' "${REFS}"; then pass "refs Intent Tie"; else fail "refs missing Intent Tie" ""; fi

section "3. glossary"
if grep -q '^\*\*Reversible Default\*\*:' "${CTX}"; then pass "CONTEXT Reversible Default"; else fail "CONTEXT Reversible Default" ""; fi
if grep -q '^\*\*Unattended Session\*\*:' "${CTX}"; then pass "CONTEXT Unattended Session"; else fail "CONTEXT Unattended Session" ""; fi
if grep -q '^\*\*Twin Sweep\*\*:' "${CTX}"; then pass "CONTEXT Twin Sweep"; else fail "CONTEXT Twin Sweep" ""; fi
if grep -q '^\*\*Impl-Equivalent Default\*\*:' "${CTX}"; then pass "CONTEXT Impl-Equivalent Default"; else fail "CONTEXT Impl-Equivalent Default" ""; fi
if grep -q '^\*\*Intent Tie\*\*:' "${CTX}"; then pass "CONTEXT Intent Tie"; else fail "CONTEXT Intent Tie" ""; fi

test_summary
