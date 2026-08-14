#!/usr/bin/env bash
# tests/test-intent-gates-candidate.sh — Principles Treatment promoted to global always-on
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/harness.sh"

AGENTS="${REPO_ROOT}/templates/global/AGENTS.md"

extract_instructions() {
  awk '/<!-- AZG:AGENT-INSTRUCTIONS:START -->/{f=1; next} /<!-- AZG:AGENT-INSTRUCTIONS:END -->/{f=0; next} f' "${AGENTS}"
}

section "1. principles treatment always-on (ADR 0021)"
INST="$(extract_instructions)"
if printf '%s\n' "${INST}" | grep -q 'Principles Treatment'; then pass "principles present"; else fail "missing Principles Treatment" ""; fi
if printf '%s\n' "${INST}" | grep -q 'Temporary File Cleanup'; then pass "cleanup kept"; else fail "missing cleanup" ""; fi
if printf '%s\n' "${INST}" | grep -q 'Telegraphic Writing Style'; then pass "telegraphic kept"; else fail "missing telegraphic" ""; fi
if awk '/Principles Treatment/{ep=NR} /Temporary File Cleanup/{tc=NR} END{exit !(ep>0 && tc>ep)}' <<<"${INST}"; then
  pass "block order: principles before cleanup"
else
  fail "wrong block order" ""
fi
for need in 'Twin Sweep' 'losing side' 'every hit' 'azg-domain-data-analysis' 'azg-domain-research'; do
  if printf '%s\n' "${INST}" | grep -qF "${need}"; then pass "has ${need}"; else fail "missing ${need}" ""; fi
done
if printf '%s\n' "${INST}" | grep -q 'Intent Tie'; then
  fail "Intent Tie heading must be gone" ""
else
  pass "no Intent Tie"
fi
for bad in 'Execution Protocol v1' 'Follow literally' 'INTENT:' 'AUTH:' 'TWINS:' 'PENDING:' 'Prove stance' 'VERIFIED:' 'azg-method-refs' 'fable-method' 'fable-loop' 'PONYTAIL:MANAGED'; do
  if printf '%s\n' "${INST}" | grep -qF "${bad}"; then
    fail "residue: ${bad}" ""
  else
    pass "no ${bad}"
  fi
done

section "2. always-on ponytail retired + vendor packs trimmed"
if grep -q 'PONYTAIL:MANAGED' "${AGENTS}" || grep -qi 'lazy senior' "${AGENTS}"; then
  fail "ponytail must not be in Device Setup AGENTS (ADR 0015)" ""
else
  pass "no always-on ponytail in global AGENTS"
fi
if [ -f "${REPO_ROOT}/templates/global/cursor/rules/azg-ponytail.mdc" ]; then
  fail "azg-ponytail.mdc stub must be deleted" ""
else
  pass "azg-ponytail.mdc stub gone"
fi
if [ ! -d "${REPO_ROOT}/templates/global/skills/vendor/ponytail-skills" ]; then
  pass "ponytail-skills removed from vendor catalog"
else
  fail "vendor ponytail-skills still present" ""
fi
if [ ! -d "${REPO_ROOT}/templates/global/skills/vendor/caveman-skills" ]; then
  pass "caveman-skills removed from vendor catalog"
else
  fail "vendor caveman-skills still present" ""
fi
assert_file_exists "data-analysis skill" "${REPO_ROOT}/templates/global/skills/azg/azg-domain-data-analysis/SKILL.md"
assert_file_exists "research skill" "${REPO_ROOT}/templates/global/skills/azg/azg-domain-research/SKILL.md"
if [ -d "${REPO_ROOT}/templates/global/skills/azg/azg-method-refs" ]; then
  fail "azg-method-refs must stay unshipped" ""
else
  pass "azg-method-refs not in global skills"
fi

section "3. repo AGENTS eval-watch rule"
if grep -q 'Eval campaigns — agent owns the watch' "${REPO_ROOT}/AGENTS.md"; then
  pass "eval-watch guidance in repo AGENTS.md"
else
  fail "missing eval-watch section" ""
fi

test_summary
