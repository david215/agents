# Default PR template

Used only when the repo ships no `pull_request_template.md`. A repo that adopts one takes over from
this file entirely — that is the point of Step 3.

Deliberately thin. A repo's real template encodes what its reviewers agreed to check; anything
invented here would be a guess at that, so this covers the minimum a reviewer needs and stops.

```markdown
## What changed

- **<label>**
  - <detail>
  - <detail>
- **<label>**
  - <detail>

## Expected effect

- <outcome supported by the diff>

## API changes

- `<METHOD /path>` (BREAKING|new|changed)
  - <what a caller must now do differently>

## Tests

See the test report comment below.
```

## Notes

**Omit `API changes` entirely** when no route has caller-visible change. An empty section reads as
"checked and clear" when it usually means "not checked".

**`Tests` is a pointer, never content.** Both the changed spec files and the run results live in the
comment — see Step 7. With no test report in this run, drop the section rather than pointing at a
comment that does not exist.

In the comment, write **one path per line, in full**. Do not compress shared prefixes into brace
expansion (`spec/{a,b}.unit.spec.ts`) or any other shorthand — a full path is greppable, clickable
in most review UIs, and readable without mentally expanding it. The shorthand only ever existed to
buy characters against a description cap that no longer applies here.

The label → detail shape, the change-group rule, and the `API changes` tags are specified in
`SKILL.md` and apply here unchanged.
