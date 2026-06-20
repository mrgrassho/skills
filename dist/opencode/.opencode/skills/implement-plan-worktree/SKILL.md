---
name: implement-plan-worktree
description: Implement a markdown plan in an isolated git worktree, validate the result, create a GitHub pull request with the repo PR helper, clean up the temporary checkout, and return the PR link and summary. Use when an agent needs to execute a plan safely without touching the main checkout.
---

# Implement Plan In Worktree

## Use when

- The user has already approved a plan and wants implementation.
- The repository may have other active agents or uncommitted work in the main checkout.
- The task needs a pushed branch and an opened GitHub pull request.

## Inputs

- `PLAN_FILE`: markdown plan to implement
- `BASE_BRANCH`: branch to start from
- `REPO_DIR`: repository root
- `REMOTE`: remote name, usually `origin`
- `PR_SCRIPT`: repo-local PR helper, usually `scripts/create_pr.sh`

## Workflow

1. Validate that the plan file exists, the repo is a git worktree, and the requested base branch exists locally or on the remote.
2. Fetch the remote, generate a timestamped branch name, and create a new worktree outside the main checkout.
3. Read the plan inside the worktree, inspect the affected code, and implement the requested changes there.
4. Run the smallest relevant validation first, then broader checks if the targeted checks pass.
5. Review the diff and commit with a plan-related message.
6. Save the PR markdown body to a file in the worktree.
7. Create the pull request from inside the worktree with `bash "$PR_SCRIPT" --base "$BASE_BRANCH" --title "$PR_TITLE" --body-file "$PR_FILE"`.
8. Include the PR URL and same markdown in the final response.
9. Remove the temporary worktree only after the PR URL is returned and the PR body has been preserved.

## Guardrails

- Never implement directly in the main checkout when isolation is requested or implied.
- Never assume the default branch. Use the exact `BASE_BRANCH`.
- Never delete the worktree before successful PR creation and a saved PR body.
- Avoid destructive cleanup commands such as `git clean -fdx` or `rm -rf` against the main repo.
- If PR creation fails, keep the worktree and report the exact path that still contains the branch state.

## Extra references

- See [examples](references/examples.md) for a concrete invocation pattern and PR output shape.
