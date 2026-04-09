# Examples

## Trigger examples

- "Write release notes for everything that landed between `v1.8.0` and `main`."
- "Summarize the user-facing changes in these three merged PRs."

## Example grouping

- Authentication: clearer login error messages and fewer forced re-auth prompts
- Reporting: exports now preserve applied date filters
- Admin: bulk invite flow now surfaces per-user failures inline

## What to skip

- dependency bumps with no user-visible effect
- test-only changes
- internal renames unless they change an external contract
