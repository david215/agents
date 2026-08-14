---
name: workflow
description: Run a feature end to end — grill, spec, tickets, implement, prove, extract, PR — resetting context at each phase boundary. Use when starting a feature that will outlast one context window.
disable-model-invocation: true
---

# Workflow

Seven phases from an idea to an open PR. This skill does not do any of the work — each phase belongs
to a skill that already exists. What it owns is **the order, and where the context resets.**

## The problem this solves

A feature does not fit in one context window. Somewhere around the third ticket the window fills
with exploration that no longer bears on anything, and the agent starts working from a summary of a
summary — confidently, and wrong.

The fix is not a bigger window. It is that **every phase leaves an artifact behind**, so the next
phase reads a file rather than remembering a conversation. Once that holds, a context reset costs
nothing, and the boundaries below become cheap instead of frightening.

| Phase | Skill | Leaves behind |
| --- | --- | --- |
| 1. Interrogate the design | `/grill-with-docs` | ADRs, glossary entries, `findings.md` |
| 2. Write it down | `/to-spec` | `spec.md` |
| 3. Slice it | `/to-tickets` | `issues/NN-*.md` with blocking edges |
| 4. Build it | `/implement` | code, commits, a ticket-scoped `test-report.md` |
| 5. Prove it | `/test-report` + `/code-review` | a branch-wide `test-report.md`, review findings |
| 6. Harvest it | `/to-durable` | ADRs, known-issues, glossary, agent doc — committed |
| 7. Publish it | `/pr` | a draft PR, with the report as a comment |

Phase 1 writes ADRs and glossary entries as they crystallise — `/grill-with-docs` runs
`/domain-modeling` for exactly that. There is no separate "persist the docs" step, and adding one
would produce a second copy of decisions already written.

`/implement` runs `/tdd`, `/code-review`, `/test-report`, and `/commit` itself. Do not call those
from here — phase 5 is the exception, and it calls two of them at a scope `/implement` never uses.

## Every phase runs, whatever the size

**Phases 1–4, 6 and 7 run on every feature, a one-line bug fix included.** The phases self-limit — an
interview over a map with no fork has nothing to ask, a spec for a one-line fix is five lines — so
there is no size exemption to judge.

Phase 4 is the one that looks skippable on a small change, where it reads as "just write the code".
Dropping it fails silently: the code still gets written, so nothing looks wrong until the PR has no
test report and nothing has been reviewed.

Phase 5 is the single exception, and it is a redundancy rule rather than a size one — see below.

## Why phase 5 exists

`/implement` scopes both its gates to **the ticket**, not the branch: `/test-report` runs against the
working tree, and `/code-review` takes the ticket's start point as its fixed point with the ticket
file as its spec source. That is what stops ticket 06 re-running ticket 01's suites, and what stops
the Spec axis reporting tickets 02–05's unbuilt requirements as missing on every run before the last.

It also means nothing has checked the whole. Phase 5 is that check. It is a phase rather than a step
on the end of phase 4 for the same reason the ticket close-out is one: work that rides on the end of
another unit is the work that goes missing.

Two runs, both at full branch scope:

- **`/test-report`** against the integration branch. It overwrites
  `.scratch/<feature-slug>/test-report.md`, which is what `/pr` posts — leave phase 4's last
  ticket-scoped table in that file and the PR ships a three-row report of a six-ticket feature.
- **`/code-review`** against the merge base, with `spec.md` as the spec source. *"Do these tickets
  together implement the feature"* is only answerable at this scope.

**Append the review's findings to `findings.md` before leaving this phase.** Every other phase
captures as it goes, and phase 6 is the skill that exists to harvest them. A finding left in context
dies at the boundary.

A red gate loops inside phase 5 — fix, `/code-review`, `/commit`, re-run — and does not advance
until it is green, or until the failure has been accepted out loud.

**Phase 5 is skipped on a single-ticket feature, and only there.** That ticket's scope *is* the
branch's scope, so both runs take the same fixed point over the same diff — the same review twice,
the same suites twice. At two tickets or more it always runs.

**This is a redundancy rule, not a size rule.** It says the work would be literally duplicate, not
that the change is too small to be worth checking, and read the other way it takes phase 4 with it.

A feature's **facts** may live in more than one repository — a frontend whose behaviour the change
depends on, a service that calls the endpoint being altered. Read them wherever they are; phase 1 is
no less thorough for a fact sitting one directory over. Its **artifacts** stay single-homed:
`.scratch/`, `docs/`, and the branch all belong to the repo being changed, and every boundary below
assumes exactly one of each.

## Where you are

The table above is only half of what survives a reset. Every phase leaves an artifact of its
**content**, and none leaves one of its **position** — a fresh session can read `spec.md` and six
tickets and still not know which phase is running, what comes next, or that anything unusual is
going on alongside the feature.

So this skill keeps one more file, `.scratch/<feature-slug>/STATE.md`, **overwritten as the closing
act of each phase** — after `/commit` finishes a ticket, after `/to-durable` commits its docs:

```
# State — email-language

Workflow: /workflow — read that skill before acting
Phase:    4 of 7 — build it (`/implement`)
Next:     /implement 03-invitations-follow-organization-timezone
Tickets:  01 done · 02 done · 03–06 not started
Branch:   feat/email-language
Also:     running as a live test of `/workflow`; notes in `workflow-notes.md`
```

**The first line names the process.** `Phase: 4` on its own is an ordinal with no referent — four of
what, governed by which skill, with what after it? A session opening this file cold needs that
before any other line means anything, and on most features nothing else in the file supplies it.
Naming the skill also puts the phase table and these boundaries back within reach in one command.

That makes the file self-explanatory once opened, not self-discovering; nothing inside a file makes
an agent open it. `/setup-workflow` writes the other half — a **Feature state** pointer in the
repo's agent doc, which a session loads whether or not it knows a workflow is running. A repo set up
before that pointer existed needs the line added by hand, because generated repo docs never re-sync.

**`Next:` carries the command to run, not a description of it.** A resuming session reads
`ticket 03` as work to pick up and starts editing files; it reads `/implement 03-…` as the thing to
type — and with it the `/tdd`, `/test-report`, and `/code-review` that skill owns. Naming a skill on
the `Phase:` line above does not substitute — it identifies, it does not instruct.

It is a bookmark, not a log. No history, no reasoning, nothing a fresh session would rather read in
`spec.md` — those belong to the artifacts that already hold them, and a second copy here is a copy
that goes stale. `Also:` is the line that earns its keep most often, because side quests and
experiments live nowhere else.

Write it when the **work** completes, not when the **context** resets. `/clear` is typed by the user
and leaves the agent no turn to act first. Closing each phase with the write means the bookmark is
already current whenever the reset arrives, announced or not.

It also settles which boundaries need a write, for free: the ones that do not are exactly the ones
where nothing finished.

Read it first when a session starts mid-feature. It is deleted with the rest of `.scratch/`.

## Before the first run

This repo must have been configured, or the phases have nothing to read:

```
/setup-matt-pocock-skills    # issue tracker, triage labels, domain docs
/setup-workflow              # VCS conventions, test commands, gitignored working directory
```

Check `docs/agents/` before starting. If it is missing, stop and run those two — a workflow that
guesses at the integration branch and the commit language will produce a PR nobody wants.

## Boundaries

At the end of each phase, work [PHASE-BOUNDARIES.md](./PHASE-BOUNDARIES.md) top to bottom. First yes
wins. It is the only decision this skill actually makes, so make it deliberately rather than by
habit.

Two boundaries have a usual answer worth knowing:

**After phase 3 → `/clear`.** The exploration, the rejected designs, the dead ends — all of it is now
in `spec.md`, the tickets, and the ADRs. That conversion is the entire purpose of phases 2 and 3, so
carrying the raw conversation past them wastes the window on a primary source you deliberately
replaced. The precondition is real, though: clear only once you believe the artifacts captured it.
If the spec reads thinner than the discussion felt, that is a signal to fix the spec, not to keep
the transcript.

**Between tickets → `/clear`.** Each ticket is sized for a fresh window by construction, and ticket
N+1 needs the *code* ticket N produced, not the reasoning about how it got there. Do not send a
ticket to a subagent instead: `/implement` keeps you in the loop by design, and question 4 of the
tree gates subagents on work that runs with you away from the keyboard.

Nor in parallel across worktrees, however clean the ticket graph looks. A blocking edge records
whether B needs A's **output** — parallel branches need the stricter property that A and B never
touch the same bytes, and `/to-tickets` does not compute it. Two tickets can be genuinely
output-independent and still edit the same spec files, both deleting fixture lines from them.
Parallel runs also multiply the test runner's
resource footprint and share one dev database — a constraint `docs/agents/testing.md` records if
anything does.

The reset is also what fires the ticket's **close-out** — `/test-report`, `/code-review`, `/commit`,
the STATE.md write. Tickets run back to back in one window blur the boundary, and the close-out is
what goes missing. Room left in the window is not the question. The stop is doing a second job.

**After the last ticket → `/clear`, and again after phase 5.** Both are question 2. Phase 5 reads
the branch, not the session that built it; phase 6 reads `findings.md`, not the session that ran the
review. The second one is only safe because phase 5 writes its findings down — that write is what
converts an otherwise-relevant context into a disposable one.

The rest of the boundaries are genuine judgement calls. Ask the questions in order and take the
first yes.

## The branch

**No skill in this chain creates it.** `/commit` commits to whatever branch is checked out, and
`/implement` delegates to `/commit` — so with no explicit step, phase 4 lands its commits straight
onto the integration branch.

Create it as the **first action of phase 4**, before the first `/implement`, named by `vcs.md`'s
convention over the feature slug.

Not earlier: `/to-spec` re-checks the slug against the finished spec and renames on approval, which
costs one `mv` only while no branch carries the old name. Not later: `/to-durable` derives its
working directory by stripping the `<type>/` prefix off the branch name, and `/pr` computes scope
from the merge base.

Phases 1–3 write only to `.scratch/`, which is gitignored — so a survey that stops before phase 4
leaves no branch to clean up.

## Working the tickets

Tickets carry blocking edges. Work the **frontier** — any ticket whose blockers are all resolved,
lowest number first. For a linear chain that is simply top to bottom.

Run `/implement` once per ticket, not once for the batch. A single run spanning four tickets is the
context problem this skill exists to avoid, wearing a different hat.

Name the ticket by its **filename**, not a position — `/implement 03-invitations-follow-organization-timezone`,
never `/implement ticket3`. Ordinal references resolve by guesswork, which is safe with six tickets
and is not with sixteen.

## Capturing as you go

Every phase appends to `.scratch/<feature-slug>/findings.md` as things surface — each skill carries
its own criteria. The discipline that matters here is that capture is **immediate and unjudged**: a
finding not written within a minute of being noticed is gone, and deciding where it belongs is phase
5's job, done once, with the whole feature visible.

## After the merge

`.scratch/<feature-slug>/` is ephemeral and gets deleted. Two checks first, then the `rm`:

```bash
git fetch origin

# 1. Did it merge? The feature's commits must be on the integration branch.
git log origin/<integration-branch> --oneline | head -20

# 2. Did the durable files land? Derive them from the merged range — do not work from memory.
git diff --name-only <merge-base> <merge-commit> -- docs/ CLAUDE.md AGENTS.md CONTEXT.md

# 3. Only when both hold:
rm -rf .scratch/<feature-slug>
```

**Step 2 is not optional.** A merge that resolved a conflict by dropping a file leaves you with a
merged PR and no ADR — and the only remaining copy of that reasoning is in the directory you are
about to remove.

**There is no recovery.** `.scratch/` is gitignored, so a deleted directory is gone: not in a branch,
not in a stash, not on the remote. That is the point — a file absent from the repository cannot be
read stale by anyone on a fresh clone. It is also why the checks run first, every time.

Run this after the PR merges, not before. The procedure is the same whatever the issue tracker is;
on GitHub, GitLab, or Jira the directory simply holds the working files without the spec and tickets.

## Anti-goals

- **Do not re-explain a phase's skill here.** This file owns sequence and boundaries; each skill
  owns its method. Two copies drift, and this is the copy with no tests.
- **Do not skip phase 5 for time.** Phase 4's two gates are ticket-scoped by construction, so on a
  multi-ticket feature *do these tickets together implement the feature* is a question none of them
  asked. The single-ticket exception above is the other claim: there the scopes coincide, so the check
  has already run rather than gone missing.
