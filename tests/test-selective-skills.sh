#!/usr/bin/env bash
# tests/test-selective-skills.sh — Test suite for selective skills & dependency resolution
#
# Run from repo root:  bash tests/test-selective-skills.sh

set -uo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/harness.sh"

TEMP_HOME="$(azg_mktemp_d "tmp_azg_sel_home-XXXXXX")"
TEMP_REPO="$(azg_mktemp_d "tmp_azg_sel_repo-XXXXXX")"

# Populate mock repo from current tree
tar -cf - --exclude=.git --exclude='tmp_azg*' -C "${REPO_ROOT}" . | tar -xf - -C "${TEMP_REPO}"

TEMP_AZG="${TEMP_REPO}/azg"

section "1. Dependency resolver finds transitive prerequisites"

bash -c "
  export AZG_ROOT='${TEMP_REPO}'
  source '${TEMP_REPO}/lib/common.sh'
  source '${TEMP_REPO}/lib/setup.sh'

  manifest='${TEMP_HOME}/test-manifest.json'
  printf '{\"version\":1,\"skills\":[\"wayfinder\",\"implement\"]}\n' > \"\${manifest}\"

  resolved=\"\$(_resolve_active_skills '${TEMP_REPO}/templates/global/skills/vendor' \"\${manifest}\")\"
  
  # wayfinder requires grilling, domain-modeling, research, prototype
  # implement requires tdd, code-review
  for req in wayfinder implement grilling domain-modeling research prototype tdd code-review; do
    if ! echo \"\${resolved}\" | grep -q \"^\${req}\$\"; then
      echo \"missing: \${req}\"
      exit 1
    fi
  done
  exit 0
"

if [ $? -eq 0 ]; then
  pass "Transitive prerequisites automatically resolved (grilling, domain-modeling, tdd, etc.)"
else
  fail "Transitive prerequisite resolution failed"
fi

section "2. azg skill list works and displays catalog vs active"

LIST_OUT="$(env HOME="${TEMP_HOME}" AZG_ROOT="${TEMP_REPO}" "${TEMP_AZG}" skill list)"

assert_output_contains "skill list shows active section" "${LIST_OUT}" "Active / Installed Skills"
assert_output_contains "skill list shows available catalog section" "${LIST_OUT}" "Available Catalog Skills"
assert_output_contains "skill list shows caveman in catalog" "${LIST_OUT}" "caveman"

section "3. azg setup installs active skills into both IDEs with 1:1 parity"

env HOME="${TEMP_HOME}" AZG_ROOT="${TEMP_REPO}" "${TEMP_AZG}" setup >/dev/null 2>&1

GEMINI_SKILLS="${TEMP_HOME}/.gemini/config/skills"
CURSOR_SKILLS="${TEMP_HOME}/.cursor/skills"

assert_dir_exists "Gemini has grill-with-docs" "${GEMINI_SKILLS}/grill-with-docs"
assert_dir_exists "Cursor has grill-with-docs" "${CURSOR_SKILLS}/grill-with-docs"
assert_dir_exists "Gemini has auto-resolved tdd" "${GEMINI_SKILLS}/tdd"
assert_dir_exists "Cursor has auto-resolved tdd" "${CURSOR_SKILLS}/tdd"

# Inactive catalog skills must not be in global directories
assert_dir_not_exists "Gemini does not have unselected caveman" "${GEMINI_SKILLS}/caveman"
assert_dir_not_exists "Cursor does not have unselected caveman" "${CURSOR_SKILLS}/caveman"
assert_dir_not_exists "Gemini does not have unselected wizard" "${GEMINI_SKILLS}/wizard"
assert_dir_not_exists "Cursor does not have unselected wizard" "${CURSOR_SKILLS}/wizard"

section "4. azg skill enable adds skill and prunes when disabled"

env HOME="${TEMP_HOME}" AZG_ROOT="${TEMP_REPO}" "${TEMP_AZG}" skill enable caveman >/dev/null 2>&1

assert_dir_exists "Gemini has enabled caveman" "${GEMINI_SKILLS}/caveman"
assert_dir_exists "Cursor has enabled caveman" "${CURSOR_SKILLS}/caveman"

env HOME="${TEMP_HOME}" AZG_ROOT="${TEMP_REPO}" "${TEMP_AZG}" skill disable caveman >/dev/null 2>&1

assert_dir_not_exists "Gemini has pruned disabled caveman" "${GEMINI_SKILLS}/caveman"
assert_dir_not_exists "Cursor has pruned disabled caveman" "${CURSOR_SKILLS}/caveman"

section "5. Custom skills survive in both IDEs"

mkdir -p "${GEMINI_SKILLS}/my-custom-skill"
printf 'SKILL.md\n' > "${GEMINI_SKILLS}/my-custom-skill/SKILL.md"

mkdir -p "${CURSOR_SKILLS}/my-custom-skill"
printf 'SKILL.md\n' > "${CURSOR_SKILLS}/my-custom-skill/SKILL.md"

env HOME="${TEMP_HOME}" AZG_ROOT="${TEMP_REPO}" "${TEMP_AZG}" setup --force >/dev/null 2>&1

assert_dir_exists "Custom skill in Gemini survives setup" "${GEMINI_SKILLS}/my-custom-skill"
assert_dir_exists "Custom skill in Cursor survives setup" "${CURSOR_SKILLS}/my-custom-skill"

test_summary
