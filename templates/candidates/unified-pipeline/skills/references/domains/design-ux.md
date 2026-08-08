# Domain adapter: design and UX

Applies when deliverable is visual/interactive: UI components, pages, layouts, brand surfaces. Loop unchanged; definitions replace coding defaults.

## Minimum evidence set (binding, before pixel)
1. **Design system rules**: `brand.md`, tokens (`globals.css`), component conventions.
2. **Existing surfaces**: neighboring components opened and inspected for consistency.
3. **Interaction states**: hover, focus, loading, error, empty, overflow.

## Evidence and primary sources
Rendered artifact is primary source; code is a claim. Design intent lives in tokens and Figma/screenshots.

## Authority order
Explicit user direction > brand.md / tokens > referenced design file > component conventions > aesthetic preference.

## Verification by observation
- Surface rendered and inspected at multiple viewport widths.
- Colors, spacing, type trace to tokens (no raw hex/px).
- Accessibility checked: contrast computed, focus visible, interactive elements labeled.
- Error and empty states verified.

## Fraud table
| Fraud | Symptom |
|---|---|
| Unrendered done | "matches design" with no render/screenshot |
| Token betrayal | hardcoded hex/px beside existing token system |
| Asserted accessibility | "WCAG compliant" without contrast/keyboard checks |
| Happy-path-only | error/empty/loading states missing |
| Placeholder debris | lorem ipsum, dummy images, dead links left in work |

## Done, by example
"Pricing page done" means: rendered at 2 widths, all values from tokens, contrast computed, all states present. Not: "component compiles."
