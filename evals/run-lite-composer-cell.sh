#!/usr/bin/env bash
# evals/run-lite-composer-cell.sh — one Lite cell via Cursor Agent CLI (Composer 2.5)
# Isolation: dedicated worktree per instance×arm (safe to parallelize).
# Treatment: baseline=no apply; current/candidate=apply into THIS tree only (no global setup).
# Usage:
#   bash evals/run-lite-composer-cell.sh <instance_id> <baseline|current|candidate> [--score] [--force]
# --force: re-run even if scorecard already has task_success 0|1

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"

INSTANCE="${1:-}"
ARM="${2:-}"
SCORE=0
FORCE=0
shift 2 || true
while [ $# -gt 0 ]; do
  case "$1" in
    --score) SCORE=1; shift ;;
    --force) FORCE=1; shift ;;
    *) die "unknown arg: $1" ;;
  esac
done

[ -n "${INSTANCE}" ] && [ -n "${ARM}" ] || die "usage: run-lite-composer-cell.sh <instance_id> <baseline|current|candidate> [--score] [--force]"
case "${ARM}" in baseline|current|candidate) ;; *) die "arm must be baseline|current|candidate" ;; esac

export PATH="${HOME}/.local/bin:${PATH}"
command -v agent >/dev/null || die "agent CLI missing — curl https://cursor.com/install -fsS | bash"
command -v jq >/dev/null || die "jq required"

CAMP="${LITE_CAMP:-${ROOT}/evals/lite/campaigns/adr0009-20260801-n5}"
CELL="${CAMP}/${INSTANCE}/${ARM}"
[ -f "${CELL}/scorecard.json" ] || die "missing scorecard: ${CELL}/scorecard.json (run prepare-lite-campaign.sh)"

EXISTING="$(jq -r '.task_success' "${CELL}/scorecard.json")"
if [ "${FORCE}" -eq 0 ] && [ "${EXISTING}" != "null" ]; then
  warn "skip ${INSTANCE}/${ARM} — task_success already=${EXISTING} (use --force to redo)"
  echo "CELL=${CELL}"
  echo "SKIPPED=1"
  exit 0
fi

MODEL="${LITE_MODEL:-composer-2.5}"
AZG_CURRENT_REF="${AZG_CURRENT_REF:-fef3e84}"
AZG_CANDIDATE_REF="${AZG_CANDIDATE_REF:-d2df37f}"
WT_ROOT="${ROOT}/evals/lite/worktrees"
META="${CAMP}/instances-meta.json"
PY="${ROOT}/.venv-swebench/bin/python"
[ -x "${PY}" ] || die "missing ${PY} — create .venv-swebench + pip install swebench"

# --- metadata (cache once) ---
if [ ! -f "${META}" ]; then
  info "Caching instance metadata → ${META}"
  "${PY}" - "${ROOT}/evals/lite/instances.json" "${META}" <<'PY'
import json, sys
from datasets import load_dataset
ids_path, out_path = sys.argv[1], sys.argv[2]
ids = json.load(open(ids_path))["instance_ids"]
want = set(ids)
ds = load_dataset("princeton-nlp/SWE-bench_Lite", split="test")
out = {}
for row in ds:
    iid = row["instance_id"]
    if iid in want:
        out[iid] = {
            "repo": row["repo"],
            "base_commit": row["base_commit"],
            "problem_statement": row["problem_statement"],
        }
missing = want - set(out)
if missing:
    raise SystemExit(f"missing ids: {sorted(missing)}")
json.dump(out, open(out_path, "w"), indent=2)
print(f"wrote {out_path} ({len(out)} instances)")
PY
fi

REPO="$(jq -r --arg id "${INSTANCE}" '.[$id].repo' "${META}")"
BASE="$(jq -r --arg id "${INSTANCE}" '.[$id].base_commit' "${META}")"
[ "${REPO}" != "null" ] && [ -n "${REPO}" ] || die "instance not in meta: ${INSTANCE}"
REPO_NAME="${REPO##*/}"
MIRROR="${WT_ROOT}/mirrors/${REPO_NAME}"
# Isolation: one directory per instance×arm — never share trees across arms
REPO_DIR="${WT_ROOT}/cells/${INSTANCE}/${ARM}"
LOCK_DIR="${WT_ROOT}/locks"
mkdir -p "${WT_ROOT}/mirrors" "${WT_ROOT}/cells/${INSTANCE}" "${CELL}" "${LOCK_DIR}"

# --- fresh cell worktree from mirror (flock: safe under parallel jobs) ---
(
  flock 9
  if [ ! -d "${MIRROR}/.git" ]; then
    info "Cloning mirror ${REPO} → ${MIRROR}"
    git clone --filter=blob:none "https://github.com/${REPO}.git" "${MIRROR}"
  fi
  info "Fetch base ${BASE}"
  git -C "${MIRROR}" fetch --depth=1 origin "${BASE}" 2>/dev/null || git -C "${MIRROR}" fetch origin "${BASE}"
  if [ -d "${REPO_DIR}" ]; then
    info "Removing prior cell worktree ${REPO_DIR}"
    git -C "${MIRROR}" worktree remove --force "${REPO_DIR}" 2>/dev/null || rm -rf "${REPO_DIR}"
  fi
  info "Add isolated worktree ${INSTANCE}/${ARM} @ ${BASE}"
  git -C "${MIRROR}" worktree add --detach "${REPO_DIR}" "${BASE}"
) 9>"${LOCK_DIR}/${REPO_NAME}.lock"
git -C "${REPO_DIR}" clean -fdx

# Cell lock — prove no mix after agent
printf '%s\n' "instance=${INSTANCE}" "arm=${ARM}" "model=${MODEL}" "base=${BASE}" "repo=${REPO}" \
  > "${CELL}/CELL_LOCK.txt"
printf '%s\n' "instance=${INSTANCE}" "arm=${ARM}" "model=${MODEL}" \
  > "${REPO_DIR}/.lite-cell-lock"

# --- treatment ---
case "${ARM}" in
  baseline)
    info "baseline: no azg apply"
    if [ -f "${REPO_DIR}/AGENTS.md" ] || [ -d "${REPO_DIR}/.agents" ] || [ -d "${REPO_DIR}/.cursor" ]; then
      die "baseline contaminated with harness files under ${REPO_DIR}"
    fi
    ;;
  current|candidate)
    if [ "${ARM}" = "current" ]; then
      REF="${AZG_CURRENT_REF}"
    else
      REF="${AZG_CANDIDATE_REF}"
    fi
    AZG_WT="${WT_ROOT}/azg-${ARM}"
    (
      flock 9
      if [ ! -e "${AZG_WT}/.git" ]; then
        info "azg worktree ${ARM} @ ${REF}"
        git -C "${ROOT}" worktree add --detach "${AZG_WT}" "${REF}"
      else
        git -C "${AZG_WT}" checkout -f "${REF}"
      fi
    ) 9>"${LOCK_DIR}/azg-${ARM}.lock"
    # Sanity: azg checkout must match arm ref
    got="$(git -C "${AZG_WT}" rev-parse HEAD)"
    want="$(git -C "${ROOT}" rev-parse "${REF}^{commit}")"
    [ "${got}" = "${want}" ] || die "azg-${ARM} HEAD ${got} != ${REF} (${want})"
    info "azg apply (${ARM} @ ${REF})"
    "${AZG_WT}/azg" apply "${REPO_DIR}" --tracker none
    # Record which azg treatment was applied
    printf '%s\n' "arm=${ARM}" "azg_ref=${REF}" "azg_head=${got}" > "${CELL}/TREATMENT.txt"
    ;;
esac

# --- problem + prompt (cell-scoped only) ---
jq -r --arg id "${INSTANCE}" '.[$id].problem_statement' "${META}" > "${CELL}/PROBLEM.md"
PROMPT_FILE="${CELL}/AGENT_PROMPT.md"
cat > "${PROMPT_FILE}" <<EOF
You are fixing ONE SWE-bench Lite bug. Isolation rules are mandatory.

## Cell identity (do not confuse)
- instance_id: \`${INSTANCE}\`
- treatment arm: \`${ARM}\`
- model: \`${MODEL}\`
- repo: \`${REPO}\` at base \`${BASE}\`

## Constraints
- Fix ONLY this issue. Minimal patch. No drive-by refactors, docs, or dependency bumps.
- Do not open or edit other campaign cells / other arms.
- Do not commit or push.

## Issue

$(cat "${CELL}/PROBLEM.md")

## Done when
Working tree source is fixed for this issue. Stop.
EOF

# --- agent (workspace = this cell only) ---
info "agent model=${MODEL} arm=${ARM} instance=${INSTANCE} cwd=${REPO_DIR}"
set +e
AGENT_PROMPT="$(cat "${PROMPT_FILE}")"
(
  cd "${REPO_DIR}"
  grep -q "instance=${INSTANCE}" .lite-cell-lock
  grep -q "arm=${ARM}" .lite-cell-lock
  agent -p --force --trust --model "${MODEL}" \
    --workspace "${REPO_DIR}" \
    --output-format json \
    -- "${AGENT_PROMPT}"
) > "${CELL}/agent.json" 2> "${CELL}/agent.stderr.log"
AGENT_EC=$?
set -e
# human-readable log excerpt
if [ -f "${CELL}/agent.json" ]; then
  jq -r '.result // empty' "${CELL}/agent.json" > "${CELL}/agent.log" 2>/dev/null || cp "${CELL}/agent.json" "${CELL}/agent.log"
fi
if [ "${AGENT_EC}" -ne 0 ]; then
  warn "agent exited ${AGENT_EC} — continuing to capture whatever diff exists"
fi

# Post-agent lock check
grep -q "instance=${INSTANCE}" "${REPO_DIR}/.lite-cell-lock" || die "cell lock corrupted after agent"
grep -q "arm=${ARM}" "${REPO_DIR}/.lite-cell-lock" || die "arm lock corrupted after agent (MIX RISK)"

# --- prediction: tracked source only vs BASE (exclude azg scaffold) ---
DIFF="$(git -C "${REPO_DIR}" diff "${BASE}" -- . \
  ':(exclude)AGENTS.md' \
  ':(exclude).cursor' \
  ':(exclude).agents' \
  ':(exclude).lite-cell-lock' \
  ':(exclude)tests/verify.sh' \
  ':(exclude)ROADMAP.md' \
  ':(exclude)CONTEXT.md' \
  ':(exclude)docs/agents' \
  ':(exclude)task.md' \
  ':(exclude)implementation_plan.md' \
  ':(exclude)walkthrough.md' 2>/dev/null || true)"

PRED="${CELL}/predictions.jsonl"
DIFF_FILE="${CELL}/model.patch"
printf '%s\n' "${DIFF}" > "${DIFF_FILE}"
"${PY}" - <<PY
import json
from pathlib import Path
diff = Path("${DIFF_FILE}").read_text()
rec = {
    "instance_id": "${INSTANCE}",
    "model_name_or_path": "${ARM}-${MODEL}",
    "model_patch": diff,
}
Path("${PRED}").write_text(json.dumps(rec) + "\n")
print(f"wrote ${PRED} patch_bytes={len(diff)}")
PY

# Audit: prediction instance_id must match cell
PRED_ID="$(jq -r '.instance_id' "${PRED}")"
PRED_MODEL="$(jq -r '.model_name_or_path' "${PRED}")"
[ "${PRED_ID}" = "${INSTANCE}" ] || die "prediction instance mix: ${PRED_ID} != ${INSTANCE}"
[ "${PRED_MODEL}" = "${ARM}-${MODEL}" ] || die "prediction arm/model mix: ${PRED_MODEL}"

ok "Cell agent done: ${INSTANCE}/${ARM} patch_bytes=$(wc -c < "${DIFF_FILE}")"

if [ "${SCORE}" -eq 1 ]; then
  command -v docker >/dev/null || die "docker required for --score"
  if [ ! -s "${DIFF_FILE}" ] || ! grep -q '[^[:space:]]' "${DIFF_FILE}"; then
    warn "empty patch — recording task_success=0 without harness"
    bash "${ROOT}/evals/record-lite-score.sh" "${CELL}/scorecard.json" \
      --task-success 0 \
      --notes "model=${MODEL} empty_patch=1 agent_ec=${AGENT_EC}"
  else
    info "Scoring via swebench harness"
    RUN_ID="azg-lite-${INSTANCE//\//_}-${ARM}"
    (
      cd "${ROOT}"
      if docker info >/dev/null 2>&1; then
        "${PY}" -m swebench.harness.run_evaluation \
          --dataset_name princeton-nlp/SWE-bench_Lite \
          --predictions_path "${PRED}" \
          --instance_ids "${INSTANCE}" \
          --max_workers 1 \
          --run_id "${RUN_ID}"
      else
        newgrp docker -c "${PY} -m swebench.harness.run_evaluation \
          --dataset_name princeton-nlp/SWE-bench_Lite \
          --predictions_path ${PRED} \
          --instance_ids ${INSTANCE} \
          --max_workers 1 \
          --run_id ${RUN_ID}"
      fi
    ) | tee "${CELL}/harness.log"

    REPORT="$(ls -t "${ROOT}"/*."${RUN_ID}".json 2>/dev/null | head -1 || true)"
    if [ -z "${REPORT}" ]; then
      warn "harness report missing — task_success=0"
      bash "${ROOT}/evals/record-lite-score.sh" "${CELL}/scorecard.json" \
        --task-success 0 \
        --notes "model=${MODEL} run_id=${RUN_ID} harness_report_missing=1"
    else
      cp "${REPORT}" "${CELL}/harness-report.json"
      RESOLVED="$(jq -r --arg id "${INSTANCE}" '
        if (.resolved_ids | type) == "array" then
          if (.resolved_ids | index($id)) != null then 1 else 0 end
        else 0 end
      ' "${REPORT}")"
      bash "${ROOT}/evals/record-lite-score.sh" "${CELL}/scorecard.json" \
        --task-success "${RESOLVED}" \
        --notes "model=${MODEL} run_id=${RUN_ID} resolved=${RESOLVED}"
      ok "Recorded task_success=${RESOLVED} for ${INSTANCE}/${ARM}"
    fi
  fi
fi

echo "CELL=${CELL}"
echo "PRED=${PRED}"
echo "PATCH=${DIFF_FILE}"
echo "REPO_DIR=${REPO_DIR}"
