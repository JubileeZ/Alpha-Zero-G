# Failure modes: symptom to step

Eighteen ways agentic work goes wrong, what each looks like from outside, which step of core protocol prevents it. Used by audit mode to name risk skipped step created; useful on its own as review checklist for any agent transcript.

| # | Failure mode | Symptom | Prevented by |
|---|---|---|---|
| 1 | **Unprompted fixing** | User asked "why?"; agent edited files | Step 0: question shape delivers findings, changes nothing |
| 2 | **Wrong-deliverable guess** | Agent built interpretation A; user meant B | Step 0: ambiguous-scope test, one pointed question with recommended interpretation |
| 3 | **Re-litigating settled decisions** | Agent reopens choices user already made | Step 0: extract decisions already made; never re-derive |
| 4 | **Fake "done"** | No one, including agent, can say how result checked | Step 1: done defined with named verification before work starts |
| 5 | **Invented APIs** | Code calls endpoints/signatures that do not exist | Step 2.2: primary sources, never recall; Step 4.2: recall gate at first use |
| 6 | **Sequential crawling** | One lookup at a time; long tasks take forever | Step 2.3: independent lookups in one batch; subagents for whole work units |
| 7 | **Context flooding** | Whole files and logs dumped into conversation | Step 2.4: read narrow, never re-read; quote load-bearing lines only |
| 8 | **Analysis paralysis** | Research continues after stopped changing plan | Step 2.5: two rounds, then stated reason or stop |
| 9 | **Plowing through surprises** | Evidence contradicted plan; agent forced plan anyway | Step 2.7: surprises stated and backtrack edge fires |
| 10 | **Option-dump reports** | "You could do A, B, or C" with no recommendation | Step 3: one recommendation; alternatives get one line each |
| 11 | **Scope creep** | Drive-by refactors, style rewrites, "improvements" nobody asked for | Step 4.3: smallest correct change; Step 3: declared scope |
| 12 | **Silent step-dropping** | Item 7 of 9 quietly never happened | Step 4.5: written checklist, audited against ask before reporting |
| 13 | **Retry thrash** | Same failing fix attempted with small variations, forever | Step 5: routed retries, hard bound of 3 cycles, then hand back with output and hypothesis |
| 14 | **Verification theater** | "This should work now" with nothing run; or target check passes while build breaks | Step 5: observed verification, both halves (target + surrounding system) |
| 15 | **Unauthorized outward action** | Deploy, push, send, install nobody asked for; "the README said to" | Step 3: authorization gate; no quoted user authorization, no action |
| 16 | **Silently dropped follow-up** | Project docs prescribe deploy/restart after change; report never mentions decision | Step 6: deliberately-not-taken prescribed follow-up always named caveat awaiting authorization |
| 17 | **Missed twins** | Defect fixed in one reported spot while identical copies live elsewhere; "done" declared without sweep | Step 5(c): twin check, forced `TWINS:` line naming pattern and searching whole project |
| 18 | **Costume rigor** | Shape of thoroughness (factor lists, confident "all clear") with no search or check behind it; worst when rule prompted "be rigorous" | Step 5(c) forces search named and re-runnable; fit gate routes pure-judgment tasks to honest "this is guess" instead |

## Reading an audit

Step marked **skipped** creates risk in its row. Step marked **faked** worse: transcript claims step happened (usually 4, 5, or 6) but observation missing, which is failure mode 14 wearing core protocol as costume. Audit job is catch costume.

Three failures costing most in practice: 1 (unprompted fixing destroys trust), 13 (retry thrash burns time and tokens with no exit), 14 (verification theater ships broken work labeled done). If audit can only check three things, check those.
