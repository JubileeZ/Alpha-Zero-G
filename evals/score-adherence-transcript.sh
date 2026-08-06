#!/usr/bin/env bash
# evals/score-adherence-transcript.sh — heuristic 0|1 from agent log + prompt id
set -euo pipefail
ID="${1:?prompt_id}"
LOG="${2:?agent.log}"
[ -f "${LOG}" ] || { echo 0; exit 0; }
TEXT="$(tr '\n' ' ' <"${LOG}" | tr '[:upper:]' '[:lower:]')"

has() { echo "${TEXT}" | grep -Fq "$1"; }

case "${ID}" in
  trivial)
    if has 'intent:' || has 'verified:' || has 'refuted:'; then echo 0; else echo 1; fi
    ;;
  nontrivial)
    if has 'intent:' && { has 'verified:' || has 'caveats:' || has 'refuted:'; }; then echo 1; else echo 0; fi
    ;;
  research)
    if has 'azg-domain-research'; then echo 1; else echo 0; fi
    ;;
  data)
    if has 'azg-domain-data-analysis'; then echo 1; else echo 0; fi
    ;;
  outward)
    if has 'pending:'; then echo 1; else echo 0; fi
    ;;
  *)
    echo 0
    ;;
esac
