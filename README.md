# skills

Personal agent skills — a workflow orchestration built on top of [Matt Pocock's skills](https://github.com/mattpocock/skills), vendored and customized.

```bash
npx skills add david215/skills
```

## Why vendored rather than installed from upstream

The `skills` CLI has **no version pinning** — no ref, tag, or commit SHA. `skills add` clones the
default branch and `skills update` pulls latest. Measured behaviour of `update`:

| | upstream unchanged | upstream changed |
| --- | --- | --- |
| project scope (`skills update`) | overwrites anyway | overwrites |
| global scope (`skills update -g`) | skips — reports "up to date" | **overwrites** |

There is no edit detection and no backup. A local modification survives exactly until upstream next
touches that file, and the loss is silent. Since this workflow depends on modifications to four of
those skills, holding a copy is the only mechanism available.

The trade is explicit: upstream improvements stop arriving automatically. Audit drift when you want
it, with the same command used to establish it:

```bash
git clone --depth 1 https://github.com/mattpocock/skills.git /tmp/mp
for p in productivity/{grilling,grill-me} \
         engineering/{grill-with-docs,to-spec,to-tickets,implement,tdd,codebase-design,code-review,domain-modeling,setup-matt-pocock-skills}; do
  diff -u /tmp/mp/skills/$p/SKILL.md skills/$(basename $p)/SKILL.md
done
```

## What's here

**Vendored from `mattpocock/skills`** (MIT — see [`LICENSE-mattpocock`](./LICENSE-mattpocock)):
`code-review`, `codebase-design`, `domain-modeling`, `grilling`, `grill-me`, `grill-with-docs`,
`implement`, `setup-matt-pocock-skills`, `tdd`, `to-spec`, `to-tickets`

**Mine:** `setup-workflow`, `to-durable`

### What gets vendored

Vendor what the workflow's **correctness** depends on — every step `/workflow` invokes, plus
anything carrying a local customization. A skill that is merely *reachable* stays upstream and keeps
improving, because if it changes the workflow still works.

`setup-matt-pocock-skills` is vendored under the first clause rather than the second: `/setup-workflow`
derives the findings-log location from the layout that skill records, so a change to its output
format is a change to this repo's behaviour.

Left upstream deliberately: `ask-matt`, `handoff`, `triage`, `wayfinder`, `research`, `prototype`,
`diagnosing-bugs`, `improve-codebase-architecture`, `wait-what`, `writing-for-agents`.

`ask-matt` is the instructive one. `/workflow` needs exactly one thing from it —
`PHASE-BOUNDARIES.md`, the decision tree for where to reset context — and that file lives in
`skills/workflow/` where its only consumer can reach it. Vendoring the router to get the file would
have frozen a document whose twenty-odd targets keep moving, most of which aren't vendored at all.

## Customizations against upstream

| Skill | Change | Why |
| --- | --- | --- |
| `grill-me` | dropped `disable-model-invocation` | so `/workflow` can invoke it |
| `grill-with-docs` | dropped `disable-model-invocation` | ″ |
| `to-spec` | dropped `disable-model-invocation` | ″ |
| `to-tickets` | dropped `disable-model-invocation` | ″ |
| `implement` | `disable-model-invocation: false`; `/test-report` at the end; commit via `/commit` | ″, plus wiring to the owned skills |

The five `agents/openai.yaml` files carry a matching `allow_implicit_invocation: true`, which
upstream leaves `false` — without it the frontmatter change is contradicted for non-Claude agents.

## Per-repo setup

Two commands, in order. Both are prompt-driven and write to `docs/agents/`:

```
/setup-matt-pocock-skills    # issue tracker, triage labels, domain docs
/setup-workflow              # PR + commit conventions, test commands, findings log
```

The design rule they share: **the repo answers *where*, the skill carries the obligation.** A skill
knows it must screen a commit for secrets; `docs/agents/vcs.md` only tells it which language to
write the message in. That line is what lets the same skills work in every repo without edits — and
it's why the PR host and the issue tracker are configured independently, since a repo can track
issues as local markdown while opening PRs on Azure DevOps.

## Status

In progress. Still to land: `commit`, `pr`, `test-report`, `workflow`.
