# Stop Checkpoint retired; Work Packets are git-native slugs

Stop and PreCompact continuity hooks hijacked agent turn-complete (`followup_message` / `decision: continue`) and last-writer-wins on a singleton `task.md`. **Checkpoint** is a git commit. A repo may hold several **Work Packets** at `.agents/work-packets/<packet-id>.md` (human kebab **Packet ID**, not a host session id). **Bind** only on continue / named slug / **Handoff Pointer**. **Independent Request**: no packet I/O. Finished packets are deleted, not emptied. `azg apply` migrates leftover `task.md` / real `session-handoff.md` and does not reseed them.

Cursor never ran `.agents/hooks/block-destructive-ops.sh` (only Antigravity `PreToolUse`; Cursor `hooks.json` matched `git commit` only). Cursor now has a thin `beforeShellExecution` adapter so the same policy actually fires. Missing `jq` or unparseable policy output **fail closed** (deny). File-write deny remains Antigravity-only (Cursor has no PreToolUse on Write). Finished packet = at least one `- [x]` and no open `- [ ]`; packets with no checkboxes stay.

**Status:** accepted 2026-08-20

**Consequences:** Adopted repos `azg apply` to drop Stop/PreCompact scripts, strip leftover `Stop` JSON, migrate packets. Commit-gate requires a staged path under `.agents/work-packets/`. ADR 0004 still holds: git gates own Checkpoint; IDE hooks are adapters.

**Amends:** SPEC §6–7 work-state. Session-handoff SFDBN file retired.
