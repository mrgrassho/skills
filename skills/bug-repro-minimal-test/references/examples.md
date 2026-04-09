# Examples

## Trigger examples

- "This endpoint sometimes returns a 500 when the cache is cold. Reproduce it and add a test before fixing it."
- "Turn this manual QA bug into the smallest failing test you can."

## Reduction pattern

1. Start from the full user flow.
2. Strip unrelated setup.
3. Collapse network or UI layers if a lower-level interface can still prove the bug.
4. Keep the final test focused on one broken invariant.

## Expected report

- reproduction command
- minimal failing test path
- root cause summary
- validation command after the fix
