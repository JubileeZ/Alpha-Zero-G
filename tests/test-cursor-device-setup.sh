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
mkdir -p "${TEMP_HOME}/.gemini/config"
awk '$0 != "<!-- AZG:AGENT-INSTRUCTIONS:START -->" && \
  $0 != "<!-- AZG:AGENT-INSTRUCTIONS:END -->"' \
  "${TEMP_REPO}/templates/global/AGENTS.md" > "${TEMP_HOME}/.gemini/config/AGENTS.md"
printf '%s\n' '# foreign user rule' > "${TEMP_HOME}/.cursor/rules/user-preference.mdc"
printf '%s\n' '# foreign azg-named rule' > "${TEMP_HOME}/.cursor/rules/azg-foreign.mdc"
printf '%s\n' '# foreign skill' > "${TEMP_HOME}/.cursor/skills/my-foreign-skill/SKILL.md"
printf '%s\n' '# builtin' > "${TEMP_HOME}/.cursor/skills-cursor/builtin-keep/SKILL.md"

assert_exit "azg setup exits 0" 0 \
  env HOME="${TEMP_HOME}" AZG_ROOT="${TEMP_REPO}" "${TEMP_AZG}" setup

assert_file_exists "Cursor skill SKILL.md installed" \
  "${TEMP_HOME}/.cursor/skills/${SAMPLE_SKILL}/SKILL.md"
assert_file_exists "Cursor skill has AZG-OWNED.md sentinel" \
  "${TEMP_HOME}/.cursor/skills/${SAMPLE_SKILL}/AZG-OWNED.md"
assert_file_exists "global AGENTS.md installed" \
  "${TEMP_HOME}/.gemini/config/AGENTS.md"
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

if grep -q '<!-- AZG:AGENT-INSTRUCTIONS:START -->' "${TEMP_HOME}/.gemini/config/AGENTS.md" &&
  grep -q '<!-- AZG:AGENT-INSTRUCTIONS:END -->' "${TEMP_HOME}/.gemini/config/AGENTS.md"; then
  pass "setup migrates global AGENTS.md agent-instruction markers"
else
  fail "setup left global AGENTS.md without agent-instruction markers"
fi

expected_ponytail="$(awk '/<!-- PONYTAIL:MANAGED:START -->/{f=1; next} /<!-- PONYTAIL:MANAGED:END -->/{f=0; next} f {sub(/\r$/, ""); print}' \
  "${TEMP_REPO}/templates/global/AGENTS.md")"
actual_ponytail="$(awk 'BEGIN{frontmatter=0} /^---$/{frontmatter += 1; next} frontmatter >= 2 {print}' \
  "${TEMP_HOME}/.cursor/rules/azg-ponytail.mdc")"
if [ "${actual_ponytail}" = "${expected_ponytail}" ]; then
  pass "azg-ponytail.mdc body matches AGENTS.md source block"
else
  fail "azg-ponytail.mdc body drifted from AGENTS.md source block"
fi

expected_agent_instructions="$(awk '/<!-- AZG:AGENT-INSTRUCTIONS:START -->/{f=1; next} /<!-- AZG:AGENT-INSTRUCTIONS:END -->/{f=0; next} f {sub(/\r$/, ""); print}' \
  "${TEMP_REPO}/templates/global/AGENTS.md")"
actual_agent_instructions="$(awk 'BEGIN{frontmatter=0} /^---$/{frontmatter += 1; next} frontmatter >= 2 {print}' \
  "${TEMP_HOME}/.cursor/rules/azg-agent-instructions.mdc")"
if [ "${actual_agent_instructions}" = "${expected_agent_instructions}" ]; then
  pass "azg-agent-instructions.mdc body matches AGENTS.md source block"
else
  fail "azg-agent-instructions.mdc body drifted from AGENTS.md source block"
fi

actual_global_agent_instructions="$(awk '/<!-- AZG:AGENT-INSTRUCTIONS:START -->/{f=1; next} /<!-- AZG:AGENT-INSTRUCTIONS:END -->/{f=0; next} f {sub(/\r$/, ""); print}' \
  "${TEMP_HOME}/.gemini/config/AGENTS.md")"
if [ "${actual_global_agent_instructions}" = "${expected_agent_instructions}" ]; then
  pass "global AGENTS.md body matches canonical source block"
else
  fail "global AGENTS.md body drifted from canonical source block"
fi

if [ -f "${TEMP_HOME}/.cursor/rules/user-preference.mdc" ] && grep -q 'foreign user rule' "${TEMP_HOME}/.cursor/rules/user-preference.mdc"; then
  pass "setup left foreign Cursor rule intact"
else
  fail "setup clobbered foreign ~/.cursor/rules/user-preference.mdc"
fi
if [ -f "${TEMP_HOME}/.cursor/rules/azg-foreign.mdc" ] && grep -q 'foreign azg-named rule' "${TEMP_HOME}/.cursor/rules/azg-foreign.mdc"; then
  pass "setup left foreign azg-named Cursor rule intact"
else
  fail "setup clobbered foreign azg-named Cursor rule"
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

section "1b. first-party azg skills + Prove stance (ADR 0010)"

for azg_skill in azg-domain-research azg-domain-data-analysis azg-method-refs; do
  assert_file_exists "Cursor azg skill ${azg_skill}" \
    "${TEMP_HOME}/.cursor/skills/${azg_skill}/SKILL.md"
  assert_file_exists "Cursor ${azg_skill} AZG-OWNED.md" \
    "${TEMP_HOME}/.cursor/skills/${azg_skill}/AZG-OWNED.md"
  assert_file_exists "Gemini azg skill ${azg_skill}" \
    "${TEMP_HOME}/.gemini/config/skills/${azg_skill}/SKILL.md"
  assert_file_exists "Gemini ${azg_skill} ANTIGRAVITY-NOTE" \
    "${TEMP_HOME}/.gemini/config/skills/${azg_skill}/ANTIGRAVITY-NOTE.md"
  if [ -f "${OWN}" ] && jq -e --arg s "${azg_skill}" '(.cursor_skills // []) | index($s) != null' "${OWN}" >/dev/null; then
    pass "ownership lists cursor_skills ${azg_skill}"
  else
    fail "ownership missing cursor_skills ${azg_skill}"
  fi
done

if grep -q 'Failure modes → gate' "${TEMP_HOME}/.cursor/skills/azg-method-refs/SKILL.md" &&
  grep -q 'TWINS search' "${TEMP_HOME}/.cursor/skills/azg-method-refs/SKILL.md" &&
  grep -q 'Classic frauds (Prove)' "${TEMP_HOME}/.cursor/skills/azg-method-refs/SKILL.md" &&
  grep -q 'Compressed examples' "${TEMP_HOME}/.cursor/skills/azg-method-refs/SKILL.md"; then
  pass "method-refs failure-mode map + frauds + examples inlined in SKILL.md"
else
  fail "method-refs SKILL.md missing failure-mode / frauds / examples"
fi

if grep -q 'Prove stance' "${TEMP_HOME}/.cursor/rules/azg-agent-instructions.mdc" &&
  grep -q 'azg-method-refs' "${TEMP_HOME}/.cursor/rules/azg-agent-instructions.mdc" &&
  grep -q 'azg-domain-research' "${TEMP_HOME}/.cursor/rules/azg-agent-instructions.mdc" &&
  grep -q 'VERIFIED:' "${TEMP_HOME}/.cursor/rules/azg-agent-instructions.mdc" &&
  ! grep -q 'Placeholder Rule' "${TEMP_HOME}/.cursor/rules/azg-agent-instructions.mdc"; then
  pass "agent-instructions include Prove stance + skill router; placeholders not global"
else
  fail "agent-instructions missing Prove/router or still has global Placeholder Rule"
fi

# Smart-sync skip must still refresh azg-owned skills (VENDOR.lock unchanged)
assert_exit "second setup (smart sync) exits 0" 0 \
  env HOME="${TEMP_HOME}" AZG_ROOT="${TEMP_REPO}" "${TEMP_AZG}" setup
assert_file_exists "azg-method-refs survives smart sync" \
  "${TEMP_HOME}/.cursor/skills/azg-method-refs/SKILL.md"

assert_marker_rejected() {
  local label="${1}"
  local malformed_agents="${2}"
  if bash -c '
    source "$1/lib/common.sh"
    source "$1/lib/setup.sh"
    _validate_cursor_rule_templates "$1/templates/global/cursor/rules" "$2"
  ' _ "${TEMP_REPO}" "${malformed_agents}" >/dev/null 2>&1; then
    fail "setup validation accepted ${label}"
  else
    pass "setup validation rejects ${label}"
  fi
}

MALFORMED_AGENTS="${TEMP_HOME}/AGENTS-missing-marker.md"
awk '$0 != "<!-- AZG:AGENT-INSTRUCTIONS:END -->"' \
  "${TEMP_REPO}/templates/global/AGENTS.md" > "${MALFORMED_AGENTS}"
assert_marker_rejected "missing AGENTS.md marker" "${MALFORMED_AGENTS}"

MALFORMED_AGENTS="${TEMP_HOME}/AGENTS-duplicate-marker.md"
awk -v marker='<!-- AZG:AGENT-INSTRUCTIONS:START -->' \
  '{print} $0 == marker {print}' \
  "${TEMP_REPO}/templates/global/AGENTS.md" > "${MALFORMED_AGENTS}"
assert_marker_rejected "duplicate AGENTS.md marker" "${MALFORMED_AGENTS}"

MALFORMED_AGENTS="${TEMP_HOME}/AGENTS-reversed-marker.md"
awk -v start='<!-- AZG:AGENT-INSTRUCTIONS:START -->' \
  -v end='<!-- AZG:AGENT-INSTRUCTIONS:END -->' \
  '$0 == start {next} $0 == end {print; print start; next} {print}' \
  "${TEMP_REPO}/templates/global/AGENTS.md" > "${MALFORMED_AGENTS}"
assert_marker_rejected "reversed AGENTS.md markers" "${MALFORMED_AGENTS}"

MALFORMED_AGENTS="${TEMP_HOME}/AGENTS-empty-marker.md"
awk -v start='<!-- AZG:AGENT-INSTRUCTIONS:START -->' \
  -v end='<!-- AZG:AGENT-INSTRUCTIONS:END -->' \
  '$0 == start {print; inside=1; next} $0 == end {print; inside=0; next} inside {print "   "; next} {print}' \
  "${TEMP_REPO}/templates/global/AGENTS.md" > "${MALFORMED_AGENTS}"
assert_marker_rejected "empty AGENTS.md marker block" "${MALFORMED_AGENTS}"

MALFORMED_AGENTS="${TEMP_HOME}/AGENTS-substring-marker.md"
awk -v end='<!-- AZG:AGENT-INSTRUCTIONS:END -->' \
  '$0 == end {print "not a marker: " end " is embedded"; next} {print}' \
  "${TEMP_REPO}/templates/global/AGENTS.md" > "${MALFORMED_AGENTS}"
assert_marker_rejected "substring AGENTS.md marker" "${MALFORMED_AGENTS}"

MALFORMED_AGENTS="${TEMP_HOME}/AGENTS-missing-ponytail-marker.md"
awk '$0 != "<!-- PONYTAIL:MANAGED:END -->"' \
  "${TEMP_REPO}/templates/global/AGENTS.md" > "${MALFORMED_AGENTS}"
assert_marker_rejected "missing ponytail marker" "${MALFORMED_AGENTS}"

MALFORMED_GLOBAL="${TEMP_HOME}/.gemini/config/AGENTS.md.malformed"
awk '$0 != "<!-- PONYTAIL:MANAGED:END -->"' \
  "${TEMP_HOME}/.gemini/config/AGENTS.md" > "${MALFORMED_GLOBAL}"
# DESTRUCTIVE: replace mocked AGENTS.md with malformed managed markers
mv "${MALFORMED_GLOBAL}" "${TEMP_HOME}/.gemini/config/AGENTS.md"
assert_exit "setup rejects malformed owned global AGENTS.md" 1 \
  env HOME="${TEMP_HOME}" AZG_ROOT="${TEMP_REPO}" "${TEMP_AZG}" setup

section "2. uninstall removes owned Cursor assets only"

assert_exit "azg uninstall exits 0" 0 \
  env HOME="${TEMP_HOME}" AZG_ROOT="${TEMP_REPO}" "${TEMP_AZG}" uninstall

assert_file_not_exists "uninstall removed owned Cursor skill" \
  "${TEMP_HOME}/.cursor/skills/${SAMPLE_SKILL}/SKILL.md"
assert_file_not_exists "uninstall removed azg-method-refs" \
  "${TEMP_HOME}/.cursor/skills/azg-method-refs/SKILL.md"
assert_file_not_exists "uninstall removed azg-ponytail.mdc" \
  "${TEMP_HOME}/.cursor/rules/azg-ponytail.mdc"
assert_file_not_exists "uninstall removed azg-agent-instructions.mdc" \
  "${TEMP_HOME}/.cursor/rules/azg-agent-instructions.mdc"

if [ -f "${TEMP_HOME}/.cursor/rules/user-preference.mdc" ]; then
  pass "uninstall left foreign Cursor rule"
else
  fail "uninstall removed foreign Cursor rule"
fi
if [ -f "${TEMP_HOME}/.cursor/rules/azg-foreign.mdc" ]; then
  pass "uninstall left foreign azg-named Cursor rule"
else
  fail "uninstall removed foreign azg-named Cursor rule"
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
