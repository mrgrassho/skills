# Examples

## Trigger examples

- "Implement the approved plan from `input.md` on top of `main`, open a pull request, and give me the PR link."
- "Use a separate worktree for this change so you do not touch the active checkout."
- "Start from `release/1.8`, do the work in a temporary worktree, then open a PR and summarize it."

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

After the worktree is created, validate that the repository provides the PR helper:

```bash
test -f "$WORKTREE_PATH/${PR_SCRIPT:-scripts/create_pr.sh}"
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
PR_SCRIPT="${PR_SCRIPT:-scripts/create_pr.sh}"
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

## Create the PR

Write the PR body to a file, then let the repo helper push the branch and create the GitHub pull request:

```bash
PR_TITLE="Implement plan from $(basename "$PLAN_FILE")"
PR_FILE="$WORKTREE_PATH/PR_DRAFT_${TS}.md"
cat > "$PR_FILE" <<EOF
## Summary
Implemented the plan described in \`$PLAN_FILE\` starting from \`$BASE_BRANCH\`.

## What changed
- ...

## Testing
- [x] Targeted tests run: \`...\`

## Notes
- ...

## Follow-ups
- ...
EOF

bash "$PR_SCRIPT" --base "$BASE_BRANCH" --title "$PR_TITLE" --body-file "$PR_FILE"
```

Keep the PR body short and operational:

```md
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

- PR creation fails:
  keep the worktree, preserve the branch state, and report the exact worktree path.
- Implementation is partial but coherent:
  create the PR anyway and mark incomplete items clearly in the PR markdown.
- Worktree removal fails:
  report the exact leftover path instead of pretending cleanup succeeded.

## Expected final response

- PR URL
- pushed branch name
- whether the temporary worktree was deleted
- clipboard copy status if attempted
- a fenced `md` block containing the PR title, summary, what changed, testing, and follow-ups
