#!/usr/bin/env bash
set -uo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/harness.sh"

run_test() {
  local name="$1"
  local cmd="$2"
  if eval "$cmd"; then
    pass "$name"
  else
    fail "$name"
  fi
}

# Test 1: Templates exist
run_test "AGENTS.md.tmpl exists" "[ -f \"$REPO_ROOT/templates/project/AGENTS.md.tmpl\" ]"
run_test "ROADMAP.md.tmpl exists" "[ -f \"$REPO_ROOT/templates/project/ROADMAP.md.tmpl\" ]"
run_test "current-state.md.tmpl exists" "[ -f \"$REPO_ROOT/templates/project/docs/agents/current-state.md.tmpl\" ]"
run_test "progress.md.tmpl exists" "[ -f \"$REPO_ROOT/templates/project/docs/agents/progress.md.tmpl\" ]"

# Test 2: Templates contain expected placeholders
run_test "AGENTS.md.tmpl has {{PROJECT_NAME}}" "grep -q '{{PROJECT_NAME}}' \"$REPO_ROOT/templates/project/AGENTS.md.tmpl\""
run_test "AGENTS.md.tmpl has {{BUILD_COMMANDS}}" "grep -q '{{BUILD_COMMANDS}}' \"$REPO_ROOT/templates/project/AGENTS.md.tmpl\""
run_test "ROADMAP.md.tmpl has {{PROJECT_NAME}}" "grep -q '{{PROJECT_NAME}}' \"$REPO_ROOT/templates/project/ROADMAP.md.tmpl\""
run_test "current-state.md.tmpl has {{BUILD_COMMANDS}}" "grep -q '{{BUILD_COMMANDS}}' \"$REPO_ROOT/templates/project/docs/agents/current-state.md.tmpl\""

# Test 3: Hook Integration Tests in isolated environment
TEMP_TEST_DIR="$(azg_mktemp_d "tmp_azg_phase5-XXXXXX")"

cd "${TEMP_TEST_DIR}"
mkdir -p .agents/hooks tests
cp "$REPO_ROOT/templates/project/.agents/hooks/commit-gate.sh" .agents/hooks/

# commit-gate testing (uses portable tests/verify.sh)
# 1. Success case: verify returns 0
printf '#!/usr/bin/env bash\nexit 0\n' > tests/verify.sh
chmod +x tests/verify.sh

_res_allow=$(echo '{"toolCall":{"name":"run_command","args":{"CommandLine":"git commit -m \"feat: foo\""}}}' | bash .agents/hooks/commit-gate.sh)
if echo "${_res_allow}" | grep -qE '"decision"[[:space:]]*:[[:space:]]*"allow"'; then
  pass "commit-gate allows commit when verify.sh passes"
else
  fail "commit-gate denied commit unexpectedly" "got: ${_res_allow}"
fi

# 2. Failure case: verify returns 1
printf '#!/usr/bin/env bash\necho "Lint error"\nexit 1\n' > tests/verify.sh
_res_deny=$(echo '{"toolCall":{"name":"run_command","args":{"CommandLine":"git commit -m \"feat: foo\""}}}' | bash .agents/hooks/commit-gate.sh)
if echo "${_res_deny}" | grep -qE '"decision"[[:space:]]*:[[:space:]]*"deny"' && echo "${_res_deny}" | grep -q "Lint error"; then
  pass "commit-gate denies commit and shows verify output when verify.sh fails"
else
  fail "commit-gate failed to deny commit or output error" "got: ${_res_deny}"
fi

# Reset verify to pass for subsequent cleanup tests
printf '#!/usr/bin/env bash\nexit 0\n' > tests/verify.sh

# 3. Cleanup case: finished Work Packet still on disk → deny
mkdir -p .agents/work-packets
echo "- [x] task 1" > .agents/work-packets/done.md
_res_cleanup_deny=$(echo '{"toolCall":{"name":"run_command","args":{"CommandLine":"git commit -m \"feat: foo\""}}}' | bash .agents/hooks/commit-gate.sh)
if echo "${_res_cleanup_deny}" | grep -qE '"decision"[[:space:]]*:[[:space:]]*"deny"' && echo "${_res_cleanup_deny}" | grep -q "Finished Work Packet"; then
  pass "commit-gate denies commit when finished Work Packet remains"
else
  fail "commit-gate failed to deny commit when finished packet remains" "got: ${_res_cleanup_deny}"
fi

# 4. Cleanup case: open Work Packet with unchecked items → allow (no git)
echo "- [ ] task 1" > .agents/work-packets/done.md
_res_cleanup_allow=$(echo '{"toolCall":{"name":"run_command","args":{"CommandLine":"git commit -m \"feat: foo\""}}}' | bash .agents/hooks/commit-gate.sh)
if echo "${_res_cleanup_allow}" | grep -qE '"decision"[[:space:]]*:[[:space:]]*"allow"'; then
  pass "commit-gate allows commit when Work Packet is in progress"
else
  fail "commit-gate denied commit when packet in-progress" "got: ${_res_cleanup_allow}"
fi

# Clean up files created for testing
rm -rf .agents/work-packets

test_summary

