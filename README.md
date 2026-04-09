# Coding Agent Skills Library

Reusable skills for Codex, Claude Code, and OpenCode.

This repository is meant to be useful to people other than the author. It keeps published skills in a predictable structure, requires each skill to have a clear trigger and a bounded workflow, and backs every published skill with at least one concrete example or helper artifact.

## Install (Quick)

Clone the repo and install every published skill into every supported coding agent:

```bash
git clone https://github.com/mrgrassho/skills.git && cd skills && bash scripts/install_skill.sh all
```

Use the installer directly when you only want one target or one skill:

- Claude Code: `bash scripts/install_skill.sh claude`
- OpenCode: `bash scripts/install_skill.sh opencode`
- Codex: `bash scripts/install_skill.sh codex`
- All supported coding agents: `bash scripts/install_skill.sh all`
- Single published skill: `bash scripts/install_skill.sh codex implement-plan-worktree`
- Project-local destination: `bash scripts/install_skill.sh opencode --dest .opencode/skills`

The installer refreshes the Claude and OpenCode export bundles automatically before copying them into place. `skills/` remains the source of truth.

## Propose Changes

If you want to improve or publish skills instead of installing them:

1. Edit or add skills under `drafts/` or `skills/`.
2. Regenerate the exported bundles with `python3 scripts/export_skill_targets.py`.
3. Validate the published set with `python3 scripts/validate_skills.py`.
4. Open a pull request with the updated skill and generated `dist/` output.

See `CONTRIBUTING.md` for the review checklist and publishing rules.

## Compatibility model

Published skills use the common subset of the `SKILL.md` format shared by Claude Code and OpenCode:

- `name`
- `description`
- Markdown instructions in the body

To keep the source portable, `skills/` avoids tool-specific frontmatter unless it is added through a platform-specific export step.

## Published skills

- `implement-plan-worktree`: implement a plan in an isolated git worktree, validate it, push it, and return PR-ready output.

The other trial skills were removed from the published set. This repo currently keeps one polished workflow instead of a broader but weaker catalog.

## Repository layout

```text
skills/
  <skill-name>/
    SKILL.md
    references/      # Optional example or lookup material
    scripts/         # Optional helper scripts
    assets/          # Optional output assets
dist/
  claude/.claude/skills/     # Generated Claude Code install bundle
  opencode/.opencode/skills/ # Generated OpenCode install bundle
drafts/             # Unpublished or incomplete skill ideas
templates/skill/    # Canonical scaffold for new skills
scripts/            # Repo tooling, including validation and export
```

## Quality bar

Published skills in `skills/` must:

- use the shared skill structure supported by Claude Code and OpenCode
- include `name` and `description` frontmatter in `SKILL.md`
- describe when the skill should trigger
- provide a bounded workflow and guardrails
- include at least one example or helper artifact outside `SKILL.md`

Drafts and partial ideas belong in `drafts/` until they meet that bar.

## Contributing

Start from `templates/skill/`, keep the skill concise, and promote it to `skills/` only when it is example-backed and reusable.
