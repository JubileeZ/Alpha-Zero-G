# Live Campaign — Trap Suite (local; gitignored under campaigns/)

| Field | Value |
|-------|-------|
| Campaign id | `pre-wfa-reverse` |
| Mode | **Full corpus** (`TRAP_FULL=1`) |
| Model | `gpt-5.6-luna-low` |
| Current ref | `d5711c2` — WFA-era Intent gates (keep) |
| Candidate ref | `2e6ff14` — **pre-WFA** (reverse Candidate) |
| Metric | Process Gate binary — not Lite Task Success |
| Prior | `full-first` was harness smoke (current≈candidate); not a WFA A/B |

Overwrite when Candidate under test changes. Do not commit campaign trees.
