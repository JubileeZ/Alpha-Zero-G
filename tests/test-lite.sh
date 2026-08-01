#!/usr/bin/env bash
# tests/test-lite.sh — SWE-bench Lite 3-arm scaffold (ADR 0007)

set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/harness.sh"

section "1. Lite manifest"
assert_file_exists "instances.json" "${REPO_ROOT}/evals/lite/instances.json"
assert_file_exists "lite README" "${REPO_ROOT}/evals/lite/README.md"
assert_file_exists "lite CAMPAIGN" "${REPO_ROOT}/evals/lite/CAMPAIGN.md"
assert_file_exists "scorecard tmpl" "${REPO_ROOT}/evals/lite/scorecard.json.tmpl"
assert_file_executable "run-lite-arm.sh" "${REPO_ROOT}/evals/run-lite-arm.sh"
assert_file_executable "prepare-lite-campaign.sh" "${REPO_ROOT}/evals/prepare-lite-campaign.sh"
assert_file_executable "record-lite-score.sh" "${REPO_ROOT}/evals/record-lite-score.sh"
assert_file_executable "analyze-lite-promote.sh" "${REPO_ROOT}/evals/analyze-lite-promote.sh"

n=$(jq -r '.n' "${REPO_ROOT}/evals/lite/instances.json")
ids=$(jq -r '.instance_ids | length' "${REPO_ROOT}/evals/lite/instances.json")
if [ "${n}" = "10" ] && [ "${ids}" = "10" ]; then
  pass "frozen slice n=10"
else
  fail "expected n=10 instance_ids" "n=${n} ids=${ids}"
fi

section "2. run-lite-arm rejects unknown instance / arm"
assert_exit "unknown instance fails" 1 bash "${REPO_ROOT}/evals/run-lite-arm.sh" not-a-real-id baseline
assert_exit "bad arm fails" 1 bash "${REPO_ROOT}/evals/run-lite-arm.sh" django__django-11001 core

section "3. prepare arms + promote"
CAMP="$(azg_mktemp_d "tmp_azg_lite-XXXXXX")"
ID="django__django-11001"

for arm in baseline current candidate; do
  out=$(bash "${REPO_ROOT}/evals/run-lite-arm.sh" "${ID}" "${arm}" 2>&1) || true
  wd=$(echo "${out}" | sed -n 's/^WORKDIR=//p' | tail -1)
  if [ -z "${wd}" ] || [ ! -f "${wd}/scorecard.json" ]; then
    fail "run-lite-arm ${arm} missing workdir" "out=${out}"
    continue
  fi
  # success: candidate best
  case "${arm}" in
    baseline) bash "${REPO_ROOT}/evals/record-lite-score.sh" "${wd}/scorecard.json" --task-success 0 --delivery-cost 100 >/dev/null ;;
    current) bash "${REPO_ROOT}/evals/record-lite-score.sh" "${wd}/scorecard.json" --task-success 0 --delivery-cost 110 >/dev/null ;;
    candidate) bash "${REPO_ROOT}/evals/record-lite-score.sh" "${wd}/scorecard.json" --task-success 1 --delivery-cost 120 >/dev/null ;;
  esac
  mkdir -p "${CAMP}/${arm}"
  cp "${wd}/scorecard.json" "${CAMP}/${arm}/scorecard.json"
  pass "prepared ${arm} scorecard"
done

bash "${REPO_ROOT}/evals/analyze-lite-promote.sh" "${CAMP}" >/dev/null
if [ "$(jq -r '.promote' "${CAMP}/promote-result.json")" = "true" ]; then
  pass "promote true when candidate beats both on pass rate"
else
  fail "expected promote true" "$(cat "${CAMP}/promote-result.json")"
fi

# Fail case: candidate worse
CAMP2="$(azg_mktemp_d "tmp_azg_lite2-XXXXXX")"
for arm in baseline current candidate; do
  mkdir -p "${CAMP2}/${arm}"
  jq -n --arg arm "${arm}" \
    --argjson ts "$( [ "${arm}" = candidate ] && echo 0 || echo 1 )" \
    '{treatment:$arm, task_success:$ts, delivery_cost:null, fixture_id:"x"}' \
    > "${CAMP2}/${arm}/scorecard.json"
done
bash "${REPO_ROOT}/evals/analyze-lite-promote.sh" "${CAMP2}" >/dev/null
if [ "$(jq -r '.promote' "${CAMP2}/promote-result.json")" = "false" ]; then
  pass "promote false when candidate worse"
else
  fail "expected promote false" "$(cat "${CAMP2}/promote-result.json")"
fi

test_summary
