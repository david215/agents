---
name: grill-with-docs
description: A relentless interview to sharpen a plan or design, which also creates docs (ADR's and glossary) as we go.
---

Run a `/grilling` session, using the `/domain-modeling` skill.

## Capture as you go

A grilling surfaces more than terms and decisions. When something surprises you that is neither —
a constraint you measured, a defect in code you were only passing through, a gotcha that cost an
hour — append it to `.scratch/<feature-slug>/findings.md` **as it surfaces**, one line, newest last:

```
- <what you found> — <where it bites> [grill]
```

Append-only; create the file if it does not exist. Enough to reconstruct the finding in a month — if
it needs a paragraph, it is a decision, and decisions go to an ADR.

Do not stop to judge whether it matters or where it belongs. Judging is `/to-durable`'s job at the
end of the feature, with everything visible at once; a finding not written within a minute of being
noticed is one you will not remember to write.

Terms and decisions are the exception — `/domain-modeling` writes those inline as they crystallise.
