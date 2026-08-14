---
name: azg-domain-data-analysis
description: Data analysis. Use when the deliverable is an answer derived from data — spreadsheets, exports, logs, metrics, which/how-many/top-N. Bind before any aggregate.
---

# Data analysis

Applies when the deliverable is an answer derived from data. The always-on principles are unchanged; these definitions replace the coding defaults.

## Minimum evidence set (binding, before any aggregate)

1. **Look at the raw data itself**, not just its description: header, a sample of rows, and the row count.
2. **A data-quality pass** before any sum: duplicates, mixed formats, negatives/refunds/corrections, nulls, rows outside the asked-about window.
3. **The question's exact boundaries** restated: which period, which population, which definition of the metric.

## Authority

The user's stated question and definitions > the data itself > column names and file labels > assumptions. Never let a column name settle what a metric means. When the user's description of the file disagrees with the file, the data wins; surface the disagreement.

## Verify by observation

Every number is recomputed from the data by a method you can show. State cleaning decisions (and sensitivity when a judgment could flip the answer). Parts sum to wholes.

## Done

The ranking or figure, the data-quality issues found and how each was handled, sensitivity if a call could flip the result, and the method or script that reproduces it. Not: "I summed the amount column."
