#!/usr/bin/env bash
# tests/test-phase2.sh — TDD suite for Phase 2: Hooks
#
# Run from repo root:  bash tests/test-phase2.sh
#
# Exit code: 0 if all tests pass, 1 if any fail.

set -uo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/harness.sh"

TEMP_WORKSPACE="$(azg_mktemp_d "tmp_azg_phase2-workspace-XXXXXX")"
TEMP_HOME="$(azg_mktemp_d "tmp_azg_phase2-home-XXXXXX")"

export HOME="${TEMP_HOME}"
export AZG_ROOT="${REPO_ROOT}"
export GIT_TERMINAL_PROMPT=0
export GIT_AUTHOR_NAME="Test User"
export GIT_AUTHOR_EMAIL="test@example.com"
export GIT_COMMITTER_NAME="Test User"
export GIT_COMMITTER_EMAIL="test@example.com"

# ---------------------------------------------------------------------------
# Setup & Scaffolding Check
# ---------------------------------------------------------------------------
section "1. Scaffolding Hooks & Rules"

APP_DIR="${TEMP_WORKSPACE}/my-app"
_scaffold_exit=0
"${AZG_ROOT}/azg" new "${APP_DIR}" --no-git --tracker github >/dev/null 2>&1 || _scaffold_exit=$?

if [ "${_scaffold_exit}" -eq 0 ]; then
  pass "azg new executes successfully"
else
  fail "azg new failed with exit code ${_scaffold_exit}"
  exit 1
fi

assert_dir_exists "App directory exists" "${APP_DIR}"
assert_dir_exists ".agents/hooks directory exists" "${APP_DIR}/.agents/hooks"
assert_dir_exists ".cursor/rules directory exists" "${APP_DIR}/.cursor/rules"

assert_file_exists "hooks.json exists" "${APP_DIR}/.agents/hooks.json"
assert_file_exists "block-destructive-ops.sh exists" "${APP_DIR}/.agents/hooks/block-destructive-ops.sh"
assert_file_exists "commit-scan.sh exists" "${APP_DIR}/.agents/hooks/commit-scan.sh"
assert_file_exists "Cursor block-destructive-ops adapter exists" \
  "${APP_DIR}/.cursor/hooks/block-destructive-ops.sh"
assert_file_contains "Cursor hooks.json wires safety adapter" \
  "${APP_DIR}/.cursor/hooks.json" "block-destructive-ops"
assert_file_not_exists "spawn-budget.sh retired (ADR 0011)" \
  "${APP_DIR}/.agents/hooks/spawn-budget.sh"
assert_file_not_exists "checkpoint.sh retired (Stop hook gone)" \
  "${APP_DIR}/.agents/hooks/checkpoint.sh"
assert_file_not_exists "checkpoint-scan.sh retired" \
  "${APP_DIR}/.agents/hooks/checkpoint-scan.sh"
assert_file_not_exists "pre-compact.sh retired" \
  "${APP_DIR}/.agents/hooks/pre-compact.sh"
assert_file_not_exists "stop-checkpoint.sh retired" \
  "${APP_DIR}/.cursor/hooks/stop-checkpoint.sh"
assert_file_not_exists "Cursor pre-compact.sh retired" \
  "${APP_DIR}/.cursor/hooks/pre-compact.sh"
assert_file_not_contains "agy hooks.json has no Stop" \
  "${APP_DIR}/.agents/hooks.json" '"Stop"'
assert_file_not_contains "agy hooks.json has no PreCompact" \
  "${APP_DIR}/.agents/hooks.json" '"PreCompact"'
assert_file_not_contains "Cursor hooks.json has no stop" \
  "${APP_DIR}/.cursor/hooks.json" '"stop"'
assert_file_not_contains "Cursor hooks.json has no preCompact" \
  "${APP_DIR}/.cursor/hooks.json" '"preCompact"'

assert_file_exists "read-agents-md.mdc rule exists" "${APP_DIR}/.cursor/rules/read-agents-md.mdc"
assert_file_not_exists "work-state-continuity.mdc retired (Session start in AGENTS.md)" \
  "${APP_DIR}/.cursor/rules/work-state-continuity.mdc"
assert_file_exists "progress-updates.mdc rule exists" "${APP_DIR}/.cursor/rules/progress-updates.mdc"
assert_file_contains "progress-updates rule is agent-requestable" "${APP_DIR}/.cursor/rules/progress-updates.mdc" "alwaysApply: false"
assert_file_exists "progress-updates skill exists" "${APP_DIR}/.agents/skills/progress-updates/SKILL.md"
assert_file_not_exists "domain-vocabulary.mdc retired (consumer = docs/agents/domain.md)" \
  "${APP_DIR}/.cursor/rules/domain-vocabulary.mdc"
assert_dir_not_exists "domain-vocabulary skill retired" \
  "${APP_DIR}/.agents/skills/domain-vocabulary"
assert_file_exists "Cursor hooks.json exists" "${APP_DIR}/.cursor/hooks.json"
assert_file_exists "Cursor commit-verify hook exists" "${APP_DIR}/.cursor/hooks/commit-verify.sh"
assert_file_exists "Cursor run-hook.cmd exists" "${APP_DIR}/.cursor/hooks/run-hook.cmd"

# Executable checks
for h in block-destructive-ops.sh commit-gate.sh commit-scan.sh; do
  if [ -x "${APP_DIR}/.agents/hooks/${h}" ]; then
    pass "Hook ${h} is executable"
  else
    fail "Hook ${h} is NOT executable"
  fi
done

# ---------------------------------------------------------------------------
# Shellcheck Checks
# ---------------------------------------------------------------------------
section "2. Shellcheck Validation"

if command -v shellcheck >/dev/null 2>&1; then
  _sc_exit=0
  # Match run-all: warnings/info (SC2034 unused stdin drain, SC2016 quoted regex) are not gate
  shellcheck -S error "${APP_DIR}/.agents/hooks"/*.sh || _sc_exit=$?
  if [ "${_sc_exit}" -eq 0 ]; then
    pass "All hook scripts pass shellcheck linting"
  else
    fail "One or more hooks failed shellcheck"
  fi
else
  echo "  – Shellcheck not installed (skipping lint check)"
fi

# ---------------------------------------------------------------------------
# commit-gate.sh Integration Tests
# ---------------------------------------------------------------------------
section "3. commit-gate.sh Tests"

COMMIT_GATE="${APP_DIR}/.agents/hooks/commit-gate.sh"
cd "${APP_DIR}"

# Mock git commit payload
commit_json='{"toolCall":{"name":"run_command","args":{"CommandLine":"git commit -m \"chore: some work\""}},"session_id":"test-session"}'
# Mock git status payload
status_json='{"toolCall":{"name":"run_command","args":{"CommandLine":"git status"}},"session_id":"test-session"}'

# Test 1: For non-commit command, it should immediately allow
out_status=$(echo "${status_json}" | "${COMMIT_GATE}")
dec_status=$(echo "${out_status}" | jq -r '.decision')
if [ "${dec_status}" = "allow" ]; then
  pass "Allows non-commit commands immediately"
else
  fail "Blocked non-commit command" "got: ${out_status}"
fi

# Test 2: For git commit command, portable gate passing
# Make sure the portable gate passes
out_commit=$(echo "${commit_json}" | "${COMMIT_GATE}")
dec_commit=$(echo "${out_commit}" | jq -r '.decision')
if [ "${dec_commit}" = "allow" ]; then
  pass "Allows commit when verify passes"
else
  fail "Blocked commit when verify passes" "got: ${out_commit}"
fi

# Test 3: For git commit command, portable gate failing
# DESTRUCTIVE: remove required file in temp scaffold to fail verify
rm -f AGENTS.md
out_commit_fail=$(echo "${commit_json}" | "${COMMIT_GATE}")
dec_commit_fail=$(echo "${out_commit_fail}" | jq -r '.decision')
if [ "${dec_commit_fail}" = "deny" ]; then
  pass "Denies commit when verify fails"
else
  fail "Allowed commit when verify fails" "got: ${out_commit_fail}"
fi
# Restore workspace integrity for other tests
cp "${REPO_ROOT}/templates/project/AGENTS.md.tmpl" AGENTS.md

# Test 4: Project tests override
# Configure a passing project test script
mkdir -p tests
printf '#!/usr/bin/env bash\nexit 0\n' > tests/project-tests.sh
chmod +x tests/project-tests.sh

out_proj_pass=$(echo "${commit_json}" | "${COMMIT_GATE}")
dec_proj_pass=$(echo "${out_proj_pass}" | jq -r '.decision')
if [ "${dec_proj_pass}" = "allow" ]; then
  pass "Allows commit when configured project-tests.sh passes"
else
  fail "Blocked commit when project-tests.sh passes" "got: ${out_proj_pass}"
fi

# Configure a failing project test script
printf '#!/usr/bin/env bash\necho "Custom error msg"\nexit 1\n' > tests/project-tests.sh
out_proj_fail=$(echo "${commit_json}" | "${COMMIT_GATE}")
dec_proj_fail=$(echo "${out_proj_fail}" | jq -r '.decision')
if [ "${dec_proj_fail}" = "deny" ] && echo "${out_proj_fail}" | grep -q "Custom error msg"; then
  pass "Denies commit and includes custom error message when project-tests.sh fails"
else
  fail "Did not behave correctly on project-tests.sh failure" "got: ${out_proj_fail}"
fi

# DESTRUCTIVE: remove temporary project test from isolated scaffold
rm -f tests/project-tests.sh

# ---------------------------------------------------------------------------
# Stop / PreCompact retired
# ---------------------------------------------------------------------------
section "4. Stop and PreCompact retired"

assert_file_not_exists "no checkpoint.sh after scaffold" \
  "${APP_DIR}/.agents/hooks/checkpoint.sh"
assert_file_not_exists "no stop-checkpoint.sh after scaffold" \
  "${APP_DIR}/.cursor/hooks/stop-checkpoint.sh"
assert_file_not_exists "no agy pre-compact.sh after scaffold" \
  "${APP_DIR}/.agents/hooks/pre-compact.sh"
assert_file_not_exists "no Cursor pre-compact.sh after scaffold" \
  "${APP_DIR}/.cursor/hooks/pre-compact.sh"

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
test_summary
