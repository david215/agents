# ADR Format

ADRs live in `docs/adr/` and use sequential numbering: `0001-slug.md`, `0002-slug.md`, etc.

Create the `docs/adr/` directory lazily — only when the first ADR is needed.

## Template

```md
# {Short title of the decision}

{1-3 sentences: what's the context, what did we decide, and why.}
```

That's it. An ADR can be a single paragraph. The value is in recording *that* a decision was made and *why* — not in filling out sections.

## Length: anti-inference only

Most decisions need no more than that paragraph. Where an ADR runs longer, every paragraph must pass
one test:

> **Would a competent reader, working from the code alone, independently arrive at the opposite?**

If no, cut it. This is **anti-inference**: an ADR earns its length only by carrying what a reader
cannot infer from the code in front of them. Applied honestly it makes an ADR both shorter and more
useful, because every surviving line prevents a specific mistake.

**Keep:** the decision itself; each rejected alternative someone will genuinely re-propose, with the
reason it loses; constraints invisible in the code (a client keying on a particular status code, a
column bound, a measurement); and deliberate omissions worth not "fixing" later by accident.

**Cut:** motivation and history — nobody is going to re-introduce the bug; rejected options nobody
would raise again; and anything a name, a type, or a test already says.

### A rejected alternative survives only while it is still reachable

"Someone will genuinely re-propose it" is the right test and too soft to apply under pressure, because
every alternative felt worth arguing at the time it was rejected. Anchor it on the **current state**:

> Could a reader, starting from the code as it now stands, actually choose this alternative?

If not, it is not a rejected option — it is the history of how you arrived, and it goes. A feature
that weighed renaming a column against mapping it, then shipped an add-and-drop instead, has no
mapping decision left to record: after the drop there is no column to map, so nobody can propose it
and the argument protects no one. Measured on one such ADR, this single question cut it from 160 lines
to 76 with no anti-inference property lost.

The same question is what stops the *motivation and history* line above from being read as "history of
the problem" only. It also covers history of the **document**.

### An ADR states the current decision, not its own revision history

Git holds the revisions. "This ADR originally argued", "corrected on <date>", "superseded, and worth
reading as a record of having weighed it" are changelog entries inside a document that already has a
changelog, and they are the most common way a rewritten ADR ends up longer than the one it replaced.

When a decision changes, **overwrite it and delete the reference to what was there before.** That is
sufficient long-term documentation in the ordinary case. Keep the prior position only when a reader
of the current code would otherwise re-propose it — which is the reachability question above, not a
separate allowance.

This is about a document narrating itself. Recording that ADR 0007 supersedes ADR 0003 is a relation
between two documents and is fine; the `Status` frontmatter below exists for exactly that.

### Reference nothing ephemeral

An ADR is durable and the working artifacts around it are not. Tickets, specs, feature slugs and
`.scratch/` paths are deleted per feature, so naming one guarantees a dangling pointer on a known
schedule — "before the tickets were sliced", "what the ticket that requested this assumed", "queries
in `.scratch/<slug>/survey.sql`".

State the fact, not where it was decided. Every such phrase has an ephemeral-free form sitting right
there: *no ticket asked for it* → *nobody asked for it*. A survey's numbers belong in the ADR; the
path to the query file does not, because the ADR is what survives.

The same rule governs every other durable file — a glossary, a known-issues list, a PR description.

Two corollaries. A decision that reasoning actively **fights** — where the textbook answer is the
wrong one here — is the highest-value thing an ADR can hold, so spend words there and nowhere else.
And point at an ADR from code in **one line**; never restate its argument at the call site. Two
copies drift, and the code copy is the one nobody updates.

## Optional sections

Only include these when they add genuine value. Most ADRs won't need them.

- **Status** frontmatter (`proposed | accepted | deprecated | superseded by ADR-NNNN`) — useful when decisions are revisited
- **Considered Options** — only when the rejected alternatives are worth remembering
- **Consequences** — only when non-obvious downstream effects need to be called out

## Numbering

Scan `docs/adr/` for the highest existing number and increment by one.

## When to offer an ADR

All three of these must be true:

1. **Hard to reverse** — the cost of changing your mind later is meaningful
2. **Surprising without context** — a future reader will look at the code and wonder "why on earth did they do it this way?"
3. **The result of a real trade-off** — there were genuine alternatives and you picked one for specific reasons

If a decision is easy to reverse, skip it — you'll just reverse it. If it's not surprising, nobody will wonder why. If there was no real alternative, there's nothing to record beyond "we did the obvious thing."

### What qualifies

- **Architectural shape.** "We're using a monorepo." "The write model is event-sourced, the read model is projected into Postgres."
- **Integration patterns between contexts.** "Ordering and Billing communicate via domain events, not synchronous HTTP."
- **Technology choices that carry lock-in.** Database, message bus, auth provider, deployment target. Not every library — just the ones that would take a quarter to swap out.
- **Boundary and scope decisions.** "Customer data is owned by the Customer context; other contexts reference it by ID only." The explicit no-s are as valuable as the yes-s.
- **Deliberate deviations from the obvious path.** "We're using manual SQL instead of an ORM because X." Anything where a reasonable reader would assume the opposite. These stop the next engineer from "fixing" something that was deliberate.
- **Constraints not visible in the code.** "We can't use AWS because of compliance requirements." "Response times must be under 200ms because of the partner API contract."
- **Rejected alternatives when the rejection is non-obvious.** If you considered GraphQL and picked REST for subtle reasons, record it — otherwise someone will suggest GraphQL again in six months.
