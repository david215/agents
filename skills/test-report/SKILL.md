---
name: test-report
description: Find every test suite touched or impacted by the branch's changes, run them, and emit a Markdown pass/fail table for the PR. Use when a test report, test table, "which tests are impacted", or PR test coverage is wanted, or at the end of /implement.
---

# Test Report

Produce one Markdown table covering every suite **touched** (the spec file itself changed) or
**impacted** (it exercises a source file that changed) by the branch, run them, and fill in
pass/fail.

## Read the repo's conventions first

`docs/agents/testing.md` supplies the run commands, the constraints that make a run fail when
ignored, the spec layout, and anything that is CI-only. **Read it before running a single test.**
Its Constraints section is the part that matters — a repo that must run one spec file per
invocation, or needs a raised heap, will OOM rather than fail informatively when you batch.

`docs/agents/vcs.md` supplies the integration branch that defines scope.

No `testing.md`? Read `package.json` scripts or the equivalent, run the narrowest command you can
find, and say in one line that the repo has no testing doc — an unrecorded constraint is exactly
what this skill cannot infer.

## Workflow

```
- [ ] 1. Resolve scope and list changed files
- [ ] 2. Classify changed files: touched specs vs source files
- [ ] 3. Map impacted source files to candidate suites
- [ ] 4. Build the suite list, dedup
- [ ] 5. Run, respecting testing.md's constraints
- [ ] 6. Emit the table
```

### 1. Resolve scope

```bash
git fetch origin <integration-branch> --prune
git merge-base HEAD origin/<integration-branch>
git diff --name-only <merge_base>..HEAD
```

If the user asks to include uncommitted work, add `git diff --name-only HEAD` and say so.

**Scope is the branch, not the ticket.** A feature built over many tickets hands this skill a growing
suite set on every run, and each run overwrites the last (see *Where the report goes*) — so the run
after the final ticket is the one that covers the whole feature. Mid-feature runs earn their cost by
catching breakage early, and may narrow to the suites that ticket touched. Take the full branch-wide
scope once the last ticket is in.

### 2. Classify changed files

- **Touched specs** — paths matching the repo's spec pattern from `testing.md`. These go straight
  into the suite list.
- **Source files** — everything else that could be under test. These drive Step 3.
- **Ignore** configs, docs, lockfiles, and migrations for suite selection unless asked otherwise.

### 3. Map impacted source files to suites

Use the spec layout from `testing.md` to derive candidates, then **confirm each path exists** before
adding it. A plausible path is not a real one.

- **Name match first** — a changed `foo.service.ts` most likely maps to a spec whose base name
  matches, in whichever location the layout specifies.
- **Module neighbours** — when a module's controller, service, or DTO changed, include that module's
  other specs too; they typically share fixtures, and a fixture change breaks them together.
- **Shared code ripples, and this is where the method earns its keep.** A change under a shared
  library can reach most of the repo. Do **not** pull in everything. Grep for direct importers of
  the changed symbol or module, and include the suites for those importers only. **Say in the report
  that the impacted set is import-based and may be incomplete** — a one-hop import scan misses
  transitive reach, and a reader who thinks the table is exhaustive is worse off than one who knows
  it is a first approximation.

### 4. Build the suite list

Combine touched and impacted, dedup, and split by suite type. **If the list is empty, say so and
stop.** Do not fall back to running everything — on a large repo that is the single most expensive
mistake available, and `testing.md` may forbid it outright.

### 5. Run

Follow `testing.md`. Do not batch spec files into one invocation when it says not to, and do not
drop a heap flag or a worker limit because a run looked fine without it once.

Capture per-suite results as you go rather than at the end — a run that dies partway still owes the
reader the rows it did finish.

**A suite that cannot run is `skipped`, not `failed`.** A missing database, an absent environment
variable, or a CI-only suite is an environment fact, and reporting it as a failure sends someone
debugging code that is fine. Put the reason in Notes.

**Never report a pass the run output does not show.** On failure, capture the failing test names.

### 6. Emit the table

```markdown
## Test report — <branch>

| Suite | Type | Relation | File | Result | Notes |
| --- | --- | --- | --- | --- | --- |
| class.service | unit | touched | apps/learning/src/class/spec/class.service.unit.spec.ts | ✅ pass | 12 tests |
| class.controller | unit | impacted | apps/learning/src/class/spec/class.controller.unit.spec.ts | ✅ pass | |
| class.service | integ | impacted | apps/learning/src/class/spec/class.service.int.spec.ts | ⏭️ skipped | no DATABASE_URL |

**Summary:** 2 passed, 0 failed, 1 skipped across 3 suites.
```

- **Relation** — `touched` (the spec changed) or `impacted` (it covers a changed source file).
- **Result** — `✅ pass`, `❌ fail`, `⏭️ skipped`, with the reason in Notes.
- **Notes** — failing test names, skip reason, or counts. Keep it short.

Write **full paths, one per row**. No brace expansion or shared-prefix shorthand: the report lands
in a PR comment where length is not the constraint, and a full path is greppable and clickable.

Prose around the table follows the language of the request; the table itself stays as shown.

## Where the report goes

Print it, **and write it to `.scratch/<feature-slug>/test-report.md`** — the same working directory
`findings.md` lives in. Derive the slug from the branch name with any `<type>/` prefix stripped;
create the directory if it does not exist. Overwrite any previous report; the current run is the only
one that matters.

That directory exists on every repo whatever the issue tracker is, which is the point — a path that
only resolved on a local-markdown tracker would make this handoff silently do nothing everywhere else.

That file is the handoff. `/pr` reads it and posts it as a comment — and it has to be a file, not
context, because `/implement` runs this skill at the end of a feature while `/pr` runs later,
frequently across a context reset. A report that exists only in the transcript is a report `/pr`
cannot find.

Print the path in the summary line so the handoff is visible.

Do not write the report to the PR description, and do not render it to an image. Both are artifacts
of a character limit that a comment does not have.
