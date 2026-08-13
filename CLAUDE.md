# agents

Seventeen skills and three always-loaded rules, installed globally via the `skills` CLI.
`README.md` explains why the repo is shaped this way; this file is what to do while editing it.

## Editing

**Edit here, push, then reinstall — never `cp` into `~/.agents/skills/`.** A copy produces a
working install with no lock entry, and `skills update` walks lock entries and nothing else, so a
copied skill is skipped forever while looking completely fine on disk.

    ./check.sh && git commit … && git push
    npx skills add david215/agents -g -s '*' -y -a claude-code codex cursor gemini-cli

**Run `./check.sh` before committing.** Regression guard — every entry exists because that thing
already shipped broken once.

**Adding a skill means adding it to `.claude-plugin/plugin.json`.** Paths must start with `./`.

**The local `grep` is ugrep, not BSD or GNU grep, and it supports `-P`.** The portability checks in
`check.sh` guard behaviour you cannot reproduce here — a pattern that works at this prompt can still
fail on a plain macOS or CI box. Do not verify a portability fix by running it locally.

**Skills are installed as copies; rules are symlinked to this repo.**

    ~/.claude/skills  ->  ~/.agents/skills                 real copies — reinstall to update
    ~/.claude/rules   ->  ~/.agents/rules  ->  rules/      two hops to this repo — no copies

So a rules edit is live everywhere the moment you save it, and there is nothing to sync; a skill
edit reaches nothing until you reinstall.

**Never diff `rules/` against an install path to prove a sync.** Both hops land back on this repo,
so the diff compares each file to itself, reports "in sync" by construction, and can never fail —
`~/.agents/rules` looks like the real copy and is not. Establish what a path *is* (`ls -l`,
`readlink`, or compare inodes with `stat -f %i`) before treating any diff across it as evidence.
Skills are safe to diff because `~/.agents/skills` genuinely holds copies.

## Writing

**The repo answers *where*; the skill carries the obligation.** A skill knows it must screen a
commit for secrets; `docs/agents/vcs.md` only says which language to write the message in. Test any
line in a generated repo doc: could this be different in another repo? If no, it belongs in a skill.
Operative form in `setup-workflow/SKILL.md`.

**An instruction needs an addressee with a turn.** Name who executes it, then check they have a turn
at the moment the instruction names. *Before the reset*, *on exit*, *when the session ends* all fail,
and fail silently.

**Where the addressee is right but the capability is not guaranteed, state a precondition and ask.**
`/code-review` needs sub-agents and a session can forbid them — so it stops rather than degrading
into a weaker review that looks identical.

**An example earns its place by pinning a shape or a transformation** — something prose specifies
poorly. An example demonstrating a rule prose states in one sentence is dead weight.

Writing rules for standing documents — anti-inference, minimal provenance, standing vs. event — are
in `rules/house-rules.md` §6.
