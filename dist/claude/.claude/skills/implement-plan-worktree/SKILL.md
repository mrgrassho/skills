---
name: implement-plan-worktree
description: Implement a markdown plan in an isolated git worktree, validate the result, push the branch, clean up the temporary checkout, and return PR-ready markdown. Use when an agent needs to execute a plan safely without touching the main checkout.
---

# Implement Plan In Worktree

## Use when

- The user has already approved a plan and wants implementation.
- The repository may have other active agents or uncommitted work in the main checkout.
- The task needs a pushed branch and a PR-ready summary.

## Inputs

- `PLAN_FILE`: markdown plan to implement
- `BASE_BRANCH`: branch to start from
- `REPO_DIR`: repository root
- `REMOTE`: remote name, usually `origin`

## Workflow

1. Validate that the plan file exists, the repo is a git worktree, and the requested base branch exists locally or on the remote.
2. Fetch the remote, generate a timestamped branch name, and create a new worktree outside the main checkout.
3. Read the plan inside the worktree, inspect the affected code, and implement the requested changes there.
4. Run the smallest relevant validation first, then broader checks if the targeted checks pass.
5. Review the diff, commit with a plan-related message, and push the implementation branch.
6. Save a PR markdown draft to a file in the worktree, copy it to the clipboard if the environment supports that, and include the same markdown in the final response.
7. Remove the temporary worktree only after the branch push succeeds and the PR draft has been preserved.

## Guardrails

- Never implement directly in the main checkout when isolation is requested or implied.
- Never assume the default branch. Use the exact `BASE_BRANCH`.
- Never delete the worktree before a successful push and a saved PR draft.
- Avoid destructive cleanup commands such as `git clean -fdx` or `rm -rf` against the main repo.
- If push fails, keep the worktree and report the exact path that still contains the branch state.

## Extra references

- See [examples](references/examples.md) for a concrete invocation pattern and PR output shape.
