---
name: workflow
description: Run a feature end to end — grill, spec, tickets, implement, extract, PR — resetting context at each phase boundary. Use when starting a feature that will outlast one context window.
disable-model-invocation: true
---

# Workflow

Six phases from an idea to an open PR. This skill does not do any of the work — each phase belongs
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
| 4. Build it | `/implement` | code, commits, `test-report.md` |
| 5. Harvest it | `/to-durable` | ADRs, known-issues, glossary, agent doc |
| 6. Publish it | `/pr` | a draft PR, with the report as a comment |

Phase 1 writes ADRs and glossary entries as they crystallise — `/grill-with-docs` runs
`/domain-modeling` for exactly that. There is no separate "persist the docs" step, and adding one
would produce a second copy of decisions already written.

`/implement` runs `/tdd`, `/code-review`, `/test-report`, and `/commit` itself. Do not call those
from here.

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

The rest of the boundaries are genuine judgement calls. Ask the questions in order and take the
first yes.

## Working the tickets

Tickets carry blocking edges. Work the **frontier** — any ticket whose blockers are all resolved,
lowest number first. For a linear chain that is simply top to bottom.

Run `/implement` once per ticket, not once for the batch. A single run spanning four tickets is the
context problem this skill exists to avoid, wearing a different hat.

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
- **Do not skip phase 5 to save time.** It is the only step that moves anything into the repository
  permanently, and it runs before the PR precisely so the rationale lands in the same diff as the
  code it explains.
- **Do not run phases 1–3 for a one-ticket change.** A bug fix with an obvious cause does not need a
  spec. Use the skills directly; this sequence earns its overhead on work that outlasts a window.
