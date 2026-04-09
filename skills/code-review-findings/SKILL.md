---
name: code-review-findings
description: Review a diff, pull request, or recent change set and return findings prioritized by severity, focusing on bugs, regressions, risky assumptions, and missing tests rather than style. Use when a user asks for a review or wants release-blocking issues called out.
---

# Code Review Findings

## Use when

- The user asks for a code review.
- The user wants a risk assessment of a diff, branch, or pull request.
- The user needs findings that are actionable, not a style pass.

## Inputs

- The diff, branch, pull request, or commit range to review
- Any relevant test output, issue context, or acceptance criteria

## Workflow

1. Read the changed code and enough surrounding context to understand the behavior being modified.
2. Trace the highest-risk paths first: correctness, data loss, authorization, race conditions, performance cliffs, and broken UX flows.
3. Compare the behavior change against test coverage and note where the diff expands behavior without a matching test.
4. Write findings first, ordered by severity, with a file reference, the concrete problem, and why it matters.
5. Add open questions or residual risks only after the findings section.
6. If no findings remain, say that explicitly and mention any testing gaps or areas not reviewed deeply.

## Guardrails

- Do not bury important issues under a summary.
- Do not spend the review on formatting or naming unless they create a real defect risk.
- Do not claim a bug without tying it to a concrete execution path or missing safeguard.
- Distinguish confirmed issues from assumptions and open questions.

## Extra references

- See [examples](references/examples.md) for realistic finding shapes and wording.
