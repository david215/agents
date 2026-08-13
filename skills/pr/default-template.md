# Default PR template

Used only when the repo ships no `pull_request_template.md`. A repo that adopts one takes over from
this file entirely — that is the point of Step 3.

Deliberately thin. A repo's real template encodes what its reviewers agreed to check; anything
invented here would be a guess at that, so this covers the minimum a reviewer needs and stops.

```markdown
## What changed

- **API changes**
  - `<METHOD /path>` (BREAKING|new|changed)
    - <what a caller must now do differently>
- **<label>**
  - <detail>
  - <detail>
- **<label>**
  - <detail>

## Expected effect

- <outcome supported by the diff>

## Tests

See the test report comment below.
```

## Notes

**`API changes` is a change-group label inside `What changed`, first position** — not a section of its
own, and never under `Expected effect`. See Step 4's *Which section it goes in*.

**Translate every label into the repo's prose language**, `API changes` included. The English here
names the concept; it is not a string to copy into a body written in another language.

**Omit `API changes` entirely** when no route has caller-visible change. An empty label reads as
"checked and clear" when it usually means "not checked".

**`Tests` is a pointer, never content** — see Step 4's *The test section is a pointer, never
content*. With no test report in this run, drop the section rather than pointing at a comment that
does not exist.

The label → detail shape, the change-group rule, and the `API changes` tags are specified in
`SKILL.md` and apply here unchanged.
