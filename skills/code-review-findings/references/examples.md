# Examples

## Trigger examples

- "Review this branch and tell me if anything is wrong."
- "Do a release-focused review of the last two commits."

## Example finding shape

```text
High: payments/checkout.py:184
The new retry loop replays the charge request after a timeout without an idempotency key. A network timeout can now create duplicate charges.
```

## Non-goals

- Cosmetic style comments
- Broad architecture advice unless it exposes a concrete regression or blocker
