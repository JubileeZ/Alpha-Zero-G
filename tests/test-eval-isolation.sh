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
if [ "${c}" = "1" ]; then pass "executor isolated (no LLM-judge call)"; else fail "isolated runner call sites" "c=${c}"; fi

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

section "5. fake HOME staging (device-core)"
assert_file_exists "stage-eval-home.sh" "${ROOT}/evals/stage-eval-home.sh"
if grep -q -- '--home' "${ROOT}/evals/run-agent-isolated.sh"; then pass "isolated runner accepts --home"; else fail "missing --home" ""; fi
if grep -q 'stage-eval-home' "${ROOT}/evals/run-trap-cell.sh"; then pass "trap cell stages eval home"; else fail "trap cell missing stage-eval-home" ""; fi
# Current/Candidate must not worktree-inject azg rules (Baseline never did)
if grep -q 'inject_azg_ref' "${ROOT}/evals/run-trap-cell.sh"; then
  fail "worktree inject_azg_ref must be removed (fake HOME replaces it)" ""
else
  pass "no worktree inject_azg_ref"
fi

home_tmp=$(azg_mktemp_d "tmp_azg_home-XXXXXX")
ref="$(git -C "${ROOT}" rev-parse HEAD)"
if bash "${ROOT}/evals/stage-eval-home.sh" "${ref}" "${home_tmp}/staged" >/dev/null; then
  pass "stage-eval-home exits 0"
else
  fail "stage-eval-home failed" ""
fi
staged="${home_tmp}/staged"
if [ -f "${staged}/.cursor/rules/azg-agent-instructions.mdc" ]; then
  pass "staged azg-agent-instructions.mdc"
else
  fail "missing azg-agent-instructions.mdc" ""
fi
if [ -f "${staged}/.cursor/rules/azg-ponytail.mdc" ]; then
  fail "staged home must not include azg-ponytail.mdc" ""
else
  pass "no staged azg-ponytail.mdc"
fi
for sk in azg-domain-research azg-domain-data-analysis azg-method-refs; do
  if [ -f "${staged}/.cursor/skills/${sk}/SKILL.md" ]; then
    fail "clean slate must not stage skill ${sk}" ""
  else
    pass "skill ${sk} not staged"
  fi
done
if grep -q 'alwaysApply: true' "${staged}/.cursor/rules/azg-agent-instructions.mdc" \
  && grep -q 'Execution Protocol v1' "${staged}/.cursor/rules/azg-agent-instructions.mdc" \
  && grep -q 'Telegraphic Writing Style' "${staged}/.cursor/rules/azg-agent-instructions.mdc" \
  && grep -q 'Temporary File Cleanup' "${staged}/.cursor/rules/azg-agent-instructions.mdc" \
  && grep -qF 'INTENT:' "${staged}/.cursor/rules/azg-agent-instructions.mdc" \
  && ! grep -qE 'Intent gates|Prove stance|PONYTAIL|lazy senior' "${staged}/.cursor/rules/azg-agent-instructions.mdc"; then
  pass "agent-instructions ep-v1 body staged"
else
  fail "agent-instructions body unexpected" ""
fi
# idempotent restage
bash "${ROOT}/evals/stage-eval-home.sh" "${ref}" "${staged}" >/dev/null
if [ -f "${staged}/.azg-eval-home-ref" ] && grep -q "${ref}" "${staged}/.azg-eval-home-ref"; then
  pass "home ref marker"
else
  fail "home ref marker" ""
fi

# Baseline path never stages/mounts Eval Device Home
bl="$(awk '/baseline\)/{f=1;next} f&&/current\)/{exit} f' "${ROOT}/evals/run-trap-cell.sh")"
if echo "${bl}" | grep -qE 'stage-eval-home|EVAL_HOME='; then
  fail "baseline must not stage EVAL_HOME" ""
else
  pass "baseline omits Eval Device Home"
fi
if grep -q '\.cursor/rules:/home/azg-eval/.cursor/rules:ro' "${ROOT}/evals/run-agent-isolated.sh"; then
  pass "rules mount is :ro"
else
  fail "rules mount should be :ro" ""
fi
if grep -q '\.cursor/rules' "${ROOT}/evals/run-agent-isolated.sh"; then
  pass "mounts staged .cursor/rules"
else
  fail "runner should mount staged rules dir" ""
fi
# no vendor tree in staged home
if [ -d "${staged}/.cursor/skills/vendor" ] || [ -d "${staged}/skills/vendor" ]; then
  fail "staged home must not include vendor skills" ""
else
  pass "no vendor skills in staged home"
fi

if grep -q '^\*\*Eval Device Home\*\*:' "${ROOT}/CONTEXT.md"; then pass "CONTEXT Eval Device Home"; else fail "CONTEXT Eval Device Home" ""; fi

test_summary
