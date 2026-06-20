#!/bin/sh

set -eu

REPO_URL="${SKILLS_REPO_URL:-https://github.com/mrgrassho/skills.git}"
REF="${SKILLS_REF:-main}"

die() {
  echo "$1" >&2
  exit 1
}

command -v git >/dev/null 2>&1 || die "git is required to install skills"
command -v bash >/dev/null 2>&1 || die "bash is required to install skills"

if [ "$#" -eq 0 ]; then
  set -- all
fi

tmp_dir="$(mktemp -d 2>/dev/null || mktemp -d -t skills-install)"

cleanup() {
  rm -rf "$tmp_dir"
}

trap cleanup EXIT HUP INT TERM

git clone --depth 1 --branch "$REF" "$REPO_URL" "$tmp_dir/skills"
bash "$tmp_dir/skills/scripts/install_skill.sh" "$@"
