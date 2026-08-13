---
name: setup-workflow
description: Configure this repo for the /workflow orchestration — PR and commit conventions, test-runner commands, and the ephemeral working directory. Run once per repo, after /setup-matt-pocock-skills.
disable-model-invocation: true
---

# Setup Workflow

Scaffold the per-repo configuration that `/workflow` and its steps read:

- **VCS** — which host PRs go to, what language commits and PR bodies are written in, who reviews → `docs/agents/vcs.md`
- **Testing** — how this repo runs its suites, and what breaks when you run them wrong → `docs/agents/testing.md`
- **Working directory** — `.scratch/` gitignored, so the findings log and test report have somewhere to live → `.gitignore`

Additive to `/setup-matt-pocock-skills`. That skill owns the issue tracker, triage labels, and domain docs; this one writes two files it does not touch, and adds its own sub-blocks to the same `## Agent skills` section.

Prompt-driven, not a script. Explore, present what you found, confirm, then write.

## The repo answers where; the skill carries the obligation

These files record facts about **this repo** — the host, the language, the commands, the layout. They never record the process itself. `/commit` knows it must screen for secrets; `docs/agents/vcs.md` only tells it which language to write the message in. Keep that line and the same skills work in every repo without edits.

The test: could this line be different in another repo? If no, it belongs in a skill, not here.

## Prerequisite

`docs/agents/issue-tracker.md` must exist. If it is absent, run `/setup-matt-pocock-skills` first, then continue here.

## The working directory is not the issue tracker

`.scratch/<feature-slug>/` holds this feature's **ephemeral working files** — the findings log and the test report. It exists on every repo, whatever the tracker is.

The tracker decides only whether the *spec and tickets* live there too. On local markdown they do, and the two coincide. On GitHub, GitLab, or Jira the spec is an issue and `.scratch/<feature-slug>/` holds the working files alone.

Keeping these separate is what makes the `/test-report` → `/pr` handoff work everywhere: `/test-report` writes a file that `/pr` reads back later, frequently across a context reset, and a path that only resolves on a markdown tracker means that handoff silently degrades to nothing on every other repo.

Nobody creates the directory here. Whichever skill writes to it first creates it.

## Process

### 1. Explore — infer before asking

Every answer you can read out of the repo is one the user does not have to type. Read all of these before asking anything:

- `git remote -v` — the PR host. `github.com` → GitHub; `dev.azure.com` or `visualstudio.com` → Azure DevOps; `gitlab.com` or a self-hosted GitLab → GitLab. No remote at all → ask.
- `git log --no-merges --format=%s -30` — three answers at once: the language subjects are written in, whether Conventional Commit prefixes are in use, and whether those prefixes carry scopes (`feat(submission):` versus `feat:`). If scoped, the set of scopes actually used is the vocabulary to record. **`--no-merges` is load-bearing** — a host's merge commits follow no convention and can be a third of the sample. An empty or one-commit history settles nothing; default to English and say so.
- `git log --no-merges -30 --format=%B | grep -ci 'co-authored-by'` — whether commits carry an attribution trailer. Read the **proportion in a recent window**, never a whole-history grep: a repo that adopted a policy partway through returns hits across all time and near-zero recently, and the two readings disagree. Most of the window → the repo accepts a trailer; near-none across a substantial window → it does not; a genuine split → the policy changed or is unenforced, so ask rather than pick.
- `git branch -a --sort=-committerdate | head -20` — the branch naming pattern. A `<type>/<slug>` shape is what `/to-durable` strips to recover a feature slug, so record the prefixes actually in use rather than the ones the commit types imply.
- `docs/agents/issue-tracker.md` — which tracker is configured. This settles issue linking: a tracker with linkable IDs (GitHub issues, ADO work items) gets linked, a local-markdown tracker has nothing to link and the PR body references the spec path instead.
- `.gitignore` — whether `.scratch/` is already ignored. This is a **precondition, not a preference**: without the entry, `/commit`'s `git add -A` commits the working directory into the repo permanently, which is the exact outcome its ephemerality exists to prevent, and nothing flags it because it is not a secret.
- Test-runner config: `package.json` scripts, `Makefile`, `pyproject.toml`, `Cargo.toml`, `go.mod`, and any `jest.*.config.*` / `vitest.config.*` / `pytest.ini`.
- Recent **merged PR titles**, if the host CLI is authenticated (`gh pr list --state merged --limit 10 --json title`, or `az repos pr list --status completed --top 10`). Repos routinely use Conventional Commit prefixes on commits and a plain descriptive phrase on PR titles, so infer the two conventions from their own evidence rather than assuming one follows the other. No CLI access → leave it as "same as the commit subject" and say so.
- `find . -maxdepth 3 -iname 'pull_request_template*'` — whether the repo ships a PR template. `/pr` fills whatever it finds, so no template means `/pr` falls back to its own default; worth telling the user, since adding one is how they pin the structure.
- Glob for the test files themselves — `**/*.spec.*`, `**/*.test.*`, `**/test_*.py` — and read the layout off the paths: co-located beside source or gathered under a top-level `tests/`, and what suffix separates unit from integration. Sample a handful of paths; do not enumerate the tree.
- `CLAUDE.md` / `AGENTS.md` — an existing `## Agent skills` block, plus any testing or commit rules already written down in prose. Rules found here are inferred answers, not questions.
- `docs/agents/vcs.md`, `testing.md` — this skill's own prior output, if it has run before.

**Infer the PR host and the issue tracker separately.** They are usually the same and legitimately differ: a repo can track issues as local markdown while opening PRs on Azure DevOps. Deriving one from the other silently misconfigures exactly the repos that most need configuring.

### 2. Present what you inferred, then ask what is left

Lead with the inferences, as statements to correct rather than questions to answer:

```
Inferred from this repo:
  PR host        Azure DevOps (dev.azure.com/…)
  Language       Korean (28 of 30 recent subjects)
  Commit scopes  feature module — submission, evaluation, class, rubric
  Branch naming  <type>/<slug> — feat/, fix/, refactor/
  Issue tracker  local markdown, .scratch/<feature>/   ← already configured
  Issue linking  none — a markdown tracker has no linkable ID
  Working dir    .scratch/<feature>/ — already in .gitignore
  Test runner    pnpm jest, configs jest.unit.config.ts / jest.int.config.ts
  Spec layout    co-located, *.unit.spec.ts / *.int.spec.ts

Correct anything wrong; otherwise I have three questions.
```

When `.scratch/` is **not** in `.gitignore`, say so on that line and that you will add it — not as a question, since the alternative is a working directory that gets committed.

Then ask only these three. All accept "none" — an empty answer is a valid configuration, not a skipped step.

**Section A — Reviewers.** Who gets added to a PR by default, and are PRs opened as drafts? Nothing in the repo reveals intent here. On a solo project the answer is usually no reviewers and no draft; say that as the recommendation so it can be accepted in a word.

**Section B — Attribution.** Do commits carry a `Co-Authored-By` trailer for agent-authored work? Ask this even when the git history answered it, unless the history was unambiguous — the harness appends the trailer by default, so an unstated preference is the tool deciding for the repo. Team repos usually say no; personal ones often do not care.

**Section C — Test gotchas.** What does someone need to know to run this repo's tests that `package.json` does not say? This is the one question worth the user's full attention, because it is the only thing here that cannot be looked up — a heap size the default undershoots, suites that must run one file at a time, integration tests needing a live database, a suite too expensive to run locally at all. Ask for it in their words and record it verbatim.

If they have nothing, write the commands alone. A thin `testing.md` that is accurate beats a padded one that guesses.

### 3. Confirm

Show the full drafted contents of both files, the `.gitignore` line, and the `## Agent skills` additions, and let the user edit before anything is written.

### 4. Write

Seed templates live in this skill's folder — start from them rather than composing from scratch:

- [vcs-github.md](./vcs-github.md) — GitHub PRs via `gh`
- [vcs-azure-devops.md](./vcs-azure-devops.md) — Azure DevOps PRs via `az`
- [testing.md](./testing.md) — test-runner commands and constraints

For a host with no seed template, write `docs/agents/vcs.md` from the user's description, keeping the same headings the seeds use so `/pr` and `/commit` find what they expect. Say in one line that `/pr` has no host module for it yet and will need the commands spelled out.

**Add `.scratch/` to `.gitignore`** if it is not already there. Append it; do not reorder or tidy the file around it. This is the only file this skill touches outside `docs/agents/` and the agent doc, and it earns the exception because the cost of the missing line is not a failed run — it is the working directory quietly becoming permanent repo content, noticed months later.

Then add to the `## Agent skills` block in whichever of `CLAUDE.md` / `AGENTS.md` already exists — edit the one that is there, never create the other:

```markdown
### VCS conventions

[host], [language] commits and PR bodies. See `docs/agents/vcs.md`.

### Testing

[one line on how suites are run here]. See `docs/agents/testing.md`.

[A guardrail line, only if the Section C answer named something whose violation causes damage —
worded so the wording itself does the triggering: "Never run the whole suite locally; it can
exhaust memory and take the machine down."]

### Findings log

Defects and gotchas found mid-feature land in `.scratch/<feature-slug>/findings.md` as they surface.

### Feature state

A `.scratch/<feature-slug>/STATE.md` means that feature is mid-flight. Read it before touching that
feature's code — it names the workflow in progress and the command that resumes it.
```

Those last two blocks are **pointers with no target on purpose.** They exist so an agent doing ad-hoc work in this repo — no skill loaded — still learns the habit. How to write a finding, and what goes to the glossary or an ADR instead, lives in the skills that capture them, where it can still be improved for repos already set up. A repo doc restating it would be a photocopy that never re-syncs.

**Feature state** carries a second job the others do not: it is the only line that can bootstrap a multi-phase workflow after a context reset. `/workflow` tells its own reader to open `STATE.md`, but a session resuming cold has not loaded `/workflow` and never sees that instruction — the pointer is what breaks the circle. Without it, resuming depends on the user remembering to say so.

Update these four sub-blocks in place if they already exist. Leave every other section of the file alone, including the sub-blocks `/setup-matt-pocock-skills` owns.

### 5. Done

Name the two files written and the skills that now read them — `/commit` and `/pr` from `vcs.md`, `/test-report` and `/tdd` from `testing.md` — plus the `.gitignore` line if one was added. Mention that editing `docs/agents/*.md` directly is the normal way to change an answer later; re-running this skill is for starting over.
