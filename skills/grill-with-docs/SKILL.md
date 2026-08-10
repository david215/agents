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

Do this **before** `/to-spec`, because the whole value is deleting scope the spec would otherwise
commit to. Three things it does that reading code cannot:

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
