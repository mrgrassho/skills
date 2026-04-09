# Contributing

This repo is a small public library of cross-agent skills for Codex, Claude Code, and OpenCode. Favor polish over volume.

## Workflow

1. Copy `templates/skill/` to `drafts/<skill-name>/` or `skills/<skill-name>/`.
2. Rename the folder to lower-case hyphen-case.
3. Fill in `SKILL.md` with accurate trigger language, workflow steps, and guardrails.
4. Add at least one concrete example or helper artifact under `references/`, `scripts/`, or `assets/`.
5. Run `python3 scripts/export_skill_targets.py`.
6. Run `python3 scripts/validate_skills.py`.
7. Move the skill into `skills/` only when it is reusable without author-specific context.

## Published skill requirements

- The folder name matches the skill `name`.
- `SKILL.md` begins with YAML frontmatter containing `name` and `description`.
- The description clearly states when an agent should use the skill.
- The body is concise and procedural, not a long essay.
- The skill contains at least one supporting artifact outside `SKILL.md`.
- Any relative links from `SKILL.md` resolve correctly.
- Source skills in `skills/` stay within the shared frontmatter subset unless a tool-specific export path requires more.
- Generated platform bundles under `dist/` are not edited by hand.

## Review checklist

- Does the trigger language make it obvious when the skill should activate?
- Is the workflow specific enough to be reliable without overfitting to one repo?
- Are the guardrails strong enough to prevent easy mistakes?
- Does the example reflect a realistic user request?
- Would another engineer understand the skill without knowing this repo or the author?
