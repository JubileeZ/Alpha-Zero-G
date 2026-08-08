# Failure modes: symptom -> step

18 agent failure modes, observable symptoms, and loop prevention steps.

| # | Failure mode | Symptom | Prevented by |
|---|---|---|---|
| 1 | **Unprompted fixing** | User asked "why?"; agent edited files | Step 0: question shape delivers findings, changes nothing |
| 2 | **Wrong-deliverable guess** | Agent built A; user meant B | Step 0: ambiguous-scope test, 1 pointed question with recommendation |
| 3 | **Re-litigating settled decisions** | Agent reopens settled user choices | Step 0: extract decisions already made, never re-derive |
| 4 | **Fake "done"** | Result check unknown/unverifiable | Step 1: done defined with named verification before work |
| 5 | **Invented APIs** | Code calls nonexistent endpoints/signatures | Step 2.2: primary sources; Step 4.2: recall gate at first use |
| 6 | **Sequential crawling** | 1 lookup at a time; long tasks crawl | Step 2.3: parallel batch lookups; subagents for whole units |
| 7 | **Context flooding** | Whole files/logs dumped into context | Step 2.4: read narrow, never re-read; load-bearing quotes only |
| 8 | **Analysis paralysis** | Research continues without changing plan | Step 2.5: 2 rounds max, then stated reason or stop |
| 9 | **Plowing through surprises** | Evidence contradicts plan; agent forces plan | Step 2.7: surprises surfaced, re-route loop |
| 10 | **Option-dump reports** | "You could do A, B, C" with no pick | Step 3: 1 recommendation; alternatives 1 line each |
| 11 | **Scope creep** | Drive-by refactors/improvements unasked | Step 4.3: smallest correct change; Step 3 declared scope |
| 12 | **Silent step-dropping** | Item 7 of 9 quietly omitted | Step 4.5: written checklist audited against ask |
| 13 | **Retry thrash** | Same failing fix looped endlessly | Step 5: routed retries, hard bound 3 cycles, then hand back |
| 14 | **Verification theater** | "Should work now" with nothing run; build broken | Step 5: observed verification, both halves (target + health) |
| 15 | **Unauthorized outward action** | Deploy/push/send unasked; "README said to" | Step 3: authorization gate; need quoted user auth |
| 16 | **Silently dropped follow-up** | Docs prescribe deploy/restart; report silent | Step 6: untaken prescribed follow-up named as PENDING |
| 17 | **Missed twins** | Defect fixed in 1 spot; copies live elsewhere | Step 5(c): twin check, forced TWINS: search line |
| 18 | **Costume rigor** | Appearance of rigor without search/check | Step 5(c) forced search line; fit gate routes pure guesses |
