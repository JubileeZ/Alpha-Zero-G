#!/usr/bin/env bash
# evals/trap-fable-pack.sh ensure|inject <worktree>
# Cache upstream fable-method method pack (AGENTS.md + skills) at VENDOR.lock pin.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"

VENDOR="${ROOT}/evals/traps/vendor/fable-method"
LOCK_FILE="${VENDOR}/VENDOR.lock"
[ -f "${LOCK_FILE}" ] || die "missing ${LOCK_FILE}"

fable_pack_dir() {
  local lock cache
  lock="$(tr -d '[:space:]' <"${LOCK_FILE}")"
  [ -n "${lock}" ] || die "empty VENDOR.lock"
  cache="${ROOT}/evals/traps/worktrees/fable-pack/${lock}"
  if [ ! -f "${cache}/AGENTS.md" ]; then
    mkdir -p "$(dirname "${cache}")"
    rm -rf "${cache}"
    info "fetching fable-method pack ${lock:0:12}"
    git clone --depth 1 "https://github.com/Sahir619/fable-method.git" "${cache}"
    local got
    got="$(git -C "${cache}" rev-parse HEAD)"
    if [ "${got}" != "${lock}" ]; then
      git -C "${cache}" fetch --depth 1 origin "${lock}"
      git -C "${cache}" checkout -q "${lock}"
    fi
    [ -f "${cache}/AGENTS.md" ] || die "fable pack missing AGENTS.md at ${lock:0:12}"
  fi
  printf '%s\n' "${cache}"
}

inject_fable_pack() {
  local wt="${1:?worktree}" cache
  cache="$(fable_pack_dir)"
  cp "${cache}/AGENTS.md" "${wt}/AGENTS.md"
  mkdir -p "${wt}/.cursor/skills" "${wt}/.agents/skills"
  for sk in fable-method fable-loop fable-judge fable-domain; do
    [ -d "${cache}/skills/${sk}" ] || continue
    rm -rf "${wt}/.cursor/skills/${sk}" "${wt}/.agents/skills/${sk}"
    cp -R "${cache}/skills/${sk}" "${wt}/.cursor/skills/"
    cp -R "${cache}/skills/${sk}" "${wt}/.agents/skills/"
  done
  tr -d '[:space:]' <"${LOCK_FILE}" >"${wt}/.trap-fable-ref"
}

cmd="${1:-}"
case "${cmd}" in
  ensure) fable_pack_dir >/dev/null ;;
  inject) inject_fable_pack "${2:?worktree}" ;;
  path) fable_pack_dir ;;
  *) die "usage: trap-fable-pack.sh ensure|inject <worktree>|path" ;;
esac
