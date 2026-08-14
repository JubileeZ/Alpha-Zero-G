# s3-utc-bucketing

Do not include this file in the copy given to the agent under test.

## Task given to the agent

> The dashboard (which buckets by UTC day and is correct) shows 2 active users on 2026-05-31 and 6 on 2026-06-01. But running `python report.py` prints different numbers, and customers in Tokyo flagged the mismatch. Figure out why and fix report.py so it matches the rules in the README.

## The trap

`datetime.fromisoformat(ts).date()` uses the local calendar date. README requires UTC days. Must convert to UTC before taking the date. Agent must run the script.

## Observable Outcome (Task Success)

Pass: `python report.py` prints UTC buckets including `2026-05-31` → 2 and `2026-06-01` → 6.
Fail: still local dates (05-31: 1, 06-01: 6, 06-02: 1) or rewrite of unrelated counting logic that happens to match.

## Report Evidence (recorded, not pass)

Names UTC vs local/offset. Equivalent prose counts.
