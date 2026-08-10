---
name: grilling
description: Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases.
---

Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled — the questions you can ask _now_ without guessing at answers you haven't heard yet. Ask the whole frontier in one round: number each question and give your recommended answer. Then wait for the user's answers before the next round.

Each question should be formatted like so:

```
❓ **Q1** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>
```

Put each question on **both** surfaces. The prose above carries the reasoning and your
recommendation at whatever length the argument needs; `AskUserQuestion` carries the decision — one
question per frontier item, your recommendation first and labelled `(Recommended)`. They hold
different content rather than two copies of one: the tool's labels run a few words and cannot hold
an argument, and prose cannot be clicked. The split also cheapens rejection — a round the user turns
down costs the answers and leaves the reasoning on screen.

The tool takes four questions at most. On a wider frontier, split across rounds or ask the remainder
in prose: asking the whole frontier in one round outranks routing all of it through the tool.

Each round the user answers reshapes the tree — settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next round. A question whose answer depends on another question still open in this round belongs to a _later_ round, not this one.

Finding _facts_ is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, etc.), go and find it — a sub-agent is usually the right way, but any lookup will do — and don't ask the user for anything you could look up yourself. Don't block on it: a running exploration is an unsettled prerequisite, so only the questions downstream of it wait for the report — ask the rest of the frontier now. The _decisions_ are the user's — put each to them and wait.

The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Do not act on it until the user confirms you have reached a shared understanding.
