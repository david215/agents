---
name: pr
description: Push the current branch and open or update a real pull request — computing scope from the merge base, filling the repo's own PR template, and posting long-running content as a comment rather than the description. Works on Azure DevOps and GitHub. Use whenever a PR is wanted for the current branch.
---

# PR

Derive a PR body from the branch's **committed** work not yet on the integration branch, fill the
repo's own PR template with it, push, and actually create or update the pull request — rather than
printing text to copy-paste.

## Read the repo's conventions first

`docs/agents/vcs.md` supplies **Host**, **Integration branch**, **Language**, **PR title**,
**Reviewers**, draft state, and **linking**. Read it before anything else, then read the matching
host module for the commands:

- [hosts/azure-devops.md](./hosts/azure-devops.md) — `az repos`, and a hard description limit
- [hosts/github.md](./hosts/github.md) — `gh pr`

No `vcs.md`? Infer the host from `git remote get-url origin` and the integration branch from
`git symbolic-ref refs/remotes/origin/HEAD`, say so in one line, and open the PR without reviewers
rather than guessing at people.

## Step 1 — Compute the scope

Every commit reachable from `HEAD` that is not on the integration branch.

```bash
git branch --show-current
git fetch origin <integration-branch> --prune
git merge-base HEAD origin/<integration-branch>
git log --reverse --no-merges --format='%H%x09%s' <merge_base>..HEAD
git diff --stat <merge_base>..HEAD
git diff <merge_base>..HEAD -- <relevant paths>
```

Read **both** the commit messages and the actual diff. Commit messages describe intent; only the
diff shows what shipped.

**Then grep the added lines for new error paths.** This is a required command, not something to
keep in mind while reading:

```bash
git diff <merge_base>..HEAD | grep -nE '^\+.*(throw |raise |panic!|return .*Err\()'
```

Match the pattern to the repo's language — `throw new …Exception` in TypeScript and Java, `raise`
in Python, `return …, err` or `panic!` in Go and Rust. A large diff makes it easy to read straight
past a new `throw` in a private helper with no route name attached, and that buried throw is
routinely the most caller-visible change in the branch. For each hit: confirm it is new rather than
moved (check for the paired `-` removal), trace it to the routes that reach it, and note whether it
carries a payload or message a caller must now branch on.

If the range is empty, stop and say so. Do not open an empty PR.

## Step 2 — Compute the title

Follow `vcs.md`'s **PR title** convention, which is frequently *not* the commit convention — many
repos use Conventional Commit prefixes on commits and a plain descriptive phrase on PR titles.
Where `vcs.md` is silent, match the style of recent merged PRs rather than the commit log.

The title is passed as its own argument, never embedded in the description.

## Step 3 — Find the repo's PR template

The body structure belongs to the repo, not to this skill. Look for a template the host already
recognises:

```bash
find . -maxdepth 3 -iname 'pull_request_template*' -not -path './.git/*' -not -path '*/node_modules/*'
```

Azure DevOps reads `pull_request_template.md` from the repo root, `.azuredevops/`, or `docs/`.
GitHub reads it from `.github/`, the root, or `docs/`, in any casing. Either host may hold a
directory of named templates; pick the one matching the change, or the default, and say which.

**Found one? It is the contract. Fill it; do not redesign it.**

- Preserve every label, its order, the checkbox syntax, and the blockquote markers exactly. A team
  reads these by shape, and a renamed label is a silent divergence from the template the repo ships.
- Replace a placeholder only when the diff answers it. `(as detailed as possible)` gets content;
  a placeholder asking whether local tests ran does not — you did not run them.
- Check a box only on evidence in the diff. Leave the rest unchecked with their placeholders intact.
  An unchecked box is information; a box checked on assumption is a false claim to a reviewer.

**No template? Use [default-template.md](./default-template.md)** and mention in one line that the
repo has none, so the user can add one if they want the structure fixed.

## Step 4 — Write the body

The template says *what sections exist*. These rules say *how to write inside them*, and apply to
whichever section asks what changed.

### Change-groups, and the label → detail shape

One top-level bullet per **change-group** — something a reviewer would consider as one decision: a
flow, a module boundary, a schema change, a background job. If two candidates describe the same flow
or would be reviewed together, merge them.

- **Label** (top level, bold, *no content of its own*) — names the group. `**Blocked access to
  deleted organizations**`, not a sentence about what changed.
- **Detail** (second level, plain) — the actual facts: what changed, where, why it matters. All real
  content lives here.
- **Sub-detail** (third level) — an escape hatch for one sub-point under a single detail. Not a
  place to enumerate files; those are detail bullets of their own.

Every label carries **at least one** child, however small the group. The uniformity is the point:
a reader skims the bold labels alone and gets the shape of the whole PR.

**Grain size is the whole game.** One label per genuine reviewable change-group — never one per file
touched or per implementation step. A body that feels too long is almost always mis-grained rather
than over-full: merge a label carrying one tiny fact into a coarser neighbour. Do not pad toward a
count either; a one-concern branch gets one label.

Order labels by blast radius: caller-visible behaviour first, then data integrity and security, then
internal refactors, renames, and docs.

### API changes get a reserved group, first position

For **every route the diff touches**, check all three contract dimensions. Do not stop at the first
that applies:

- **Request** — new, changed, or removed fields, params, or validation rules.
- **Response** — new, changed, or removed fields, or a status-code change on the success path.
- **Errors** — new or changed thrown errors, a new payload, or a message a caller must branch on
  differently. This is the dimension that hides inside a large diff, which is why Step 1 greps for
  it mechanically. **An error path alone qualifies a route**, with no request or response change.

A route also qualifies when its **side effects or authorization outcome** changed enough to surprise
a caller relying on the old behaviour — even with all three dimensions literally untouched. This is
very often the most important change in the PR, and a narrow "did the schema change" reading is
exactly what drops it.

When any route qualifies, this group comes **first** and is labelled in the repo's prose language,
matching the surrounding text — `API 변경 사항` in a Korean body, not `API changes`. The English form
in this file and in `default-template.md` is the name of the concept, not a string to copy: a body
whose every other label is Korean and whose most important label is English reads as a template that
was filled in without being read. Each child is a route written as `` `METHOD /path` `` followed by
exactly one tag:

| Tag | Meaning |
| --- | --- |
| `(BREAKING)` | the contract shape or status code itself moved — a new required field or param, a removed or renamed response field, a narrowed type, a changed success status |
| `(new)` | a brand-new route; no prior callers to break |
| `(changed)` | everything else that qualifies — additive fields, a new error or validation path, a side-effect or authorization change |
| `(global)` | a cross-cutting change not scoped to one route, e.g. `` `error response format` (global) `` |

A new blocking error path is `(changed)`, **never** `(BREAKING)`, even when it turns a
previously-succeeding caller into a failure. `(BREAKING)` is reserved for the contract shape moving,
not for "this can now fail."

A route qualifying under more than one category takes its single most severe tag, by
`(BREAKING)` > `(new)` > `(changed)` > `(global)` — one bullet per route, never split. Order routes
by that same category sequence, with impact as the secondary sort. A category with no qualifying
route contributes nothing; no empty markers.

Under each route sit the **caller-facing facts**, one per dimension that actually changed, as
sub-bullets rather than inline text after a colon. Implementation detail already stated elsewhere in
the body does not belong here.

If no route has caller-visible change, omit the group. Do not manufacture one.

#### Which section it goes in, when the repo's template has several

It goes in the section that asks **what changed** — first position inside it. Not the section that
asks what effects are expected, even though a contract change is arguably the most effect-laden thing
in the branch.

Two reasons, and they decide it rather than merely leaning:

- An effects section asks what a reader should **anticipate** — Korean templates make this explicit
  with `예상`. A route list with tags is a factual inventory of what shipped, so it answers the wrong
  question there, and it displaces the consequences that genuinely belong in that section.
- The routes need the change-groups that explain them nearby. Split across two sections, a reviewer
  reads a contract delta with its rationale one section away.

The effects section then has a real job rather than a redundant one: the *consequences* of those
route changes. `PATCH /organizations` accepting a new field is a change; every pre-existing
organization silently switching email language because of it is an effect.

**Only when a template has no what-changed section at all** does the group move under effects. Say so
in one line when that happens, since it departs from the shape above.

### Prose

- Base every claim on the committed diff, not on commit titles.
- Write in `vcs.md`'s **Language**. Keep it short and PR-ready; in Korean, avoid the polite report
  register (`~습니다`).
- Name the specific change. `improved the logic`, `structural cleanup`, and `handling refined` say
  nothing on their own.
- Claim no effect the diff does not show, and no test run the user did not report.
- State an assumption in one line where the branch reads more than one way.
- **Name nothing ephemeral.** A description outlives the branch; a ticket, a spec, a feature slug and
  a `.scratch/` path do not — they are deleted after the merge. Describe what the branch does, not
  which ticket asked for it or where the spec lives. If the repo's `vcs.md` says to link the spec
  path because the tracker has no linkable ID, that instruction predates this rule and is wrong: a
  path into a deleted directory links to nothing. The test-report comment is the one exception this
  skill already makes, and it resolves before the merge rather than after.

### The test section is a pointer, never content

Everything about tests belongs in a **comment**: which spec files moved, and what happened when they
ran. The body only points at it.

The reason is staleness, not size. A description is the PR's standing summary of what the branch
does; a test report is a point-in-time artifact that a single further push invalidates. Buried in the
description it becomes a table every reviewer scrolls past forever. On Azure DevOps the description
cap forces this anyway; on GitHub nothing forces it and it is still correct.

**Resolve the report before writing this section** — whether it exists decides what you may check.

```bash
ls .scratch/<feature-slug>/test-report.md       # slug = branch name minus any <type>/ prefix
git log -1 --format=%cI -- ':!docs/' ':!*.md'   # newest CODE commit, for the staleness check
```

`/test-report` writes that file; this skill does not run tests and does not compose the table. A
report older than the newest **code** commit describes code no longer on the branch — say so and ask
rather than posting it, because a stale table carries more authority than no table, which is the
thing this whole arrangement exists to avoid.

**The exclusions are load-bearing.** `/to-durable` runs immediately before this skill and commits
documentation. Docs change no code, so a report predating only those commits is still current.
Comparing against the newest commit of any kind flags every correctly-executed run of `/workflow` —
which trains the reader to wave the check through, and it is the one check standing between a stale
table and a reviewer who believes it. Widen the exclusions to fit the repo; keep the intent, which is
*commits that could invalidate a test run*.

A template's test items are part of the contract — they cannot be deleted, and leaving them blank
reads as unconsidered. Fill each with a pointer, in the repo's prose language:

```
- [x] 테스트 변경 사항
  > 변경된 스펙 파일 목록은 아래 테스트 리포트 코멘트 참고

- [x] 로컬 테스트가 수행되었나요?
  > 실행 결과는 아래 테스트 리포트 코멘트 참고
```

Every test item gets the same treatment — the one asking which files changed and the one asking
whether they ran both resolve to the same comment, so neither carries content of its own.

No anchor or link is needed. Both hosts render comments directly beneath the description, so "see the
comment below" resolves itself — which is why the body can be finished here, before the comment
exists, with no second update call to insert a URL.

**Never write the content in both places.** A body listing spec files and a comment listing them
again drift on the next push, and the body is the copy nobody updates.

**The report is what licenses a checkbox.** Check an item only for what the report actually shows:
the diff proves spec files changed, so that box gets checked; whether a local run happened is known
only if the report says so. **No report file?** Do not invent one and do not check any test box —
say `/test-report` has not run for this branch and leave the items with their original placeholders.
A pointer to a comment that will not exist is worse than an honest blank.

### User overrides

Natural-language instructions in the same message constrain **what to describe**, never git history.
Exclusions ("leave out the lockfile"), focus ("just the auth work"), language, audience. There is no
`@` syntax; read the phrasing literally.

Compute the full range for context regardless, then base the body on the remaining diff
(`git diff <merge_base>..HEAD -- . ':!path'`). **If excluded work is still on the branch, say so in
one line** inside the body — a reviewer who reads the description as the whole branch is being
misled otherwise.

## Step 5 — Check the length, then push

Host modules carry the limits; Azure DevOps has a hard description cap that will silently truncate.
Measure with `LC_ALL=en_US.UTF-8 wc -m`, never `wc -c` — multi-byte prose runs three bytes per
character and a byte count will make you cut a body that fits. **The locale prefix is the measurement:**
under `LC_ALL=C` or `POSIX` — the default in Docker, cron, and most CI — `wc -m` counts bytes too, so
the bare command fails in the same direction as `wc -c` while looking like the fix.

Over budget means a label is mis-grained. Go back to Step 4 and merge, rather than abbreviating
prose into shorthand.

```bash
git push -u origin <branch>    # or plain `git push` when upstream is set
```

The branch must exist on the remote with the current commits, or the host rejects the PR. No
confirmation gate: the PR opens as a draft, so a human reviews before anyone is notified in earnest.

## Step 6 — Create or update

Check for an **active** PR on this source → target pair first and update it in place rather than
opening a duplicate. A completed or abandoned PR from earlier history does not count as existing.
Commands are in the host module.

Open as a draft when `vcs.md` says draft. Never pass auto-complete, policy bypass, squash, or
delete-source-branch flags — those are merge-time decisions for the human who publishes the PR.

## Step 7 — Post the report as a comment

Post `.scratch/<feature-slug>/test-report.md` verbatim. Step 4 already resolved it, checked it for
staleness, and decided which boxes the body may check — if it found no report, there is nothing to
post and this step is a no-op.

**Update the existing report comment rather than posting another**, unless the result changed in a
way reviewers should be re-notified about. Comments notify and description edits do not — which is
what makes a comment the right home, and also what makes re-posting on every push spam.

Write every path in full, one per line. Compressed file lists (`spec/{a,b}.unit.spec.ts`) only ever
existed to buy characters against the description cap; a comment has ~37× as many on Azure DevOps and
no practical limit on GitHub, and a full path is greppable and clickable.

**Where the host has a resolved state for comments, post the report in it.** The report asks nothing
of a reviewer, so an open thread misfiles it as an outstanding item in the unresolved count people
clear before approving — and clearing it falls to someone who did not write it. This is host-specific:
Azure DevOps threads carry a status, plain GitHub PR comments do not.

Commands are in the host module.

## Step 8 — Report back

Print the PR URL, say plainly whether it was created or updated, and say it is a draft — the user
still publishes it and confirms reviewers before anyone is notified.

---

See [examples.md](./examples.md) for a filled body showing the label → detail shape and a populated
`API changes` group.
