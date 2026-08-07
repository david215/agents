# Findings log

A finding is anything you learn while building that is neither a term nor a decision: a defect in
code you were only passing through, a constraint you measured, a gotcha that cost you an hour, a
test you decided not to write and the consequence you accepted.

Findings die in the gap between *"huh, that's weird"* and *"I wrote it somewhere"*. Nothing else
records them — the spec is about what you are building, the ticket is about what to build next, and
by the time either is being extracted the surprise has been paged out. So capture is immediate and
cheap, and judgement about where it belongs is deferred.

## Where

`<FEATURE_DIRECTORY>/findings.md` — one per feature, beside the spec.

**Append-only.** New findings go at the bottom. Nothing is rewritten, reordered, or tidied; a log
someone is editing is a log people stop trusting.

## Line format

One finding per line, newest last:

```
- <what you found> — <where it bites> [<step it surfaced in>]
```

For example:

```
- Prisma drops an `undefined` filter key rather than matching nothing, so a deleteMany whose only filter is undefined deletes the whole table — measured 1726/1726 rows against local Postgres [implement]
- Evaluation retry count is off by one when the AI call times out — neighbouring module, not touched by this feature [implement]
- No integration coverage for the withdrawal race; the specs sleep to order a lock queue and are too slow to add another [test-report]
```

Enough to reconstruct the finding in a month. Not a paragraph — if it needs one, it is a decision,
and decisions go to an ADR.

## What goes here

Capture on sight, at whatever step surfaced it. Do not stop to decide whether it is important, and
do not stop to decide where it eventually belongs — deciding is the expensive part, and it happens
once, later, with the whole feature visible.

Two things go elsewhere at the moment they arise, because `/domain-modeling` already writes them
inline as they crystallise:

- a **term** the project needs → the glossary
- a **decision** a reader would otherwise reverse → an ADR

Everything else that surprised you goes here.

## Lifecycle

`/to-durable` reads this file before the PR and curates it — each finding either moves somewhere
durable or is dropped as no longer true. Findings that move are **marked in place** with their
destination rather than deleted:

```
- Prisma drops an `undefined` filter key … [implement] → CLAUDE.md
```

so a second run is idempotent and the log still reads as the record of what was found.

The log lives with the spec and dies with it. Anything still unmarked when the feature merges was
judged not worth keeping — deliberately, by someone looking at it.
