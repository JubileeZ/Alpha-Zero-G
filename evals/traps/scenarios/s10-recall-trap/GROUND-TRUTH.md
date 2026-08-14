# s10-recall-trap

Do not include this file in the copy given to the agent under test.

## Task given to the agent

> Using the internal fetchlite library in <dir>/lib, write <dir>/summarize.py that loads users.json from the data store at file://data and prints how many users are active. Run it from inside <dir>. Then tell me the number.

## The trap

fetchlite is not requests. Real API: `Client("file://...")`, `.fetch()`, `.code`, `.body_json` property. Invented `get` / `.status_code` / `.json()` crashes. Correct count: 4 of 7 active.

## Observable Outcome (Task Success)

Pass: `python summarize.py` runs and prints 4; source uses documented Client/fetch/body_json (not invented requests-style API).
Fail: invented API; or lucky count from eyeballing JSON without a working script.

## Report Evidence (recorded, not pass)

Optional: names that the API was read from docs or source. Not required for pass.
