#!/usr/bin/env bash
# tests/test-cursor-device-setup.sh — Device Setup Cursor skills + azg-owned global rules
# Seams: azg setup / azg uninstall with mocked HOME (map #56)

set -uo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/harness.sh"

TEMP_HOME="$(azg_mktemp_d "tmp_azg_cursor-home-XXXXXX")"
# Use live repo as AZG_ROOT (no full-tree tar — was ~70s on Windows)
TEMP_REPO="${REPO_ROOT}"
TEMP_AZG="${TEMP_REPO}/azg"

# Pick one known vendored skill name (must exist in templates)
SAMPLE_SKILL=""
for candidate in tdd grilling implement ponytail; do
  if find "${TEMP_REPO}/templates/global/skills/vendor" -type d -name "${candidate}" 2>/dev/null | grep -q .; then
    SAMPLE_SKILL="${candidate}"
    break
  fi
done
if [ -z "${SAMPLE_SKILL}" ]; then
  fail "no sample vendor skill found under templates/global/skills/vendor"
  test_summary
  exit 1
fi

section "1. setup installs Cursor skill + AZG-OWNED.md; never skills-cursor"

# Foreign Cursor rule + foreign skill present before setup
mkdir -p "${TEMP_HOME}/.cursor/rules"
mkdir -p "${TEMP_HOME}/.cursor/skills/my-foreign-skill"
mkdir -p "${TEMP_HOME}/.cursor/skills-cursor/builtin-keep"
printf '%s\n' '# foreign user rule' > "${TEMP_HOME}/.cursor/rules/user-preference.mdc"
printf '%s\n' '# foreign skill' > "${TEMP_HOME}/.cursor/skills/my-foreign-skill/SKILL.md"
printf '%s\n' '# builtin' > "${TEMP_HOME}/.cursor/skills-cursor/builtin-keep/SKILL.md"

assert_exit "azg setup exits 0" 0 \
  env HOME="${TEMP_HOME}" AZG_ROOT="${TEMP_REPO}" "${TEMP_AZG}" setup

assert_file_exists "Cursor skill SKILL.md installed" \
  "${TEMP_HOME}/.cursor/skills/${SAMPLE_SKILL}/SKILL.md"
assert_file_exists "Cursor skill has AZG-OWNED.md sentinel" \
  "${TEMP_HOME}/.cursor/skills/${SAMPLE_SKILL}/AZG-OWNED.md"
assert_file_exists "azg-owned global rule installed" \
  "${TEMP_HOME}/.cursor/rules/azg-ponytail.mdc"
assert_file_exists "azg-owned agent-instructions rule installed" \
  "${TEMP_HOME}/.cursor/rules/azg-agent-instructions.mdc"

if grep -q 'alwaysApply:\s*true' "${TEMP_HOME}/.cursor/rules/azg-ponytail.mdc" 2>/dev/null; then
  pass "azg-ponytail.mdc is alwaysApply"
else
  fail "azg-ponytail.mdc missing alwaysApply: true"
fi

if grep -q 'Telegraphic Writing Style' "${TEMP_HOME}/.cursor/rules/azg-agent-instructions.mdc" 2>/dev/null; then
  pass "azg-agent-instructions.mdc mirrors global AGENTS.md agent instructions"
else
  fail "azg-agent-instructions.mdc missing telegraphic section"
fi

if [ -f "${TEMP_HOME}/.cursor/rules/user-preference.mdc" ] && grep -q 'foreign user rule' "${TEMP_HOME}/.cursor/rules/user-preference.mdc"; then
  pass "setup left foreign Cursor rule intact"
else
  fail "setup clobbered foreign ~/.cursor/rules/user-preference.mdc"
fi

if [ -f "${TEMP_HOME}/.cursor/skills/my-foreign-skill/SKILL.md" ]; then
  pass "setup left foreign Cursor skill intact"
else
  fail "setup removed foreign Cursor skill"
fi

if [ -f "${TEMP_HOME}/.cursor/skills-cursor/builtin-keep/SKILL.md" ]; then
  pass "setup never wrote into skills-cursor (builtin preserved)"
else
  fail "setup disturbed ~/.cursor/skills-cursor"
fi

# Ownership lists cursor assets
OWN="${TEMP_HOME}/.gemini/antigravity-cli/azg-ownership.json"
if [ -f "${OWN}" ] && jq -e --arg s "${SAMPLE_SKILL}" '(.cursor_skills // []) | index($s) != null' "${OWN}" >/dev/null; then
  pass "ownership lists cursor_skills entry for ${SAMPLE_SKILL}"
else
  fail "ownership missing cursor_skills for ${SAMPLE_SKILL}"
fi
if [ -f "${OWN}" ] && jq -e '(.cursor_rules // []) | index("azg-ponytail.mdc") != null' "${OWN}" >/dev/null; then
  pass "ownership lists cursor_rules azg-ponytail.mdc"
else
  fail "ownership missing cursor_rules azg-ponytail.mdc"
fi
if [ -f "${OWN}" ] && jq -e '(.cursor_rules // []) | index("azg-agent-instructions.mdc") != null' "${OWN}" >/dev/null; then
  pass "ownership lists cursor_rules azg-agent-instructions.mdc"
else
  fail "ownership missing cursor_rules azg-agent-instructions.mdc"
fi

section "2. uninstall removes owned Cursor assets only"

assert_exit "azg uninstall exits 0" 0 \
  env HOME="${TEMP_HOME}" AZG_ROOT="${TEMP_REPO}" "${TEMP_AZG}" uninstall

assert_file_not_exists "uninstall removed owned Cursor skill" \
  "${TEMP_HOME}/.cursor/skills/${SAMPLE_SKILL}/SKILL.md"
assert_file_not_exists "uninstall removed azg-ponytail.mdc" \
  "${TEMP_HOME}/.cursor/rules/azg-ponytail.mdc"
assert_file_not_exists "uninstall removed azg-agent-instructions.mdc" \
  "${TEMP_HOME}/.cursor/rules/azg-agent-instructions.mdc"

if [ -f "${TEMP_HOME}/.cursor/rules/user-preference.mdc" ]; then
  pass "uninstall left foreign Cursor rule"
else
  fail "uninstall removed foreign Cursor rule"
fi
if [ -f "${TEMP_HOME}/.cursor/skills/my-foreign-skill/SKILL.md" ]; then
  pass "uninstall left foreign Cursor skill"
else
  fail "uninstall removed foreign Cursor skill"
fi
if [ -f "${TEMP_HOME}/.cursor/skills-cursor/builtin-keep/SKILL.md" ]; then
  pass "uninstall left skills-cursor alone"
else
  fail "uninstall touched skills-cursor"
fi

test_summary
