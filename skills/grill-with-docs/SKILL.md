---
name: grill-with-docs
description: A relentless interview to sharpen a plan or design, which also creates docs (ADR's and glossary) as we go.
---

Run a `/grilling` session, using the `/domain-modeling` skill.

## Map the territory before round one

When the subject is a change to code that already exists, the design tree does not come from the
user — it comes from the codebase. Before the first round, find every call site the change touches,
what data each one can already reach, and what already exists to be reused. Timebox it. You are
after the shape, not a full reading.

This is not the fact-finding `/grilling` already asks for, which serves a question you know you
have. Mapping *produces* the questions. The sharpest question in a session is usually a fork nobody
could have known was there — a caller with no access to the data the feature assumes, two call sites
that already disagree, a translated template written months ago and never wired to anything. Skip
the map and you will open by asking the user to describe their own codebase, which is both slower
and less accurate than reading it.

The map is never wasted work: `/implement` needs it regardless, and it is what tells you whether
this feature needs a spec at all.

### Map the data too, when behaviour keys off it

The codebase tells you what *can* happen. It does not tell you how often, to how many rows, or
whether the case the design is being built around exists at all. Whenever the feature's behaviour
depends on stored values — a column it branches on, a table it migrates, a population it treats
differently — go and read production before the spec is written.

Read-only, always. Aggregates before identities: counts, distributions and date ranges first, and
pull actual rows only once the count is small enough that a human will review them. A grilling never
writes to production.

Do this **before round one**, alongside the code map, and certainly before `/to-spec`. The map and the
survey want the same timing for the same reason: **the map prices existence, the survey prices
importance.** A question deserves the user's attention in proportion to the population it governs, and
only the survey knows the population — so asking first allocates the scarcest thing in the process,
round-one attention, by guesswork. One run spent a round-one slot on a fork governing 17 rows, while
the question that reshaped the whole feature was answered later by a single `count(*)` returning zero.

Three things a survey does that reading code cannot:

- **Sizes the work.** "Correct the organizations with a wrong timezone" was heading for a
  classification script. The count came back **two**, and the script became two `UPDATE` statements
  and one fewer ticket.
- **Contradicts recollection.** Treat what the user remembers about their own data as a hypothesis.
  Six organizations everyone recalled as foreign turned out to be abandoned single-day trials with
  zero students; correcting them would have changed nothing any human would ever see.
- **Reorders the feature.** The half of that feature everyone was focused on governed a path used
  **37 times in the product's lifetime**, while the half nobody was discussing ran on every signup.
  Nothing in the code says which is which.

The corollary is the point: a survey is what makes *"does this need to exist at all?"* answerable
with a number instead of an intuition.

**If you cannot reach the database, say so and hand over the queries.** Credentials fail, sandboxes
refuse to read a connection string out of an `.env`, a production box is not reachable from here. The
failure mode is silent: nothing downstream notices a survey that never ran, because no artifact is
missing — there was never going to be one. So write the SQL to `.scratch/<feature-slug>/` anyway, show
it, and ask the user to run it or to supply a connection string. The file makes the ask concrete and
costs one message. Do not proceed to `/to-spec` on an unrun survey without saying plainly that the
spec is being written on unmeasured assumptions.

## Name the feature after its outcome

The findings log needs `.scratch/<feature-slug>/`, so the slug gets chosen at the moment of maximum
ignorance — before the map, before the survey, before a single question is answered. Slug the
**outcome**, and let the mechanism stay unnamed: mechanisms are exactly what a grilling overturns.
`email-language` survived the discovery that org timezone governs one of three emails and an
explicit locale governs the other two; `email-language-by-org-timezone` was stale within the hour.
A term already in the glossary is the safest choice available — it survived this scrutiny once.

The name is load-bearing beyond the directory: the branch carries the same slug, and `/to-durable`
strips the branch prefix to find its own working directory. Rename late and you are renaming two
things in sync. `/to-spec` owns the checkpoint that catches it while it is still free.

## Capture as you go

A grilling surfaces more than terms and decisions. When something surprises you that is neither —
a constraint you measured, a defect in code you were only passing through, a gotcha that cost an
hour — append it to `.scratch/<feature-slug>/findings.md` **as it surfaces**, one line, newest last:

```
- <what you found> — <where it bites> [grill]
```

Append-only; create the file if it does not exist. Enough to reconstruct the finding in a month — if
it needs a paragraph, it is a decision, and decisions go to an ADR.

Do not stop to judge whether it matters or where it belongs. Judging is `/to-durable`'s job at the
end of the feature, with everything visible at once; a finding not written within a minute of being
noticed is one you will not remember to write.

Terms and decisions are the exception — `/domain-modeling` writes those inline as they crystallise.
