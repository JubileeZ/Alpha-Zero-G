#!/usr/bin/env bash
# tests/host-contract-smoke.sh — Host-contract simulator
#
# Proves the adapter contract both IDEs must honor:
#   hook returns deny/permission:deny  →  pending side effect MUST NOT run
#   hook returns allow                 →  side effect MAY run
#
# This is not a substitute for manual Cursor/Antigravity smoke
# (see docs/agents/host-contract-smoke.md); it locks the protocol so CI
# cannot regress the deny→no-side-effect invariant.

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=tests/harness.sh
source "$(dirname "${BASH_SOURCE[0]}")/harness.sh"

WORK="$(azg_mktemp_d "tmp_azg_host_contract-XXXXXX")"
cd "${WORK}"

# Minimal project with template hooks + portable gate
mkdir -p .agents/hooks .cursor/hooks tests
cp "${ROOT}/templates/project/.agents/hooks/block-destructive-ops.sh" .agents/hooks/
cp "${ROOT}/templates/project/.agents/hooks/commit-gate.sh" .agents/hooks/
cp "${ROOT}/templates/project/.cursor/hooks/commit-verify.sh" .cursor/hooks/
cp "${ROOT}/templates/project/tests/verify.sh" tests/
chmod +x .agents/hooks/*.sh .cursor/hooks/*.sh tests/verify.sh

# Stub harness files so verify.sh can pass when we need allow-path
for f in AGENTS.md ROADMAP.md; do printf '# stub\n' > "${f}"; done
mkdir -p docs/agents .agents
for f in current-state.md progress.md issue-tracker.md triage-labels.md domain.md; do
  printf '# stub\n' > "docs/agents/${f}"
done
cp "${ROOT}/templates/project/.agents/hooks.json" .agents/hooks.json
cp "${ROOT}/templates/project/.agents/spawn-budget.json" .agents/spawn-budget.json
for hook in checkpoint.sh spawn-budget.sh pre-compact.sh; do
  cp "${ROOT}/templates/project/.agents/hooks/${hook}" .agents/hooks/
  chmod +x ".agents/hooks/${hook}"
done
cp "${ROOT}/templates/project/tests/test-harness.sh" tests/
chmod +x tests/test-harness.sh

# --- Host simulator ----------------------------------------------------------
# Runs HOOK with PAYLOAD on stdin. Only executes SIDE_EFFECT if decision/permission is allow.
simulate_host() {
  local hook="$1"
  local payload="$2"
  local side_effect="$3"
  local out decision
  out=$(printf '%s' "${payload}" | bash "${hook}" 2>/dev/null) || true
  decision=$(printf '%s' "${out}" | sed -n 's/.*"decision"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)
  if [ -z "${decision}" ]; then
    decision=$(printf '%s' "${out}" | sed -n 's/.*"permission"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)
  fi
  case "${decision}" in
    allow)
      # Host proceeds
      eval "${side_effect}"
      ;;
    deny)
      # Host MUST NOT proceed — intentional no-op
      :
      ;;
    *)
      printf 'HOST_CONTRACT_ERROR: unparseable hook output: %s\n' "${out}" >&2
      return 2
      ;;
  esac
  printf '%s' "${decision}"
}

section "1. Antigravity deny must not execute side effect"

CANARY="${WORK}/agy-deny-canary"
rm -f "${CANARY}"
payload='{"toolCall":{"name":"run_command","args":{"CommandLine":"rm -rf /"}}}'
decision=$(simulate_host ".agents/hooks/block-destructive-ops.sh" "${payload}" "touch '${CANARY}'")
if [ "${decision}" = "deny" ] && [ ! -e "${CANARY}" ]; then
  pass "Antigravity deny prevented side effect"
else
  fail "Antigravity deny must block side effect" "decision=${decision} canary_exists=$([ -e "${CANARY}" ] && echo yes || echo no)"
fi

section "2. Antigravity allow may execute side effect"

CANARY="${WORK}/agy-allow-canary"
rm -f "${CANARY}"
payload='{"toolCall":{"name":"run_command","args":{"CommandLine":"echo safe"}}}'
decision=$(simulate_host ".agents/hooks/block-destructive-ops.sh" "${payload}" "touch '${CANARY}'")
if [ "${decision}" = "allow" ] && [ -e "${CANARY}" ]; then
  pass "Antigravity allow ran side effect"
else
  fail "Antigravity allow should run side effect" "decision=${decision} canary_exists=$([ -e "${CANARY}" ] && echo yes || echo no)"
fi

section "3. Cursor deny must not execute side effect"

# Break verify so commit-verify denies
rm -f AGENTS.md
CANARY="${WORK}/cursor-deny-canary"
rm -f "${CANARY}"
payload='{"command":"git commit -m test"}'
decision=$(simulate_host ".cursor/hooks/commit-verify.sh" "${payload}" "touch '${CANARY}'")
if [ "${decision}" = "deny" ] && [ ! -e "${CANARY}" ]; then
  pass "Cursor deny prevented side effect"
else
  fail "Cursor deny must block side effect" "decision=${decision} canary_exists=$([ -e "${CANARY}" ] && echo yes || echo no)"
fi

section "4. Cursor allow may execute side effect"

printf '# stub\n' > AGENTS.md
git init -q
printf 'x\n' > README
git add README
git -c user.email=t@t -c user.name=t commit -m init -q
CANARY="${WORK}/cursor-allow-canary"
rm -f "${CANARY}"
payload='{"command":"git commit -m test"}'
decision=$(simulate_host ".cursor/hooks/commit-verify.sh" "${payload}" "touch '${CANARY}'")
if [ "${decision}" = "allow" ] && [ -e "${CANARY}" ]; then
  pass "Cursor allow ran side effect"
else
  fail "Cursor allow should run side effect" "decision=${decision} canary_exists=$([ -e "${CANARY}" ] && echo yes || echo no)"
fi

section "5. Cursor hooks.json failClosed contract"

HOOKS_JSON="${ROOT}/templates/project/.cursor/hooks.json"
if grep -q '"failClosed"[[:space:]]*:[[:space:]]*true' "${HOOKS_JSON}"; then
  pass "Cursor beforeShellExecution uses failClosed: true"
else
  fail "Cursor commit hook must set failClosed: true"
fi
if grep -q 'run-hook\.cmd' "${HOOKS_JSON}" && [ -f "${ROOT}/templates/project/.cursor/hooks/run-hook.cmd" ]; then
  pass "Cursor hooks use run-hook.cmd launcher (Windows-safe)"
else
  fail "Cursor hooks must invoke via run-hook.cmd (bare .sh opens on Windows)"
fi
# Windows ShellExecutes path tokens ending in .sh inside the command string
if grep -E '"command"[[:space:]]*:[[:space:]]*"[^"]*\.sh"' "${HOOKS_JSON}"; then
  fail "Cursor hooks.json must not put .sh paths in command (causes editor open on Windows)"
else
  pass "Cursor hooks.json commands contain no .sh paths"
fi

section "5b. Spawn-budget PreToolUse wiring (ADR 0006)"

AGY_HOOKS="${ROOT}/templates/project/.agents/hooks.json"
if grep -q 'invoke_subagent' "${AGY_HOOKS}" && grep -q 'spawn-budget.sh' "${AGY_HOOKS}"; then
  pass "hooks.json wires spawn-budget on PreToolUse invoke_subagent"
else
  fail "spawn-budget must be on PreToolUse invoke_subagent (SubagentStart cannot block)"
fi

section "5c. Spawn-budget slot lifecycle (allow → deny → finish → reuse)"

SPAWN_HOOK=".agents/hooks/spawn-budget.sh"
bash "${SPAWN_HOOK}" --reset >/dev/null
_spawn_ok=1
for _i in 1 2 3 4 5; do
  _out=$(printf '{"subagent_id":"s%s"}' "${_i}" | bash "${SPAWN_HOOK}")
  echo "${_out}" | grep -q '"decision":"allow"' || _spawn_ok=0
done
_deny=$(printf '{"subagent_id":"s6"}' | bash "${SPAWN_HOOK}")
echo "${_deny}" | grep -q '"decision":"deny"' || _spawn_ok=0
printf '{"subagent_id":"s1"}' | bash "${SPAWN_HOOK}" --finish >/dev/null
_reuse=$(printf '{"subagent_id":"s6"}' | bash "${SPAWN_HOOK}")
echo "${_reuse}" | grep -q '"decision":"allow"' || _spawn_ok=0
if [ "${_spawn_ok}" -eq 1 ]; then
  pass "spawn-budget concurrent slots: 5 allow, 6th deny, finish frees reuse"
else
  fail "spawn-budget slot lifecycle broken" "deny=${_deny} reuse=${_reuse}"
fi
bash "${SPAWN_HOOK}" --reset >/dev/null

section "6. Manual smoke doc present"

assert_file_exists "host-contract-smoke.md exists" "${ROOT}/docs/agents/host-contract-smoke.md"
assert_file_contains "doc covers Cursor" "${ROOT}/docs/agents/host-contract-smoke.md" "Cursor"
assert_file_contains "doc covers Antigravity" "${ROOT}/docs/agents/host-contract-smoke.md" "Antigravity"

test_summary
