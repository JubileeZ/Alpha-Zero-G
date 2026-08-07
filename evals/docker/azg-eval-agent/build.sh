#!/usr/bin/env bash
# evals/docker/azg-eval-agent/build.sh — build azg-eval-agent:<VERSION>
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"

command -v docker >/dev/null || die "docker required to build azg-eval-agent"
VER="$(tr -d '[:space:]' <"${DIR}/VERSION")"
[ -n "${VER}" ] || die "empty VERSION"
IMAGE="${AZG_EVAL_AGENT_IMAGE:-azg-eval-agent:${VER}}"

info "building ${IMAGE} (AGENT_VERSION=${VER})"
docker build \
  --build-arg "AGENT_VERSION=${VER}" \
  -t "${IMAGE}" \
  -t "azg-eval-agent:latest" \
  "${DIR}"
info "built ${IMAGE}"
printf '%s\n' "${IMAGE}"
