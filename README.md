# agents

Two artifacts. **Seventeen skills** that run a feature from an idea to an open PR, resetting context
at each phase boundary — built on top of [Matt Pocock's skills](https://github.com/mattpocock/skills),
vendored and customized. And **three rules** that load into every session regardless of what it is
about.

The difference is the trigger, not the content: a skill is repo-adaptive and invoked when its
description matches; a rule is unconditional and always in context.

```bash
npx skills add david215/agents -g -s '*' -y -a claude-code codex cursor gemini-cli
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

## The seven phases

`/workflow` owns the order and where the context resets. Nothing else — each phase's method belongs
to a skill that already exists.

| Phase | Skill | Leaves behind |
| --- | --- | --- |
| 1. Interrogate the design | `/grill-with-docs` | ADRs, glossary entries, `findings.md` |
| 2. Write it down | `/to-spec` | `spec.md` |
| 3. Slice it | `/to-tickets` | `issues/NN-*.md` with blocking edges |
| 4. Build it | `/implement` | code, commits, a ticket-scoped `test-report.md` |
| 5. Prove it | `/test-report` + `/code-review` | a branch-wide `test-report.md`, review findings |
| 6. Harvest it | `/to-durable` | ADRs, known-issues, glossary, agent doc — committed |
| 7. Publish it | `/pr` | a draft PR, with the report as a comment |

The organizing rule is that **every phase leaves an artifact behind**, so the next phase reads a file
rather than remembering a conversation. Once that holds, a context reset costs nothing. A phase that
selected no work still writes its artifact — `/test-report` on a docs-only branch reports zero
suites rather than exiting silently, because absence is the only signal the next phase has that a
step never ran.

All seven run on every feature, a one-line fix included; there is no size exemption. The single
exception is phase 5, skipped on a **single-ticket** feature, where that ticket's scope *is* the
branch's scope and the phase would re-run phase 4's gates over the same diff. That is a redundancy
rule, and reading it as licence to do less on a small change is how phase 4 — which owns `/tdd`,
`/code-review`, `/test-report`, and `/commit` — gets dropped without anything looking wrong.

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

## Instructions need an addressee with a turn

Every instruction in a skill is executed by somebody. Name them, then check they have a turn at the
moment the instruction names. `/workflow` once told the agent to overwrite `STATE.md` "immediately
before the reset" — a moment that does not exist for it, since `/clear` is typed by the user and
yields no turn beforehand. What earns this a rule is that the failure is **silent**: nothing errors,
the file just goes stale while looking maintained.

The related case is an instruction whose addressee is right but whose **capability** is not
guaranteed — `/code-review` requires sub-agents, and a session can forbid them. That one states the
requirement as a precondition and asks, rather than degrading into a weaker review that looks
identical.

Neither is a `check.sh` entry. Both tests are semantic, and the only greppable part — those phrases —
appears legitimately in the passages explaining the rule, so a check would need an exclusion list
longer than the signal it finds. The operative forms live in [`CLAUDE.md`](./CLAUDE.md).

## Rules

`rules/` holds three files that are always in context, never invoked:

| File | What it is |
| --- | --- |
| `ponytail.md` | A YAGNI ladder — stop at the first rung that holds. Vendored from [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) (MIT — see [`LICENSE-ponytail`](./LICENSE-ponytail)). |
| `karpathy.md` | Four behavioural constraints against common LLM coding failures. Vendored from [forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) (MIT — see [`LICENSE-karpathy`](./LICENSE-karpathy)). |
| `house-rules.md` | Mine. Honest communication, critical engagement, and the tiebreaker when the other two conflict. |

The design rule above — *the repo answers where, the skill carries the obligation* — does not apply
here, because a rule has no repo to ask. It is loaded before there is a task, let alone a codebase.

Upstream ponytail ships two variants: the full `skills/ponytail/SKILL.md`, and a trimmed
`.agents/rules/ponytail.md` built for exactly this slot. Take the trimmed one. The full skill body is
2.6× the size and most of the excess — the intensity table, the `/ponytail lite|full|ultra` switch,
the `argument-hint` machinery — is meaningless for a file that is never invoked, yet it is paid for
in every context window. What the trimmed version drops that is *not* dead weight is its `Output`
section, the terse-response contract; that lives in `house-rules.md` §7 instead.

`ponytail.md` is byte-identical to upstream. `karpathy.md` is edited — narrower description, an added
closing "these guidelines are working if" block — so diff it before pulling upstream changes:

```bash
git clone --depth 1 https://github.com/DietrichGebert/ponytail.git /tmp/pt
git clone --depth 1 https://github.com/forrestchang/andrej-karpathy-skills.git /tmp/kp
diff /tmp/pt/.agents/rules/ponytail.md rules/ponytail.md
diff /tmp/kp/skills/karpathy-guidelines/SKILL.md rules/karpathy.md
```

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
| `grill-me` | dropped `disable-model-invocation` | so it can be invoked as a skill, not only typed as `/grill-me`. Nothing here calls it — `/workflow` phase 1 runs `/grill-with-docs` |
| `grilling` | fact-finding no longer mandates a sub-agent; each question goes on **both** prose and `AskUserQuestion` | a session can forbid sub-agents and no lookup needs one; the prose template predates the tool, so every run rediscovered the overlap |
| `grill-with-docs` | ″, plus **Capture as you go**, **Map the territory before round one**, **Map the data too** (timed before round one, with a hand-over path when the database is unreachable), **Name the feature after its outcome** | ″, plus findings-log capture, and the three things a grilling cannot get from the user: code shape, production data, a name that survives discovery. The map prices existence; only the survey prices importance, so asking first allocates round-one attention by guesswork |
| `to-spec` | ″, plus a **feature-slug checkpoint** after the spec is written | ″, plus the spec is the last artifact landing before the branch exists, so it is the last moment a rename costs one `mv` |
| `to-tickets` | ″, plus **state scope by extent, not by count** | ″, plus counts in acceptance criteria were wrong twice in one six-ticket feature |
| `implement` | set `disable-model-invocation: false`; **Capture as you go**; `/test-report` stated as a gate; commit via `/commit` | ″, plus wiring to the owned skills |
| `domain-modeling` | `ADR-FORMAT.md` gains **Length: anti-inference only**, plus reachability, no self-history, and no ephemeral references | ADRs written mid-feature were otherwise ungoverned — and once governed, still drifted: the three ADRs one workflow produced ran 99, 160 and 234 lines against ~50 for the hand-written ones |
| `setup-matt-pocock-skills` | `issue-tracker-local.md` gains ephemerality and lifecycle; `domain.md` gains an ADR-length pointer | `.scratch/` is worthless as an ephemeral layer if nothing ever extracts from it or deletes it |
| `to-durable` | anti-goal: **do not carry an ephemeral reference into a durable file** | it is the step most likely to — every finding arrives with a ticket and a slug attached, and the phrasing comes along for free |
| `pr` | prose rule: **name nothing ephemeral** in the description | a description outlives the branch; a spec path does not, and one repo's `vcs.md` explicitly told it to link one |
| `code-review` | sub-agents stated as a **precondition** that stops and asks | a session can forbid them, and running both axes in one context loses the isolation while looking identical |

The five `agents/openai.yaml` files carry a matching `allow_implicit_invocation: true`, which
upstream leaves `false` — without it the frontmatter change is contradicted for non-Claude agents.

**Most of these are body edits, not frontmatter.** Reviewing upstream is a merge exercise now, not
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

## Editing these skills

Edit here, push, then reinstall. **Never `cp` into `~/.agents/skills/`.**

```bash
./check.sh && git commit … && git push     # reinstall pulls from the remote, so push first
npx skills add david215/agents -g -s '*' -y -a claude-code codex cursor gemini-cli
```

A copy produces a *working* install with no lock entry, and `skills update` walks lock entries and
nothing else — so a copied skill is skipped forever while looking completely fine on disk. `check.sh`
cannot catch it either: it lints the repo, not the installation.

**Name the agents; do not use `--all`.** It expands to `--agent '*'`, which targets all 75 agents the
CLI knows about — creating a `skills/` directory for every one, whether or not that agent is
installed. It also fails loudly on the two that cannot install globally, printing two lines per skill
that read like a broken install and are not. The four named above are the agents actually present
here; add one when you install one. `claude-code` gets a symlink into `~/.agents/skills`, the rest
read that store directly.

**Adding a skill means adding it to [`.claude-plugin/plugin.json`](./.claude-plugin/plugin.json)
too.** That manifest is what makes `skills list` group these seventeen under one heading instead of
scattering them through the alphabet; the CLI stores its `name` as each skill's `pluginName`. Paths
must start with `./` or they are ignored. Omitting a skill does not break its install — discovery
searches `skills/` regardless — it just leaves that one ungrouped in the listing.

### The lock file, and how it goes missing

The lock lives at `~/.agents/.skill-lock.json`, or under `$XDG_STATE_HOME/skills/` if that is set.

**`Source: local` means the skill has no lock entry.** It says nothing about how the files arrived. A
`cp` reads as `local` — but so does a perfectly good install whose lock entry has since vanished, and
the whole lock is discarded without warning if it is unreadable or written by an older CLI. So a
version bump can void every entry at once, silently.

```bash
npx skills list -g | grep -B1 'Source: local'   # should print nothing
```

Read a hit as *unmanaged*, not *copied*. It once fired on all thirty installed skills, and the cause
was one missing lock file rather than thirty bad installs.

Restoring is just reinstalling from each source. Nothing is overwritten when the installed copies
already match their source, so `diff -rq` them first and the repair is pure metadata:

```bash
npx skills add david215/agents -g -s '*' -y -a claude-code codex cursor gemini-cli
npx skills add mattpocock/skills -g -y -a claude-code codex cursor gemini-cli -s ask-matt diagnosing-bugs \
  improve-codebase-architecture prototype research triage wayfinder handoff wait-what writing-for-agents
npx skills add vercel-labs/skills -g -y -a claude-code codex cursor gemini-cli -s find-skills
```

Two ways that goes wrong, both of which exit 0:

- `-s` and `-a` both take **space-separated** names. A comma-separated list parses as one bogus name.
  For `-s` the CLI answers by printing every available skill, which reads like a successful run; for
  `-a` it prints `Invalid agents:` with the whole list echoed back as a single name.
- Omitting `-g` installs project-scoped into the current directory, creating `.agents/`, `.claude/`,
  `agent/` and `skills-lock.json`, plus symlinks into `skills/` alongside the real ones.

## Checks

```bash
./check.sh
```

A regression guard, not a test suite. Every check in it exists because the thing it looks for already
shipped broken once and re-reading never caught it — a `grep -P` that BSD grep rejects, a `wc -m`
that counts bytes under `LC_ALL=C`, a relative link to a seed that was deleted.
