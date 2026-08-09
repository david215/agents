# skills

Seventeen agent skills that run a feature from an idea to an open PR, resetting context at each phase
boundary. Built on top of [Matt Pocock's skills](https://github.com/mattpocock/skills), vendored and
customized.

```bash
npx skills add david215/skills
```

## Getting started on a new repo

Two setup commands, in order. Both are prompt-driven and write to `docs/agents/`:

```
/setup-matt-pocock-skills    # issue tracker, triage labels, domain docs
/setup-workflow              # PR + commit conventions, test commands, gitignored working directory
```

They read the repo before asking anything — host, commit language, scope vocabulary, branch pattern,
test runner, spec layout — and present those as statements to correct. What is left is three
questions nothing in a repo can answer: reviewers, attribution, and test gotchas.

Then, per feature:

```
/workflow
```

## The six phases

`/workflow` owns the order and where the context resets. Nothing else — each phase's method belongs
to a skill that already exists.

| Phase | Skill | Leaves behind |
| --- | --- | --- |
| 1. Interrogate the design | `/grill-with-docs` | ADRs, glossary entries, `findings.md` |
| 2. Write it down | `/to-spec` | `spec.md` |
| 3. Slice it | `/to-tickets` | `issues/NN-*.md` with blocking edges |
| 4. Build it | `/implement` | code, commits, `test-report.md` |
| 5. Harvest it | `/to-durable` | ADRs, known-issues, glossary, agent doc |
| 6. Publish it | `/pr` | a draft PR, with the report as a comment |

The organizing rule is that **every phase leaves an artifact behind**, so the next phase reads a file
rather than remembering a conversation. Once that holds, a context reset costs nothing.

Every phase is also usable on its own. `/commit`, `/pr`, and `/test-report` in particular are worth
having whether or not you ever run the full sequence.

## The design rule

**The repo answers *where*; the skill carries the obligation.**

A skill knows it must screen a commit for secrets. `docs/agents/vcs.md` only tells it which language
to write the message in. That line is what lets the same skills work in every repo without edits —
and it is why the PR host and the issue tracker are configured independently, since a repo can track
issues as local markdown while opening PRs on Azure DevOps.

The test, applied to any line in a generated repo doc: *could this be different in another repo?* If
no, it belongs in a skill.

One consequence worth knowing: `.scratch/<feature-slug>/` holds each feature's ephemeral working
files — the findings log and the test report — on **every** repo, whatever the issue tracker is. The
tracker decides only whether the spec and tickets live there too. A working directory that resolved
only on a markdown tracker would make the `/test-report` → `/pr` handoff silently do nothing
everywhere else.

## What's here

**Vendored from `mattpocock/skills`** (MIT — see [`LICENSE-mattpocock`](./LICENSE-mattpocock)):
`code-review`, `codebase-design`, `domain-modeling`, `grilling`, `grill-me`, `grill-with-docs`,
`implement`, `setup-matt-pocock-skills`, `tdd`, `to-spec`, `to-tickets`

**Mine:** `commit`, `pr`, `setup-workflow`, `test-report`, `to-durable`, `workflow`

### What gets vendored

Vendor what the workflow's **correctness** depends on — every step `/workflow` invokes, plus
anything carrying a local customization. A skill that is merely *reachable* stays upstream and keeps
improving, because if it changes the workflow still works.

`setup-matt-pocock-skills` is vendored under the first clause rather than the second: `/setup-workflow`
reads the tracker layout that skill records, so a change to its output format is a change to this
repo's behaviour.

Left upstream deliberately: `ask-matt`, `handoff`, `triage`, `wayfinder`, `research`, `prototype`,
`diagnosing-bugs`, `improve-codebase-architecture`, `wait-what`, `writing-for-agents`.

`ask-matt` is the instructive one. `/workflow` needs exactly one thing from it —
`PHASE-BOUNDARIES.md`, the decision tree for where to reset context — and that file lives in
`skills/workflow/` where its only consumer can reach it. Vendoring the router to get the file would
have frozen a document whose twenty-odd targets keep moving, most of which aren't vendored at all.

## Why vendored rather than installed from upstream

The `skills` CLI has **no version pinning** — no ref, tag, or commit SHA. `skills add` clones the
default branch and `skills update` pulls latest. Measured behaviour of `update`:

| | upstream unchanged | upstream changed |
| --- | --- | --- |
| project scope (`skills update`) | overwrites anyway | overwrites |
| global scope (`skills update -g`) | skips — reports "up to date" | **overwrites** |

There is no edit detection and no backup. A local modification survives exactly until upstream next
touches that file, and the loss is silent. Since this workflow depends on modifications to seven of
those files, holding a copy is the only mechanism available.

### Customizations against upstream

| Skill | Change | Why |
| --- | --- | --- |
| `grill-me` | dropped `disable-model-invocation` | so `/workflow` can invoke it |
| `grill-with-docs` | ″, plus a **Capture as you go** section | ″, plus findings-log capture |
| `to-spec` | ″ | ″ |
| `to-tickets` | ″ | ″ |
| `implement` | set `disable-model-invocation: false`; **Capture as you go**; `/test-report` stated as a gate; commit via `/commit` | ″, plus wiring to the owned skills |
| `domain-modeling` | `ADR-FORMAT.md` gains **Length: anti-inference only** | ADRs written mid-feature were otherwise ungoverned |
| `setup-matt-pocock-skills` | `issue-tracker-local.md` gains ephemerality and lifecycle; `domain.md` gains an ADR-length pointer | `.scratch/` is worthless as an ephemeral layer if nothing ever extracts from it or deletes it |

The five `agents/openai.yaml` files carry a matching `allow_implicit_invocation: true`, which
upstream leaves `false` — without it the frontmatter change is contradicted for non-Claude agents.

**Seven of these are body edits, not frontmatter.** Reviewing upstream is a merge exercise now, not
a glance at a few one-line diffs. That is the deliberate price of putting writing rules in skills
rather than in seeds: a rule shipped inside a seed can never be improved for a repo already set up,
because generated repo docs are repo-owned and never re-sync.

### Auditing drift

Diff whole skill directories, not just `SKILL.md` — three of the seven customizations are in
co-located files, and a `SKILL.md`-only diff reports clean on exactly the files that changed most.

```bash
git clone --depth 1 https://github.com/mattpocock/skills.git /tmp/mp
for p in productivity/{grilling,grill-me} \
         engineering/{grill-with-docs,to-spec,to-tickets,implement,tdd,codebase-design,code-review,domain-modeling,setup-matt-pocock-skills}; do
  diff -ur /tmp/mp/skills/$p skills/$(basename $p)
done
```

## Checks

```bash
./check.sh
```

A regression guard, not a test suite. Every check in it exists because the thing it looks for already
shipped broken once and re-reading never caught it — a `grep -P` that BSD grep rejects, a `wc -m`
that counts bytes under `LC_ALL=C`, a relative link to a seed that was deleted.
