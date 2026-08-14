#!/usr/bin/env bash
# evals/stage-eval-home.sh — stage azg-owned Device Setup core into a fake HOME (ADR 0013).
# Usage: bash evals/stage-eval-home.sh <git-ref> <dest-dir>
# Contents: AGENT-INSTRUCTIONS .mdc + azg Device Setup skills present at ref
# (ponytail retired from always-on — ADR 0015).
# When ref resolves to HEAD, prefer worktree templates (uncommitted Candidate OK).
# Idempotent when dest/.azg-eval-home-ref matches fingerprint.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"

REF_IN="${1:-}"
DEST="${2:-}"
[ -n "${REF_IN}" ] && [ -n "${DEST}" ] || die "usage: stage-eval-home.sh <git-ref> <dest-dir>"

SHA="$(git -C "${ROOT}" rev-parse "${REF_IN}^{commit}")"
HEAD_SHA="$(git -C "${ROOT}" rev-parse HEAD)"
USE_WT=0
[ "${SHA}" = "${HEAD_SHA}" ] && USE_WT=1

AGENTS_SRC="${ROOT}/templates/global/AGENTS.md"
if [ "${USE_WT}" -eq 1 ] && [ -f "${AGENTS_SRC}" ]; then
  AGENTS_HASH="$(cksum "${AGENTS_SRC}" | awk '{print $1"-"$2}')"
else
  AGENTS_HASH="$(git -C "${ROOT}" show "${SHA}:templates/global/AGENTS.md" | cksum | awk '{print $1"-"$2}')"
fi
SK_HASH="none"
if [ "${USE_WT}" -eq 1 ] && [ -d "${ROOT}/templates/global/skills/azg" ]; then
  _sk_blob=""
  for _sk_md in "${ROOT}/templates/global/skills/azg"/*/SKILL.md; do
    [ -f "${_sk_md}" ] || continue
    _sk_blob="${_sk_blob}$(cksum "${_sk_md}" | awk '{print $1"-"$2}')"
  done
  [ -n "${_sk_blob}" ] && SK_HASH="$(printf '%s' "${_sk_blob}" | cksum | awk '{print $1"-"$2}')"
elif git -C "${ROOT}" cat-file -e "${SHA}:templates/global/skills/azg" 2>/dev/null; then
  SK_HASH="$(git -C "${ROOT}" ls-tree -r --name-only "${SHA}" templates/global/skills/azg \
    | grep '/SKILL.md$' | cksum | awk '{print $1"-"$2}')"
fi
[ -n "${SK_HASH}" ] || SK_HASH="none"
FINGERPRINT="${SHA}:wt${USE_WT}:sk${SK_HASH}:ag${AGENTS_HASH}:nopony"
MARKER="${DEST}/.azg-eval-home-ref"

if [ -f "${MARKER}" ] && [ "$(cat "${MARKER}")" = "${FINGERPRINT}" ] \
  && [ -f "${DEST}/.cursor/rules/azg-agent-instructions.mdc" ] \
  && [ ! -f "${DEST}/.cursor/rules/azg-ponytail.mdc" ]; then
  info "eval home ready ${DEST} @ ${FINGERPRINT}"
  exit 0
fi

# Serialize rebuilds of the same dest (parallel trap cells)
LOCKDIR="${DEST}.lock"
mkdir -p "$(dirname "${DEST}")"
for _i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30; do
  if mkdir "${LOCKDIR}" 2>/dev/null; then
    break
  fi
  if [ -f "${MARKER}" ] && [ "$(cat "${MARKER}")" = "${FINGERPRINT}" ]; then
    info "eval home ready ${DEST} @ ${FINGERPRINT} (waited)"
    exit 0
  fi
  sleep 0.2
done
[ -d "${LOCKDIR}" ] || die "could not lock ${DEST}"

cleanup_lock() { rmdir "${LOCKDIR}" 2>/dev/null || true; }
trap cleanup_lock EXIT

if [ -f "${MARKER}" ] && [ "$(cat "${MARKER}")" = "${FINGERPRINT}" ] \
  && [ -f "${DEST}/.cursor/rules/azg-agent-instructions.mdc" ] \
  && [ ! -f "${DEST}/.cursor/rules/azg-ponytail.mdc" ]; then
  info "eval home ready ${DEST} @ ${FINGERPRINT}"
  exit 0
fi

TMP="$(mktemp -d "${TMPDIR:-/tmp}/azg-eval-home-XXXXXX")"
AGENTS_TMP="${TMP}/AGENTS.md"
if [ "${USE_WT}" -eq 1 ] && [ -f "${AGENTS_SRC}" ]; then
  awk '{ sub(/\r$/, ""); print }' "${AGENTS_SRC}" >"${AGENTS_TMP}"
else
  git -C "${ROOT}" show "${SHA}:templates/global/AGENTS.md" >"${AGENTS_TMP}"
fi

render_rule() {
  local rule_base="$1" start_m="$2" end_m="$3"
  local stub_ref="templates/global/cursor/rules/${rule_base}"
  local stub_wt="${ROOT}/${stub_ref}"
  local out="${TMP}/.cursor/rules/${rule_base}"
  mkdir -p "$(dirname "${out}")"
  if [ "${USE_WT}" -eq 1 ] && [ -f "${stub_wt}" ]; then
    awk '{ sub(/\r$/, ""); print }' "${stub_wt}" >"${out}"
  elif git -C "${ROOT}" cat-file -e "${SHA}:${stub_ref}" 2>/dev/null; then
    git -C "${ROOT}" show "${SHA}:${stub_ref}" | awk '{ sub(/\r$/, ""); print }' >"${out}"
  else
    [ -f "${stub_wt}" ] || die "missing rule stub: ${stub_wt}"
    awk '{ sub(/\r$/, ""); print }' "${stub_wt}" >"${out}"
  fi
  extract_managed_block "${AGENTS_TMP}" "${start_m}" "${end_m}" >>"${out}" \
    || die "empty/missing marker block for ${rule_base} at ${SHA}"
}

mkdir -p "${TMP}/.cursor/rules" "${TMP}/.cursor/skills" "${TMP}/.agents/skills"
render_rule azg-agent-instructions.mdc '<!-- AZG:AGENT-INSTRUCTIONS:START -->' '<!-- AZG:AGENT-INSTRUCTIONS:END -->'

_stage_azg_skill() {
  local sk="$1"
  local sk_wt="${ROOT}/templates/global/skills/azg/${sk}/SKILL.md"
  mkdir -p "${TMP}/.cursor/skills/${sk}" "${TMP}/.agents/skills/${sk}"
  if [ "${USE_WT}" -eq 1 ] && [ -f "${sk_wt}" ]; then
    cp "${sk_wt}" "${TMP}/.cursor/skills/${sk}/SKILL.md"
  elif git -C "${ROOT}" cat-file -e "${SHA}:templates/global/skills/azg/${sk}/SKILL.md" 2>/dev/null; then
    git -C "${ROOT}" show "${SHA}:templates/global/skills/azg/${sk}/SKILL.md" \
      >"${TMP}/.cursor/skills/${sk}/SKILL.md"
  else
    return 0
  fi
  cp "${TMP}/.cursor/skills/${sk}/SKILL.md" "${TMP}/.agents/skills/${sk}/SKILL.md"
}
if [ "${USE_WT}" -eq 1 ] && [ -d "${ROOT}/templates/global/skills/azg" ]; then
  for sk_dir in "${ROOT}/templates/global/skills/azg"/*/; do
    [ -d "${sk_dir}" ] || continue
    [ -f "${sk_dir}/SKILL.md" ] || continue
    _stage_azg_skill "$(basename "${sk_dir}")"
  done
elif git -C "${ROOT}" cat-file -e "${SHA}:templates/global/skills/azg" 2>/dev/null; then
  while IFS= read -r sk; do
    [ -n "${sk}" ] || continue
    _stage_azg_skill "${sk}"
  done < <(git -C "${ROOT}" ls-tree --name-only "${SHA}:templates/global/skills/azg" \
    | awk -F/ 'NF==1 {print}')
fi

printf '%s\n' "${FINGERPRINT}" >"${TMP}/.azg-eval-home-ref"

rm -rf "${DEST}"
mkdir -p "$(dirname "${DEST}")"
mv "${TMP}" "${DEST}"
info "staged eval home ${DEST} @ ${FINGERPRINT}"
