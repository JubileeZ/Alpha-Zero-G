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
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

_cursor_rule_markers() {
  local rule_base="${1}"

  case "${rule_base}" in
    azg-ponytail.mdc)
      printf '%s\n' '<!-- PONYTAIL:MANAGED:START -->' '<!-- PONYTAIL:MANAGED:END -->'
      ;;
    azg-agent-instructions.mdc)
      printf '%s\n' '<!-- AZG:AGENT-INSTRUCTIONS:START -->' '<!-- AZG:AGENT-INSTRUCTIONS:END -->'
      ;;
    *)
      die "No AGENTS.md marker mapping for Cursor rule: ${rule_base}"
      ;;
  esac
}

_validate_cursor_rule_templates() {
  local cursor_rules_tmpl_dir="${1}"
  local template_agents="${2}"
  local rule_src rule_base marker_start marker_end

  [ -d "${cursor_rules_tmpl_dir}" ] || die "Cursor rules template dir missing: ${cursor_rules_tmpl_dir}"
  for rule_src in "${cursor_rules_tmpl_dir}"/azg-*.mdc; do
    [ -f "${rule_src}" ] || continue
    rule_base="$(basename "${rule_src}")"
    # Bash 3.2-safe (macOS / GHA macos-latest): two reads, not Bash-4 array-load
    {
      IFS= read -r marker_start
      IFS= read -r marker_end
    } < <(_cursor_rule_markers "${rule_base}")
    if ! extract_managed_block "${template_agents}" "${marker_start}" "${marker_end}" > /dev/null; then
      die "AGENTS.md marker block missing or empty for Cursor rule: ${rule_base}"
    fi
  done
}

_render_cursor_rule() {
  local rule_src="${1}"
  local rule_dest="${2}"
  local template_agents="${3}"
  local rule_base marker_start marker_end body

  rule_base="$(basename "${rule_src}")"
  # Bash 3.2-safe (macOS / GHA macos-latest): two reads, not Bash-4 array-load
  {
    IFS= read -r marker_start
    IFS= read -r marker_end
  } < <(_cursor_rule_markers "${rule_base}")
  body="$(extract_managed_block "${template_agents}" "${marker_start}" "${marker_end}")" || \
    die "AGENTS.md marker block missing or empty for Cursor rule: ${rule_base}"

  local render_tmp="${rule_dest}.azg.render.tmp"
  if ! awk '{ sub(/\r$/, ""); print }' "${rule_src}" > "${render_tmp}" ||
    ! printf '%s\n' "${body}" >> "${render_tmp}"; then
    # DESTRUCTIVE: remove failed Cursor rule render temporary
    rm -f "${render_tmp}"
    die "Failed to render Cursor rule: ${rule_dest}"
  fi
  if ! atomic_copy "${render_tmp}" "${rule_dest}"; then
    # DESTRUCTIVE: remove failed Cursor rule render temporary
    rm -f "${render_tmp}"
    die "Failed to install Cursor rule: ${rule_dest}"
  fi
  # DESTRUCTIVE: remove completed Cursor rule render temporary
  rm -f "${render_tmp}"
}

_migrate_agent_instruction_try() {
  local target="${1}"
  local start_heading="${2}"
  local end_line="${3}"
  local tmp="${target}.azg.migrate.tmp"

  if awk -v start="${start_heading}" -v end="${end_line}" '
    {
      line = $0
      sub(/\r$/, "", line)
      if (line == start) {
        starts += 1
        if (starts != 1 || state != 0) bad = 1
        print "<!-- AZG:AGENT-INSTRUCTIONS:START -->"
        state = 1
      }
      print line
      if (line == end) {
        ends += 1
        if (ends != 1 || state != 1) bad = 1
        print "<!-- AZG:AGENT-INSTRUCTIONS:END -->"
        state = 2
      }
    }
    END { exit !(starts == 1 && ends == 1 && state == 2 && bad != 1) }
  ' "${target}" > "${tmp}"; then
    # DESTRUCTIVE: replace owned AGENTS.md with marker-preserving migration
    if mv "${tmp}" "${target}"; then
      return 0
    fi
    # DESTRUCTIVE: remove failed marker migration temporary
    rm -f "${tmp}"
    return 1
  fi
  # DESTRUCTIVE: remove failed temporary marker migration
  rm -f "${tmp}"
  return 1
}

_migrate_agent_instruction_markers() {
  local target="${1}"
  # Current template (Cleanup → last Report line), then legacy Placeholder → old telegraphic.
  if _migrate_agent_instruction_try "${target}" \
    "# AGENT INSTRUCTIONS: Temporary File Cleanup" \
    "Before send: non-trivial → layout: top owed \`INTENT:\`/\`AUTH:\` → main body → bottom owed \`TWINS:\`/\`PENDING:\` + Prove verdict; omit un-owed (no N/A). Repair missing lines, then send."; then
    return 0
  fi
  _migrate_agent_instruction_try "${target}" \
    "# AGENT INSTRUCTIONS: Project AGENTS.md Placeholder Rule" \
    "Write all system/project doc updates or additions in telegraphic style: drop articles (a/an/the), pleasantries, filler (just/actually/basically/simply), and hedging. Use concise fragments. Keep code, paths, commands, and technical terms exact."
}

# _install_skill_pair NAME SRC_PARENT OVERLAY_DIR FORCE GEMINI_COUNT_VAR CURSOR_COUNT_VAR
#
# Installs one skill into both targets: Gemini (overlay-processed) and Cursor
# (plain copy). Foreign copies are left alone unless FORCE=1. Records ownership
# and increments the named caller counters (same eval pattern as prune).
_install_skill_pair() {
  local skill_name="${1}"
  local src_parent="${2}"
  local overlay_dir="${3}"
  local force="${4}"
  local gemini_count_var="${5}"
  local cursor_count_var="${6}"

  if [ "${force}" -eq 0 ] && azg_skill_is_foreign "${AZG_GLOBAL_SKILLS_DIR}/${skill_name}"; then
    warn "Foreign skill '${skill_name}' (no ANTIGRAVITY-NOTE) — skipping (use --force to overwrite)"
  else
    apply_overlay "${skill_name}" "${src_parent}" "${overlay_dir}" "${AZG_GLOBAL_SKILLS_DIR}"
    azg_ownership_add_skill "${skill_name}"
    # ponytail: indirect variable increment via eval (no ((VAR++)) with set -e)
    eval "${gemini_count_var}=\$(( \${${gemini_count_var}} + 1 ))"
  fi

  if [ "${force}" -eq 0 ] && azg_cursor_skill_is_foreign "${AZG_CURSOR_SKILLS_DIR}/${skill_name}"; then
    warn "Foreign Cursor skill '${skill_name}' (no AZG-OWNED.md) — skipping (use --force to overwrite)"
  else
    install_cursor_skill "${skill_name}" "${src_parent}" "${AZG_CURSOR_SKILLS_DIR}"
    azg_ownership_add_cursor_skill "${skill_name}"
    eval "${cursor_count_var}=\$(( \${${cursor_count_var}} + 1 ))"
  fi
}

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
  local azg_skills_dir="${template_global}/skills/azg"
  local azg_overlay_dir="${template_global}/skills/overlay/azg"
  local cursor_rules_tmpl_dir="${template_global}/cursor/rules"

  if [ ! -f "${template_agents}" ]; then
    die "Template AGENTS.md not found: ${template_agents}"
  fi
  if [ -d "${cursor_rules_tmpl_dir}" ]; then
    _validate_cursor_rule_templates "${cursor_rules_tmpl_dir}" "${template_agents}"
  fi

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
    info "  create dir : ${AZG_CURSOR_SKILLS_DIR}"
    info "  create dir : ${AZG_CURSOR_RULES_DIR}"
    info "  copy file  : ${template_mcp} → ${AZG_GLOBAL_MCP_CONFIG}"
    info "  copy file  : ${template_agents} → ${AZG_GLOBAL_AGENTS}"
    info "  render file : Cursor rules from ${template_agents} → ${AZG_CURSOR_RULES_DIR}/azg-*.mdc"

    if [ "${skip_sync}" -eq 1 ]; then
      info "  [SMART SYNC] vendor skills up-to-date (VENDOR.lock unchanged); would skip vendor skill copying"
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
              info "  copy skill : ${skill_dir} → ${AZG_CURSOR_SKILLS_DIR}/${skill_name}/"
            done
          done
        done
      else
        info "  (no vendor skills found — run azg update --vendor to populate)"
      fi
    fi

    if [ -d "${azg_skills_dir}" ]; then
      for skill_dir in "${azg_skills_dir}"/*/; do
        [ -d "${skill_dir}" ] || continue
        [ -f "${skill_dir}/SKILL.md" ] || continue
        local azg_skill_name
        azg_skill_name="$(basename "${skill_dir}")"
        info "  copy azg skill : ${skill_dir} → ${AZG_GLOBAL_SKILLS_DIR}/${azg_skill_name}/"
        info "  copy azg skill : ${skill_dir} → ${AZG_CURSOR_SKILLS_DIR}/${azg_skill_name}/"
      done
    else
      info "  (no first-party azg skills at ${azg_skills_dir})"
    fi

    ok "Dry run complete. Run 'azg setup' to apply."
    return 0
  fi

  step "azg setup v${AZG_VERSION} — installing global config"
  info "Destination: ${AZG_GLOBAL_DIR}"
  info "Skills: vendored + azg-owned"

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
    if extract_managed_block "${AZG_GLOBAL_AGENTS}" \
      '<!-- PONYTAIL:MANAGED:START -->' '<!-- PONYTAIL:MANAGED:END -->' > /dev/null 2>&1; then
      local agents_sync_tmp="${AZG_GLOBAL_AGENTS}.azg.sync.tmp"
      if ! cp "${AZG_GLOBAL_AGENTS}" "${agents_sync_tmp}"; then
        # DESTRUCTIVE: remove failed AGENTS.md sync temporary
        rm -f "${agents_sync_tmp}"
        die "Failed to prepare AGENTS.md sync temporary"
      fi
      if ! extract_managed_block "${agents_sync_tmp}" \
        '<!-- AZG:AGENT-INSTRUCTIONS:START -->' \
        '<!-- AZG:AGENT-INSTRUCTIONS:END -->' > /dev/null 2>&1; then
        _migrate_agent_instruction_markers "${agents_sync_tmp}" || {
          # DESTRUCTIVE: remove failed AGENTS.md sync temporary
          rm -f "${agents_sync_tmp}"
          die "Owned AGENTS.md lacks migratable agent-instruction markers; use --force to refresh"
        }
      fi
      local new_ponytail
      new_ponytail="$(extract_managed_block "${template_agents}" \
        '<!-- PONYTAIL:MANAGED:START -->' '<!-- PONYTAIL:MANAGED:END -->')" || {
        # DESTRUCTIVE: remove failed AGENTS.md sync temporary
        rm -f "${agents_sync_tmp}"
        die "Failed to extract AGENTS.md ponytail block"
      }
      local new_agent_instructions
      new_agent_instructions="$(extract_managed_block "${template_agents}" \
        '<!-- AZG:AGENT-INSTRUCTIONS:START -->' '<!-- AZG:AGENT-INSTRUCTIONS:END -->')" || {
        # DESTRUCTIVE: remove failed AGENTS.md sync temporary
        rm -f "${agents_sync_tmp}"
        die "Failed to extract AGENTS.md agent-instruction block"
      }
      if ! replace_managed_block "${agents_sync_tmp}" \
        "<!-- PONYTAIL:MANAGED:START -->" "<!-- PONYTAIL:MANAGED:END -->" "${new_ponytail}" ||
        ! replace_managed_block "${agents_sync_tmp}" \
          "<!-- AZG:AGENT-INSTRUCTIONS:START -->" \
          "<!-- AZG:AGENT-INSTRUCTIONS:END -->" "${new_agent_instructions}"; then
        # DESTRUCTIVE: remove failed AGENTS.md sync temporary
        rm -f "${agents_sync_tmp}"
        die "Failed to update AGENTS.md managed blocks"
      fi
      # DESTRUCTIVE: replace owned global AGENTS.md with synchronized blocks
      if ! atomic_copy "${agents_sync_tmp}" "${AZG_GLOBAL_AGENTS}"; then
        # DESTRUCTIVE: remove failed AGENTS.md sync temporary
        rm -f "${agents_sync_tmp}"
        die "Failed to install synchronized AGENTS.md"
      fi
      # DESTRUCTIVE: remove completed AGENTS.md sync temporary
      rm -f "${agents_sync_tmp}"
      azg_ownership_set_flag agents true
      ok "Updated: AGENTS.md managed blocks (global)"
    elif [ "$(azg_ownership_get agents)" = "true" ]; then
      if grep -q '<!-- PONYTAIL:MANAGED:' "${AZG_GLOBAL_AGENTS}" ||
        grep -q '<!-- AZG:AGENT-INSTRUCTIONS:' "${AZG_GLOBAL_AGENTS}"; then
        die "Owned AGENTS.md has malformed managed markers; use --force to refresh"
      fi
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
  local cursor_skills_copied=0

  ensure_dir "${AZG_CURSOR_SKILLS_DIR}"
  ensure_dir "${AZG_CURSOR_RULES_DIR}"

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

          _install_skill_pair "${skill_name}" "${category_dir}" \
            "${template_global}/skills/overlay/${vendor_name}" "${force}" \
            skills_copied cursor_skills_copied
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

  # First-party azg skills — always refresh (not gated by VENDOR.lock smart sync)
  local azg_skills_copied=0
  local azg_cursor_skills_copied=0
  if [ -d "${azg_skills_dir}" ]; then
    if [ ! -f "${azg_overlay_dir}/_shared/ANTIGRAVITY-NOTE.md.tmpl" ]; then
      die "azg skill overlay missing: ${azg_overlay_dir}/_shared/ANTIGRAVITY-NOTE.md.tmpl"
    fi
    local azg_skill_dir azg_skill_name
    for azg_skill_dir in "${azg_skills_dir}"/*/; do
      [ -d "${azg_skill_dir}" ] || continue
      [ -f "${azg_skill_dir}/SKILL.md" ] || continue
      azg_skill_name="$(basename "${azg_skill_dir}")"

      _install_skill_pair "${azg_skill_name}" "${azg_skills_dir}" \
        "${azg_overlay_dir}" "${force}" \
        azg_skills_copied azg_cursor_skills_copied
    done
  else
    warn "First-party azg skills dir missing: ${azg_skills_dir}"
  fi

  # Cursor azg-owned global rules (foreign-safe: only azg-*.mdc)
  local cursor_rules_installed=0
  if [ -d "${cursor_rules_tmpl_dir}" ]; then
    local rule_src rule_base rule_dest
    for rule_src in "${cursor_rules_tmpl_dir}"/azg-*.mdc; do
      [ -f "${rule_src}" ] || continue
      rule_base="$(basename "${rule_src}")"
      rule_dest="${AZG_CURSOR_RULES_DIR}/${rule_base}"
      if [ -f "${rule_dest}" ] && [ "${force}" -eq 0 ] && ! azg_ownership_owns_cursor_rule "${rule_base}"; then
        warn "Foreign Cursor rule '${rule_base}' — skipping (use --force to overwrite)"
        continue
      fi
      _render_cursor_rule "${rule_src}" "${rule_dest}" "${template_agents}"
      azg_ownership_add_cursor_rule "${rule_base}"
      cursor_rules_installed=$((cursor_rules_installed + 1))
      ok "Installed Cursor rule: ${rule_base}"
    done
  else
    warn "Cursor rules template dir missing: ${cursor_rules_tmpl_dir}"
  fi

  local _sum_skills=""
  if [ "${skip_sync}" -eq 1 ]; then
    _sum_skills="vendor skills up-to-date (smart sync)"
  elif [ "${skills_copied}" -gt 0 ] || [ "${cursor_skills_copied}" -gt 0 ]; then
    _sum_skills="${skills_copied} Gemini vendor skill(s), ${cursor_skills_copied} Cursor vendor skill(s) installed"
  else
    _sum_skills="no vendor skills to install (run 'azg update --vendor' to vendor skills)"
  fi
  if [ "${azg_skills_copied}" -gt 0 ] || [ "${azg_cursor_skills_copied}" -gt 0 ]; then
    _sum_skills="${_sum_skills}, ${azg_skills_copied} Gemini azg skill(s), ${azg_cursor_skills_copied} Cursor azg skill(s)"
  fi
  [ "${skills_pruned}" -gt 0 ] && _sum_skills="${_sum_skills}, ${skills_pruned} removed (deleted upstream)"
  [ "${cursor_rules_installed}" -gt 0 ] && _sum_skills="${_sum_skills}, ${cursor_rules_installed} Cursor rule(s)"

  ok "Setup complete. ${_sum_skills}."
  info "Global config: ${AZG_GLOBAL_DIR}"
  info "Cursor skills: ${AZG_CURSOR_SKILLS_DIR}"
  info "Cursor rules: ${AZG_CURSOR_RULES_DIR}"
}
