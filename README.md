# Codex Skills Library

Curated, reusable Codex-compatible skills focused on developer productivity.

This repository is meant to be useful to people other than the author. It keeps published skills in a predictable structure, requires each skill to have a clear trigger and a bounded workflow, and backs every published skill with at least one concrete example or helper artifact.

## Quick start

1. Pick a skill from `skills/`.
2. Copy that skill directory into your local Codex skills directory, typically `~/.codex/skills/`.
3. Keep the folder name and `SKILL.md` together so Codex can discover the skill correctly.
4. Run `python3 scripts/validate_skills.py` before publishing changes back to this repo.

## Published skills

- `implement-plan-worktree`: implement a plan in an isolated git worktree, validate it, push it, and return PR-ready output.
- `code-review-findings`: review a diff and report bugs, regressions, and missing tests with findings first.
- `bug-repro-minimal-test`: reproduce a bug and reduce it to the smallest failing automated test before fixing it.
- `release-notes-from-diff`: turn diffs, commits, or merged PRs into user-facing release notes.
- `repo-onboarding-map`: read an unfamiliar codebase and produce a high-signal onboarding map.

## Repository layout

```text
skills/
  <skill-name>/
    SKILL.md
    references/      # Optional example or lookup material
    scripts/         # Optional helper scripts
    assets/          # Optional output assets
drafts/             # Unpublished or incomplete skill ideas
templates/skill/    # Canonical scaffold for new skills
scripts/            # Repo tooling, including skill validation
```

## Quality bar

Published skills in `skills/` must:

- use the standard Codex skill structure
- include `name` and `description` frontmatter in `SKILL.md`
- describe when the skill should trigger
- provide a bounded workflow and guardrails
- include at least one example or helper artifact outside `SKILL.md`

Drafts and partial ideas belong in `drafts/` until they meet that bar.

## Contributing

Start from `templates/skill/`, keep the skill concise, and promote it to `skills/` only when it is example-backed and reusable. See `CONTRIBUTING.md` for the review checklist and publishing rules.
