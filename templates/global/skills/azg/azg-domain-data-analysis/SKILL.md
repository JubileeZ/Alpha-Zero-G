---
name: azg-domain-data-analysis
description: Spreadsheet, export, metrics, top-N from data. Use when the answer derives from datasets/logs. Open before aggregating: binds min evidence for data work.
---

# azg-domain-data-analysis

Applies when deliverable = answer from data (spreadsheets, exports, logs, metrics, top-N). Loop unchanged.

## Minimum evidence set (binding, before any aggregate)

1. **Look at raw data** — header, sample rows, row count. Exports dirtier than described.
2. **Data-quality pass** before sum: duplicates, mixed formats, refunds/negatives, nulls, out-of-window rows.
3. **Exact question boundaries** restated: period, population, metric definition.

## Evidence and primary sources

Dataset = primary. User description of dataset = claim. Disagreement → data wins; surface it.

## Authority order

User question/definitions > data itself > column names/file labels > assumptions. Column name "total" never settles metric meaning.

## Verification by observation

- Every number recomputed by showable method (script > described method > unexplained figure).
- Quality decisions stated with counts; sensitivity when judgment could flip answer.
- Totals cross-check; independent recount survives.

## Fraud table (claim re-check)

| Fraud | Symptom |
|---|---|
| Naive aggregation | duplicates/refunds/out-of-window silently included |
| Silent cleaning | rows dropped/merged with no mention |
| Cherry-picked windows | filter chosen to flatter conclusion |
| Phantom precision | exact figures from dirty inputs, no caveat |
| Unreproducible answers | numbers with no method/artifact |
| Description trust | analyzing what file was said to contain |

## Done, by example

"Top products for Q2 done" = ranking + amounts, quality issues + handling, sensitivity if judgment flips #1, reproducible method. Not: "summed amount column."

Provenance: Fable Method sector skill ideas (MIT); azg-owned wording.
