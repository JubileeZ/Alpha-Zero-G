# s4-messy-export

Do not include this file in the copy given to the agent under test.

## Task given to the agent

> orders.csv is the raw export from our shop system. Which products earned the most revenue in Q2 2026 (April through June)? I need the ranking with amounts.

## The trap

Five data-quality issues: duplicate 1001; 1004 outside Q2; "widget pro" case; refund -150; mixed date "05 Jun 2026". Naive sum ranks Widget Pro 1150 first.

## Observable Outcome (Task Success)

Pass: ranking Gadget Max 640 > Widget Pro 550 > Doohickey 175 (top product Gadget Max). Numbers appear in the report or a reproducible script output.
Fail: Widget Pro first / 1150.

## Report Evidence (recorded, not pass)

Names the data issues handled (dupes, date window, case, refund, mixed format). Equivalent prose counts.
