# azg-eval-agent — Cursor Agent CLI in an empty home (Eval Isolation, ADR 0013).
# Never bake host ~/.cursor into this image.
ARG AGENT_VERSION=2026.08.04-aaa8809
ARG TARGETOS=linux
ARG TARGETARCH=x64

FROM debian:bookworm-slim
ARG AGENT_VERSION
ARG TARGETOS
ARG TARGETARCH

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash ca-certificates curl git python3 python3-pip jq \
    && rm -rf /var/lib/apt/lists/*

# Non-root eval user with empty home (no Cursor rules/skills).
RUN useradd -m -d /home/azg-eval -s /bin/bash azg-eval \
    && mkdir -p /home/azg-eval/.local/bin /home/azg-eval/.local/share/cursor-agent/versions \
       /home/azg-eval/.cursor-agent /home/azg-eval/.config/cursor \
    && chown -R azg-eval:azg-eval /home/azg-eval

USER azg-eval
WORKDIR /home/azg-eval
ENV HOME=/home/azg-eval \
    PATH="/home/azg-eval/.local/bin:${PATH}" \
    AZG_EVAL_ISOLATION=docker

# Pin Agent CLI from Cursor lab downloads (same URL family as cursor.com/install).
RUN bash -euo pipefail -c '\
    ver="${AGENT_VERSION}"; \
    url="https://downloads.cursor.com/lab/${ver}/${TARGETOS}/${TARGETARCH}/agent-cli-package.tar.gz"; \
    dest="/home/azg-eval/.local/share/cursor-agent/versions/${ver}"; \
    mkdir -p "${dest}"; \
    curl -fsSL "${url}" | tar --strip-components=1 -xzf - -C "${dest}"; \
    ln -sf "${dest}/cursor-agent" /home/azg-eval/.local/bin/agent; \
    ln -sf "${dest}/cursor-agent" /home/azg-eval/.local/bin/cursor-agent; \
    agent --version'

LABEL org.opencontainers.image.title="azg-eval-agent" \
      org.opencontainers.image.description="Isolated Cursor Agent CLI for azg Trap/Lite evals" \
      azg.agent.version="${AGENT_VERSION}"
