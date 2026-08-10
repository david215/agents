# Host — Azure DevOps

Requires the `az` CLI with the `azure-devops` extension, already authenticated. **No PAT is
needed** — do not set one up or ask the user for one. If a command fails with an auth error, report
the exact error rather than guessing at a fix.

## Resolve org, project, repository

Parse from the remote rather than hardcoding, so this survives a rename or re-home:

```bash
git remote get-url origin
# https://<org>@dev.azure.com/<org>/<project>/_git/<repo>
# → org https://dev.azure.com/<org>   project <project>   repository <repo>
```

If parsing fails because the remote shape is unfamiliar, say so and ask. Do not fall back to values
from another repo.

## Length limits

Two very different caps, and conflating them is the mistake this section exists to prevent:

| Surface | Limit |
| --- | --- |
| PR **description** | 4,000 characters — silently truncated past it |
| PR **comment** | 150,000 characters |

Treat **3,900 as the description ceiling**, not a target. Measure before creating:

```bash
printf '%s' "<body>" > <scratch>/pr-body.txt
LC_ALL=en_US.UTF-8 wc -m < <scratch>/pr-body.txt
```

`wc -m`, never `wc -c`. Korean runs three bytes per character, so a byte count reads roughly triple
and will make you cut a body that fits. Over 3,900 means a label is mis-grained — merge, then
re-measure. Delete the file afterwards.

**Keep the locale prefix.** `wc -m` counts characters only in a UTF-8 locale; under `LC_ALL=C` or
`POSIX` it counts bytes, so the bare command silently becomes the `wc -c` this section warns
against — measured on macOS, `한글테스트` returns 5 with a UTF-8 locale and 15 without.

Comments are ~37× larger, which is why the test report goes there.

## Find an existing active PR

```bash
az repos pr list --org <org> --project <project> --repository <repo> \
  --source-branch <branch> --status active \
  --query "[?targetRefName=='refs/heads/<integration-branch>']"
```

## Create

```bash
az repos pr create --org <org> --project <project> --repository <repo> \
  --source-branch <branch> --target-branch <integration-branch> \
  --title "<title>" --description "<body>" \
  --draft true \
  --optional-reviewers <from vcs.md Reviewers>
```

Reviewers come from `vcs.md`. Prefer `--optional-reviewers` over `--required-reviewers` unless the
repo says otherwise: the branch policy decides who must approve, and hardcoding required reviewers
into a skill silently tightens that policy.

## Update

```bash
az repos pr update --org <org> --id <pr-id> --title "<title>" --description "<body>"
```

## Post a comment

There is no `az repos pr comment` subcommand. Reach the REST API directly:

```bash
az devops invoke --area git --resource pullRequestThreads --http-method POST \
  --route-parameters project=<project> repositoryId=<repo> pullRequestId=<id> \
  --api-version 7.1 --in-file <scratch>/comment.json   # body built from .scratch/<feature-slug>/test-report.md
```

`comment.json` is
`{"comments": [{"parentCommentId": 0, "content": "<report>", "commentType": 1}], "status": <n>}`.

### Post the report thread resolved, not active

A test report asks nothing of a reviewer. Left active it joins the unresolved-comment count Azure
DevOps shows on the PR — the list reviewers work through before approving — so it reads as an
outstanding item, and someone has to resolve a comment they did not write to clear it. Resolved, it
still renders in full and still notifies on creation.

Two calls, because only the second value is verified on this resource:

```bash
# 1. POST as above, and read pullRequestThreads' returned id.
# 2. Then close the thread:
echo '{"status":"closed"}' > <scratch>/thread-status.json
az devops invoke --area git --resource pullRequestThreads --http-method PATCH \
  --route-parameters project=<project> repositoryId=<repo> pullRequestId=<id> threadId=<threadId> \
  --api-version 7.1 --in-file <scratch>/thread-status.json
```

`closed` is the right status, not `fixed` — nothing was repaired.

Measured 2026-08-10 against `dev.azure.com`: the PATCH accepts the string `"closed"` and echoes it
back. Whether a thread can be *born* closed by putting `"status": "closed"` in the POST body is
**untested** — the field is honoured on create (`1` yields an active thread), so it likely collapses
to one call. Verify before simplifying: a create that silently ignores the field leaves the thread
active, which is what this section exists to prevent.

To update an existing report comment instead of adding a thread, GET the threads first and PATCH the
matching comment.

## Work item linking

`vcs.md`'s **Work item linking** section decides whether to link, and to what. See
`az repos pr work-item --help` for the current subcommand shape — verify it before relying on it.

## PR URL

`create` and `update` return a `pullRequestId`:

```
https://dev.azure.com/<org>/<project>/_git/<repo>/pullrequest/<id>
```
