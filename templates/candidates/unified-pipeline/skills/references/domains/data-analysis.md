# Domain adapter: data analysis

Applies when deliverable is answer derived from data: spreadsheets, exports, logs, metrics. Loop unchanged; definitions replace coding defaults.

## Minimum evidence set (binding, before aggregate)
1. **Raw data inspected**: header, row sample, row count. Real exports are dirty.
2. **Data-quality pass**: duplicates, mixed formats, refunds/negatives, nulls, out-of-window rows.
3. **Exact question boundaries**: period, population, metric definition restated.

## Evidence and primary sources
Dataset is primary source; user description is a claim. Disagreements surfaced.

## Authority order
User question/definitions > dataset itself > column names/labels > assumptions.

## Verification by observation
- Numbers recomputed by runnable script or method.
- Data-quality choices stated (deduped X, excluded Y, netted Z).
- Totals cross-check: parts sum to whole.

## Fraud table
| Fraud | Symptom |
|---|---|
| Naive aggregation | duplicates/refunds silently included |
| Silent cleaning | rows dropped with no count/rationale |
| Cherry-picked windows | filter chosen to flatter conclusion |
| Phantom precision | exact numbers from dirty inputs without caveat |
| Unreproducible answers | numbers without method/script |

## Done, by example
"Top products Q2 done" means: ranking with amounts, data-quality issues handled, sensitivity stated, reproducible script shown. Not: "summed amount column."
