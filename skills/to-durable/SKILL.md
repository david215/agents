---
name: to-durable
description: Harvest the durable value out of a feature's ephemeral spec and tickets, before the PR — decisions into ADRs, findings into a known-issues file, vocabulary into the glossary.
argument-hint: "[feature-slug]"
---

# To Durable

A spec and its tickets exist to carry thinking between context windows. Once the feature merges,
nobody asks "what are we building" or "what do I build next" again — so those files stop being
documentation and start being a stale copy of decisions that live elsewhere.

This skill moves what must survive into the repo's durable docs, **before the PR**, so the rationale
lands in the same diff as the code it explains and a reviewer sees both together.

**It does not delete anything.** Deletion happens after the merge, and belongs to the repo's own
documented procedure — see *Handoff* below.

## Where this fits

After `/implement` has finished a feature's tickets, before you open the PR. Run it once per
feature, on the feature branch.

## Process

### 1. Resolve the feature

Derive the slug from the current branch name with any `<type>/` prefix stripped —
`fix/duplicate-payments` → `duplicate-payments`. Check it against the issue tracker's directories.

If the argument was given, use that instead. If neither resolves to a real directory, **list what is
actually there and ask** — do not guess. A branch can predate the naming convention, or cover two
features.

### 2. Report readiness, then confirm

Read the tickets and report anything that looks unfinished: unchecked acceptance criteria, a status
that is not the tracker's done state.

**Warn; never refuse.** Checkbox state is not a reliable done-signal — tickets routinely ship with
criteria unchecked, and some freeze their checklists deliberately as a record of what was verified at
the time. Show the user what you found and let them decide.

### 3. Survey

Read the spec and **every** ticket, in full. The spec is usually the merged record, but tickets
accumulate implementation notes the spec never absorbed — a measurement, a reverted approach, a
defect found in passing. Those notes are frequently the most valuable thing in the directory, and
they are the first thing lost.

### 4. Propose, then stop

Three categories. Propose concrete entries for each, then **stop and wait for approval** — deletion
downstream is irreversible, so a bad extraction cannot be corrected later.

**Decisions → an ADR.** Apply one test per paragraph:

> Would a competent reader, working from the code alone, independently arrive at the opposite?

If no, cut it. Keep the decision itself; each rejected alternative someone will genuinely
re-propose, with the reason it loses; constraints invisible in the code (a client keying on a
particular status code, a column bound, a measurement); and deliberate omissions worth not "fixing"
later by accident. Cut motivation and history — nobody is going to re-introduce the bug — along with
rejected options nobody would raise again, and anything a name, a type, or a test already says.

The highest-value thing an ADR can hold is a decision that reasoning actively **fights** — where the
textbook answer is the wrong one here. Spend words there and nowhere else.

**Findings → a known-issues file.** Defects and accepted coverage gaps discovered while building and
deliberately not fixed. Not design rationale, and not a backlog. These are silently lost otherwise,
because nothing else records them: a bug in a neighbouring module, a check that could not be
verified, a test the team decided not to write and the consequence they accepted.

**Vocabulary → the glossary.** Terms the feature introduced or sharpened, in whatever format the
glossary already uses. Terms the spec used consistently but the glossary never defined are the ones
to look for.

### 5. Write

Write only what was approved. Create the known-issues file lazily if the repo has none. Stage the
result so it rides in the PR rather than trailing it.

If a decision belongs in an ADR that already exists, extend that ADR rather than adding a second one
on the same subject.

### 6. Handoff

Append to the spec:

<extracted-to>

## Extracted to

- `<path>` — one line on what went there
- `<path>` — …

</extracted-to>

This list is what makes deletion safe. The repo's deletion procedure confirms every path here is
present on the integration branch before removing the directory — one check that covers both "did
the extraction run" and "did the PR merge". If the repo has no such procedure documented, say so and
suggest adding one; do not delete anything yourself.

## Repo conventions win

Read the repo's own agent documentation first if it has any — an issue-tracker doc for where specs
and tickets live and what the deletion procedure is, a domain doc for ADR location, numbering, and
length. Where the repo states a convention, follow it. This skill supplies the method; the repo
supplies the file layout.

Where the repo says nothing: ADRs in `docs/adr/` numbered sequentially, known issues in
`docs/known-issues.md`, glossary in `CONTEXT.md`.

## Anti-goals

- **Do not summarise the spec.** A summary is a third copy that drifts. Extract only what prevents a
  future mistake; let the rest die with the file.
- **Do not delete, move, or archive the spec or tickets.** Not even after a successful extraction.
- **Do not restate an ADR's argument at the call site.** Point at it in one line. Two copies drift,
  and the code copy is the one nobody updates.
- **Do not pad to look thorough.** A feature with one real decision gets one short ADR, no
  known-issues entries, and no new vocabulary. That is a successful run.
