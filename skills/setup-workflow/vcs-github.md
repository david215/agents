# VCS conventions

How `/commit` and `/pr` behave in this repo.

## Host

**GitHub** — `<OWNER>/<REPO>`.

Authentication is the existing `gh auth` session. If `gh` fails with an auth error, report the exact
error rather than guessing at a fix — and check `gh auth status` first, since a machine with more
than one account logged in can have the wrong one active.

## Integration branch

`<DEFAULT_BRANCH>` — the branch PRs target, and the merge-base for computing a change's scope.

## Branch naming

`<BRANCH_PATTERN>`

<!--
e.g. "`<type>/<slug>` — `feat/`, `fix/`, `refactor/`, matching the Conventional Commit types."
Or "No convention — branches are named freely."
-->

`/pr` creates branches to this pattern. `/to-durable` reads it in reverse, stripping the prefix to
recover the feature slug that names the spec directory — so a repo with no convention should say so
plainly, and the whole branch name becomes the slug.

## Language

Commit subjects and PR bodies are written in **<LANGUAGE>**.

Conventional Commit types stay English and lowercase (`feat`, `fix`, `refactor`, …) regardless of
the prose language.

## PR title

<PR_TITLE_CONVENTION>

<!--
Frequently NOT the commit convention. e.g. "A plain descriptive phrase, no Conventional Commit
prefix." Or "Same as the commit subject."
-->

## Commit scopes

<SCOPES>

<!--
e.g. "Scoped by package — `api`, `web`, `cli`. New scopes are fine; match an existing directory
name." Or "No scopes — `feat: …`, no parentheses."
-->

## Attribution

<ATTRIBUTION>

<!--
One of: "No trailer — commits carry the author only." / "`Co-Authored-By: <agent>` on agent-authored
commits."
-->

State this either way. The agent harness appends a `Co-Authored-By` trailer by default, so leaving
it unstated is a decision made by the tool rather than by the repo.

## Reviewers

Added to every PR by default:

```
<GITHUB_HANDLE>
```

PRs are opened as **<draft | ready>**.

Solo repo with no reviewers? Leave this section empty — `/pr` skips the flag rather than inventing
one.

## Issue linking

<LINKING>

<!--
e.g. "`Closes #<n>` in the PR body, so the merge closes the issue." Or "None — the issue tracker is
local markdown with no linkable ID; the PR body references the spec path instead."
-->

## Length limits

GitHub's body and comment caps are both far larger than anything a PR description reaches in
practice, so no length budget is enforced here and long content stays in the description.

> Unverified: the exact cap has not been measured against this host the way Azure DevOps' 4,000 /
> 150,000 split was. Confirm before relying on it for anything that pushes size.

The one thing worth keeping regardless: **the test report goes in a comment, not the description.**
Not for length — a description is the PR's standing summary, and burying a run log in it means
every reviewer scrolls past a table that was already stale by the second push.

## Commands

```bash
# open a draft PR
gh pr create --base <DEFAULT_BRANCH> --draft --title "<title>" --body-file <file>

# post the test report as a comment
gh pr comment <NUMBER> --body-file <file>

# list your open PRs
gh pr list --author @me
```
