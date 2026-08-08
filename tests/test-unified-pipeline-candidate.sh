#!/usr/bin/env bash
# tests/test-unified-pipeline-candidate.sh — Candidate package + eval staging (not global promote)
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/harness.sh"

ROOT="${REPO_ROOT}"
CAND="${ROOT}/templates/candidates/unified-pipeline"

section "1. package layout"
assert_file_exists "candidate AGENTS" "${CAND}/AGENTS.md"
assert_file_exists "single cursor stub" "${CAND}/cursor/rules/azg-agent-instructions.mdc"
assert_file_exists "orchestrate skill" "${CAND}/skills/orchestrate/SKILL.md"
assert_file_exists "judge skill" "${CAND}/skills/judge/SKILL.md"
assert_file_exists "NOTICE" "${CAND}/NOTICE"
assert_file_exists "failure-modes ref" "${CAND}/skills/references/failure-modes.md"
if [ -f "${CAND}/cursor/rules/azg-ponytail.mdc" ]; then
  fail "candidate must not ship separate azg-ponytail.mdc (ponytail nested in pipeline)" ""
else
  pass "no separate ponytail cursor rule"
fi
if [ -d "${CAND}/skills/fable-method" ] || [ -d "${CAND}/skills/fable-loop" ] || [ -d "${CAND}/skills/fable-judge" ]; then
  fail "fable-* skill dirs must not ship on device paths" ""
else
  pass "no fable-* skill directories"
fi

section "2. AGENTS markers + pipeline order"
agents="${CAND}/AGENTS.md"
if grep -q '<!-- AZG:AGENT-INSTRUCTIONS:START -->' "${agents}" \
  && grep -q '<!-- AZG:AGENT-INSTRUCTIONS:END -->' "${agents}"; then
  pass "AGENT-INSTRUCTIONS markers"
else
  fail "missing AGENT-INSTRUCTIONS markers" ""
fi
if grep -q '<!-- PONYTAIL:MANAGED:START -->' "${agents}" \
  && grep -q '<!-- PONYTAIL:MANAGED:END -->' "${agents}"; then
  pass "nested PONYTAIL:MANAGED markers"
else
  fail "missing nested ponytail markers" ""
fi
if grep -q 'BEGIN VENDORED' "${agents}"; then
  fail "must not use BEGIN VENDORED chrome" ""
else
  pass "no BEGIN VENDORED"
fi
# Order: ACT before SHAPE/ponytail before VERIFY (containment)
act_line=$(grep -n '## §2 ACT' "${agents}" | head -1 | cut -d: -f1)
pony_line=$(grep -n 'PONYTAIL:MANAGED:START' "${agents}" | head -1 | cut -d: -f1)
verify_line=$(grep -n '## §4 VERIFY' "${agents}" | head -1 | cut -d: -f1)
if [ -n "${act_line}" ] && [ -n "${pony_line}" ] && [ -n "${verify_line}" ] \
  && [ "${act_line}" -lt "${pony_line}" ] && [ "${pony_line}" -lt "${verify_line}" ]; then
  pass "ACT → ponytail → VERIFY order"
else
  fail "pipeline order" "act=${act_line} pony=${pony_line} verify=${verify_line}"
fi

section "3. skills handoff contract"
orch="${CAND}/skills/orchestrate/SKILL.md"
if grep -q '## Inherits' "${orch}" && grep -q '## Subagent Rule Overrides' "${orch}"; then
  pass "orchestrate inherit + overrides"
else
  fail "orchestrate missing handoff contract" ""
fi
if grep -qi 'IGNORE §3' "${orch}"; then
  pass "verifier/evidence ignore §3"
else
  fail "missing IGNORE §3 overrides" ""
fi
if grep -q '^name: orchestrate' "${orch}" && grep -q '^name: judge' "${CAND}/skills/judge/SKILL.md"; then
  pass "skill names azg (orchestrate/judge)"
else
  fail "skill frontmatter names" ""
fi

section "4. stage-unified-pipeline-home"
assert_file_exists "stager" "${ROOT}/evals/stage-unified-pipeline-home.sh"
home_tmp=$(azg_mktemp_d "tmp_azg_upipe-XXXXXX")
if bash "${ROOT}/evals/stage-unified-pipeline-home.sh" "${home_tmp}/staged" >/dev/null; then
  pass "stager exits 0"
else
  fail "stager failed" ""
fi
staged="${home_tmp}/staged"
if [ -f "${staged}/.cursor/rules/azg-agent-instructions.mdc" ]; then
  pass "staged single agent-instructions rule"
else
  fail "missing staged azg-agent-instructions.mdc" ""
fi
if [ -f "${staged}/.cursor/rules/azg-ponytail.mdc" ]; then
  fail "staged home must not include separate ponytail rule" ""
else
  pass "no staged azg-ponytail.mdc"
fi
for sk in orchestrate judge; do
  if [ -f "${staged}/.cursor/skills/${sk}/SKILL.md" ] \
    && [ -f "${staged}/.agents/skills/${sk}/SKILL.md" ]; then
    pass "staged skill ${sk} (cursor+agents)"
  else
    fail "missing staged skill ${sk}" ""
  fi
done
if [ -f "${staged}/.cursor/skills/references/failure-modes.md" ] \
  || [ -f "${staged}/.agents/skills/references/failure-modes.md" ]; then
  pass "staged references"
else
  fail "references not staged" ""
fi
if grep -q 'alwaysApply: true' "${staged}/.cursor/rules/azg-agent-instructions.mdc" \
  && grep -q 'PONYTAIL:MANAGED:START' "${staged}/.cursor/rules/azg-agent-instructions.mdc"; then
  pass "staged rule embeds nested ponytail"
else
  fail "staged rule missing frontmatter or nested ponytail" ""
fi

section "5. trap cell routes pack"
if grep -q 'unified-pipeline' "${ROOT}/evals/run-trap-cell.sh"; then
  pass "run-trap-cell knows unified-pipeline"
else
  fail "run-trap-cell missing unified-pipeline branch" ""
fi
if grep -q 'stage-unified-pipeline-home' "${ROOT}/evals/run-trap-cell.sh"; then
  pass "trap cell calls unified stager"
else
  fail "trap cell does not call unified stager" ""
fi

section "6. global not promoted"
if grep -q '## §0 ROUTER' "${ROOT}/templates/global/AGENTS.md"; then
  fail "templates/global/AGENTS.md must stay clean-slate until promote" ""
else
  pass "global AGENTS not promoted"
fi
if [ -d "${ROOT}/templates/global/skills/azg/orchestrate" ]; then
  fail "orchestrate must not be in templates/global/skills/azg yet" ""
else
  pass "global skills/azg not promoted"
fi

section "7. ADR + glossary pointer"
assert_file_exists "ADR 0014" "${ROOT}/docs/adr/0014-unified-pipeline-candidate.md"
if grep -q 'Method Naming' "${ROOT}/CONTEXT.md" || grep -q 'no fable-\*' "${ROOT}/CONTEXT.md" \
  || grep -q 'Method naming' "${ROOT}/CONTEXT.md"; then
  pass "CONTEXT naming pointer"
else
  fail "CONTEXT missing method-naming pointer" ""
fi

test_summary
