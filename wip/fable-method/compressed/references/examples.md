# Worked examples: one per ask shape

Each example shows protocol applied end to end, with two steps weak models most often fake (Step 1 definition of done and Step 5 observed verification) spelled out concretely.

## 1. Trivial (gate, no protocol)

**Ask:** "Rename `getUsrData` to `getUserData` in api.ts."

One file, under 10 lines, no new behavior, no searching needed: trivial. Make edits (definition plus call sites in that file), run typecheck or build project already uses, report: "Renamed, 3 call sites updated, `tsc` clean." Done in three sentences. No classification table, no plan.

If rename turned out to cross files (search shows 14 call sites in 6 files), gate fails retroactively: say so and enter full protocol at Step 1 with checklist.

## 2. Question / assessment

**Ask:** "Why is the dashboard slow?"

- **Step 0:** assessment. Deliverable is diagnosis. Change nothing.
- **Step 1:** done = cause backed by observations; every claim citable to file and line or measurement.
- **Step 2:** in one parallel batch: data-fetching hook, render path, look at what network requests actually fire (run app or read query configuration). Surprise check: is slowness where assumed?
- **Step 3:** one cause, one recommended fix. "It could be several things" is not finding.
- **Step 6:** "The dashboard refetches all 12 widgets on every keystroke: `useDashboard.ts:41` has no debounce and query cache key includes raw search string. Fix would be 300ms debounce plus normalized cache key. Want me to make that change?" No files touched; offer at end is only bridge to task.

## 3. Task

**Ask:** "Fix the failing date test."

- **Step 0:** task. Deliverable is fixed code, verified.
- **Step 1:** done = full suite passes, including `test_format_date`. Verification = suite run output.
- **Step 2:** read test and function it exercises in one batch. Surprise: test correct; `formatDate` drops timezone offset. Stated to user, since changes where fix goes.
- **Step 4:** one edit in `formatDate`. Nothing else touched.
- **Step 5:** full suite run: 42 passed. Both halves: target test passes, rest of suite still passes.
- **Step 6:** "The test was right: `formatDate` dropped timezone offset (`dates.ts:27`). Fixed in one line; all 42 tests pass (output below)."

## 4. Plan-first

**Ask:** "Analyze how my projects configure X and propose a global standard."

- **Step 0:** plan-first: user said "propose", applying standard across projects is wide blast radius. Deliverable is plan; stop after presenting.
- **Step 1:** done = plan user can approve; each planned step names own verification (for config rollout: file exists, per-project files still lint/build, diff summary per project).
- **Step 2:** parallel: find every config instance, read all in one batch, fetch any external reference user named. Tabulate what projects actually do; frequency table is evidence.
- **Step 3:** one proposed standard. Conflicts between projects named, each with recommended resolution, not silently averaged.
- **Deliver plan. Stop.** Steps 4-6 happen only after approval; execution surgical: precise edits per project, measured before/after, report includes what intentionally left alone and why.
