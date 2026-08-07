#!/usr/bin/env bash
# evals/traps/run-tier-sweep.sh — one full Trap Suite loop per model tier.
# Default tiers: gpt-5.6-luna-low · medium · high (clean-slate Current = HEAD worktree).
# Usage: bash evals/traps/run-tier-sweep.sh [--force]
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${ROOT}"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"

export PATH="${HOME}/.local/bin:${PATH}"
export TRAP_FULL=1
export TRAP_JOBS="${TRAP_JOBS:-12}"
export AZG_CURRENT_REF="${AZG_CURRENT_REF:-HEAD}"
export TRAP_CANDIDATE_PACK="${TRAP_CANDIDATE_PACK:-fable-method}"
export AZG_CANDIDATE_REF="${AZG_CANDIDATE_REF:-HEAD}"
export AZG_EVAL_DOCKER="${AZG_EVAL_DOCKER:-1}"
# Clean slate: do not stage parked azg distill skills
export AZG_EVAL_AZG_SKILLS="${AZG_EVAL_AZG_SKILLS:-0}"

PARENT="${TRAP_CAMP:-${ROOT}/evals/traps/campaigns/cleanslate-tier-sweep}"
TIERS="${TRAP_TIERS:-gpt-5.6-luna-low gpt-5.6-luna-medium gpt-5.6-luna-high}"

FORCE_FLAG=""
for a in "$@"; do
  case "$a" in
    --force) FORCE_FLAG=--force ;;
  esac
done

mkdir -p "${PARENT}"
skills_json="${AZG_EVAL_AZG_SKILLS:-0}"
jq -n \
  --argjson full 1 \
  --arg pack "${TRAP_CANDIDATE_PACK}" \
  --arg cref "${AZG_CURRENT_REF}" \
  --argjson skills "${skills_json}" \
  --arg note "clean-slate Current (Ponytail+cleanup+telegraphic); Fable Candidate; one full loop per tier" \
  --arg tiers "${TIERS}" \
  '{
    trap_full: $full,
    tiers: ($tiers | split(" ") | map(select(length>0))),
    candidate_pack: $pack,
    current_ref: $cref,
    azg_eval_azg_skills: $skills,
    isolation: "docker",
    note: $note
  }' >"${PARENT}/meta.json"

echo $$ >"${PARENT}/campaign.pid"
info "tier sweep parent=${PARENT} tiers=${TIERS}"

for m in ${TIERS}; do
  short="${m##*-}" # low|medium|high
  export TRAP_MODEL="${m}"
  export TRAP_CAMP="${PARENT}/${short}"
  info "=== tier ${short} model=${m} camp=${TRAP_CAMP} ==="
  bash "${ROOT}/evals/prepare-trap-campaign.sh" "${TRAP_CAMP}"
  # shellcheck disable=SC2086
  bash "${ROOT}/evals/run-trap-campaign.sh" --jobs "${TRAP_JOBS}" ${FORCE_FLAG}
done

bash "${ROOT}/evals/analyze-trap-tiers.sh" "${PARENT}"
info "tier sweep finished → ${PARENT}/TIERS.md"
rm -f "${PARENT}/campaign.pid"
printf 'AZG_TRAP_CAMPAIGN_FINISHED parent=%s artifact=%s\n' "${PARENT}" "${PARENT}/TIERS.md"
