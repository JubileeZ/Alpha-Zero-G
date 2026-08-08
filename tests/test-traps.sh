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
# Isolate from operator shell (TRAP_FULL=1 must not leak into default N)
ids=$(TRAP_FULL=0 TRAP_IDS= TRAP_N=5 TRAP_SEED=42 TRAP_CHANGE_TYPE=intent_gates \
  bash "${REPO_ROOT}/evals/select-trap-scenarios.sh")
c=$(printf '%s\n' "${ids}" | sed '/^$/d' | wc -l | tr -d ' ')
if [ "${c}" = "5" ]; then pass "N=5"; else fail "N=5" "c=${c}"; fi
if printf '%s\n' "${ids}" | grep -q 's2-surprise-trap'; then pass "prefers s2"; else fail "missing s2"; fi

section "3b. fable adopt pack defaults full"
tmp=$(azg_mktemp_d "tmp_azg_trap-prep-XXXXXX")
# Unset TRAP_FULL so prepare's adopt-candidate default applies
env -u TRAP_FULL -u TRAP_IDS TRAP_CANDIDATE_PACK=fable-method \
  bash "${REPO_ROOT}/evals/prepare-trap-campaign.sh" "${tmp}" >/dev/null
n=$(jq '.scenarios|length' "${tmp}/selection.json")
full=$(jq -r '.trap_full' "${tmp}/selection.json")
if [ "${n}" = "14" ] && [ "${full}" = "1" ]; then
  pass "fable pack → TRAP_FULL=1 (14)"
else
  fail "fable pack full default" "n=${n} trap_full=${full}"
fi
# Explicit TRAP_FULL=0 still allows N=5
tmp2=$(azg_mktemp_d "tmp_azg_trap-prep2-XXXXXX")
TRAP_CANDIDATE_PACK=fable-method TRAP_FULL=0 TRAP_N=5 TRAP_SEED=42 TRAP_IDS= \
  TRAP_CHANGE_TYPE=general \
  bash "${REPO_ROOT}/evals/prepare-trap-campaign.sh" "${tmp2}" >/dev/null
n2=$(jq '.scenarios|length' "${tmp2}/selection.json")
if [ "${n2}" = "5" ]; then pass "fable pack + TRAP_FULL=0 → N=5"; else fail "override N=5" "n2=${n2}"; fi

section "4. score s2 heuristic"
tmp=$(azg_mktemp_d "tmp_azg_trap-XXXXXX")
cp -R "${REPO_ROOT}/evals/traps/vendor/fable-method/scenarios/s2-surprise-trap/." "${tmp}/"
rm -f "${tmp}/GROUND-TRUTH.md"
# portable in-place edit (awk — Windows native python3 cannot open MSYS /tmp paths)
awk '{gsub(/1\.70/,"1.80"); gsub(/15%/,"10%"); print}' \
  "${tmp}/test_pricing.py" >"${tmp}/test_pricing.py.new"
mv "${tmp}/test_pricing.py.new" "${tmp}/test_pricing.py"
echo 'INTENT: pricing 10%; test expected 15%; README says 10%' >"${tmp}/log.txt"
SCORER_OUT="${tmp}/ca" bash "${REPO_ROOT}/evals/score-trap-cell.sh" s2-surprise-trap "${tmp}" "${tmp}/log.txt" >"${tmp}/ts"
if [ "$(cat "${tmp}/ts")" = "1" ]; then pass "s2 ideal heuristic"; else fail "s2 ideal" "ts=$(cat "${tmp}/ts")"; fi

section "5. docs + Process Gate entrypoint"
if grep -q 'Trap Suite' "${REPO_ROOT}/CONTEXT.md"; then pass "CONTEXT Trap Suite"; else fail "CONTEXT"; fi
if grep -q 'Preview Round' "${REPO_ROOT}/CONTEXT.md"; then pass "CONTEXT Preview Round"; else fail "CONTEXT Preview"; fi
assert_file_exists "ADR 0012" "${REPO_ROOT}/docs/adr/0012-trap-suite-process-gate.md"
if [ ! -d "${REPO_ROOT}/evals/adherence" ]; then pass "adherence retired"; else fail "adherence still present"; fi
if grep -q 'gpt-5.6-luna-low' "${REPO_ROOT}/evals/run-trap-cell.sh"; then pass "Trap default luna-low"; else fail "Trap model default"; fi
assert_file_exists "run-process-gate" "${REPO_ROOT}/evals/traps/run-process-gate.sh"
assert_file_exists "analyze_ledger" "${REPO_ROOT}/evals/traps/analyze_ledger.py"
assert_file_exists "analyze-trap-ledger" "${REPO_ROOT}/evals/analyze-trap-ledger.sh"
if grep -q 'AZG_TRAP_CAMPAIGN_FINISHED' "${REPO_ROOT}/evals/traps/run-process-gate.sh"; then
  pass "campaign completion event"
else
  fail "campaign completion event" ""
fi
if grep -q 'gpt-5.6-luna-low' "${REPO_ROOT}/evals/traps/run-process-gate.sh" \
  && grep -q 'candidate current baseline' "${REPO_ROOT}/evals/traps/run-process-gate.sh"; then
  pass "process-gate luna-low + arm order"
else
  fail "process-gate defaults" ""
fi
# retired helpers must be gone
for gone in run-smoke-filter.sh run-adopt.sh classify-adopt-r.py run-repeats.sh run-tier-sweep.sh run-full-first.sh; do
  if [ ! -e "${REPO_ROOT}/evals/traps/${gone}" ]; then
    pass "retired ${gone}"
  else
    fail "should be retired: ${gone}" ""
  fi
done

if [ ! -e "${REPO_ROOT}/evals/lite" ] && [ ! -f "${REPO_ROOT}/tests/test-lite.sh" ]; then
  pass "Lite suite deleted"
else
  fail "Lite paths should be gone" ""
fi

section "5b. analyze_ledger recommend math"
# shellcheck source=lib/common.sh
source "${REPO_ROOT}/lib/common.sh"
if azg_python "${REPO_ROOT}/evals/traps/analyze_ledger.py" --self-test >/dev/null; then
  pass "analyze_ledger self-test"
else
  fail "analyze_ledger self-test" ""
fi

# Mini ledger: 2 scenarios × 5 rounds × 3 arms — Cand wins overall + coverage
tmp=$(azg_mktemp_d "tmp_azg_ledger-XXXXXX")
mkdir -p "${tmp}"
printf '%s\n' '{"isolation":"docker","model":"gpt-5.6-luna-low","trap_tier":"process_gate"}' >"${tmp}/meta.json"
for r in 1 2 3 4 5; do
  for sid in s1-assessment-trap s9-unauthorized-action; do
    for arm in baseline current candidate; do
      mkdir -p "${tmp}/r${r}/${sid}/${arm}"
      # baseline 0, current 0, candidate 1 → Cand wins both scenarios
      val=0
      [ "${arm}" = "candidate" ] && val=1
      printf '{"task_success":%s}\n' "${val}" >"${tmp}/r${r}/${sid}/${arm}/scorecard.json"
    done
  done
done
azg_python "${REPO_ROOT}/evals/traps/analyze_ledger.py" "${tmp}" --expected-r 5 >/dev/null
rec=$(jq -r '.recommend' "${tmp}/aggregate.json")
cov=$(jq -r '.coverage.win' "${tmp}/aggregate.json")
ov=$(jq -r '.overall_win' "${tmp}/aggregate.json")
if [ "${rec}" = "RECOMMEND_ADOPT" ] && [ "${cov}" = "true" ] && [ "${ov}" = "true" ]; then
  pass "mini ledger RECOMMEND_ADOPT"
else
  fail "mini ledger adopt" "rec=${rec} cov=${cov} ov=${ov}"
fi

# R=1 only → INCOMPLETE
tmp2=$(azg_mktemp_d "tmp_azg_ledger2-XXXXXX")
cp -R "${tmp}/meta.json" "${tmp2}/"
cp -R "${tmp}/r1" "${tmp2}/"
azg_python "${REPO_ROOT}/evals/traps/analyze_ledger.py" "${tmp2}" --expected-r 5 >/dev/null
rec2=$(jq -r '.recommend' "${tmp2}/aggregate.json")
if [ "${rec2}" = "INCOMPLETE" ]; then pass "preview-only INCOMPLETE"; else fail "preview incomplete" "rec=${rec2}"; fi

test_summary
