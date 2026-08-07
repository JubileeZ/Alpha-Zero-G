#!/usr/bin/env bash
# evals/run-agent-isolated.sh — run Cursor Agent CLI under Eval Isolation (ADR 0013).
#
# Default: Docker image azg-eval-agent (empty HOME; no host ~/.cursor).
# Escape: AZG_EVAL_DOCKER=0 → host agent; callers must tag isolation=host (not promote-grade).
#
# Usage:
#   bash evals/run-agent-isolated.sh [--workspace DIR] -- [agent args...]
# Prints isolation mode on fd 3 if open: docker|host
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"

WORKSPACE=""
EVAL_HOME=""
while [ $# -gt 0 ]; do
  case "$1" in
    --workspace) WORKSPACE="$2"; shift 2 ;;
    --home) EVAL_HOME="$2"; shift 2 ;;
    --) shift; break ;;
    -h|--help)
      cat <<'EOF'
Usage: run-agent-isolated.sh [--workspace DIR] [--home DIR] -- [agent args...]

Env:
  AZG_EVAL_DOCKER=1|0   default 1 (Docker). 0 = host agent (isolation=host).
  AZG_EVAL_AGENT_IMAGE  default azg-eval-agent:<VERSION> from evals/docker/azg-eval-agent/VERSION
  CURSOR_API_KEY        preferred auth in Docker
  AZG_EVAL_AUTH_JSON    override path to auth.json (default ~/.cursor-agent/auth.json)

--home DIR  Eval Device Home (azg-owned rules/skills). Mounted read-only under
            container $HOME/.cursor/{rules,skills} and $HOME/.agents/skills.
            Never mount host ~/.cursor. Baseline omits --home.
EOF
      exit 0
      ;;
    *) die "unknown arg: $1 (use -- before agent args)" ;;
  esac
done
[ $# -gt 0 ] || die "missing agent args after --"

# Default ON
USE_DOCKER=1
case "${AZG_EVAL_DOCKER:-1}" in
  0|false|FALSE|no|NO|off|OFF) USE_DOCKER=0 ;;
esac

emit_isolation() {
  local mode="$1"
  if [ -n "${AZG_EVAL_ISOLATION_FILE:-}" ]; then
    # Parent dir may be gone (stale env from a prior probe) — never fail the agent for this.
    mkdir -p "$(dirname "${AZG_EVAL_ISOLATION_FILE}")" 2>/dev/null || true
    printf '%s\n' "${mode}" >"${AZG_EVAL_ISOLATION_FILE}" 2>/dev/null || true
  fi
  # optional fd 3
  if { true >&3; } 2>/dev/null; then
    printf '%s\n' "${mode}" >&3 2>/dev/null || true
  fi
}

if [ "${USE_DOCKER}" -eq 0 ]; then
  export PATH="${HOME}/.local/bin:${PATH}"
  command -v agent >/dev/null || die "agent CLI missing on host"
  emit_isolation host
  warn "Eval Isolation=host (AZG_EVAL_DOCKER=0) — not promote-grade"
  if [ -n "${WORKSPACE}" ]; then
    cd "${WORKSPACE}"
  fi
  exec agent "$@"
fi

command -v docker >/dev/null || die "docker required (or set AZG_EVAL_DOCKER=0 for host smoke)"
VER="$(tr -d '[:space:]' <"${ROOT}/evals/docker/azg-eval-agent/VERSION")"
IMAGE="${AZG_EVAL_AGENT_IMAGE:-azg-eval-agent:${VER}}"
if ! docker image inspect "${IMAGE}" >/dev/null 2>&1; then
  info "image ${IMAGE} missing — building"
  bash "${ROOT}/evals/docker/azg-eval-agent/build.sh" >/dev/null
fi

AUTH_JSON="${AZG_EVAL_AUTH_JSON:-}"
if [ -z "${AUTH_JSON}" ]; then
  if [ -f "${HOME}/.cursor-agent/auth.json" ]; then
    AUTH_JSON="${HOME}/.cursor-agent/auth.json"
  elif [ -f "${HOME}/.config/cursor/auth.json" ]; then
    AUTH_JSON="${HOME}/.config/cursor/auth.json"
  fi
fi

DOCKER_ARGS=(run --rm -i)
# Network for Cursor API
DOCKER_ARGS+=(--network host)
DOCKER_ARGS+=(-e HOME=/home/azg-eval -e PATH=/home/azg-eval/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin)
DOCKER_ARGS+=(-u azg-eval)

if [ -n "${CURSOR_API_KEY:-}" ]; then
  DOCKER_ARGS+=(-e "CURSOR_API_KEY=${CURSOR_API_KEY}")
elif [ -n "${AUTH_JSON}" ] && [ -f "${AUTH_JSON}" ]; then
  # Agent may read either path under HOME — mount both from the same host file.
  DOCKER_ARGS+=(-v "${AUTH_JSON}:/home/azg-eval/.cursor-agent/auth.json:ro")
  DOCKER_ARGS+=(-v "${AUTH_JSON}:/home/azg-eval/.config/cursor/auth.json:ro")
else
  die "Docker eval needs CURSOR_API_KEY or auth.json (~/.cursor-agent or ~/.config/cursor)"
fi

# Hard rule: never mount host ~/.cursor
if [ -n "${WORKSPACE}" ]; then
  [ -d "${WORKSPACE}" ] || die "workspace not a directory: ${WORKSPACE}"
  # Bind at same absolute path so --workspace args match host paths
  DOCKER_ARGS+=(-v "${WORKSPACE}:${WORKSPACE}" -w "${WORKSPACE}")
fi

# Eval Device Home (grill): mount staged rules/skills only — keep image $HOME/.local/agent
if [ -n "${EVAL_HOME}" ]; then
  [ -d "${EVAL_HOME}/.cursor/rules" ] || die "eval home missing .cursor/rules: ${EVAL_HOME}"
  DOCKER_ARGS+=(-v "${EVAL_HOME}/.cursor/rules:/home/azg-eval/.cursor/rules:ro")
  if [ -d "${EVAL_HOME}/.cursor/skills" ]; then
    DOCKER_ARGS+=(-v "${EVAL_HOME}/.cursor/skills:/home/azg-eval/.cursor/skills:ro")
  fi
  if [ -d "${EVAL_HOME}/.agents/skills" ]; then
    DOCKER_ARGS+=(-v "${EVAL_HOME}/.agents/skills:/home/azg-eval/.agents/skills:ro")
  fi
fi

# Safety: refuse if someone exported a cursor mount hint
case "${AZG_EVAL_DOCKER_EXTRA_MOUNTS:-}" in
  *'/.cursor:'*|*'/.cursor/'*) die "refusing mount that looks like host ~/.cursor" ;;
esac

DOCKER_ARGS+=("${IMAGE}" agent "$@")

emit_isolation docker
exec docker "${DOCKER_ARGS[@]}"
