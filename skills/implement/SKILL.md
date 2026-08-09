---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: false
---

Implement the work described by the user in the spec or tickets.

Use /tdd where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and /test-report at the end.

Once done, use /code-review to review the work.

Commit your work using /commit to the current branch.

## Capture as you go

Implementation is where the most valuable findings appear and where they are most easily lost — you
are mid-task, the surprise is a detour, and the moment passes. Append each to the feature's findings
log the moment it surfaces, tagged `[implement]`. See `docs/agents/findings.md` for the path and line
format.

What counts: a defect in code you were only passing through, a constraint you measured, a gotcha that
cost you an hour, a test you decided not to write and the consequence you accepted. Do not stop to
judge importance or destination — `/to-durable` does that at the end, once, with everything visible.
