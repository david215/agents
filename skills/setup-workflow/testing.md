# Testing

How this repo's suites are run, and what breaks when they are run wrong. `/test-report` reads this
file; `/implement` and `/tdd` read it before running anything.

## Commands

| Suite | Command |
| --- | --- |
| <unit> | `<COMMAND>` |
| <integration> | `<COMMAND>` |
| <typecheck> | `<COMMAND>` |

Prefer the narrowest command that answers the question. A typecheck is far cheaper than a spec run
and catches most signature-level breakage.

## Constraints

<!--
The section that earns this file. Everything above can be read off package.json; nothing here can.
Record what someone learned the hard way — a heap size the default undershoots, suites that must run
one file at a time, a live database requirement, a suite too expensive to run locally at all.
Delete this comment and the placeholder below once filled; an empty section is fine if the repo
genuinely has no gotchas.
-->

- `<CONSTRAINT>`

## Scoping a run

Run only the specs the change actually touches. Scope by **file**, not by directory — a bare
directory path can match far more than expected.

After changing shared code (a guard, a query module, a schema), the specs that break are the ones
that construct or mock the thing you changed, not the ones next to it. Grep for those and include
them.

## Where specs live

<SPEC_LAYOUT>

<!--
e.g. "Co-located under `<module>/spec/*.spec.ts`; libs under `libs/<lib>/src/spec/`. Unit specs are
`*.unit.spec.ts`, integration `*.int.spec.ts`." — whatever a reader needs to map a changed source
file to the suites that cover it.
-->

## Local versus CI

<LOCAL_VS_CI>

<!--
Name anything that is CI-only, and why. A monorepo that spins up a full app per spec file can
exhaust memory when the whole suite runs at once — that makes "run everything locally" a machine
outage, not a slow command, and it is worth saying so explicitly.
-->
