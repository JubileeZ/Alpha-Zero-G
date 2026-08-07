#!/usr/bin/env bash
# tests/test-eval-isolation.sh — Eval Isolation structural checks (ADR 0013)
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/harness.sh"

ROOT="${REPO_ROOT}"
section "1. artifacts"
assert_file_exists "Dockerfile" "${ROOT}/evals/docker/azg-eval-agent/Dockerfile"
assert_file_exists "VERSION" "${ROOT}/evals/docker/azg-eval-agent/VERSION"
assert_file_exists "build.sh" "${ROOT}/evals/docker/azg-eval-agent/build.sh"
assert_file_exists "run-agent-isolated.sh" "${ROOT}/evals/run-agent-isolated.sh"
assert_file_exists "ADR 0013" "${ROOT}/docs/adr/0013-eval-isolation-docker.md"
if grep -q '^\*\*Eval Isolation\*\*:' "${ROOT}/CONTEXT.md"; then pass "CONTEXT Eval Isolation"; else fail "CONTEXT" ""; fi

section "2. trap wiring"
if grep -q 'run-agent-isolated.sh' "${ROOT}/evals/run-trap-cell.sh"; then pass "trap cell uses isolated runner"; else fail "trap cell" ""; fi
c=$(grep -c 'run-agent-isolated.sh' "${ROOT}/evals/run-trap-cell.sh" || true)
if [ "${c}" -ge 2 ]; then pass "executor+judge both isolated (${c})"; else fail "need ≥2 call sites" "c=${c}"; fi

section "3. analyze refuses host promote"
tmp=$(azg_mktemp_d "tmp_azg_iso-XXXXXX")
mkdir -p "${tmp}/s1/baseline" "${tmp}/s1/current" "${tmp}/s1/candidate"
jq -n '{isolation:"host",scenarios:["s1"]}' >"${tmp}/selection.json"
for arm in baseline current candidate; do
  jq -n --arg a "$arm" '{scenario_id:"s1",treatment:$a,task_success:1,score_override:null,correct_action:null,notes:null,model:null}' \
    >"${tmp}/s1/${arm}/scorecard.json"
done
bash "${ROOT}/evals/analyze-trap.sh" "${tmp}" >/dev/null
pr=$(jq -r '.promote_process_gate' "${tmp}/promote-result.json")
blocked=$(jq -r '.promote_blocked_by_isolation' "${tmp}/promote-result.json")
iso=$(jq -r '.isolation' "${tmp}/promote-result.json")
if [ "${pr}" = "false" ] && [ "${blocked}" = "true" ] && [ "${iso}" = "host" ]; then
  pass "host isolation blocks promote"
else
  fail "host promote not blocked" "pr=${pr} blocked=${blocked} iso=${iso}"
fi

# docker isolation allows rate-based promote
jq -n '{isolation:"docker",scenarios:["s1"]}' >"${tmp}/selection.json"
bash "${ROOT}/evals/analyze-trap.sh" "${tmp}" >/dev/null
pr=$(jq -r '.promote_process_gate' "${tmp}/promote-result.json")
blocked=$(jq -r '.promote_blocked_by_isolation' "${tmp}/promote-result.json")
if [ "${pr}" = "true" ] && [ "${blocked}" = "false" ]; then
  pass "docker isolation allows promote"
else
  fail "docker promote" "pr=${pr} blocked=${blocked}"
fi

# incomplete campaign (nulls) must not promote
jq -n '{scenario_id:"s1",treatment:"baseline",task_success:null,score_override:null,correct_action:null,notes:null,model:null}' \
  >"${tmp}/s1/baseline/scorecard.json"
bash "${ROOT}/evals/analyze-trap.sh" "${tmp}" >/dev/null
pr=$(jq -r '.promote_process_gate' "${tmp}/promote-result.json")
note=$(jq -r '.note' "${tmp}/promote-result.json")
if [ "${pr}" = "false" ] && echo "${note}" | grep -qi 'Incomplete'; then
  pass "null scorecards block promote"
else
  fail "nulls should block promote" "pr=${pr} note=${note}"
fi
# restore filled baseline for cleanliness
jq -n '{scenario_id:"s1",treatment:"baseline",task_success:1,score_override:null,correct_action:null,notes:null,model:null}' \
  >"${tmp}/s1/baseline/scorecard.json"
section "4. Dockerfile never copies host .cursor"
if grep -Eiq 'COPY.*\.cursor|ADD.*\.cursor' "${ROOT}/evals/docker/azg-eval-agent/Dockerfile"; then
  fail "Dockerfile must not COPY host .cursor" ""
else
  pass "no .cursor COPY in Dockerfile"
fi

test_summary
