---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: false
---

Implement the work described by the user in the spec or tickets.

Use /tdd where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and /test-report at the end.

**/test-report is a gate, not a report.** A failing suite means the work in this ticket is wrong —
fix it and re-run. Do not carry a red table forward to /commit or /pr on the theory that someone will
read it; the point of running at the end of a ticket is that the ticket is not finished until it is
green, or until you have said out loud why a failure is being accepted.

Once done, use /code-review to review the work.

## Both gates run at ticket scope

Tell `/test-report` to use **ticket scope** — the working tree, since this runs before `/commit`.
Give `/code-review` the ticket's start point as its fixed point, and the **ticket file** as its spec
source rather than the feature spec. Reviewed against the whole spec, every ticket but the last
reports its siblings' unbuilt requirements as missing, and the Spec axis turns into noise you learn
to skim.

Ticket scope is only safe under `/workflow`, whose phase 5 runs both skills at branch scope before
the PR. Running `/implement` standalone across several tickets means nothing checks the whole — do
that run yourself at the end, and say that you did.

## Delegate discovery, keep decisions

A bounded, read-only question goes to an `Explore` subagent: every call site of `X`, every spec that
builds a given fixture, every module importing a library you are changing. It comes back as
`file:line` and costs the main window a few lines instead of a few thousand.

Decisions and edits stay here. `Explore` has no `Edit` or `Write`, which is why it is the right type
— the boundary is enforced by tooling rather than by this paragraph.

Paste what the sweep needs into the prompt, including the counting rule: **`file:line` lists, never
counts.** An agent that greps and reports a number has thrown away the evidence somewhere nobody can
inspect it.

This is not "send the ticket to a subagent", which `/workflow` forbids. The line is that discovery
answers a question you already have; implementation decides what to do about the answer.

Commit your work using /commit to the current branch.

## Capture as you go

Implementation is where the most valuable findings appear and where they are most easily lost — you
are mid-task, the surprise is a detour, and the moment passes. Append each to
`.scratch/<feature-slug>/findings.md` the moment it surfaces, one line, newest last:

```
- <what you found> — <where it bites> [implement]
```

What counts: a defect in code you were only passing through, a constraint you measured, a gotcha that
cost you an hour, a test you decided not to write and the consequence you accepted.
