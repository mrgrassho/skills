---
name: release-notes-from-diff
description: Turn a git diff, commit range, or merged pull request list into concise user-facing release notes grouped by impact. Use when the user needs changelog text, shipment notes, or a polished summary of what changed.
---

# Release Notes From Diff

## Use when

- The user wants release notes, a changelog entry, or a shipment summary.
- The available input is a diff, commit list, or merged PR set rather than a prewritten summary.
- The output should emphasize user-visible changes instead of internal refactors.

## Inputs

- Commit range, branch diff, pull request list, or patch
- Optional issue tracker links or acceptance criteria
- Target audience if known, such as customers, internal teams, or release managers

## Workflow

1. Gather the source material and separate user-facing changes from internal maintenance work.
2. Group the meaningful changes by product area, workflow, or theme instead of by commit order.
3. Rewrite implementation detail into user impact: what changed, who benefits, and any important caveat.
4. Call out breaking changes, migration steps, or known follow-ups explicitly.
5. Keep the wording concise and factual, and exclude changes that cannot be justified from the source material.
6. If the evidence is incomplete, note the gap instead of inventing a feature description.

## Guardrails

- Do not list internal refactors as customer-facing improvements without proof.
- Do not mirror commit messages verbatim if they are too implementation-specific.
- Avoid bloated release notes; merge related changes into one clear item when possible.
- Preserve uncertainty when the diff does not prove whether a change is shipped or experimental.

## Extra references

- See [examples](references/examples.md) for grouping patterns and tone.
