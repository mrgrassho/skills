---
name: bug-repro-minimal-test
description: Reproduce a reported bug, reduce it to the smallest failing automated test, and use that test to verify a fix. Use when debugging a regression or flaky behavior and you want proof before changing production code.
---

# Bug Repro Minimal Test

## Use when

- The user reports a bug and wants a reliable reproduction.
- A fix should be driven by a failing automated test instead of guesswork.
- The current failure is broad, flaky, or buried in a larger scenario.

## Inputs

- Bug report, failing behavior, or symptom
- Repository and test framework context
- Any relevant logs, stack traces, or user steps

## Workflow

1. Restate the bug as a specific observable failure and identify the narrowest public interface that exhibits it.
2. Search existing tests for adjacent coverage before writing anything new.
3. Reproduce the failure locally with the smallest command that still demonstrates the bug.
4. Convert the reproduction into the smallest failing automated test that proves the wrong behavior.
5. Confirm the test fails for the intended reason rather than setup noise.
6. Implement the fix only after the failing test is stable, then rerun the targeted test and the nearest broader suite.
7. Report the bug cause, the new regression test, and any remaining risk.

## Guardrails

- Do not start with a fix when the bug is not yet reproduced.
- Avoid broad end-to-end tests when a unit or integration test can prove the same behavior.
- Do not keep incidental setup in the final test if it is not required to trigger the bug.
- If the bug cannot be reproduced, say exactly what was tried and what evidence is still missing.

## Extra references

- See [examples](references/examples.md) for reduction patterns and reporting shape.
