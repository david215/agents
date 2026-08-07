---
name: setup-workflow
description: Configure this repo for the /workflow orchestration — PR and commit conventions, test-runner commands, and the findings log. Run once per repo, after /setup-matt-pocock-skills.
disable-model-invocation: true
---

# Setup Workflow

Scaffold the per-repo configuration that `/workflow` and its steps read:

- **VCS** — which host PRs go to, what language commits and PR bodies are written in, who reviews → `docs/agents/vcs.md`
- **Testing** — how this repo runs its suites, and what breaks when you run them wrong → `docs/agents/testing.md`
- **Findings log** — where a defect or gotcha gets written the moment it surfaces → `docs/agents/findings.md`

Additive to `/setup-matt-pocock-skills`. That skill owns the issue tracker, triage labels, and domain docs; this one writes three files it does not touch, and adds its own sub-blocks to the same `## Agent skills` section.

Prompt-driven, not a script. Explore, present what you found, confirm, then write.

## The repo answers where; the skill carries the obligation

These files record facts about **this repo** — the host, the language, the commands, the layout. They never record the process itself. `/commit` knows it must screen for secrets; `docs/agents/vcs.md` only tells it which language to write the message in. Keep that line and the same skills work in every repo without edits.

The test: could this line be different in another repo? If no, it belongs in a skill, not here.

## Prerequisite

`docs/agents/issue-tracker.md` must exist — the findings log lives beside the spec, so its location is derived rather than asked. If the file is absent, run `/setup-matt-pocock-skills` first, then continue here.

## Process

### 1. Explore — infer before asking

Every answer you can read out of the repo is one the user does not have to type. Read all of these before asking anything:

- `git remote -v` — the PR host. `github.com` → GitHub; `dev.azure.com` or `visualstudio.com` → Azure DevOps; `gitlab.com` or a self-hosted GitLab → GitLab. No remote at all → ask.
- `git log --format=%s -30` — three answers at once: the language subjects are written in, whether Conventional Commit prefixes are in use, and whether those prefixes carry scopes (`feat(submission):` versus `feat:`). If scoped, the set of scopes actually used is the vocabulary to record. An empty or one-commit history settles nothing; default to English and say so.
- `git log -30 --format=%B | grep -i 'co-authored-by'` — whether commits carry an attribution trailer. Hits mean the repo accepts one; no hits across a substantial history mean it does not, and a short history means neither.
- `git branch -a --sort=-committerdate | head -20` — the branch naming pattern. A `<type>/<slug>` shape is what `/to-durable` strips to recover a feature slug, so record the prefixes actually in use rather than the ones the commit types imply.
- `docs/agents/issue-tracker.md` — where feature directories live. The findings log goes beside the spec, under the same per-feature directory. This also settles issue linking: a tracker with linkable IDs (GitHub issues, ADO work items) gets linked, a local-markdown tracker has nothing to link and the PR body references the spec path instead.
- Test-runner config: `package.json` scripts, `Makefile`, `pyproject.toml`, `Cargo.toml`, `go.mod`, and any `jest.*.config.*` / `vitest.config.*` / `pytest.ini`.
- Glob for the test files themselves — `**/*.spec.*`, `**/*.test.*`, `**/test_*.py` — and read the layout off the paths: co-located beside source or gathered under a top-level `tests/`, and what suffix separates unit from integration. Sample a handful of paths; do not enumerate the tree.
- `CLAUDE.md` / `AGENTS.md` — an existing `## Agent skills` block, plus any testing or commit rules already written down in prose. Rules found here are inferred answers, not questions.
- `docs/agents/vcs.md`, `testing.md`, `findings.md` — this skill's own prior output, if it has run before.

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
  Findings log   .scratch/<feature>/findings.md        ← derived from the above
  Issue linking  none — a markdown tracker has no linkable ID
  Test runner    pnpm jest, configs jest.unit.config.ts / jest.int.config.ts
  Spec layout    co-located, *.unit.spec.ts / *.int.spec.ts

Correct anything wrong; otherwise I have three questions.
```

Then ask only these three. All accept "none" — an empty answer is a valid configuration, not a skipped step.

**Section A — Reviewers.** Who gets added to a PR by default, and are PRs opened as drafts? Nothing in the repo reveals intent here. On a solo project the answer is usually no reviewers and no draft; say that as the recommendation so it can be accepted in a word.

**Section B — Attribution.** Do commits carry a `Co-Authored-By` trailer for agent-authored work? Ask this even when the git history answered it, unless the history was unambiguous — the harness appends the trailer by default, so an unstated preference is the tool deciding for the repo. Team repos usually say no; personal ones often do not care.

**Section C — Test gotchas.** What does someone need to know to run this repo's tests that `package.json` does not say? This is the one question worth the user's full attention, because it is the only thing here that cannot be looked up — a heap size the default undershoots, suites that must run one file at a time, integration tests needing a live database, a suite too expensive to run locally at all. Ask for it in their words and record it verbatim.

If they have nothing, write the commands alone. A thin `testing.md` that is accurate beats a padded one that guesses.

### 3. Confirm

Show the full drafted contents of all three files plus the `## Agent skills` additions, and let the user edit before anything is written.

### 4. Write

Seed templates live in this skill's folder — start from them rather than composing from scratch:

- [vcs-github.md](./vcs-github.md) — GitHub PRs via `gh`
- [vcs-azure-devops.md](./vcs-azure-devops.md) — Azure DevOps PRs via `az`
- [testing.md](./testing.md) — test-runner commands and constraints
- [findings.md](./findings.md) — the findings-log convention

For a host with no seed template, write `docs/agents/vcs.md` from the user's description, keeping the same headings the seeds use so `/pr` and `/commit` find what they expect. Say in one line that `/pr` has no host module for it yet and will need the commands spelled out.

Then add to the `## Agent skills` block in whichever of `CLAUDE.md` / `AGENTS.md` already exists — edit the one that is there, never create the other:

```markdown
### VCS conventions

[host], [language] commits and PR bodies. See `docs/agents/vcs.md`.

### Testing

[one line on how suites are run here]. See `docs/agents/testing.md`.

### Findings log

Defects and gotchas found mid-feature land in [path] as they surface. See `docs/agents/findings.md`.
```

Update these three sub-blocks in place if they already exist. Leave every other section of the file alone, including the sub-blocks `/setup-matt-pocock-skills` owns.

### 5. Done

Name the three files written and the skills that now read them — `/commit` and `/pr` from `vcs.md`, `/test-report` from `testing.md`, `/workflow` and `/to-durable` from `findings.md`. Mention that editing `docs/agents/*.md` directly is the normal way to change an answer later; re-running this skill is for starting over.
