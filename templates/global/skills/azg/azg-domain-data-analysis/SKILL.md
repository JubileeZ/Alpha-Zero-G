---
name: azg-domain-data-analysis
description: Domain adapter for data analysis — binding min evidence on raw data, quality pass, and reproducible aggregates. Use for spreadsheets, exports, logs, metrics, top-N from data. Open before aggregating.
---

# Domain adapter: data analysis

Applies when the answer is derived from data: spreadsheets, exports, logs, metrics, which/how-many/top-N. Loop unchanged; these nouns replace coding defaults.

## Minimum evidence set (binding, before any aggregate)

1. **Look at the raw data** — header, sample rows, row count. Exports are dirtier than described.
2. **Data-quality pass** before sums: duplicates, mixed formats, negatives/refunds, nulls, out-of-window rows.
3. **Exact boundaries** restated: period, population, metric definition.

## Evidence and authority

Dataset is primary; user's description of it is a claim. Disagreement → data wins; surface it.

Authority: user question/definitions > data > column names/file labels > assumptions. Column name "total" does not define the metric.

## Verification by observation

- Every number recomputed by a showable method (script > described method > unexplained figure).
- Cleaning decisions stated with counts; sensitivity when a judgment could flip the answer.
- Totals cross-check; independent recount survives.

## Fraud table (Prove)

| Fraud | Symptom |
|---|---|
| Naive aggregation | duplicates/refunds/out-of-window included silently |
| Silent cleaning | drops/merges with no count or rationale |
| Cherry-picked windows | filter chosen to flatter conclusion |
| Phantom precision | exact figures from dirty inputs, no caveat |
| Unreproducible answers | numbers with no method/artifact |
| Description trust | analyzing the file as described, not as it is |
| Label/claim mismatch | scenario or Findings names not in runner/CSV output |
| Unfair counterfactual | compared paths that optimized the same objective |

## Done (example)

Ranking with amounts; quality issues found and how handled; sensitivity if judgment flips rank-1; script/method that reproduces. Not: "I summed the amount column."
