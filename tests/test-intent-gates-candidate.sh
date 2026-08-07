#!/usr/bin/env bash
# tests/test-intent-gates-candidate.sh — Think/Prove Candidate always-on + azg skills
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/harness.sh"

AGENTS="${REPO_ROOT}/templates/global/AGENTS.md"
AZG_SKILLS="${REPO_ROOT}/templates/global/skills/azg"

extract_instructions() {
  awk '/<!-- AZG:AGENT-INSTRUCTIONS:START -->/{f=1; next} /<!-- AZG:AGENT-INSTRUCTIONS:END -->/{f=0; next} f' "${AGENTS}"
}

section "1. always-on Think/Prove + precedence"
INST="$(extract_instructions)"
if printf '%s\n' "${INST}" | grep -q 'Temporary File Cleanup'; then pass "cleanup kept"; else fail "missing cleanup" ""; fi
if printf '%s\n' "${INST}" | grep -q 'Telegraphic Writing Style'; then pass "telegraphic kept"; else fail "missing telegraphic" ""; fi
for need in 'Precedence' 'Think / Prove' 'INTENT:' 'AUTH:' 'TWINS:' 'PENDING:' 'Prove Stance' 'azg-orchestrate' 'azg-method-refs' 'azg-domain-devops'; do
  if printf '%s\n' "${INST}" | grep -qF "${need}"; then
    pass "has ${need}"
  else
    fail "missing ${need}" ""
  fi
done
# No upstream product name on device
if printf '%s\n' "${INST}" | grep -qiE '\bfable\b'; then
  fail "fable product name leaked into always-on" ""
else
  pass "no fable product name in always-on"
fi

section "2. block order: AGENT-INSTRUCTIONS before PONYTAIL"
a_line="$(awk '/<!-- AZG:AGENT-INSTRUCTIONS:START -->/{print NR; exit}' "${AGENTS}")"
p_line="$(awk '/<!-- PONYTAIL:MANAGED:START -->/{print NR; exit}' "${AGENTS}")"
if [ -n "${a_line}" ] && [ -n "${p_line}" ] && [ "${a_line}" -lt "${p_line}" ]; then
  pass "AGENT-INSTRUCTIONS precedes PONYTAIL (${a_line} < ${p_line})"
else
  fail "block order wrong (a=${a_line:-?} p=${p_line:-?})" ""
fi
if grep -q 'lazy senior' "${AGENTS}"; then
  pass "ponytail block present"
else
  fail "ponytail missing" ""
fi

section "3. family pack skills present"
expected_skills=(
  azg-orchestrate
  azg-method-refs
  azg-domain-research
  azg-domain-data-analysis
  azg-domain-marketing
  azg-domain-business-ops
  azg-domain-finance
  azg-domain-legal
  azg-domain-design
  azg-domain-devops
)
if [ ! -d "${AZG_SKILLS}" ]; then
  fail "templates/global/skills/azg missing" ""
else
  pass "skills/azg directory present"
fi
for sk in "${expected_skills[@]}"; do
  if [ -f "${AZG_SKILLS}/${sk}/SKILL.md" ]; then
    pass "skill ${sk}"
  else
    fail "missing skill ${sk}" ""
  fi
done
if [ -f "${AZG_SKILLS}/azg-method-refs/references/failure-modes.md" ]; then
  pass "method-refs failure-modes reference"
else
  fail "missing failure-modes.md" ""
fi

section "4. repo AGENTS eval-watch rule"
if grep -q 'Eval campaigns — agent owns the watch' "${REPO_ROOT}/AGENTS.md"; then
  pass "eval-watch guidance in repo AGENTS.md"
else
  fail "missing eval-watch section" ""
fi

test_summary
