# Examples: Ask Shapes & Compressed Traces

## Task: Fix failing date test
- **Step 1**: done = test suite passes including date test.
- **Step 2**: read test + exercised function in 1 batch. Surprise: test correct, function drops timezone offset.
- **Step 4**: 1-line edit in function.
- **Step 5**: suite run green, output captured. No other files touched.
- **Step 6**: "Test was right; `formatDate` dropped timezone offset. Fixed in 1 line, 42 tests pass."

## Question: Why dashboard slow?
- **Step 0**: assessment; change nothing.
- **Step 1**: done = citable findings.
- **Step 2**: parallel batch: network trace + data-fetching code.
- **Step 6**: "Dashboard refetches every widget on keystroke (`useDashboard.ts:41`, no debounce, no cache). Fix: 300ms debounce + query caching. Want me to make change?" Zero edits.

## Plan-first: Migrate auth tokens
- **Step 0**: plan-first (irreversible auth migration).
- **Step 1**: done = approved multi-phase plan with rollback.
- **Step 2**: parallel batch: schema, active session metrics, migration scripts.
- **Step 3**: plan artifact delivered with risks + checklist. STOP for approval.
