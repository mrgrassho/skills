# Examples

## Trigger examples

- "Implement the approved plan from `input.md` on top of `main`, push the branch, and give me a PR draft."
- "Use a separate worktree for this change so you do not touch the active checkout."
- "Start from `release/1.8`, do the work in a temporary worktree, then push and summarize it."

## Recommended naming

- Branch: `agent/<base-branch>/plan-<timestamp>`
- Worktree: `../wt-plan-<timestamp>`

Example:

- Branch: `agent/main/plan-20260409-153012`
- Worktree: `../wt-plan-20260409-153012`

## Validate inputs first

Use the smallest checks that prove the plan can start safely:

```bash
test -f "$PLAN_FILE"
git -C "$REPO_DIR" rev-parse --is-inside-work-tree >/dev/null
git -C "$REPO_DIR" fetch "$REMOTE" --prune
git -C "$REPO_DIR" rev-parse --verify "$REMOTE/$BASE_BRANCH" \
  || git -C "$REPO_DIR" rev-parse --verify "$BASE_BRANCH"
```

If the remote branch exists, create the worktree from `"$REMOTE/$BASE_BRANCH"`.
If it does not but the local branch exists, create the worktree from `"$BASE_BRANCH"` instead.

## Happy-path command sequence

```bash
TS="$(date +%Y%m%d-%H%M%S)"
SAFE_BASE="$(printf '%s' "$BASE_BRANCH" | tr '/ ' '--')"
IMPL_BRANCH="agent/${SAFE_BASE}/plan-${TS}"
WORKTREE_PATH="$(cd "$REPO_DIR/.." && pwd)/wt-plan-${TS}"

git -C "$REPO_DIR" fetch "$REMOTE" --prune
git -C "$REPO_DIR" worktree add -b "$IMPL_BRANCH" "$WORKTREE_PATH" "$REMOTE/$BASE_BRANCH"

cd "$WORKTREE_PATH"
cat "$PLAN_FILE"
```

Local fallback:

```bash
git -C "$REPO_DIR" worktree add -b "$IMPL_BRANCH" "$WORKTREE_PATH" "$BASE_BRANCH"
```

## Review before commit

Before committing, inspect the change shape explicitly:

```bash
git status --short
git diff --stat
git diff
```

Run the smallest relevant test set first, then broaden if needed.

## PR markdown shape

Keep the final PR body short and operational:

```md
# PR Title
Implement plan from `input.md`

## Summary
Implemented the plan described in `input.md` starting from `main`.

## What changed
- ...

## Testing
- [x] Targeted tests run: `...`

## Notes
- ...

## Follow-ups
- ...
```

If anything is incomplete, call it out directly in `Notes` or `Follow-ups`.

## Clipboard behavior

Save the PR markdown to a file first. Copy it to the clipboard only when the environment supports it.

Examples:

- macOS: `pbcopy < "$PR_FILE"`
- Linux with xclip: `xclip -selection clipboard < "$PR_FILE"`
- Linux with xsel: `xsel --clipboard --input < "$PR_FILE"`

If no clipboard tool exists:

- do not fail the task
- return the PR markdown in the final response
- state that clipboard copy was unavailable

## Failure handling examples

- Push fails:
  keep the worktree, preserve the branch state, and report the exact worktree path.
- Implementation is partial but coherent:
  push it anyway and mark incomplete items clearly in the PR markdown.
- Worktree removal fails:
  report the exact leftover path instead of pretending cleanup succeeded.

## Expected final response

- pushed branch name
- whether the temporary worktree was deleted
- clipboard copy status if attempted
- a fenced `md` block containing the PR title, summary, what changed, testing, and follow-ups
