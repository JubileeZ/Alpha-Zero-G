#!/usr/bin/env bash
# evals/stage-execution-protocol-v1-home.sh — stage Candidate Treatment from
# templates/candidates/execution-protocol-v1/ into a fake HOME (Eval Device Home).
# Usage: bash evals/stage-execution-protocol-v1-home.sh <dest-dir>
# Does NOT read templates/global/ — Candidate-only until Trap promote.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"

DEST="${1:-}"
[ -n "${DEST}" ] || die "usage: stage-execution-protocol-v1-home.sh <dest-dir>"

CAND="${ROOT}/templates/candidates/execution-protocol-v1"
AGENTS="${CAND}/AGENTS.md"
STUB="${CAND}/cursor/rules/azg-agent-instructions.mdc"
[ -f "${AGENTS}" ] || die "missing candidate AGENTS: ${AGENTS}"
[ -f "${STUB}" ] || die "missing candidate rule stub: ${STUB}"

AGENTS_HASH="$(cksum "${AGENTS}" | awk '{print $1"-"$2}')"
STUB_HASH="$(cksum "${STUB}" | awk '{print $1"-"$2}')"
FINGERPRINT="execution-protocol-v1:ag${AGENTS_HASH}:stub${STUB_HASH}"
MARKER="${DEST}/.azg-eval-home-ref"

if [ -f "${MARKER}" ] && [ "$(cat "${MARKER}")" = "${FINGERPRINT}" ] \
  && [ -f "${DEST}/.cursor/rules/azg-agent-instructions.mdc" ] \
  && [ ! -f "${DEST}/.cursor/rules/azg-ponytail.mdc" ]; then
  info "execution-protocol-v1 eval home ready ${DEST} @ ${FINGERPRINT}"
  exit 0
fi

LOCKDIR="${DEST}.lock"
mkdir -p "$(dirname "${DEST}")"
for _i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30; do
  if mkdir "${LOCKDIR}" 2>/dev/null; then
    break
  fi
  if [ -f "${MARKER}" ] && [ "$(cat "${MARKER}")" = "${FINGERPRINT}" ]; then
    info "execution-protocol-v1 eval home ready ${DEST} @ ${FINGERPRINT} (waited)"
    exit 0
  fi
  sleep 0.2
done
[ -d "${LOCKDIR}" ] || die "could not lock ${DEST}"
cleanup_lock() { rmdir "${LOCKDIR}" 2>/dev/null || true; }
trap cleanup_lock EXIT

TMP="$(mktemp -d "${TMPDIR:-/tmp}/azg-epv1-home-XXXXXX")"
mkdir -p "${TMP}/.cursor/rules"

awk '{ sub(/\r$/, ""); print }' "${STUB}" >"${TMP}/.cursor/rules/azg-agent-instructions.mdc"
extract_managed_block "${AGENTS}" \
  '<!-- AZG:AGENT-INSTRUCTIONS:START -->' \
  '<!-- AZG:AGENT-INSTRUCTIONS:END -->' \
  >>"${TMP}/.cursor/rules/azg-agent-instructions.mdc" \
  || die "empty/missing AGENT-INSTRUCTIONS markers in candidate AGENTS.md"

printf '%s\n' "${FINGERPRINT}" >"${TMP}/.azg-eval-home-ref"

rm -rf "${DEST}"
mkdir -p "$(dirname "${DEST}")"
mv "${TMP}" "${DEST}"
info "staged execution-protocol-v1 eval home ${DEST} @ ${FINGERPRINT}"
