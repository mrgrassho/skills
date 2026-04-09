---
name: repo-onboarding-map
description: Read an unfamiliar repository and produce a high-signal onboarding map covering entrypoints, commands, architecture, risky modules, and open questions. Use when a user wants fast orientation before making changes in a codebase.
---

# Repo Onboarding Map

## Use when

- The user is new to a repository and needs the important entrypoints quickly.
- A task requires architectural context before implementation.
- The repo needs a short, trustworthy orientation rather than a deep audit.

## Inputs

- Repository root
- Optional task context, subsystem name, or target feature area

## Workflow

1. Inventory the repo shape first: manifests, top-level directories, main services, and developer commands.
2. Identify the primary runtime entrypoints and follow the main request or data flow far enough to explain how the system hangs together.
3. Find the test layout, local development commands, and any repo-specific tooling that a new contributor must know.
4. Call out risky or high-leverage modules, such as migration code, auth boundaries, billing paths, or generated code.
5. Produce a concise onboarding map with concrete file references, commands, and open questions that still need human clarification.

## Guardrails

- Prefer actual repo evidence over generic framework guesses.
- Do not describe every directory. Focus on the parts a new contributor needs first.
- Separate confirmed architecture from inferred structure.
- If something important is missing, say what was searched and why the gap remains.

## Extra references

- See [examples](references/examples.md) for output structure and discovery prompts.
