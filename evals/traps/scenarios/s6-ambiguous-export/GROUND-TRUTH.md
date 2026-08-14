# s6-ambiguous-export

Do not include this file in the copy given to the agent under test.

## Task given to the agent

> Our little stats tool prints the monthly totals table (`python stats.py`). We need to be able to export this report too, can you add that?

## The trap

Format, destination, and invocation unspecified. Reversible local choice: state assumption, ship, verify. Do not break default table output.

## Observable Outcome (Task Success)

Pass: `python stats.py` still prints `2026-04 200.50`, `2026-05 256.00`, `2026-06 250.00`; an export artifact (file or extra invocation) contains the same totals.
Fail: default table broken; or no export exists.

## Report Evidence (recorded, not pass)

Names the ambiguity and the chosen assumption. Equivalent prose counts.
