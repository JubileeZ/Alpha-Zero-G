#!/usr/bin/env bash
# evals/stage-execution-protocol-v2-home.sh — stage Candidate Treatment from
# templates/candidates/execution-protocol-v2/ into a fake HOME (Eval Device Home).
# Usage: bash evals/stage-execution-protocol-v2-home.sh <dest-dir>
# Does NOT read templates/global/ — Candidate-only until Trap promote.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"

DEST="${1:-}"
[ -n "${DEST}" ] || die "usage: stage-execution-protocol-v2-home.sh <dest-dir>"

CAND="${ROOT}/templates/candidates/execution-protocol-v2"
AGENTS="${CAND}/AGENTS.md"
STUB="${CAND}/cursor/rules/azg-agent-instructions.mdc"
[ -f "${AGENTS}" ] || die "missing candidate AGENTS: ${AGENTS}"
[ -f "${STUB}" ] || die "missing candidate rule stub: ${STUB}"
[ -f "${CAND}/skills/orchestrate/SKILL.md" ] || die "missing orchestrate skill"
[ -f "${CAND}/skills/judge/SKILL.md" ] || die "missing judge skill"

AGENTS_HASH="$(cksum "${AGENTS}" | awk '{print $1"-"$2}')"
ORCH_HASH="$(cksum "${CAND}/skills/orchestrate/SKILL.md" | awk '{print $1"-"$2}')"
JUDGE_HASH="$(cksum "${CAND}/skills/judge/SKILL.md" | awk '{print $1"-"$2}')"
FINGERPRINT="execution-protocol-v2:ag${AGENTS_HASH}:orch${ORCH_HASH}:judge${JUDGE_HASH}"
MARKER="${DEST}/.azg-eval-home-ref"

if [ -f "${MARKER}" ] && [ "$(cat "${MARKER}")" = "${FINGERPRINT}" ] \
  && [ -f "${DEST}/.cursor/rules/azg-agent-instructions.mdc" ] \
  && [ ! -f "${DEST}/.cursor/rules/azg-ponytail.mdc" ] \
  && [ -f "${DEST}/.cursor/skills/orchestrate/SKILL.md" ] \
  && [ -f "${DEST}/.cursor/skills/judge/SKILL.md" ]; then
  info "execution-protocol-v2 eval home ready ${DEST} @ ${FINGERPRINT}"
  exit 0
fi

LOCKDIR="${DEST}.lock"
mkdir -p "$(dirname "${DEST}")"
for _i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30; do
  if mkdir "${LOCKDIR}" 2>/dev/null; then
    break
  fi
  if [ -f "${MARKER}" ] && [ "$(cat "${MARKER}")" = "${FINGERPRINT}" ]; then
    info "execution-protocol-v2 eval home ready ${DEST} @ ${FINGERPRINT} (waited)"
    exit 0
  fi
  sleep 0.2
done
[ -d "${LOCKDIR}" ] || die "could not lock ${DEST}"
cleanup_lock() { rmdir "${LOCKDIR}" 2>/dev/null || true; }
trap cleanup_lock EXIT

TMP="$(mktemp -d "${TMPDIR:-/tmp}/azg-epv2-home-XXXXXX")"
mkdir -p "${TMP}/.cursor/rules" "${TMP}/.cursor/skills" "${TMP}/.agents/skills"

awk '{ sub(/\r$/, ""); print }' "${STUB}" >"${TMP}/.cursor/rules/azg-agent-instructions.mdc"
extract_managed_block "${AGENTS}" \
  '<!-- AZG:AGENT-INSTRUCTIONS:START -->' \
  '<!-- AZG:AGENT-INSTRUCTIONS:END -->' \
  >>"${TMP}/.cursor/rules/azg-agent-instructions.mdc" \
  || die "empty/missing AGENT-INSTRUCTIONS markers in candidate AGENTS.md"

for sk in orchestrate judge; do
  mkdir -p "${TMP}/.cursor/skills/${sk}" "${TMP}/.agents/skills/${sk}"
  cp "${CAND}/skills/${sk}/SKILL.md" "${TMP}/.cursor/skills/${sk}/SKILL.md"
  cp "${CAND}/skills/${sk}/SKILL.md" "${TMP}/.agents/skills/${sk}/SKILL.md"
done

printf '%s\n' "${FINGERPRINT}" >"${TMP}/.azg-eval-home-ref"

rm -rf "${DEST}"
mkdir -p "$(dirname "${DEST}")"
mv "${TMP}" "${DEST}"
info "staged execution-protocol-v2 eval home ${DEST} @ ${FINGERPRINT}"
