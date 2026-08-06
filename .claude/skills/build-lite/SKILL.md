---
name: build-lite
description: Implement tasks from a feature plan, ticking them off as they complete.
argument-hint: [--auto] [slug]
arguments: mode slug
disable-model-invocation: true
allowed-tools: Read Edit Write Grep Glob Bash(git *) Skill(code-review *)
---

# Build from plan

## Resolve arguments first

- If `$mode` is exactly `--auto`, the mode is **auto** and the slug is `$slug`.
- Otherwise the mode is **review** and the slug is `$mode`.
- If the resolved slug is empty, ask which feature and stop.

Read `artifacts/features/<slug>/plan.md`. If it doesn't exist, tell the user to run `/plan-lite` first and stop.

Ticked tasks are already done — skip them and resume at the first unticked one. A plan may have been revised between runs, so read the current file rather than assuming it matches what you saw earlier in the session. Say which task you're resuming at before making any change.

## Standing rules — apply to every task, every turn

Work the unchecked tasks in file order. For each one: make the change, run the task's Verify command, then tick its checkbox in `plan.md`. Never tick a box whose verification didn't pass.

Stay inside the task's listed files. If the change genuinely requires touching a file the task doesn't list, that's a stop condition, not a judgement call.

**Stop immediately and end the turn if:**

- A Verify command fails and the fix isn't obvious in one attempt
- The task is ambiguous enough that you'd be guessing at intent
- The work would touch files outside the task's listed set

State which condition tripped, what you did up to that point, and what you'd need to continue. Do not proceed past a stop condition in either mode.

## After a story finishes

When ticking a task completes every task under a story, invoke `/code-review` for that story's changes before reporting. Fold its findings into the end-of-turn report. A review finding is information, not a stop condition — surface it and keep going unless it independently meets one of the stop conditions above.

## Mode: review

After each task, end the turn with: the task name, a summary of the diff, and the verification result. Wait for the user before the next task.

## Mode: auto

Continue through tasks without stopping for approval. End the turn when the current story's tasks are all ticked, and report every task completed plus the state of that story's acceptance criteria in `story.md`.

Auto mode changes when you report, not what stops you. The stop conditions above still apply.
