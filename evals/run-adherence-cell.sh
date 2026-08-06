#!/usr/bin/env bash
# evals/run-adherence-cell.sh — one prompt × arm via Cursor Agent CLI
# Usage: run-adherence-cell.sh <prompt_id> <baseline|current|candidate> [--force]
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"

PROMPT_ID="${1:-}"
ARM="${2:-}"
FORCE=0
[ "${3:-}" = "--force" ] && FORCE=1
[ -n "${PROMPT_ID}" ] && [ -n "${ARM}" ] || die "usage: run-adherence-cell.sh <prompt_id> <baseline|current|candidate> [--force]"

export PATH="${HOME}/.local/bin:${PATH}"
command -v agent >/dev/null || die "agent CLI missing — curl https://cursor.com/install | bash && agent login"
command -v jq >/dev/null || die "jq required"

CAMP="${ADHERENCE_CAMP:-${ROOT}/evals/adherence/campaigns/wfa-lever-luna}"
MODEL="${ADHERENCE_MODEL:-gpt-5.6-luna}"
CURRENT_REF="${AZG_CURRENT_REF:-2e6ff14}"
CANDIDATE_REF="${AZG_CANDIDATE_REF:-HEAD}"
PROMPTS="${ROOT}/evals/adherence/prompts.json"
CELL="${CAMP}/${PROMPT_ID}/${ARM}"
SC="${CELL}/scorecard.json"
WT="${ROOT}/evals/adherence/worktrees"
REPO_DIR="${WT}/cells/${PROMPT_ID}/${ARM}"

mkdir -p "${CELL}" "${WT}/cells/${PROMPT_ID}"
[ -f "${SC}" ] || die "missing scorecard — run prepare-adherence-campaign.sh first"

if [ "${FORCE}" -eq 0 ] && [ "$(jq -r '.task_success' "${SC}")" != "null" ]; then
  info "skip ${PROMPT_ID}/${ARM} (already scored)"
  exit 0
fi

PROMPT_TEXT="$(jq -r --arg id "${PROMPT_ID}" '.prompts[] | select(.id==$id) | .prompt' "${PROMPTS}")"
[ -n "${PROMPT_TEXT}" ] && [ "${PROMPT_TEXT}" != "null" ] || die "unknown prompt_id: ${PROMPT_ID}"

azg_src_for_arm() {
  case "$1" in
    baseline) echo "" ;;
    current) echo "${CURRENT_REF}" ;;
    candidate) echo "${CANDIDATE_REF}" ;;
    *) die "bad arm" ;;
  esac
}

# --- fresh fixture cell ---
rm -rf "${REPO_DIR}"
mkdir -p "${REPO_DIR}/data"
cd "${REPO_DIR}"
git init -q
git -c user.email=azg@test -c user.name=azg commit --allow-empty -qm 'fixture root' 2>/dev/null || true

printf '%s\n' 'smoke fixture file' >fixture.txt
printf '%s\n' 'def greeting():' '    return "hello"' >app.py
printf '%s\n' 'product,amount' 'alpha,10' 'beta,30' 'gamma,20' >data/sales.csv

# Project AGENTS shell (identity only)
cat >AGENTS.md <<'EOF'
# adherence-fixture
---
## Project Identity
Adherence smoke fixture. Not a product repo.
**Stack:** Python 3
---
## Key Commands
| Command | When |
|---------|------|
| `python -c "from app import greeting; print(greeting())"` | Check greeting |
EOF

REF="$(azg_src_for_arm "${ARM}")"
if [ -n "${REF}" ]; then
  REF_SHA="$(git -C "${ROOT}" rev-parse "${REF}^{commit}")"
  mkdir -p .cursor/rules .agents/skills .cursor/skills
  {
    echo '---'
    echo 'description: AZG agent instructions (adherence cell)'
    echo 'alwaysApply: true'
    echo '---'
    git -C "${ROOT}" show "${REF_SHA}:templates/global/AGENTS.md" \
      | awk '/<!-- AZG:AGENT-INSTRUCTIONS:START -->/{f=1; next} /<!-- AZG:AGENT-INSTRUCTIONS:END -->/{f=0; next} f'
  } >.cursor/rules/azg-agent-instructions.mdc

  {
    echo ''
    git -C "${ROOT}" show "${REF_SHA}:templates/project/AGENTS.md.tmpl" \
      | awk '/<!-- AZG:MANAGED:START -->/,/<!-- AZG:MANAGED:END -->/'
  } >>AGENTS.md

  for sk in azg-domain-research azg-domain-data-analysis azg-method-refs; do
    if git -C "${ROOT}" cat-file -e "${REF_SHA}:templates/global/skills/azg/${sk}/SKILL.md" 2>/dev/null; then
      mkdir -p ".agents/skills/${sk}" ".cursor/skills/${sk}"
      git -C "${ROOT}" show "${REF_SHA}:templates/global/skills/azg/${sk}/SKILL.md" \
        >".agents/skills/${sk}/SKILL.md"
      cp ".agents/skills/${sk}/SKILL.md" ".cursor/skills/${sk}/SKILL.md"
    fi
  done
  echo "${REF_SHA}" >.adherence-azg-ref
else
  echo 'baseline' >.adherence-azg-ref
fi

git add -A
git -c user.email=azg@test -c user.name=azg commit -qm "cell ${PROMPT_ID}/${ARM}" || true

# --- agent ---
info "agent model=${MODEL} arm=${ARM} prompt=${PROMPT_ID} cwd=${REPO_DIR}"
set +e
(
  cd "${REPO_DIR}"
  agent -p --force --trust --model "${MODEL}" \
    --workspace "${REPO_DIR}" \
    --output-format json \
    -- "${PROMPT_TEXT}"
) >"${CELL}/agent.json" 2>"${CELL}/agent.stderr.log"
AGENT_EC=$?
set -e

if [ -f "${CELL}/agent.json" ]; then
  jq -r '.result // empty' "${CELL}/agent.json" >"${CELL}/agent.log" 2>/dev/null \
    || cp "${CELL}/agent.json" "${CELL}/agent.log"
else
  echo "(no agent.json; ec=${AGENT_EC})" >"${CELL}/agent.log"
fi

SCORE=""
if [ "${AGENT_EC}" -ne 0 ]; then
  warn "agent exited ${AGENT_EC} — leaving task_success null (not heuristic-scored)"
  jq \
    --arg model "${MODEL}" \
    --arg notes "agent_ec=${AGENT_EC} unscored" \
    '.task_success=null | .model=$model | .notes=$notes' \
    "${SC}" >"${SC}.tmp" && mv "${SC}.tmp" "${SC}"
  info "unscored ${PROMPT_ID}/${ARM} agent_ec=${AGENT_EC}"
  exit 1
fi

SCORE="$("${ROOT}/evals/score-adherence-transcript.sh" "${PROMPT_ID}" "${CELL}/agent.log")"
jq \
  --argjson ts "${SCORE}" \
  --arg model "${MODEL}" \
  --arg notes "agent_ec=${AGENT_EC} heuristic=${SCORE}" \
  '.task_success=$ts | .model=$model | .notes=$notes' \
  "${SC}" >"${SC}.tmp" && mv "${SC}.tmp" "${SC}"

info "scored ${PROMPT_ID}/${ARM} task_success=${SCORE} agent_ec=${AGENT_EC}"
exit 0
