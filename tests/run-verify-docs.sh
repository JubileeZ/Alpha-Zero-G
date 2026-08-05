#!/usr/bin/env bash
# tests/run-verify-docs.sh — cross-platform launcher for verify_docs.py
# Tries python3, python, then Windows py -3 (Store stubs are ignored).

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="${ROOT}/tests/verify_docs.py"

if [ ! -f "${SCRIPT}" ]; then
  printf 'verify_docs.py not found: %s\n' "${SCRIPT}" >&2
  exit 1
fi

_py_ok() {
  local cmd="${1}"
  shift
  "${cmd}" "$@" -c 'import sys; sys.exit(0 if sys.version_info[0] >= 3 else 1)' 2>/dev/null
}

if _py_ok python3; then
  exec python3 "${SCRIPT}"
fi
if _py_ok python; then
  exec python "${SCRIPT}"
fi
if command -v py >/dev/null 2>&1 && _py_ok py -3; then
  exec py -3 "${SCRIPT}"
fi

printf 'No Python 3 found (tried python3, python, py -3).\n' >&2
exit 127
