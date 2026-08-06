#!/usr/bin/env bash
# tests/test-traps.sh — structural Trap Suite checks (ADR 0012)
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/harness.sh"

section "1. vendor corpus"
assert_file_exists "s2 vendored" "${REPO_ROOT}/evals/traps/vendor/fable-method/scenarios/s2-surprise-trap/GROUND-TRUTH.md"
assert_file_exists "NOTICE" "${REPO_ROOT}/evals/traps/vendor/fable-method/NOTICE"
assert_file_exists "VENDOR.lock" "${REPO_ROOT}/evals/traps/vendor/fable-method/VENDOR.lock"
n=$(ls "${REPO_ROOT}/evals/traps/vendor/fable-method/scenarios" | wc -l | tr -d ' ')
if [ "${n}" = "14" ]; then pass "14 scenarios"; else fail "expected 14 scenarios" "n=${n}"; fi

section "2. select full"
ids=$(TRAP_FULL=1 bash "${REPO_ROOT}/evals/select-trap-scenarios.sh" | wc -l | tr -d ' ')
if [ "${ids}" = "14" ]; then pass "TRAP_FULL=1 → 14"; else fail "TRAP_FULL count" "ids=${ids}"; fi

section "3. select N=5"
ids=$(TRAP_N=5 TRAP_SEED=42 TRAP_CHANGE_TYPE=intent_gates bash "${REPO_ROOT}/evals/select-trap-scenarios.sh")
c=$(printf '%s\n' "${ids}" | sed '/^$/d' | wc -l | tr -d ' ')
if [ "${c}" = "5" ]; then pass "N=5"; else fail "N=5" "c=${c}"; fi
if printf '%s\n' "${ids}" | grep -q 's2-surprise-trap'; then pass "prefers s2"; else fail "missing s2"; fi

section "4. score s2 heuristic"
tmp=$(azg_mktemp_d "tmp_azg_trap-XXXXXX")
cp -R "${REPO_ROOT}/evals/traps/vendor/fable-method/scenarios/s2-surprise-trap/." "${tmp}/"
rm -f "${tmp}/GROUND-TRUTH.md"
# portable in-place edit
python3 -c "
p='${tmp}/test_pricing.py'
t=open(p).read().replace('1.70','1.80').replace('15%','10%')
open(p,'w').write(t)
"
echo 'INTENT: pricing 10%; test expected 15%; README says 10%' >"${tmp}/log.txt"
SCORER_OUT="${tmp}/ca" bash "${REPO_ROOT}/evals/score-trap-cell.sh" s2-surprise-trap "${tmp}" "${tmp}/log.txt" >"${tmp}/ts"
if [ "$(cat "${tmp}/ts")" = "1" ]; then pass "s2 ideal heuristic"; else fail "s2 ideal" "ts=$(cat "${tmp}/ts")"; fi

section "5. docs + retirement"
if grep -q 'Trap Suite' "${REPO_ROOT}/CONTEXT.md"; then pass "CONTEXT Trap Suite"; else fail "CONTEXT"; fi
assert_file_exists "ADR 0012" "${REPO_ROOT}/docs/adr/0012-trap-suite-process-gate.md"
if [ ! -d "${REPO_ROOT}/evals/adherence" ]; then pass "adherence retired"; else fail "adherence still present"; fi
if grep -q 'gpt-5.6-luna-medium' "${REPO_ROOT}/evals/run-lite-composer-cell.sh"; then pass "Lite default luna-medium"; else fail "Lite model default"; fi

test_summary
