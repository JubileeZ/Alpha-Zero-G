#!/usr/bin/env bash
# lib/setup.sh — azg setup
# Installs all vendored global skills + MCP config (full-only; no core profile).
# Sourced by the azg dispatcher; do NOT run directly.
#
# Usage (via dispatcher):
#   azg setup              — install/refresh global config
#   azg setup --dry-run    — print what would be done, write nothing
#   azg setup --force      — re-install even if files are already present

# shellcheck source=lib/common.sh
# common.sh is already sourced by the dispatcher before this file is sourced.

cmd_setup() {
  local dry_run=0
  local force=0

  while [ $# -gt 0 ]; do
    case "$1" in
      --dry-run)
        dry_run=1
        shift
        ;;
      --force)
        force=1
        shift
        ;;
      --profile)
        die "azg setup: --profile removed; setup always installs all vendored skills"
        ;;
      *)
        die "azg setup: unknown option '$1'. Usage: azg setup [--dry-run] [--force]"
        ;;
    esac
  done

  local template_global="${AZG_ROOT}/templates/global"
  local template_mcp="${template_global}/mcp_config.json"
  local template_agents="${template_global}/AGENTS.md"
  local vendor_base_dir="${template_global}/skills/vendor"

  local skip_sync=0
  local current_stamp_file="${AZG_GLOBAL_DIR}/setup_stamp"
  local new_stamp=""

  if [ -d "${vendor_base_dir}" ]; then
    new_stamp="$(find "${vendor_base_dir}" -name "VENDOR.lock" -exec grep "^commit:" {} + | sort)"
  fi

  if [ "${force}" -eq 0 ] && [ -f "${current_stamp_file}" ] && [ -n "${new_stamp}" ]; then
    local old_stamp
    old_stamp="$(cat "${current_stamp_file}" 2>/dev/null || echo "")"
    if [ "${old_stamp}" = "${new_stamp}" ]; then
      skip_sync=1
    fi
  fi

  if [ "${dry_run}" -eq 1 ]; then
    require_jq
    step "azg setup --dry-run: showing planned actions (no files will be written)"
    info "  create dir : ${AZG_GLOBAL_DIR}"
    info "  create dir : ${AZG_GLOBAL_SKILLS_DIR}"
    info "  copy file  : ${template_mcp} → ${AZG_GLOBAL_MCP_CONFIG}"
    info "  copy file  : ${template_agents} → ${AZG_GLOBAL_AGENTS}"

    if [ "${skip_sync}" -eq 1 ]; then
      info "  [SMART SYNC] skills are up-to-date (VENDOR.lock unchanged); would skip skill copying"
    else
      if [ -d "${vendor_base_dir}" ]; then
        for vendor_root in "${vendor_base_dir}"/*/; do
          [ -d "${vendor_root}" ] || continue
          for category_dir in "${vendor_root}"/*/; do
            [ -d "${category_dir}" ] || continue
            for skill_dir in "${category_dir}"/*/; do
              [ -d "${skill_dir}" ] || continue
              local skill_name
              skill_name="$(basename "${skill_dir}")"
              info "  copy skill : ${skill_dir} → ${AZG_GLOBAL_SKILLS_DIR}/${skill_name}/"
            done
          done
        done
      else
        info "  (no vendor skills found — run azg update --vendor to populate)"
      fi
    fi

    ok "Dry run complete. Run 'azg setup' to apply."
    return 0
  fi

  step "azg setup v${AZG_VERSION} — installing global config"
  info "Destination: ${AZG_GLOBAL_DIR}"
  info "Skills: all vendored"

  require_jq

  ensure_dir "${AZG_GLOBAL_DIR}"
  ensure_dir "${AZG_GLOBAL_SKILLS_DIR}"

  if [ ! -f "${template_mcp}" ]; then
    die "Template mcp_config.json not found: ${template_mcp}"
  fi

  azg_ownership_init

  local _install_mcp=1
  if [ -f "${AZG_GLOBAL_MCP_CONFIG}" ] && [ "${force}" -eq 0 ]; then
    if diff -q "${template_mcp}" "${AZG_GLOBAL_MCP_CONFIG}" > /dev/null 2>&1; then
      info "mcp_config.json already up-to-date, skipping"
      _install_mcp=0
      azg_ownership_set_flag mcp true
    elif [ "$(azg_ownership_get mcp)" != "true" ]; then
      warn "Foreign mcp_config.json present — skipping (use --force to overwrite)"
      _install_mcp=0
    fi
  fi

  if [ "${_install_mcp}" -eq 1 ]; then
    ensure_dir "$(dirname "${AZG_GLOBAL_MCP_CONFIG}")"
    atomic_copy "${template_mcp}" "${AZG_GLOBAL_MCP_CONFIG}"
    azg_ownership_set_flag mcp true
    ok "Installed: mcp_config.json"
  fi

  if [ ! -f "${template_agents}" ]; then
    die "Template AGENTS.md not found: ${template_agents}"
  fi

  if [ ! -f "${AZG_GLOBAL_AGENTS}" ]; then
    ensure_dir "$(dirname "${AZG_GLOBAL_AGENTS}")"
    atomic_copy "${template_agents}" "${AZG_GLOBAL_AGENTS}"
    azg_ownership_set_flag agents true
    ok "Installed: AGENTS.md (global)"
  elif [ "${force}" -eq 1 ]; then
    cp "${AZG_GLOBAL_AGENTS}" "${AZG_GLOBAL_AGENTS}.bak"
    atomic_copy "${template_agents}" "${AZG_GLOBAL_AGENTS}"
    azg_ownership_set_flag agents true
    ok "Installed: AGENTS.md (global, forced; backup saved to .bak)"
  elif diff -q "${template_agents}" "${AZG_GLOBAL_AGENTS}" > /dev/null 2>&1; then
    info "AGENTS.md already up-to-date, skipping"
    azg_ownership_set_flag agents true
  else
    if grep -q '<!-- PONYTAIL:MANAGED:START -->' "${AZG_GLOBAL_AGENTS}"; then
      local new_ponytail
      new_ponytail="$(awk '/<!-- PONYTAIL:MANAGED:START -->/{f=1; next} /<!-- PONYTAIL:MANAGED:END -->/{f=0} f' "${template_agents}")"
      if replace_managed_block "${AZG_GLOBAL_AGENTS}" "<!-- PONYTAIL:MANAGED:START -->" "<!-- PONYTAIL:MANAGED:END -->" "${new_ponytail}"; then
        azg_ownership_set_flag agents true
        ok "Updated: AGENTS.md ponytail block (global)"
      else
        die "Failed to update managed block in ${AZG_GLOBAL_AGENTS}"
      fi
    elif [ "$(azg_ownership_get agents)" = "true" ]; then
      cp "${AZG_GLOBAL_AGENTS}" "${AZG_GLOBAL_AGENTS}.bak"
      atomic_copy "${template_agents}" "${AZG_GLOBAL_AGENTS}"
      ok "Installed: AGENTS.md (global, owned file refreshed; backup .bak)"
    else
      warn "Foreign AGENTS.md (no PONYTAIL markers) — skipping (use --force to overwrite)"
    fi
  fi

  local template_statusline="${AZG_ROOT}/templates/global/statusline.sh"
  local statusline_path="${AZG_GLOBAL_DIR}/statusline.sh"
  local _install_statusline=1

  if [ ! -f "${template_statusline}" ]; then
    die "Template statusline.sh not found: ${template_statusline}"
  fi

  if [ -f "${statusline_path}" ] && [ "${force}" -eq 0 ]; then
    if diff -q "${template_statusline}" "${statusline_path}" > /dev/null 2>&1; then
      info "statusline.sh already up-to-date, skipping"
      _install_statusline=0
    fi
  fi

  if [ "${_install_statusline}" -eq 1 ]; then
    atomic_copy "${template_statusline}" "${statusline_path}"
    chmod +x "${statusline_path}"
    azg_ownership_set_flag statusline true
    ok "Installed: statusline.sh"
  fi

  local settings_file="${AZG_GLOBAL_DIR}/settings.json"
  if [ -f "${settings_file}" ]; then
    info "Merging statusline configuration into settings.json"
    local tmp_settings="${settings_file}.azg.tmp"
    jq --arg path "${statusline_path}" '
      .statusLine = {
        type: "command",
        command: $path,
        enabled: true
      }
    ' "${settings_file}" > "${tmp_settings}" && mv "${tmp_settings}" "${settings_file}"
  else
    info "Creating new settings.json with statusline configuration"
    printf '{\n  "statusLine": {\n    "type": "command",\n    "command": "%s",\n    "enabled": true\n  }\n}\n' "${statusline_path}" > "${settings_file}"
  fi
  ok "Configured: settings.json"

  source "${AZG_ROOT}/lib/apply-overlay.sh"

  local skills_copied=0
  local skills_pruned=0

  if [ "${skip_sync}" -eq 1 ]; then
    info "Smart Sync: VENDOR.lock commits unchanged. Skipping global skill sync."
  elif [ -d "${vendor_base_dir}" ]; then
    for vendor_root in "${vendor_base_dir}"/*/; do
      [ -d "${vendor_root}" ] || continue
      local vendor_name
      vendor_name="$(basename "${vendor_root}")"

      for category_dir in "${vendor_root}"/*/; do
        [ -d "${category_dir}" ] || continue
        for skill_dir in "${category_dir}"/*/; do
          [ -d "${skill_dir}" ] || continue
          local skill_name
          skill_name="$(basename "${skill_dir}")"

          local skill_dest="${AZG_GLOBAL_SKILLS_DIR}/${skill_name}"
          if [ "${force}" -eq 0 ] && azg_skill_is_foreign "${skill_dest}"; then
            warn "Foreign skill '${skill_name}' (no ANTIGRAVITY-NOTE) — skipping (use --force to overwrite)"
            continue
          fi

          apply_overlay "${skill_name}" "${category_dir}" "${template_global}/skills/overlay/${vendor_name}" "${AZG_GLOBAL_SKILLS_DIR}"
          azg_ownership_add_skill "${skill_name}"
          skills_copied=$((skills_copied + 1))
        done
      done

      _prune_vendor_skills \
        "${AZG_GLOBAL_SKILLS_DIR}" \
        "${vendor_root}" \
        skills_pruned
    done

    if [ -n "${new_stamp}" ]; then
      printf "%s\n" "${new_stamp}" > "${current_stamp_file}"
    fi
  else
    info "No vendor skills found at ${vendor_base_dir}"
    info "Tip: run 'azg update --vendor' to vendor skills"
  fi

  local _sum_skills=""
  if [ "${skip_sync}" -eq 1 ]; then
    _sum_skills="skills up-to-date (smart sync)"
  elif [ "${skills_copied}" -gt 0 ]; then
    _sum_skills="${skills_copied} skill(s) installed"
  else
    _sum_skills="no skills to install (run 'azg update --vendor' to vendor skills)"
  fi
  [ "${skills_pruned}" -gt 0 ] && _sum_skills="${_sum_skills}, ${skills_pruned} removed (deleted upstream)"

  ok "Setup complete. ${_sum_skills}."
  info "Global config: ${AZG_GLOBAL_DIR}"
}
