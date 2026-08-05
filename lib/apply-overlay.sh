#!/usr/bin/env bash
# lib/apply-overlay.sh — tool-map remap + ANTIGRAVITY-NOTE injection
#
# Implements the apply_overlay() contract from the Phase 3 plan:
#   1. rm -rf the destination under ~/.gemini/antigravity-cli/skills/<name>/
#   2. cp -R from vendor/mattpocock-skills/<category>/<name>/
#   3. Remap tools:/allowed-tools: lines in SKILL.md frontmatter only,
#      using tool-map.json. Unmapped tokens pass through unchanged.
#   4. Render _shared/ANTIGRAVITY-NOTE.md.tmpl → <dest>/ANTIGRAVITY-NOTE.md
#      with {{SKILL_NAME}} substituted.
#   5. If overlay/<name>/ exists, copy its contents into <dest>/ (additive).
#
# Usage:
#   apply_overlay SKILL_NAME VENDOR_CATEGORY_DIR OVERLAY_DIR DEST_DIR
#
#   SKILL_NAME           — e.g. "tdd"
#   VENDOR_CATEGORY_DIR  — e.g. "templates/global/skills/vendor/mattpocock-skills/engineering"
#   OVERLAY_DIR          — e.g. "templates/global/skills/overlay/mattpocock-skills"
#   DEST_DIR             — e.g. "~/.gemini/antigravity-cli/skills"
#
# Called by: azg setup (via setup.sh)
# Sourced by setup.sh; do NOT run directly.
#
# Cross-platform guarantees:
#   - No sed -i on target files (tmp-file + mv)
#   - No ((VAR++))
#   - #!/usr/bin/env bash shebang

# shellcheck source=lib/common.sh
# common.sh is already sourced by the dispatcher before this file is sourced.

apply_overlay() {
  local skill_name="${1}"
  local vendor_category_dir="${2}"
  local overlay_dir="${3}"
  local dest_dir="${4}"

  local skill_src="${vendor_category_dir}/${skill_name}"
  local skill_dest="${dest_dir}/${skill_name}"
  local skill_md="${skill_dest}/SKILL.md"
  local note_tmpl=""
  local overlay_name
  overlay_name="$(basename "${overlay_dir}")"
  if [ "${overlay_name}" = "azg" ]; then
    note_tmpl="${overlay_dir}/_shared/ANTIGRAVITY-NOTE.md.tmpl"
  else
    note_tmpl="${AZG_ROOT}/templates/global/skills/overlay/_shared/ANTIGRAVITY-NOTE-VENDOR.md.tmpl"
  fi
  local note_dest="${skill_dest}/ANTIGRAVITY-NOTE.md"
  local tool_map="${overlay_dir}/tool-map.json"
  local per_skill_overlay="${overlay_dir}/${skill_name}"

  # -------------------------------------------------------------------------
  # Validate inputs
  # -------------------------------------------------------------------------
  if [ -z "${skill_name}" ]; then
    die "apply_overlay: SKILL_NAME is required"
  fi

  if [ ! -d "${skill_src}" ]; then
    die "apply_overlay: vendor source not found: ${skill_src}"
  fi

  if [ ! -f "${note_tmpl}" ]; then
    die "apply_overlay: ANTIGRAVITY-NOTE template not found: ${note_tmpl}"
  fi

  if [ ! -f "${tool_map}" ]; then
    die "apply_overlay: tool-map.json not found: ${tool_map}"
  fi

  # -------------------------------------------------------------------------
  # Step 1 + 2: rm -rf destination, then cp -R from vendor
  # -------------------------------------------------------------------------
  rm -rf "${skill_dest}"
  cp -R "${skill_src}" "${skill_dest}"

  # -------------------------------------------------------------------------
  # Step 3: Remap tools:/allowed-tools: lines in SKILL.md frontmatter only
  # -------------------------------------------------------------------------
  if [ -f "${skill_md}" ]; then
    _remap_skill_frontmatter "${skill_md}" "${tool_map}"
  fi

  # -------------------------------------------------------------------------
  # Step 4: Render ANTIGRAVITY-NOTE.md.tmpl → ANTIGRAVITY-NOTE.md
  # -------------------------------------------------------------------------
  if [ "${overlay_name}" = "azg" ]; then
    _render_antigravity_note "${note_tmpl}" "${note_dest}" "${skill_name}"
  else
    _render_vendor_antigravity_note "${note_tmpl}" "${note_dest}" "${skill_name}" "${overlay_name}"
  fi

  # -------------------------------------------------------------------------
  # Step 5: If per-skill overlay exists, copy its contents additively
  # -------------------------------------------------------------------------
  if [ -d "${per_skill_overlay}" ]; then
    cp -R "${per_skill_overlay}/." "${skill_dest}/"
  fi

  ok "Overlay applied: ${skill_name}"
}

# install_cursor_skill SKILL_NAME VENDOR_CATEGORY_DIR DEST_DIR
# Plain copy into Cursor user skills (no Antigravity tool-map). Writes AZG-OWNED.md.
# Never targets skills-cursor — caller must pass AZG_CURSOR_SKILLS_DIR.
install_cursor_skill() {
  local skill_name="${1}"
  local vendor_category_dir="${2}"
  local dest_dir="${3}"

  local skill_src="${vendor_category_dir}/${skill_name}"
  local skill_dest="${dest_dir}/${skill_name}"

  if [ -z "${skill_name}" ]; then
    die "install_cursor_skill: SKILL_NAME is required"
  fi
  if [ ! -d "${skill_src}" ]; then
    die "install_cursor_skill: skill source not found: ${skill_src}"
  fi
  if [ ! -f "${skill_src}/SKILL.md" ]; then
    die "install_cursor_skill: SKILL.md missing in ${skill_src}"
  fi

  # Guard: refuse skills-cursor path (Cursor built-ins)
  case "${dest_dir}" in
    */skills-cursor|*/skills-cursor/)
      die "install_cursor_skill: refusing to write into skills-cursor"
      ;;
  esac

  # DESTRUCTIVE: replace owned Cursor skill copy on refresh
  rm -rf "${skill_dest}"
  cp -R "${skill_src}" "${skill_dest}"
  printf '%s\n' \
    '# AZG-owned' \
    '' \
    'Installed by `azg setup`. Do not edit by hand; removed by `azg uninstall`.' \
    > "${skill_dest}/AZG-OWNED.md"
  ok "Installed Cursor skill: ${skill_name}"
}

# ---------------------------------------------------------------------------
# _remap_skill_frontmatter SKILL_MD TOOL_MAP_JSON
#
# Rewrites only the `tools:` and `allowed-tools:` lines in the YAML frontmatter
# of SKILL_MD (the block between the first pair of `---` lines).
# Uses tool-map.json for the token substitutions.
# Body content (after the closing ---) is NEVER touched.
#
# Remapping is done with a pure-bash word-replacement approach so we never
# need to invoke jq at apply time (it may not be installed on all machines).
# tool-map.json keys are embedded at source time via a static lookup table.
# ---------------------------------------------------------------------------
_remap_skill_frontmatter() {
  local skill_md="${1}"
  local tool_map_json="${2}"

  if [ "$(jq 'length' "${tool_map_json}" 2>/dev/null || echo 0)" -eq 0 ]; then
    return 0
  fi

  local tmp_map
  tmp_map="$(mktemp "${TMPDIR:-${TEMP:-/tmp}}/tmp_azg-toolmap-XXXXXX")"
  # shellcheck disable=SC2064
  trap "rm -f '${tmp_map}'" RETURN

  jq -r 'to_entries[] | "\(.key)=\(.value)"' "${tool_map_json}" > "${tmp_map}" || true

  local tmp_out="${skill_md}.azg.tmp"

  awk -v mapfile="${tmp_map}" '
    BEGIN {
      while ((getline line < mapfile) > 0) {
        n = index(line, "=")
        if (n > 0) {
          k = substr(line, 1, n-1)
          v = substr(line, n+1)
          mapping[k] = v
        }
      }
      close(mapfile)
      fm_count = 0
    }

    /^---$/ {
      fm_count++
      print
      next
    }

    fm_count == 1 && /^(tools|allowed-tools):/ {
      line = $0
      for (k in mapping) {
        v = mapping[k]
        prev = ""
        while (prev != line) {
          prev = line
          result = ""
          remaining = line
          while (length(remaining) > 0) {
            pos = index(remaining, k)
            if (pos == 0) {
              result = result remaining
              remaining = ""
            } else {
              before = substr(remaining, 1, pos - 1)
              after = substr(remaining, pos + length(k))
              pre_char = (pos > 1) ? substr(before, length(before), 1) : ""
              post_char = (length(after) > 0) ? substr(after, 1, 1) : ""
              pre_ok  = (pre_char  == "" || pre_char  == " " || pre_char  == "[" || pre_char  == ",")
              post_ok = (post_char == "" || post_char == " " || post_char == "]" || post_char == ",")
              if (pre_ok && post_ok) {
                result = result before v
                remaining = after
              } else {
                result = result before k
                remaining = after
              }
            }
          }
          line = result
        }
      }
      print line
      next
    }

    { print }
  ' "${skill_md}" > "${tmp_out}"

  mv "${tmp_out}" "${skill_md}"
}

# ---------------------------------------------------------------------------
# _render_antigravity_note TEMPLATE DEST SKILL_NAME
# ---------------------------------------------------------------------------
_render_antigravity_note() {
  render_template "${1}" "${2}" "SKILL_NAME" "${3}"
}

_render_vendor_antigravity_note() {
  local tmpl="${1}"
  local dest="${2}"
  local skill_name="${3}"
  local overlay_name="${4}"

  local vendor_label vendor_url vendor_path tool_remap_note
  case "${overlay_name}" in
    mattpocock-skills)
      vendor_label="mattpocock/skills"
      vendor_url="https://github.com/mattpocock/skills"
      vendor_path="mattpocock-skills"
      tool_remap_note="Tool references in this file have been remapped from the upstream tool names to their Antigravity equivalents (e.g. Bash → run_command, Read → read_file)."
      ;;
    ponytail-skills)
      vendor_label="DietrichGebert/ponytail"
      vendor_url="https://github.com/DietrichGebert/ponytail"
      vendor_path="ponytail-skills"
      tool_remap_note="Tool references in this file have been remapped from the upstream tool names to their Antigravity equivalents (if any)."
      ;;
    *)
      die "apply_overlay: unknown vendor overlay '${overlay_name}'"
      ;;
  esac

  render_template "${tmpl}" "${dest}" \
    "SKILL_NAME" "${skill_name}" \
    "VENDOR_LABEL" "${vendor_label}" \
    "VENDOR_URL" "${vendor_url}" \
    "VENDOR_PATH" "${vendor_path}" \
    "TOOL_REMAP_NOTE" "${tool_remap_note}"
}

# ---------------------------------------------------------------------------
# _prune_vendor_skills SKILLS_DIR VENDOR_DIR COUNT_VAR
#
# Removes installed skills that are vendor-managed (have ANTIGRAVITY-NOTE.md)
# but no longer exist in the vendor tree (deleted or renamed upstream).
# Custom skills (no ANTIGRAVITY-NOTE.md) are NEVER touched.
#
# Arguments:
#   SKILLS_DIR  — installed skills root (e.g. ~/.gemini/antigravity-cli/skills)
#   VENDOR_DIR  — vendor tree root (e.g. templates/.../vendor/mattpocock-skills)
#   COUNT_VAR   — name of caller variable to increment for each pruned skill
# ---------------------------------------------------------------------------
_prune_vendor_skills() {
  local skills_dir="${1}"
  local vendor_dir="${2}"
  local count_var="${3}"

  [ -d "${skills_dir}" ] || return 0

  for installed_dir in "${skills_dir}"/*/; do
    [ -d "${installed_dir}" ] || continue
    local skill_name
    skill_name="$(basename "${installed_dir}")"

    # Not vendor-managed: no sentinel → skip (never prune custom skills)
    [ -f "${installed_dir}/ANTIGRAVITY-NOTE.md" ] || continue

    # First-party azg skills are owned by source, not vendored — never vendor-prune
    if [ -d "${AZG_ROOT:-}/templates/global/skills/azg/${skill_name}" ]; then
      continue
    fi

    local vendor_name
    vendor_name="$(basename "${vendor_dir}")"
    local belongs=0
    if grep -q "vendor/" "${installed_dir}/ANTIGRAVITY-NOTE.md"; then
      if grep -q "vendor/${vendor_name}/" "${installed_dir}/ANTIGRAVITY-NOTE.md"; then
        belongs=1
      fi
    else
      belongs=1
    fi
    [ "${belongs}" -eq 1 ] || continue

    # Still present in vendor tree? Check all included categories.
    local found=0
    for category_dir in "${vendor_dir}"/*/; do
      [ -d "${category_dir}" ] || continue
      if [ -d "${category_dir}/${skill_name}" ]; then
        found=1
        break
      fi
    done

    if [ "${found}" -eq 0 ]; then
      warn "skill '${skill_name}' no longer in vendor — removing (deleted upstream)"
      rm -rf "${installed_dir}"
      # ponytail: indirect variable increment via printf+eval (no ((VAR++)) with set -e)
      eval "${count_var}=\$(( \${${count_var}} + 1 ))"
    fi
  done
  return 0
}
