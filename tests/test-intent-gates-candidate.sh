#!/usr/bin/env bash
# tests/test-intent-gates-candidate.sh — clean slate: Fable distill removed from always-on
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/harness.sh"

AGENTS="${REPO_ROOT}/templates/global/AGENTS.md"

extract_instructions() {
  awk '/<!-- AZG:AGENT-INSTRUCTIONS:START -->/{f=1; next} /<!-- AZG:AGENT-INSTRUCTIONS:END -->/{f=0; next} f' "${AGENTS}"
}

section "1. clean-slate always-on (no Fable distill)"
INST="$(extract_instructions)"
if printf '%s\n' "${INST}" | grep -q 'Temporary File Cleanup'; then pass "cleanup kept"; else fail "missing cleanup" ""; fi
if printf '%s\n' "${INST}" | grep -q 'Telegraphic Writing Style'; then pass "telegraphic kept"; else fail "missing telegraphic" ""; fi
for bad in 'Intent gates' 'Prove stance' 'INTENT:' 'AUTH:' 'TWINS:' 'PENDING:' 'VERIFIED:' 'azg-method-refs' 'Reversible Default' 'Impl-Equivalent'; do
  if printf '%s\n' "${INST}" | grep -qF "${bad}"; then
    fail "distill residue: ${bad}" ""
  else
    pass "no ${bad}"
  fi
done

section "2. ponytail untouched + azg skills deleted"
if grep -q 'PONYTAIL:MANAGED:START' "${AGENTS}" && grep -q 'lazy senior' "${AGENTS}"; then
  pass "ponytail block present"
else
  fail "ponytail missing" ""
fi
if [ -d "${REPO_ROOT}/templates/global/skills/azg" ]; then
  fail "skills/azg still present" ""
else
  pass "templates/global/skills/azg deleted"
fi

section "3. repo AGENTS eval-watch rule"
if grep -q 'Eval campaigns — agent owns the watch' "${REPO_ROOT}/AGENTS.md"; then
  pass "eval-watch guidance in repo AGENTS.md"
else
  fail "missing eval-watch section" ""
fi

test_summary
