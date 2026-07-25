#!/usr/bin/env bash
# tests/test-phase8.sh — TDD suite for Phase 8: update and uninstall

set -uo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/harness.sh"

TEMP_HOME="$(azg_mktemp_d "tmp_azg_phase8-home-XXXXXX")"
TEMP_REPO="$(azg_mktemp_d "tmp_azg_phase8-repo-XXXXXX")"
UPSTREAM_REPO="$(azg_mktemp_d "tmp_azg_phase8-upstream-XXXXXX")"

section "1. azg update — runs git pull on AZG_ROOT"

# Setup fake upstream
cd "${UPSTREAM_REPO}"
git init -q
git config user.name "Test"
git config user.email "test@example.com"
tar -cf - --exclude=.git --exclude='tmp_azg*' -C "${REPO_ROOT}" . | tar -xf - -C "${UPSTREAM_REPO}"
git add .
git commit -q -m "Initial commit"
cd "${REPO_ROOT}"

rm -rf "${TEMP_REPO}"
git clone -q --no-local "${UPSTREAM_REPO}" "${TEMP_REPO}"
git -C "${TEMP_REPO}" config user.name "Test"
git -C "${TEMP_REPO}" config user.email "test@example.com"

# Make upstream have a new commit
cd "${UPSTREAM_REPO}"
echo "NEW_FILE" > test_update_file.txt
git add test_update_file.txt
git commit -q -m "New file"
cd "${REPO_ROOT}"

TEMP_AZG="${TEMP_REPO}/azg"

assert_exit "azg update exits 0" 0 env HOME="${TEMP_HOME}" AZG_ROOT="${TEMP_REPO}" "${TEMP_AZG}" update
if [ -f "${TEMP_REPO}/test_update_file.txt" ]; then
  pass "azg update pulled upstream commits"
else
  fail "azg update failed to pull upstream commits"
fi

section "2. azg uninstall — removes ~/.gemini/antigravity-cli/"

# Populate via setup
env HOME="${TEMP_HOME}" AZG_ROOT="${TEMP_REPO}" "${TEMP_AZG}" setup >/dev/null 2>&1
if [ ! -d "${TEMP_HOME}/.gemini/antigravity-cli" ]; then
  fail "Setup failed to create dir"
fi

assert_exit "azg uninstall exits 0" 0 env HOME="${TEMP_HOME}" AZG_ROOT="${TEMP_REPO}" "${TEMP_AZG}" uninstall

assert_dir_not_exists "uninstall removes ~/.gemini/antigravity-cli/" "${TEMP_HOME}/.gemini/antigravity-cli"
assert_dir_not_exists "uninstall removes ~/.gemini/config/skills/" "${TEMP_HOME}/.gemini/config/skills"
assert_file_not_exists "uninstall removes ~/.gemini/config/mcp_config.json" "${TEMP_HOME}/.gemini/config/mcp_config.json"
if [ -d "${TEMP_HOME}/.gemini" ]; then
  pass "uninstall leaves ~/.gemini untouched"
else
  fail "uninstall should not remove ~/.gemini itself"
fi

# Try running uninstall again (idempotent)
assert_output_contains "uninstall output mentions already removed or removed" "emove" env HOME="${TEMP_HOME}" AZG_ROOT="${TEMP_REPO}" "${TEMP_AZG}" uninstall

section "3. uninstall preserves foreign MCP and custom skills"

TEMP_HOME2="$(azg_mktemp_d "tmp_azg_phase8-home2-XXXXXX")"
mkdir -p "${TEMP_HOME2}/.gemini/config/skills/my-custom"
echo "# custom" > "${TEMP_HOME2}/.gemini/config/skills/my-custom/SKILL.md"
mkdir -p "${TEMP_HOME2}/.gemini/config"
printf '%s\n' '{"mcpServers":{"keep-me":{}}}' > "${TEMP_HOME2}/.gemini/config/mcp_config.json"
printf '%s\n' '# my agents' > "${TEMP_HOME2}/.gemini/config/AGENTS.md"

# Setup should not clobber foreign MCP/AGENTS; should install azg dir + skills
env HOME="${TEMP_HOME2}" AZG_ROOT="${TEMP_REPO}" "${TEMP_AZG}" setup >/dev/null 2>&1 || true

if grep -q 'keep-me' "${TEMP_HOME2}/.gemini/config/mcp_config.json" 2>/dev/null; then
  pass "setup left foreign mcp_config.json intact"
else
  fail "setup overwrote foreign mcp_config.json"
fi
if [ -f "${TEMP_HOME2}/.gemini/config/skills/my-custom/SKILL.md" ]; then
  pass "setup left custom skill intact"
else
  fail "setup removed custom skill"
fi

env HOME="${TEMP_HOME2}" AZG_ROOT="${TEMP_REPO}" "${TEMP_AZG}" uninstall >/dev/null 2>&1

if [ -f "${TEMP_HOME2}/.gemini/config/mcp_config.json" ] && grep -q 'keep-me' "${TEMP_HOME2}/.gemini/config/mcp_config.json"; then
  pass "uninstall left foreign mcp_config.json"
else
  fail "uninstall removed foreign mcp_config.json"
fi
if [ -f "${TEMP_HOME2}/.gemini/config/skills/my-custom/SKILL.md" ]; then
  pass "uninstall left custom skill"
else
  fail "uninstall removed custom skill"
fi
if [ -f "${TEMP_HOME2}/.gemini/config/AGENTS.md" ] && grep -q 'my agents' "${TEMP_HOME2}/.gemini/config/AGENTS.md"; then
  pass "uninstall left foreign AGENTS.md"
else
  fail "uninstall removed foreign AGENTS.md"
fi
if [ ! -d "${TEMP_HOME2}/.gemini/antigravity-cli" ]; then
  pass "uninstall still removes azg antigravity-cli dir"
else
  fail "uninstall left antigravity-cli"
fi

test_summary
