# Commit — worked example

One commit body, before and after applying the change-group grouping and blast-radius ordering rules
from `SKILL.md`. Nothing is added or removed between the two — only merged, nested, and reordered.

**Title (unchanged):** `fix(webhook): reject duplicate payment callbacks and widen the retry window`

## Before — flat, unordered

```
- Add an idempotency check on the payment callback so a replayed webhook is a no-op
- Store the key in a new payment_callback_log table with a unique constraint
- Widen the retry window from 3 attempts over 30s to 5 attempts over 5m
- Use exponential backoff instead of a fixed 10s interval
- Extract the retry policy into a shared constant so the refund handler can reuse it
- Rename handleCallback to handlePaymentCallback for symmetry with handleRefundCallback
- Add unit tests for the duplicate-callback path
```

Seven bullets, no visible ranking. A reviewer reads all seven before learning which one matters.

## After — regrouped

```
- Reject duplicate payment callbacks with an idempotency key
  - Keyed on the provider's transaction ID, in a new `payment_callback_log` table with a unique
    constraint — the constraint, not the application check, is what makes a concurrent replay safe
  - A replay is now a no-op returning 200, so the provider stops retrying; previously it did not
  - Unit coverage for the duplicate path
- Widen the callback retry window from 3 attempts over 30s to 5 over 5m, with exponential backoff
  - The old fixed 10s interval put all three attempts inside the provider's own outage window, so a
    brief upstream blip cost the callback outright
  - Policy extracted into a shared constant; the refund handler reuses it rather than keeping a
    second copy that would drift
- Rename `handleCallback` to `handlePaymentCallback`, for symmetry with `handleRefundCallback`
```

## What changed, and why

1. **Same seven facts, three top-level bullets.** Nothing was cut. The table and its constraint are
   *how* the idempotency check works, not a second decision. Backoff and the shared constant are
   both the retry policy — one change-group, reviewed together.

2. **Order leads with risk.** A duplicate payment callback is a money-correctness bug, which
   outranks a reliability tuning change, which outranks a rename that changes no behaviour at all.

3. **Rationale nests, it never competes.** *Why the constraint rather than the application check*
   and *why 10s was wrong* sit under the changes they justify. As siblings they would read as five
   more things the commit did.

4. **A test attaches to the change it covers.** "Add unit tests for the duplicate-callback path"
   became a sub-bullet of bullet 1, not a trailing bullet of its own. Tests sort last only when they
   stand alone as the commit's actual subject — a test-only commit, or coverage added for code that
   was not otherwise touched.
