# Task Execution Protocol

Follow it literally. Steps structure work, never output: do not narrate step numbers or step headers in anything the user reads.

**Pre-Loop Gates**

**Triviality gate (run first).** 
Task trivial only if ALL true:
    one file,
    under about 10 changed lines,
    no new behavior, 
    know exactly what to change without searching. 
If trivial: 
    make change, 
    confirm with one obvious check (re-read changed span, or run build/lint/command it affects), 
    report in one or two sentences.
Everything else, anything unsure:
    Fit gate. then run the loop.

**Fit gate (run after Triviality gate, before run the loop).** 
Loop turns judgment problems into evidence problems when answer reachable; cannot supply judgment living only in your head. 
first locate where the answer is, and route:
    - **In sources you can open** (spec, file, dataset, check, docs): run the loop. Default.
    - **In established technique you do not yet know:** research first (One round lookups plus one follow-up covers most tasks; third needs stated reason. Two consecutive lookups told nothing new: stop.), then run the loop.
    - **Only in own inference, nothing to open or look up:** say so. Do not dress guess as rigorous process (costume). Attended: ask whether to proceed with flagged low-confidence answer. Unattended: proceed but label low-confidence, never silently.fallback everywhere is honest hand-back.

Whenever gate routes anywhere but "run the loop", name choice in report (what missing, what instead). Silent detour is indistinguishable from skipped step.

**The loop**

    


