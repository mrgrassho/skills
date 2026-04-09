#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_ROOT="$ROOT/skills"
CLAUDE_EXPORT_ROOT="$ROOT/dist/claude/.claude/skills"
OPENCODE_EXPORT_ROOT="$ROOT/dist/opencode/.opencode/skills"
XDG_CONFIG_HOME_DEFAULT="${XDG_CONFIG_HOME:-$HOME/.config}"
CODEX_HOME_DEFAULT="${CODEX_HOME:-$HOME/.codex}"

usage() {
  cat <<'EOF'
Usage: bash scripts/install_skill.sh <tool> [skill-name ...] [--dest PATH] [--dry-run]

Tools:
  claude
  opencode
  codex
  all

Examples:
  bash scripts/install_skill.sh all
  bash scripts/install_skill.sh claude
  bash scripts/install_skill.sh codex implement-plan-worktree
  bash scripts/install_skill.sh opencode --dest .opencode/skills
  bash scripts/install_skill.sh all --dry-run
EOF
}

die() {
  echo "$1" >&2
  exit 1
}

join_by_comma() {
  local first=1
  local item

  for item in "$@"; do
    if [[ $first -eq 1 ]]; then
      printf '%s' "$item"
      first=0
    else
      printf ', %s' "$item"
    fi
  done
}

expand_path() {
  local path="$1"

  case "$path" in
    "~")
      printf '%s\n' "$HOME"
      ;;
    "~/"*)
      printf '%s/%s\n' "$HOME" "${path#~/}"
      ;;
    *)
      printf '%s\n' "$path"
      ;;
  esac
}

list_skill_dirs() {
  [[ -d "$SOURCE_ROOT" ]] || die "skills/ directory not found"
  find "$SOURCE_ROOT" -mindepth 1 -maxdepth 1 -type d | LC_ALL=C sort
}

reset_directory() {
  local path="$1"
  rm -rf "$path"
  mkdir -p "$path"
}

export_target() {
  local target_root="$1"
  local skill_dir
  local skill_name

  reset_directory "$target_root"
  while IFS= read -r skill_dir; do
    [[ -n "$skill_dir" ]] || continue
    skill_name="$(basename "$skill_dir")"
    cp -R "$skill_dir" "$target_root/$skill_name"
  done < <(list_skill_dirs)
}

prepare_source_root() {
  local tool="$1"

  case "$tool" in
    codex)
      printf '%s\n' "$SOURCE_ROOT"
      ;;
    claude)
      export_target "$CLAUDE_EXPORT_ROOT"
      printf '%s\n' "$CLAUDE_EXPORT_ROOT"
      ;;
    opencode)
      export_target "$OPENCODE_EXPORT_ROOT"
      printf '%s\n' "$OPENCODE_EXPORT_ROOT"
      ;;
    *)
      die "Unknown tool: $tool"
      ;;
  esac
}

default_destination() {
  local tool="$1"

  case "$tool" in
    claude)
      printf '%s\n' "$HOME/.claude/skills"
      ;;
    opencode)
      printf '%s\n' "$XDG_CONFIG_HOME_DEFAULT/opencode/skills"
      ;;
    codex)
      printf '%s\n' "$CODEX_HOME_DEFAULT/skills"
      ;;
    *)
      die "Unknown tool: $tool"
      ;;
  esac
}

skill_exists() {
  local needle="$1"
  shift
  local item

  for item in "$@"; do
    if [[ "$item" == "$needle" ]]; then
      return 0
    fi
  done

  return 1
}

install_skill_dir() {
  local source_dir="$1"
  local destination_root="$2"
  local dry_run="$3"
  local target_dir="$destination_root/$(basename "$source_dir")"

  if [[ "$dry_run" == "true" ]]; then
    printf '%s\n' "$target_dir"
    return 0
  fi

  mkdir -p "$destination_root"
  rm -rf "$target_dir"
  cp -R "$source_dir" "$target_dir"
  printf '%s\n' "$target_dir"
}

dry_run="false"
dest=""
positionals=()

while (($# > 0)); do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --dry-run)
      dry_run="true"
      ;;
    --dest)
      shift
      (($# > 0)) || die "--dest requires a path"
      dest="$1"
      ;;
    -*)
      die "Unknown option: $1"
      ;;
    *)
      positionals+=("$1")
      ;;
  esac
  shift
done

((${#positionals[@]} > 0)) || {
  usage >&2
  exit 1
}

tool="${positionals[0]}"
requested_skills=("${positionals[@]:1}")

case "$tool" in
  all)
    tools=("claude" "codex" "opencode")
    ;;
  claude|codex|opencode)
    tools=("$tool")
    ;;
  *)
    die "Unknown tool: $tool"
    ;;
esac

if [[ "$tool" == "all" && -n "$dest" ]]; then
  die "--dest cannot be used with 'all'. Install each tool separately."
fi

available_skills=()
while IFS= read -r skill_dir; do
  [[ -n "$skill_dir" ]] || continue
  available_skills+=("$(basename "$skill_dir")")
done < <(list_skill_dirs)

((${#available_skills[@]} > 0)) || die "No published skills found."

selected_skills=()
missing_skills=()

if ((${#requested_skills[@]} == 0)); then
  selected_skills=("${available_skills[@]}")
else
  for skill_name in "${requested_skills[@]}"; do
    if skill_exists "$skill_name" "${available_skills[@]}"; then
      selected_skills+=("$skill_name")
    else
      missing_skills+=("$skill_name")
    fi
  done
fi

if ((${#missing_skills[@]} > 0)); then
  available_list="$(join_by_comma "${available_skills[@]}")"
  missing_list="$(join_by_comma "${missing_skills[@]}")"
  die "Unknown skill(s): $missing_list. Available skills: $available_list"
fi

for current_tool in "${tools[@]}"; do
  source_root="$(prepare_source_root "$current_tool")"
  destination_root="$(default_destination "$current_tool")"
  if [[ -n "$dest" ]]; then
    destination_root="$dest"
  fi
  destination_root="$(expand_path "$destination_root")"

  if [[ "$dry_run" == "true" ]]; then
    echo "Dry run for $current_tool:"
  else
    echo "Installing for $current_tool:"
  fi

  for skill_name in "${selected_skills[@]}"; do
    target_dir="$(install_skill_dir "$source_root/$skill_name" "$destination_root" "$dry_run")"
    echo "- $skill_name -> $target_dir"
  done

  if [[ "$dry_run" == "true" ]]; then
    echo "Would install ${#selected_skills[@]} skill(s) into $destination_root"
  else
    echo "Installed ${#selected_skills[@]} skill(s) into $destination_root"
  fi
done
