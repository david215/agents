# Host — GitHub

Requires `gh`, already authenticated. Check `gh auth status` first when anything fails: a machine
with more than one account logged in can have the wrong one active, and the error that surfaces is a
permission denial rather than an auth prompt. Report the exact error rather than guessing at a fix.

`gh` reads the repository from the remote, so there is nothing to parse.

## Length limits

GitHub's caps are far larger than anything a PR body reaches in practice, so no budget is enforced
here and long content stays where it reads best.

> **Unverified.** GitHub's REST documentation states no limit for `body`, and this has not been
> measured the way Azure DevOps' 4,000 / 150,000 split was. The cheap way to settle it: POST a body
> of known length to a throwaway PR and read the 422 message, which names the maximum. Do that
> before relying on a number.

The test report still goes in a comment. Not for length — see Step 7 of `SKILL.md`.

## Find an existing open PR

```bash
gh pr list --head <branch> --base <integration-branch> --state open --json number,url
```

## Create

```bash
gh pr create --base <integration-branch> --draft \
  --title "<title>" --body-file <scratch>/pr-body.md \
  --reviewer <from vcs.md Reviewers>
```

Use `--body-file` rather than `--body`: it keeps the exact body as an artifact you can re-read, and
sidesteps shell quoting on multi-line markdown. Omit `--reviewer` entirely when `vcs.md` names none
— an empty flag value is an error, not a no-op.

Drop `--draft` when `vcs.md` says PRs open ready.

## Update

```bash
gh pr edit <number> --title "<title>" --body-file <scratch>/pr-body.md
```

## Post a comment

```bash
gh pr comment <number> --body-file .scratch/<feature-slug>/test-report.md
```

To update the existing report comment rather than adding another:

```bash
gh pr comment <number> --edit-last --body-file .scratch/<feature-slug>/test-report.md
```

`--edit-last` only edits a comment authored by the current account; if the last comment is someone
else's, it fails rather than overwriting — which is the behaviour you want.

## Issue linking

`vcs.md`'s **Issue linking** section decides this. Where the repo links, put `Closes #<n>` in the
body so the merge closes the issue.

## PR URL

`gh pr create` prints the URL on stdout. Otherwise `gh pr view <number> --json url`.
