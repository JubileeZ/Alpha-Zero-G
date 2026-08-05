#!/usr/bin/env bash
# lib/uninstall.sh — azg uninstall
# Removes only Alpha-Zero-G–owned global assets (ADR 0008).
# Sourced by the azg dispatcher; do NOT run directly.

cmd_uninstall() {
  step "Uninstalling Alpha-Zero-G owned global files..."

  local removed=0
  local ownership
  ownership="$(azg_ownership_path)"

  # Skills: only vendor-managed (ANTIGRAVITY-NOTE) or listed in ownership
  if [ -d "${AZG_GLOBAL_SKILLS_DIR}" ]; then
    local skill_dir skill_name
    for skill_dir in "${AZG_GLOBAL_SKILLS_DIR}"/*/; do
      [ -d "${skill_dir}" ] || continue
      skill_name="$(basename "${skill_dir}")"
      if [ -f "${skill_dir}/ANTIGRAVITY-NOTE.md" ] || azg_ownership_list_owns skills "${skill_name}"; then
        # DESTRUCTIVE: remove azg-owned skill only
        rm -rf "${skill_dir}"
        ok "Removed skill: ${skill_name}"
        removed=1
      else
        info "Leaving foreign skill: ${skill_name}"
      fi
    done
    if [ -d "${AZG_GLOBAL_SKILLS_DIR}" ] && [ -z "$(ls -A "${AZG_GLOBAL_SKILLS_DIR}" 2>/dev/null || true)" ]; then
      rmdir "${AZG_GLOBAL_SKILLS_DIR}" 2>/dev/null || true
      ok "Removed empty: ${AZG_GLOBAL_SKILLS_DIR}"
      removed=1
    fi
  fi

  # Cursor skills: AZG-OWNED.md or listed in cursor_skills — never skills-cursor
  if [ -d "${AZG_CURSOR_SKILLS_DIR}" ]; then
    local cskill_dir cskill_name
    for cskill_dir in "${AZG_CURSOR_SKILLS_DIR}"/*/; do
      [ -d "${cskill_dir}" ] || continue
      cskill_name="$(basename "${cskill_dir}")"
      if [ -f "${cskill_dir}/AZG-OWNED.md" ] || azg_ownership_list_owns cursor_skills "${cskill_name}"; then
        # DESTRUCTIVE: remove azg-owned Cursor skill only
        rm -rf "${cskill_dir}"
        ok "Removed Cursor skill: ${cskill_name}"
        removed=1
      else
        info "Leaving foreign Cursor skill: ${cskill_name}"
      fi
    done
  fi

  # Cursor rules: only owned azg-*.mdc entries — never wipe rules dir
  if [ -d "${AZG_CURSOR_RULES_DIR}" ]; then
    local rule_file rule_base
    for rule_file in "${AZG_CURSOR_RULES_DIR}"/azg-*.mdc; do
      [ -f "${rule_file}" ] || continue
      rule_base="$(basename "${rule_file}")"
      if azg_ownership_list_owns cursor_rules "${rule_base}"; then
        # DESTRUCTIVE: remove azg-owned Cursor rule only
        rm -f "${rule_file}"
        ok "Removed Cursor rule: ${rule_base}"
        removed=1
      else
        info "Leaving Cursor rule (not in ownership): ${rule_base}"
      fi
    done
  fi

  # MCP: only if we own it
  if [ -f "${AZG_GLOBAL_MCP_CONFIG}" ]; then
    if [ "$(azg_ownership_get mcp)" = "true" ]; then
      rm -f "${AZG_GLOBAL_MCP_CONFIG}"
      ok "Removed: ${AZG_GLOBAL_MCP_CONFIG}"
      removed=1
    else
      info "Leaving foreign mcp_config.json"
    fi
  fi

  # AGENTS: owned flag or managed markers
  if [ -f "${AZG_GLOBAL_AGENTS}" ]; then
    if [ "$(azg_ownership_get agents)" = "true" ] || grep -q '<!-- PONYTAIL:MANAGED:START -->' "${AZG_GLOBAL_AGENTS}" 2>/dev/null; then
      rm -f "${AZG_GLOBAL_AGENTS}"
      ok "Removed: ${AZG_GLOBAL_AGENTS}"
      removed=1
    else
      info "Leaving foreign AGENTS.md"
    fi
  fi

  # azg home dir (statusline, settings, ownership, stamp)
  if [ -d "${AZG_GLOBAL_DIR}" ]; then
    # DESTRUCTIVE: entire antigravity-cli dir is azg-managed
    rm -rf "${AZG_GLOBAL_DIR}"
    ok "Removed: ${AZG_GLOBAL_DIR}"
    removed=1
  fi

  if [ "${removed}" -eq 0 ]; then
    info "Already removed (or not found)"
  fi
}
