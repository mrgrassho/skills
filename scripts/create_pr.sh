#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bash scripts/create_pr.sh [--base BRANCH] [--title TITLE] [--body BODY] [--body-file FILE] [--draft] [--web]

Push the current branch and create a GitHub pull request with gh.

Options:
  --base BRANCH  Base branch for the pull request. Defaults to main.
  --title TITLE  Pull request title. Defaults to gh --fill.
  --body BODY    Pull request body. Defaults to gh --fill.
  --body-file FILE
                 Read the pull request body from a file.
  --draft        Create the pull request as a draft.
  --web          Open the pull request form in the browser.
  -h, --help     Show this help.
EOF
}

die() {
  echo "$1" >&2
  exit 1
}

base_branch="main"
title=""
body=""
body_file=""
draft="false"
web="false"

while (($# > 0)); do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --base)
      shift
      (($# > 0)) || die "--base requires a branch name"
      base_branch="$1"
      ;;
    --title)
      shift
      (($# > 0)) || die "--title requires text"
      title="$1"
      ;;
    --body)
      shift
      (($# > 0)) || die "--body requires text"
      body="$1"
      ;;
    --body-file)
      shift
      (($# > 0)) || die "--body-file requires a path"
      body_file="$1"
      ;;
    --draft)
      draft="true"
      ;;
    --web)
      web="true"
      ;;
    -*)
      die "Unknown option: $1"
      ;;
    *)
      die "Unexpected argument: $1"
      ;;
  esac
  shift
done

command -v gh >/dev/null 2>&1 || die "GitHub CLI is not installed or not on PATH"
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "Not inside a git repository"

current_branch="$(git rev-parse --abbrev-ref HEAD)"
[[ -n "$current_branch" ]] || die "Detached HEAD is not supported"
[[ "$current_branch" != "$base_branch" ]] || die "Create a feature branch before opening a pull request"

if [[ -n "$body" && -n "$body_file" ]]; then
  die "Use either --body or --body-file, not both"
fi

if [[ -n "$body_file" && ! -f "$body_file" ]]; then
  die "Body file not found: $body_file"
fi

if ! git diff --quiet || ! git diff --cached --quiet; then
  die "Working tree has uncommitted changes. Commit or stash them before creating a pull request."
fi

git push -u origin "$current_branch"

args=(--base "$base_branch" --head "$current_branch" --fill)

if [[ -n "$title" ]]; then
  args+=(--title "$title")
fi

if [[ -n "$body" ]]; then
  args+=(--body "$body")
fi

if [[ -n "$body_file" ]]; then
  args+=(--body-file "$body_file")
fi

if [[ "$draft" == "true" ]]; then
  args+=(--draft)
fi

if [[ "$web" == "true" ]]; then
  args+=(--web)
fi

gh pr create "${args[@]}"
