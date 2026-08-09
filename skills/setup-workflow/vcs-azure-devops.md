# VCS conventions

How `/commit` and `/pr` behave in this repo.

## Host

**Azure DevOps** — `<ORG>/<PROJECT>/<REPO>`.

Authentication is the existing `az login`; no PAT is needed. If an `az repos` command fails with an
auth error, report the exact error rather than guessing at a fix.

## Integration branch

`<DEV_BRANCH>` — the branch PRs target, and the merge-base for computing a change's scope.

## Branch naming

`<BRANCH_PATTERN>`

<!--
e.g. "`<type>/<slug>` — `feat/`, `fix/`, `refactor/`, matching the Conventional Commit types."
Or "No convention — branches are named freely."
-->

`/to-durable` and `/test-report` read this in reverse, stripping the prefix to recover the feature
slug that names the working directory — so a repo with no convention should say so plainly, and the
whole branch name becomes the slug.

## Language

Commit subjects and PR bodies are written in **<LANGUAGE>**.

Conventional Commit types stay English and lowercase (`feat`, `fix`, `refactor`, …) regardless of
the prose language.

## PR title

<PR_TITLE_CONVENTION>

<!--
Frequently NOT the commit convention. e.g. "A plain descriptive phrase, no Conventional Commit
prefix — `조직 생성 시 IANA timezone 저장 추가`, not `feat: …`." Or "Same as the commit subject."
-->

## Commit scopes

<SCOPES>

<!--
e.g. "Scoped by feature module — `submission`, `evaluation`, `class`, `rubric`. New scopes are fine;
match an existing directory name." Or "No scopes — `feat: …`, no parentheses."
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
<REVIEWER_EMAIL_OR_ID>
<REVIEWER_EMAIL_OR_ID>
```

PRs are opened as **<draft | ready>**.

## Work item linking

<LINKING>

<!--
e.g. "Link the ADO work item to the PR — see `az repos pr work-item --help` for the exact
subcommand." Or "None — the issue tracker is local markdown with no linkable ID; the PR body
references the spec path instead."
-->

## Length limits

Azure DevOps enforces two very different caps, and conflating them is the mistake this section
exists to prevent:

| Surface | Limit |
| --- | --- |
| PR **description** | 4,000 characters — silently truncated past it |
| PR **comment** | 150,000 characters |

Measure with `LC_ALL=en_US.UTF-8 wc -m`, not `wc -c`. Multi-byte prose (Korean is 3 bytes per
character) makes a byte count read nearly 3× the real length and will make you cut a description
that fits. The locale prefix is part of the measurement — under `LC_ALL=C`, `wc -m` counts bytes too.

Because comments are ~37× larger, **anything long goes in a comment, not the description** — the
test report in particular. There is no `az repos pr comment` subcommand; reach the REST API through:

```bash
az devops invoke --area git --resource pullRequestThreads --http-method POST
```

## Commands

```bash
# open a draft PR
az repos pr create --repository <REPO> --source-branch <BRANCH> --target-branch <DEV_BRANCH> --draft

# list your open PRs
az repos pr list --repository <REPO> --status active
```
