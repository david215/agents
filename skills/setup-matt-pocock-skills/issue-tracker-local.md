# Issue tracker: Local Markdown

Issues and specs for this repo live as markdown files in `.scratch/`.

**`.scratch/` is gitignored and ephemeral.** It carries thinking between context windows — the spec
answers "what are we building", the tickets answer "what do I build next", and both questions stop
being asked the moment the feature merges. Nothing durable may live only here. See *Lifecycle*.

## Conventions

- One feature per directory: `.scratch/<feature-slug>/`
- The spec is `.scratch/<feature-slug>/spec.md`
- Implementation issues are one file per ticket at `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, numbered from `01` — never a single combined tickets file
- Triage state is recorded as a `Status:` line near the top of each issue file (see `triage-labels.md` for the role strings)
- Comments and conversation history append to the bottom of the file under a `## Comments` heading
- The findings log is `.scratch/<feature-slug>/findings.md`, beside the spec
- **Ticket bodies stay thin; acceptance criteria stay thick.** A few sentences of what-to-build, a detailed checklist, and a line naming the ADR to read first. Do not restate the spec's reasoning in the ticket — that copy is the one an implementing agent reads, and the one most likely to be stale.

## Lifecycle

Specs and tickets are extracted, then deleted. Nothing in `.scratch/` survives its feature.

**Before the PR — extract.** Run `/to-durable` on the feature branch. It reads the findings log, the
spec, and the tickets, and proposes what must move somewhere durable, so the extraction rides in the
same diff as the code it explains. It then appends an **`## Extracted to`** list to `spec.md` naming
every durable file it produced. That list is the handoff to deletion.

**After the merge — delete.** Documented rather than scripted, because it is a check and an `rm`:

```bash
# 1. Confirm on the integration branch that every path in spec.md's "Extracted to" list is present.
git fetch origin
git ls-tree -r origin/<integration-branch> --name-only | grep -F -e <path> -e <path>

# 2. Only if step 1 accounts for every listed file:
rm -rf .scratch/<feature-slug>
```

**Step 1 is not optional.** It covers both preconditions at once: if a listed file is absent from the
integration branch, either the extraction never ran or the PR has not merged — and in both cases you
do not delete.

**There is no recovery.** `.scratch/` is gitignored, so a deleted directory is gone: not in a branch,
not in a stash, not on the remote. That is the point — a file absent from the repository cannot be
read stale by anyone on a fresh clone. It is also why the check runs first, every time.

## When a skill says "publish to the issue tracker"

Create a new file under `.scratch/<feature-slug>/` (creating the directory if needed).

## When a skill says "fetch the relevant ticket"

Read the file at the referenced path. The user will normally pass the path or the issue number directly.

## Wayfinding operations

Used by `/wayfinder`. The **map** is a file with one **child** file per ticket.

- **Map**: `.scratch/<effort>/map.md` — the Notes / Decisions-so-far / Fog body.
- **Child ticket**: `.scratch/<effort>/issues/NN-<slug>.md`, numbered from `01`, with the question in the body. A `Type:` line records the ticket type (`research`/`prototype`/`grilling`/`task`); a `Status:` line records `claimed`/`resolved`.
- **Blocking**: a `Blocked by: NN, NN` line near the top. A ticket is unblocked when every file it lists is `resolved`.
- **Frontier**: scan `.scratch/<effort>/issues/` for files that are open, unblocked, and unclaimed; first by number wins.
- **Claim**: set `Status: claimed` and save before any work.
- **Resolve**: append the answer under an `## Answer` heading, set `Status: resolved`, then append a context pointer (gist + link) to the map's Decisions-so-far in `map.md`.
