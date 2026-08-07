---
name: azg-domain-design
description: UI/UX, layouts, design reviews, brand surfaces, presentations. Open before pixels: bind design system and rendered surfaces.
---

# azg-domain-design

Applies when deliverable = visual/interactive (UI, pages, layouts, reviews, brand surfaces, presentations). Loop unchanged.

## Minimum evidence set (binding, before any pixel)

1. **Design system rules** — brand.md, tokens, component conventions. None → say so before inventing.
2. **Existing surfaces** — neighboring pages/components opened and looked at.
3. **Interaction states** — hover, focus, loading, error, empty, overflow — not happy path only.

## Evidence and primary sources

Rendered artifact = primary; code = claim about it. Intent in brand.md/tokens/design refs — not memory of "what looks good."

## Authority order

Explicit user/client > brand.md/tokens > referenced design file > existing conventions > aesthetic preference. "Make it pop" does not override tokens — surface conflict.

## Verification by observation

- Surface rendered and looked at (screenshot/live); ≥2 widths if responsive.
- Colors/spacing/radii/type from tokens; grep raw hex/px next to tokens.
- A11y checked not asserted: contrast computed, focus visible, labels, keyboard path.
- All min-evidence states exist and were seen.

## Fraud table (claim re-check)

| Fraud | Symptom |
|---|---|
| Unrendered done | "matches design" with no screenshot/render |
| Token betrayal | hardcoded hex/px/fonts beside token system |
| Asserted accessibility | WCAG claim with no contrast/keyboard/label check |
| Happy-path-only | error/empty/loading/overflow missing unmentioned |
| Off-family surfaces | foreign to neighbors, unflagged |
| Placeholder debris | lorem/stock/dead links in "finished" work |

## Done, by example

"Pricing page done" = rendered at two widths, values from tokens, contrast on new pairs, all states present, consistent with siblings. Not: "compiles and looks fine."

Provenance: Fable Method sector skill ideas (MIT); azg-owned wording.
