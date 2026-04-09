# Examples

## Trigger examples

- "Implement the approved plan from `input.md` on top of `main`, push the branch, and give me a PR draft."
- "Use a separate worktree for this change so you do not touch the active checkout."

## Expected output shape

- Pushed branch name
- Whether the temporary worktree was deleted
- Clipboard copy status if attempted
- A fenced `md` block containing the PR title, summary, testing, and follow-ups

## Notes

- Prefer a timestamped branch name such as `agent/main/plan-20260409-153012`.
- Prefer a worktree path outside the repository root to avoid accidental cleanup mistakes.
