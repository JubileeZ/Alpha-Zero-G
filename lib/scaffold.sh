#!/usr/bin/env bash
# lib/scaffold.sh — azg new
# Scaffold engine for new Antigravity CLI projects.

set -u
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd -P)"

source "$REPO_ROOT/lib/common.sh"

AZG_VERSION="$(cat "$REPO_ROOT/VERSION" 2>/dev/null || echo "unknown")"
TODAY="$(date +%Y-%m-%d 2>/dev/null || echo "unknown")"

# ── helpers in lib/common.sh (copy_template, render_template) ────────────────

cmd_new() {
    local target_dir=""
    local git_init="yes"
    local tracker="github"

    while [ $# -gt 0 ]; do
        case "$1" in
            --no-git)
                git_init="no"
                shift
                ;;
            --tracker)
                if [ -n "${2:-}" ]; then
                    tracker="$2"
                    shift 2
                else
                    die "Error: --tracker requires an argument."
                fi
                ;;
            -*)
                die "Error: Unknown option $1"
                ;;
            *)
                if [ -z "$target_dir" ]; then
                    target_dir="$1"
                    shift
                else
                    die "Error: Multiple target directories specified ($target_dir and $1)"
                fi
                ;;
        esac
    done

    if [ -z "$target_dir" ]; then
        printf 'Usage: azg new <target-dir> [--no-git] [--tracker <github|gitlab|local|none>]\n' >&2
        exit 1
    fi

    local project_name
    project_name="$(basename "$target_dir")"

    if [ -e "$target_dir" ]; then
        printf 'Error: "%s" already exists. Choose a different name or use "azg apply" to retrofit.\n' "$target_dir" >&2
        exit 1
    fi

    printf 'Scaffolding "%s"...\n' "$project_name" >&2
    mkdir -p "$target_dir"

    local tmpl_proj="$REPO_ROOT/templates/project"

    # Copy .agents/ skeleton and hooks
    copy_template \
        "$tmpl_proj/.agents/hooks/block-destructive-ops.sh" \
        "$target_dir/.agents/hooks/block-destructive-ops.sh"
    chmod +x "$target_dir/.agents/hooks/block-destructive-ops.sh"

    copy_template \
        "$tmpl_proj/.agents/hooks/commit-gate.sh" \
        "$target_dir/.agents/hooks/commit-gate.sh"
    chmod +x "$target_dir/.agents/hooks/commit-gate.sh"

    copy_template \
        "$tmpl_proj/.agents/hooks/checkpoint-scan.sh" \
        "$target_dir/.agents/hooks/checkpoint-scan.sh"
    chmod +x "$target_dir/.agents/hooks/checkpoint-scan.sh"

    copy_template \
        "$tmpl_proj/.agents/hooks/checkpoint.sh" \
        "$target_dir/.agents/hooks/checkpoint.sh"
    chmod +x "$target_dir/.agents/hooks/checkpoint.sh"

    copy_template \
        "$tmpl_proj/.agents/hooks/spawn-budget.sh" \
        "$target_dir/.agents/hooks/spawn-budget.sh"
    chmod +x "$target_dir/.agents/hooks/spawn-budget.sh"

    copy_template \
        "$tmpl_proj/.agents/hooks/pre-compact.sh" \
        "$target_dir/.agents/hooks/pre-compact.sh"
    chmod +x "$target_dir/.agents/hooks/pre-compact.sh"

    copy_template "$tmpl_proj/.agents/hooks.json" "$target_dir/.agents/hooks.json"
    copy_template "$tmpl_proj/.agents/spawn-budget.json" "$target_dir/.agents/spawn-budget.json"
    copy_template "$tmpl_proj/.agents/session-handoff.md.tmpl" "$target_dir/.agents/session-handoff.md"
    copy_template "$tmpl_proj/.gitignore" "$target_dir/.gitignore"

    # Copy .cursor/rules/ (.mdc — Cursor ignores plain .md rules)
    mkdir -p "$target_dir/.cursor/rules"
    for rule in "$tmpl_proj/.cursor/rules"/*.mdc; do
        if [ -f "$rule" ]; then
            copy_template "$rule" "$target_dir/.cursor/rules/$(basename "$rule")"
        fi
    done

    # Copy project skills (Antigravity / agent-requestable; skip .gitkeep-only placeholders)
    mkdir -p "$target_dir/.agents/skills"
    for item in "$tmpl_proj/.agents/skills"/*; do
        if [ -d "$item" ] && [ -f "$item/SKILL.md" ]; then
            cp -R "$item" "$target_dir/.agents/skills/"
        fi
    done

    # Copy Cursor hook adapters (run-hook.cmd = Windows-safe; hooks.json must not cite .sh)
    mkdir -p "$target_dir/.cursor/hooks"
    copy_template "$tmpl_proj/.cursor/hooks.json" "$target_dir/.cursor/hooks.json"
    copy_template "$tmpl_proj/.cursor/hooks/run-hook.cmd" "$target_dir/.cursor/hooks/run-hook.cmd"
    chmod +x "$target_dir/.cursor/hooks/run-hook.cmd"
    for chook in commit-verify.sh stop-checkpoint.sh pre-compact.sh; do
        copy_template "$tmpl_proj/.cursor/hooks/$chook" "$target_dir/.cursor/hooks/$chook"
        chmod +x "$target_dir/.cursor/hooks/$chook"
    done

    # Copy VSCode settings
    copy_template "$tmpl_proj/.vscode/settings.json" "$target_dir/.vscode/settings.json"

    # Copy test harness + portable verify gate
    copy_template "$tmpl_proj/tests/test-harness.sh" "$target_dir/tests/test-harness.sh"
    chmod +x "$target_dir/tests/test-harness.sh"
    copy_template "$tmpl_proj/tests/verify.sh" "$target_dir/tests/verify.sh"
    chmod +x "$target_dir/tests/verify.sh"

    # Copy pre-seeded agent guides
    copy_template "$tmpl_proj/docs/agents/triage-labels.md" "$target_dir/docs/agents/triage-labels.md"
    copy_template "$tmpl_proj/docs/agents/domain.md" "$target_dir/docs/agents/domain.md"
    copy_template "$tmpl_proj/docs/agents/CONTEXT.md.tmpl" "$target_dir/docs/agents/CONTEXT.md.tmpl"

    # Copy the correct issue-tracker template based on selected tracker
    local tracker_src=""
    if [ "$tracker" = "github" ]; then
        tracker_src="$tmpl_proj/docs/agents/issue-tracker.md"
    elif [ "$tracker" = "gitlab" ]; then
        tracker_src="$REPO_ROOT/templates/global/skills/vendor/mattpocock-skills/engineering/setup-matt-pocock-skills/issue-tracker-gitlab.md"
    elif [ "$tracker" = "local" ]; then
        tracker_src="$REPO_ROOT/templates/global/skills/vendor/mattpocock-skills/engineering/setup-matt-pocock-skills/issue-tracker-local.md"
    fi

    if [ -n "$tracker_src" ] && [ -f "$tracker_src" ]; then
        copy_template "$tracker_src" "$target_dir/docs/agents/issue-tracker.md"
    else
        # None or fallback
        printf "# Issue tracker: None\n\nNo external issue tracker is configured.\nAll work state is tracked locally on the filesystem using task.md and ROADMAP.md.\n" > "$target_dir/docs/agents/issue-tracker.md"
    fi

    # Build commands default table
    local build_cmds_table='| Command | What it does |
|---------|-------------|
| `bash tests/verify.sh` | Portable delivery gate (harness + project validation) |
| `bash tests/test-harness.sh` | Harness integrity self-check |'

    # Render AGENTS.md
    render_template \
        "$tmpl_proj/AGENTS.md.tmpl" \
        "$target_dir/AGENTS.md" \
        "PROJECT_NAME" "$project_name" \
        "AZG_VERSION" "$AZG_VERSION" \
        "DATE" "$TODAY" \
        "BUILD_COMMANDS" "$build_cmds_table"

    # Render ROADMAP.md
    render_template \
        "$tmpl_proj/ROADMAP.md.tmpl" \
        "$target_dir/ROADMAP.md" \
        "PROJECT_NAME" "$project_name" \
        "AZG_VERSION" "$AZG_VERSION" \
        "DATE" "$TODAY" \
        "BUILD_COMMANDS" "$build_cmds_table"

    # Render docs/agents/current-state.md
    render_template \
        "$tmpl_proj/docs/agents/current-state.md.tmpl" \
        "$target_dir/docs/agents/current-state.md" \
        "PROJECT_NAME" "$project_name" \
        "AZG_VERSION" "$AZG_VERSION" \
        "DATE" "$TODAY" \
        "BUILD_COMMANDS" "$build_cmds_table"

    # Render docs/agents/progress.md
    render_template \
        "$tmpl_proj/docs/agents/progress.md.tmpl" \
        "$target_dir/docs/agents/progress.md" \
        "PROJECT_NAME" "$project_name" \
        "AZG_VERSION" "$AZG_VERSION" \
        "DATE" "$TODAY" \
        "BUILD_COMMANDS" "$build_cmds_table"

    # Render task.md from template
    render_template \
        "$tmpl_proj/task.md.tmpl" \
        "$target_dir/task.md" \
        "TASK_NAME" "Initial project setup"

    # Git init
    if [ "$git_init" = "yes" ]; then
        if command -v git >/dev/null 2>&1; then
            (
                cd "$target_dir"
                git init -q
                git add .
                git commit -q -m "chore: scaffold project with Alpha-Zero-G v${AZG_VERSION}"
            )
        else
            printf 'Warning: git not found; skipping git init.\n' >&2
        fi
    fi

    printf '\nDone! Project scaffolded at: %s\n' "$target_dir" >&2
    printf '\nNext steps:\n' >&2
    printf '  1. cd %s\n' "$project_name" >&2
    printf '  2. bash tests/verify.sh  (portable delivery gate)\n' >&2
    printf '  3. agy  (start your first session)\n\n' >&2
}
