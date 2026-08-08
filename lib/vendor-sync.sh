#!/usr/bin/env bash
# lib/vendor-sync.sh — re-vendor mattpocock/skills and ponytail skills from upstream
#
# Shallow-clones upstreams (or uses overrides for testing),
# copies skills into the vendor tree, writes VENDOR.lock, and prints summary.
#
# Called by: azg update --vendor  (via update.sh)
# Sourced by update.sh; do NOT run directly.

_vendor_sync_cleanup() {
  local dir="${1}"
  if [ -n "${dir}" ] && [ -d "${dir}" ]; then
  # DESTRUCTIVE: remove temporary vendor clone directory
    find "${dir}" -delete
  fi
}

vendor_sync() {
  # Respect AZG_ROOT from environment or fall back to the value set by common.sh
  local azg_root="${AZG_ROOT:-}"
  if [ -z "${azg_root}" ]; then
    azg_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  fi

  local upstream_matt="${AZG_VENDOR_UPSTREAM:-https://github.com/mattpocock/skills.git}"
  local upstream_pony="${AZG_PONYTAIL_UPSTREAM:-https://github.com/DietrichGebert/ponytail.git}"
  local upstream_caveman="${AZG_CAVEMAN_UPSTREAM:-https://github.com/JuliusBrussee/caveman.git}"

  # -------------------------------------------------------------------------
  # Dependency check
  # -------------------------------------------------------------------------
  if ! command -v git > /dev/null 2>&1; then
    err "Required command 'git' not found."
    err "Install git from https://git-scm.com/downloads and re-run."
    return 1
  fi

  clone_matt=""
  clone_pony=""
  clone_caveman=""
  local commit_matt="" commit_pony="" commit_caveman=""

  # Always clean up clone directories even on error or early return
  # shellcheck disable=SC2064
  trap '_vendor_sync_cleanup "${clone_matt}"; _vendor_sync_cleanup "${clone_pony}"; _vendor_sync_cleanup "${clone_caveman}"' RETURN

  # 1. Sync mattpocock-skills
  step "vendor-sync: syncing mattpocock-skills"
  if ! _clone_upstream "${upstream_matt}" "skills/engineering skills/productivity" clone_matt commit_matt; then
    return 1
  fi
  _sync_one_repo "${clone_matt}" "${upstream_matt}" "${commit_matt}" "${azg_root}/templates/global/skills/vendor/mattpocock-skills" "skills/engineering skills/productivity" ""
  
  # 2. Sync ponytail-skills
  step "vendor-sync: syncing ponytail-skills"
  if ! _clone_upstream "${upstream_pony}" "skills" clone_pony commit_pony; then
    return 1
  fi
  _sync_one_repo "${clone_pony}" "${upstream_pony}" "${commit_pony}" "${azg_root}/templates/global/skills/vendor/ponytail-skills" "skills" "ponytail"

  # 3. Sync caveman-skills (catalog)
  step "vendor-sync: syncing caveman-skills"
  if ! _clone_upstream "${upstream_caveman}" "skills" clone_caveman commit_caveman; then
    return 1
  fi
  _sync_one_repo "${clone_caveman}" "${upstream_caveman}" "${commit_caveman}" "${azg_root}/templates/global/skills/vendor/caveman-skills" "skills" "caveman"

  # 4. Ponytail AGENTS always-on sync retired (ADR 0015) — vendor skills only
  info "vendor-sync: skipping ponytail AGENTS.md inject (always-on retired; catalog remains)"

  ok "vendor-sync complete"
  ok "Run 'azg setup' on each device to push vendor changes to ~/.gemini/antigravity-cli/"
}

_clone_upstream() {
  local upstream="${1}"
  local sparse_dirs="${2}"
  local ret_clone_dir_var="${3}"
  local ret_commit_sha_var="${4}"

  local tmp_clone
  tmp_clone="$(mktemp -d "${TMPDIR:-${TEMP:-/tmp}}/tmp_azg-vendor-clone-XXXXXX")"

  info "Cloning upstream (shallow, sparse)…"
  if [ -d "${upstream}" ]; then
    if ! git clone --quiet "${upstream}" "${tmp_clone}/repo" 2>/dev/null; then
      err "git clone failed from: ${upstream}"
      _vendor_sync_cleanup "${tmp_clone}"
      return 1
    fi
  else
    if ! git clone --quiet --depth=1 --filter=blob:none --sparse "${upstream}" "${tmp_clone}/repo" 2>/dev/null; then
      err "git clone failed from: ${upstream}"
      _vendor_sync_cleanup "${tmp_clone}"
      return 1
    fi
    # shellcheck disable=SC2086
    if ! git -C "${tmp_clone}/repo" sparse-checkout set ${sparse_dirs} 2>/dev/null; then
      err "git sparse-checkout failed"
      _vendor_sync_cleanup "${tmp_clone}"
      return 1
    fi
  fi

  local commit_sha
  commit_sha="$(git -C "${tmp_clone}/repo" rev-parse HEAD 2>/dev/null)"
  if [ -z "${commit_sha}" ]; then
    err "Could not determine HEAD commit SHA"
    _vendor_sync_cleanup "${tmp_clone}"
    return 1
  fi

  info "Pinned commit: ${commit_sha}"

  eval "${ret_clone_dir_var}=\"\${tmp_clone}\""
  eval "${ret_commit_sha_var}=\"\${commit_sha}\""
  return 0
}

_sync_one_repo() {
  local tmp_clone="${1}"
  local upstream="${2}"
  local commit_sha="${3}"
  local dest_base="${4}"
  local sparse_dirs="${5}"
  local rename_category="${6:-}"

  local today
  today="$(date -u '+%Y-%m-%d')"
  local vendor_lock="${dest_base}/VENDOR.lock"

  ensure_dir "${dest_base}"

  local total_added=0
  local total_removed=0

  if [ -n "${rename_category}" ]; then
    local src_dir="${tmp_clone}/repo/skills"
    local dst_dir="${dest_base}/${rename_category}"

    if [ ! -d "${src_dir}" ]; then
      warn "skills/ directory not found in upstream — skipping"
      return 1
    fi

    # Count before
    local before_count=0
    if [ -d "${dst_dir}" ]; then
      before_count="$(find "${dst_dir}" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
    fi

    # Wholesale replace
    _vendor_sync_cleanup "${dst_dir}"
    cp -R "${src_dir}" "${dst_dir}"

    # Count after
    local after_count
    after_count="$(find "${dst_dir}" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"

    local diff_count=$((after_count - before_count))
    if [ "${diff_count}" -ge 0 ]; then
      total_added=$((total_added + diff_count))
    else
      total_removed=$((total_removed + (-diff_count)))
    fi
    info "  ${rename_category}/: ${after_count} skills"
  else
    # Loop over categories inside sparse_dirs (which are space-separated)
    # shellcheck disable=SC2086
    for category_path in ${sparse_dirs}; do
      local category
      category="$(basename "${category_path}")"
      local src_dir="${tmp_clone}/repo/${category_path}"
      local dst_dir="${dest_base}/${category}"

      if [ ! -d "${src_dir}" ]; then
        warn "Category '${category}' not found in upstream — skipping"
        continue
      fi

      # Count before
      local before_count=0
      if [ -d "${dst_dir}" ]; then
        before_count="$(find "${dst_dir}" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
      fi

      # Wholesale replace
      _vendor_sync_cleanup "${dst_dir}"
      cp -R "${src_dir}" "${dst_dir}"

      # Count after
      local after_count
      after_count="$(find "${dst_dir}" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"

      local diff_count=$((after_count - before_count))
      if [ "${diff_count}" -ge 0 ]; then
        total_added=$((total_added + diff_count))
      else
        total_removed=$((total_removed + (-diff_count)))
      fi
      info "  ${category}/: ${after_count} skills"
    done
  fi

  # Write VENDOR.lock (atomic)
  local lock_content
  lock_content="source: ${upstream}
commit: ${commit_sha}
date_vendored: ${today}"

  if [[ "${dest_base}" == *mattpocock-skills* ]]; then
    lock_content="${lock_content}
license: MIT (verify against upstream before publishing)
included:
  - skills/engineering
  - skills/productivity
excluded:
  - skills/deprecated
  - skills/in-progress
  - skills/misc
  - skills/personal"
  fi

  lock_content="${lock_content}
"
  atomic_write "${vendor_lock}" "${lock_content}"

  info "  Commit  : ${commit_sha}"
  info "  Date    : ${today}"
  if [ "${total_added}" -gt 0 ] || [ "${total_removed}" -gt 0 ]; then
    info "  Changes : +${total_added} / -${total_removed} skill directories"
  else
    info "  Changes : none (already up-to-date)"
  fi
  info "  VENDOR.lock written to: ${vendor_lock}"
}

_sync_ponytail_agents() {
  local clone_dir="${1}"
  local target_agents="${2}"

  local upstream_agents="${clone_dir}/repo/AGENTS.md"
  if [ ! -f "${upstream_agents}" ]; then
    warn "AGENTS.md not found in ponytail upstream — skipping"
    return 0
  fi

  local upstream_content
  upstream_content="$(cat "${upstream_agents}")"

  if [ -z "${upstream_content}" ]; then
    warn "Upstream AGENTS.md is empty — skipping sync"
    return 0
  fi

  if replace_managed_block "${target_agents}" "<!-- PONYTAIL:MANAGED:START -->" "<!-- PONYTAIL:MANAGED:END -->" "${upstream_content}"; then
    ok "Synced ponytail AGENTS.md into template"
  else
    warn "No PONYTAIL:MANAGED markers in ${target_agents} — skipping sync"
  fi
}
