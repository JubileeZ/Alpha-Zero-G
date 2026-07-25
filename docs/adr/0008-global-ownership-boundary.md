# Global Ownership Boundary

`azg setup` / `azg uninstall` must only create, refresh, or delete assets Alpha-Zero-G owns. Foreign MCP configs, custom skills (no vendor sentinel), and unmanaged AGENTS.md must be left alone unless the operator passes `--force`. Ownership is recorded in a small manifest under the global azg dir so uninstall is selective rather than `rm -rf` of shared `~/.gemini` trees.
