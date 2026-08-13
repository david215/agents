# PR — worked example

Illustrative. A real body comes from `git log` and `git diff` over `<merge_base>..HEAD`, never from
this scenario.

**Branch scope:** account withdrawal now cascades to owned organizations; a blocker check was added
to the withdrawal route; the transaction retry helper was extracted for reuse.

**Title:** `Cascade organization soft-delete on account withdrawal`

```markdown
## What changed

- **API changes**
  - `DELETE /account/withdrawal` (changed)
    - Now returns `409` with `reason: "UNSETTLED_INVOICE"` when a blocker exists; previously always
      succeeded
    - Side effect widened: owned organizations are soft-deleted and their subscriptions suspended
  - `GET /organization` (changed)
    - Soft-deleted organizations are excluded from the list; a caller holding a stale ID now gets
      `404` rather than a deleted record
- **Withdrawal cascade to owned organizations**
  - `account.withdrawal.service` now soft-deletes organizations the withdrawing user solely owns,
    and suspends their active subscriptions in the same transaction
  - Organizations with a second owner are left untouched; ownership transfer is out of scope
- **Withdrawal blocker check**
  - `assertNoWithdrawalBlockers` rejects withdrawal while an unsettled invoice exists, raising
    before any write so a partial cascade cannot happen
- **Transaction retry helper extracted**
  - `libs/prisma/transaction.conflict.retry` replaces three near-identical inline retry loops
    - Call sites pass the same options object rather than re-declaring backoff per call

## Expected effect

- A withdrawn owner no longer leaves orphaned organizations billable
- Withdrawal fails loudly on an unsettled invoice instead of succeeding and stranding the balance

## Tests

See the test report comment below.
```

`API changes` leads `What changed` rather than sitting in its own section, and the two routes'
*consequences* — orphaned organizations, the loud failure — are what `Expected effect` carries. Those
two lines would be the whole section if the route list were moved down here.

The comment that pairs with it, posted in Step 7:

```markdown
### Test report

**Changed specs**

- `apps/account/src/account/spec/account.withdrawal.service.unit.spec.ts` (changed)
- `apps/account/src/account/spec/organization.service.unit.spec.ts` (changed)
- `libs/prisma/src/spec/transaction.conflict.retry.util.unit.spec.ts` (new)

**Run**

| Suite | Result |
| --- | --- |
| `account.withdrawal.service.unit.spec.ts` | 14 passed |
| `organization.service.unit.spec.ts` | 9 passed |
| `transaction.conflict.retry.util.unit.spec.ts` | 6 passed |
```

## What to notice

**Three labels, not eight.** The retry helper and its call-site convention are one change-group.
The cascade and the "second owner is untouched" carve-out are one group, because a reviewer decides
them together.

**Depth-3 used exactly once**, for the call-site convention under the retry detail. In a body this
size that is the calibration: an escape hatch, not a way to enumerate files.
