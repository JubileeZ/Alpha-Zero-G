#!/usr/bin/env bash
# evals/stage-eval-home.sh — stage azg-owned Device Setup core into a fake HOME (ADR 0013).
# Usage: bash evals/stage-eval-home.sh <git-ref> <dest-dir>
# Contents: Ponytail + AGENT-INSTRUCTIONS .mdc + azg skills from that ref.
# Idempotent when dest/.azg-eval-home-ref matches resolved SHA.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"

REF_IN="${1:-}"
DEST="${2:-}"
[ -n "${REF_IN}" ] && [ -n "${DEST}" ] || die "usage: stage-eval-home.sh <git-ref> <dest-dir>"

SHA="$(git -C "${ROOT}" rev-parse "${REF_IN}^{commit}")"
MARKER="${DEST}/.azg-eval-home-ref"

if [ -f "${MARKER}" ] && [ "$(cat "${MARKER}")" = "${SHA}" ] \
  && [ -f "${DEST}/.cursor/rules/azg-ponytail.mdc" ] \
  && [ -f "${DEST}/.cursor/rules/azg-agent-instructions.mdc" ]; then
  info "eval home ready ${DEST} @ ${SHA}"
  exit 0
fi

# Serialize rebuilds of the same dest (parallel trap cells)
LOCKDIR="${DEST}.lock"
mkdir -p "$(dirname "${DEST}")"
for _i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30; do
  if mkdir "${LOCKDIR}" 2>/dev/null; then
    break
  fi
  # Another cell may have finished staging while we waited
  if [ -f "${MARKER}" ] && [ "$(cat "${MARKER}")" = "${SHA}" ]; then
    info "eval home ready ${DEST} @ ${SHA} (waited)"
    exit 0
  fi
  sleep 0.2
done
[ -d "${LOCKDIR}" ] || die "could not lock ${DEST}"

cleanup_lock() { rmdir "${LOCKDIR}" 2>/dev/null || true; }
trap cleanup_lock EXIT

# Re-check under lock
if [ -f "${MARKER}" ] && [ "$(cat "${MARKER}")" = "${SHA}" ] \
  && [ -f "${DEST}/.cursor/rules/azg-ponytail.mdc" ]; then
  info "eval home ready ${DEST} @ ${SHA}"
  exit 0
fi

TMP="$(mktemp -d "${TMPDIR:-/tmp}/azg-eval-home-XXXXXX")"
AGENTS_TMP="${TMP}/AGENTS.md"
git -C "${ROOT}" show "${SHA}:templates/global/AGENTS.md" >"${AGENTS_TMP}"

render_rule() {
  local rule_base="$1" start_m="$2" end_m="$3"
  local stub_ref="templates/global/cursor/rules/${rule_base}"
  local out="${TMP}/.cursor/rules/${rule_base}"
  mkdir -p "$(dirname "${out}")"
  if git -C "${ROOT}" cat-file -e "${SHA}:${stub_ref}" 2>/dev/null; then
    git -C "${ROOT}" show "${SHA}:${stub_ref}" | awk '{ sub(/\r$/, ""); print }' >"${out}"
  else
    # Older refs may lack stubs — fall back to live templates (frontmatter only)
    local stub="${ROOT}/templates/global/cursor/rules/${rule_base}"
    [ -f "${stub}" ] || die "missing rule stub: ${stub}"
    awk '{ sub(/\r$/, ""); print }' "${stub}" >"${out}"
  fi
  extract_managed_block "${AGENTS_TMP}" "${start_m}" "${end_m}" >>"${out}" \
    || die "empty/missing marker block for ${rule_base} at ${SHA}"
}

mkdir -p "${TMP}/.cursor/rules" "${TMP}/.cursor/skills" "${TMP}/.agents/skills"
render_rule azg-ponytail.mdc '<!-- PONYTAIL:MANAGED:START -->' '<!-- PONYTAIL:MANAGED:END -->'
render_rule azg-agent-instructions.mdc '<!-- AZG:AGENT-INSTRUCTIONS:START -->' '<!-- AZG:AGENT-INSTRUCTIONS:END -->'

for sk in azg-domain-research azg-domain-data-analysis azg-method-refs; do
  if ! git -C "${ROOT}" cat-file -e "${SHA}:templates/global/skills/azg/${sk}/SKILL.md" 2>/dev/null; then
    die "missing azg skill at ${SHA}: ${sk}"
  fi
  mkdir -p "${TMP}/.cursor/skills/${sk}" "${TMP}/.agents/skills/${sk}"
  git -C "${ROOT}" show "${SHA}:templates/global/skills/azg/${sk}/SKILL.md" \
    >"${TMP}/.cursor/skills/${sk}/SKILL.md"
  cp "${TMP}/.cursor/skills/${sk}/SKILL.md" "${TMP}/.agents/skills/${sk}/SKILL.md"
done

printf '%s\n' "${SHA}" >"${TMP}/.azg-eval-home-ref"

rm -rf "${DEST}"
mkdir -p "$(dirname "${DEST}")"
mv "${TMP}" "${DEST}"
info "staged eval home ${DEST} @ ${SHA}"
