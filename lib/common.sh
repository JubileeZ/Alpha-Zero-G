#!/usr/bin/env bash
# lib/common.sh — shared helpers for all azg subcommands
# Source this file: source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
# POSIX-safe: no sed -i, no ((VAR++)) with set -e, no bashisms beyond arrays.
# GHA macos-latest default bash is 3.2 — keep lib/ free of Bash 4-only builtins
# (array-load builtins, associative declare, case-modifying parameter expansion).

set -euo pipefail

# ---------------------------------------------------------------------------
# Version
# ---------------------------------------------------------------------------
AZG_VERSION="$(cat "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/VERSION" 2>/dev/null || echo "unknown")"
# Honor pre-set AZG_ROOT (tests / wrappers); else resolve from this file
if [ -z "${AZG_ROOT:-}" ]; then
  AZG_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

# ---------------------------------------------------------------------------
# Colors (disabled when not a terminal or NO_COLOR is set)
# ---------------------------------------------------------------------------
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  CLR_RESET="\033[0m"
  CLR_BOLD="\033[1m"
  CLR_RED="\033[0;31m"
  CLR_GREEN="\033[0;32m"
  CLR_YELLOW="\033[0;33m"
  CLR_BLUE="\033[0;34m"
  CLR_CYAN="\033[0;36m"
else
  CLR_RESET=""
  CLR_BOLD=""
  CLR_RED=""
  CLR_GREEN=""
  CLR_YELLOW=""
  CLR_BLUE=""
  CLR_CYAN=""
fi

# ---------------------------------------------------------------------------
# Logging helpers
# ---------------------------------------------------------------------------
info()    { printf "${CLR_BLUE}[azg]${CLR_RESET} %s\n" "$*"; }
ok()      { printf "${CLR_GREEN}[azg]${CLR_RESET} %s\n" "$*"; }
warn()    { printf "${CLR_YELLOW}[azg warn]${CLR_RESET} %s\n" "$*" >&2; }
err()     { printf "${CLR_RED}[azg error]${CLR_RESET} %s\n" "$*" >&2; }
die()     { err "$*"; exit 1; }
step()    { printf "${CLR_CYAN}[azg]${CLR_RESET} ${CLR_BOLD}%s${CLR_RESET}\n" "$*"; }

# ---------------------------------------------------------------------------
# OS detection
# ---------------------------------------------------------------------------
# Sets: AZG_OS ("linux" | "macos" | "windows" | "unknown")
detect_os() {
  local uname_s
  uname_s="$(uname -s 2>/dev/null || echo "Unknown")"
  case "${uname_s}" in
    Linux*)  AZG_OS="linux"   ;;
    Darwin*) AZG_OS="macos"   ;;
    MINGW*|MSYS*|CYGWIN*) AZG_OS="windows" ;;
    *)       AZG_OS="unknown" ;;
  esac
}

detect_os

# ---------------------------------------------------------------------------
# Dependency checks
# ---------------------------------------------------------------------------
# require_cmd CMD [INSTALL_HINT]
# Exits non-zero with an install hint if CMD is not in PATH.
require_cmd() {
  local cmd="${1}"
  local hint="${2:-}"
  if ! command -v "${cmd}" > /dev/null 2>&1; then
    if [ -n "${hint}" ]; then
      die "Required command '${cmd}' not found. ${hint}"
    else
      die "Required command '${cmd}' not found."
    fi
  fi
}

# Checks for jq; prints OS-specific install hint and exits if missing.
require_jq() {
  if command -v jq > /dev/null 2>&1; then
    return 0
  fi
  local hint
  case "${AZG_OS}" in
    linux)
      # Detect distro for a better hint
      if command -v pacman > /dev/null 2>&1; then
        hint="Install with: sudo pacman -S jq  (or: paru -S jq)"
      elif command -v apt-get > /dev/null 2>&1; then
        hint="Install with: sudo apt-get install jq"
      elif command -v dnf > /dev/null 2>&1; then
        hint="Install with: sudo dnf install jq"
      else
        hint="Install jq from https://jqlang.github.io/jq/download/"
      fi
      ;;
    macos)
      hint="Install with: brew install jq"
      ;;
    windows)
      hint="Install with: winget install jqlang.jq  (or: choco install jq)"
      ;;
    *)
      hint="Install jq from https://jqlang.github.io/jq/download/"
      ;;
  esac
  die "'jq' is required but not found. ${hint}"
}

# ---------------------------------------------------------------------------
# Path constants (set after detect_os runs)
# ---------------------------------------------------------------------------
AZG_GLOBAL_DIR="${HOME}/.gemini/antigravity-cli"
AZG_GLOBAL_SKILLS_DIR="${HOME}/.gemini/config/skills"
AZG_GLOBAL_MCP_CONFIG="${HOME}/.gemini/config/mcp_config.json"
AZG_GLOBAL_AGENTS="${HOME}/.gemini/config/AGENTS.md"
# Cursor Device Setup roots (map #56 / #57 — never skills-cursor)
AZG_CURSOR_SKILLS_DIR="${HOME}/.cursor/skills"
AZG_CURSOR_RULES_DIR="${HOME}/.cursor/rules"

# ---------------------------------------------------------------------------
# Atomic file write helpers
# ---------------------------------------------------------------------------
# atomic_write DEST CONTENT
# Writes CONTENT to a temp file then moves it into place (same-filesystem mv).
atomic_write() {
  local dest="${1}"
  local tmp
  tmp="${dest}.azg.tmp"
  if [ $# -ge 2 ]; then
    if ! printf '%s' "${2}" > "${tmp}"; then
      # DESTRUCTIVE: remove failed atomic-write temporary
      rm -f "${tmp}"
      return 1
    fi
  else
    if ! cat > "${tmp}"; then
      # DESTRUCTIVE: remove failed atomic-write temporary
      rm -f "${tmp}"
      return 1
    fi
  fi
  if ! mv "${tmp}" "${dest}"; then
    # DESTRUCTIVE: remove failed atomic-write temporary
    rm -f "${tmp}"
    return 1
  fi
}

# atomic_copy SRC DEST
# Copies SRC to a temp file alongside DEST, then mv (atomic on same filesystem).
atomic_copy() {
  local src="${1}"
  local dest="${2}"
  local tmp
  tmp="${dest}.azg.tmp"
  if ! cp "${src}" "${tmp}"; then
    # DESTRUCTIVE: remove failed atomic-copy temporary
    rm -f "${tmp}"
    return 1
  fi
  if ! mv "${tmp}" "${dest}"; then
    # DESTRUCTIVE: remove failed atomic-copy temporary
    rm -f "${tmp}"
    return 1
  fi
}

# ---------------------------------------------------------------------------
# Template helpers (used by scaffold + apply)
# ---------------------------------------------------------------------------
render_template() {
  local src="${1}"
  local dst="${2}"
  shift 2

  local content
  content="$(cat "${src}")"

  while [ $# -ge 2 ]; do
    local key="${1}"
    local val="${2}"
    shift 2
    export TEMPLATE_VAL="${val}"
    content="$(printf '%s' "${content}" | awk -v k="{{${key}}}" '{ gsub(k, ENVIRON["TEMPLATE_VAL"]); print }')"
    unset TEMPLATE_VAL
  done

  mkdir -p "$(dirname "${dst}")"
  printf '%s\n' "${content}" | atomic_write "${dst}"
}

copy_template() {
  local src="${1}"
  local dst="${2}"
  mkdir -p "$(dirname "${dst}")"
  atomic_write "${dst}" < "${src}"
}

# ---------------------------------------------------------------------------
# Misc helpers
# ---------------------------------------------------------------------------
ensure_dir() {
  local dir="${1}"
  if [ ! -d "${dir}" ]; then
    mkdir -p "${dir}"
  fi
}

# replace_managed_block TARGET_FILE START_MARKER END_MARKER NEW_CONTENT
# Replaces everything between START_MARKER and END_MARKER (inclusive of markers)
# with START_MARKER + NEW_CONTENT + END_MARKER.
# Returns 0 on success, or 1 if target file does not contain START_MARKER.
replace_managed_block() {
  local target="${1}"
  local start_marker="${2}"
  local end_marker="${3}"
  local new_content="${4}"

  if [ ! -f "${target}" ]; then
    return 1
  fi

  # Fail closed: exactly one ordered start/end pair required before rewrite.
  local marker_state
  marker_state="$(awk -v start="${start_marker}" -v end="${end_marker}" '
    {
      line = $0
      sub(/\r$/, "", line)
    }
    line == start { starts += 1; if (ends == 0) order_ok = 1 }
    line == end { ends += 1 }
    END {
      if (starts == 1 && ends == 1 && order_ok == 1) print "ok"
      else print "bad"
    }
  ' "${target}")"
  if [ "${marker_state}" != "ok" ]; then
    return 1
  fi

  export _RMB_CONTENT="${new_content}"
  export _RMB_START="${start_marker}"
  export _RMB_END="${end_marker}"

  # Replace using a complete temporary, then atomic_copy.
  local replace_tmp="${target}.azg.replace.tmp"
  if ! awk '
  BEGIN { in_block = 0 }
  {
      line = $0
      sub(/\r$/, "", line)
  }
  line == ENVIRON["_RMB_START"] {
      print ENVIRON["_RMB_START"]
      print ENVIRON["_RMB_CONTENT"]
      print ENVIRON["_RMB_END"]
      in_block = 1
      next
  }
  line == ENVIRON["_RMB_END"] {
      in_block = 0
      next
  }
  !in_block { print line }
  ' "${target}" > "${replace_tmp}"; then
    # DESTRUCTIVE: remove failed managed-block replacement temporary
    rm -f "${replace_tmp}"
    unset _RMB_CONTENT _RMB_START _RMB_END
    return 1
  fi
  if ! atomic_copy "${replace_tmp}" "${target}"; then
    # DESTRUCTIVE: remove failed managed-block replacement temporary
    rm -f "${replace_tmp}"
    unset _RMB_CONTENT _RMB_START _RMB_END
    return 1
  fi
  # DESTRUCTIVE: remove completed managed-block replacement temporary
  rm -f "${replace_tmp}"

  unset _RMB_CONTENT _RMB_START _RMB_END
  return 0
}

# remove_managed_block TARGET_FILE START_MARKER END_MARKER
# Deletes one ordered marker pair and content between (inclusive). Returns 1 if absent/malformed.
remove_managed_block() {
  local target="${1}"
  local start_marker="${2}"
  local end_marker="${3}"

  [ -f "${target}" ] || return 1

  local marker_state
  marker_state="$(awk -v start="${start_marker}" -v end="${end_marker}" '
    {
      line = $0
      sub(/\r$/, "", line)
    }
    line == start { starts += 1; if (ends == 0) order_ok = 1 }
    line == end { ends += 1 }
    END {
      if (starts == 1 && ends == 1 && order_ok == 1) print "ok"
      else print "bad"
    }
  ' "${target}")"
  if [ "${marker_state}" != "ok" ]; then
    return 1
  fi

  export _RMB_START="${start_marker}"
  export _RMB_END="${end_marker}"
  local remove_tmp="${target}.azg.remove.tmp"
  if ! awk '
  BEGIN { in_block = 0 }
  {
      line = $0
      sub(/\r$/, "", line)
  }
  line == ENVIRON["_RMB_START"] { in_block = 1; next }
  line == ENVIRON["_RMB_END"] { in_block = 0; next }
  !in_block { print line }
  ' "${target}" > "${remove_tmp}"; then
    rm -f "${remove_tmp}"
    unset _RMB_START _RMB_END
    return 1
  fi
  if ! atomic_copy "${remove_tmp}" "${target}"; then
    rm -f "${remove_tmp}"
    unset _RMB_START _RMB_END
    return 1
  fi
  rm -f "${remove_tmp}"
  unset _RMB_START _RMB_END
  return 0
}

# extract_managed_block SOURCE_FILE START_MARKER END_MARKER
# Prints non-empty content between one ordered marker pair.
# Fails closed when markers are missing, duplicated, reversed, or empty.
extract_managed_block() {
  local source="${1}"
  local start_marker="${2}"
  local end_marker="${3}"

  [ -f "${source}" ] || return 1

  awk -v start="${start_marker}" -v end="${end_marker}" '
    BEGIN { state = 0; starts = 0; ends = 0; content = 0; bad = 0 }
    {
      line = $0
      sub(/\r$/, "", line)
    }
    line == start {
      starts += 1
      if (starts != 1 || state != 0) bad = 1
      state = 1
      next
    }
    line == end {
      ends += 1
      if (ends != 1 || state != 1) bad = 1
      state = 2
      next
    }
    state == 1 {
      print line
      if (line ~ /[^[:space:]]/) content = 1
    }
    END {
      if (starts != 1 || ends != 1 || state != 2 || content != 1 || bad == 1) exit 1
    }
  ' "${source}"
}

# ---------------------------------------------------------------------------
# Global ownership (ADR 0008)
# Manifest: ${AZG_GLOBAL_DIR}/azg-ownership.json
# ---------------------------------------------------------------------------
AZG_OWNERSHIP_FILE_NAME="azg-ownership.json"

azg_ownership_path() {
  printf '%s\n' "${AZG_GLOBAL_DIR}/${AZG_OWNERSHIP_FILE_NAME}"
}

# Ensure ownership file exists (empty owned set).
azg_ownership_init() {
  local path
  path="$(azg_ownership_path)"
  ensure_dir "${AZG_GLOBAL_DIR}"
  if [ ! -f "${path}" ]; then
    printf '%s\n' '{"version":1,"mcp":false,"agents":false,"statusline":false,"skills":[],"cursor_skills":[],"cursor_rules":[]}' > "${path}"
  fi
}

azg_ownership_get() {
  # Usage: azg_ownership_get mcp|agents|statusline
  local key="${1}"
  local path
  path="$(azg_ownership_path)"
  [ -f "${path}" ] || { printf 'false\n'; return 0; }
  jq -r --arg k "${key}" '.[$k] // false | tostring' "${path}"
}

azg_ownership_set_flag() {
  # Usage: azg_ownership_set_flag mcp|agents|statusline true|false
  local key="${1}"
  local val="${2}"
  local path tmp
  path="$(azg_ownership_path)"
  azg_ownership_init
  tmp="${path}.azg.tmp"
  jq --arg k "${key}" --argjson v "${val}" '.[$k] = $v' "${path}" > "${tmp}" && mv "${tmp}" "${path}"
}

azg_ownership_list_add() {
  # Usage: azg_ownership_list_add skills|cursor_skills|cursor_rules ITEM
  local list_key="${1}"
  local item="${2}"
  local path tmp
  path="$(azg_ownership_path)"
  azg_ownership_init
  tmp="${path}.azg.tmp"
  jq --arg k "${list_key}" --arg v "${item}" '.[$k] = ((.[$k] // []) + [$v] | unique)' "${path}" > "${tmp}" && mv "${tmp}" "${path}"
}

azg_ownership_list_remove() {
  # Usage: azg_ownership_list_remove skills|cursor_skills|cursor_rules ITEM
  local list_key="${1}"
  local item="${2}"
  local path tmp
  path="$(azg_ownership_path)"
  [ -f "${path}" ] || return 0
  tmp="${path}.azg.tmp"
  jq --arg k "${list_key}" --arg v "${item}" \
    '.[$k] = ((.[$k] // []) | map(select(. != $v)))' "${path}" > "${tmp}" && mv "${tmp}" "${path}"
}

azg_ownership_list_owns() {
  # Usage: azg_ownership_list_owns skills|cursor_skills|cursor_rules ITEM
  local list_key="${1}"
  local item="${2}"
  local path
  path="$(azg_ownership_path)"
  [ -f "${path}" ] || return 1
  jq -e --arg k "${list_key}" --arg v "${item}" '(.[$k] // []) | index($v) != null' "${path}" >/dev/null 2>&1
}

# True if dest skill is foreign custom (exists, no vendor sentinel, not force).
azg_skill_is_foreign() {
  local dest="${1}"
  [ -d "${dest}" ] || return 1
  [ -f "${dest}/ANTIGRAVITY-NOTE.md" ] && return 1
  return 0
}

# True if Cursor skill dir is foreign (exists, no AZG-OWNED.md).
azg_cursor_skill_is_foreign() {
  local dest="${1}"
  [ -d "${dest}" ] || return 1
  [ -f "${dest}/AZG-OWNED.md" ] && return 1
  return 0
}

# Run real Python 3 (ignore Windows Store stubs). Usage: azg_python - arg… <<'PY'
azg_python() {
  local _azg_py_ok
  _azg_py_ok() {
    local cmd="${1}"
    shift
    "${cmd}" "$@" -c 'import sys; sys.exit(0 if sys.version_info[0] >= 3 else 1)' 2>/dev/null
  }
  if _azg_py_ok python3; then
    python3 "$@"
    return
  fi
  if _azg_py_ok python; then
    python "$@"
    return
  fi
  if command -v py >/dev/null 2>&1 && _azg_py_ok py -3; then
    py -3 "$@"
    return
  fi
  die "No Python 3 found (tried python3, python, py -3)"
}
