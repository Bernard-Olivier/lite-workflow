# Feature workflow skills

A lite, 3-step AI workflow that takes a feature from a rough idea to reviewed, staged code, with the artifacts on
disk as the only state.

It ships four Claude Code skills. `ideate-lite`, `plan-lite` and `build-lite` are the three steps below.
`research-lite` is never invoked directly; `plan-lite` spawns it as an isolated sub-agent.

## Workflow

| Step | Skill                            | Output                                  | Uses                                                   |
| ---- | -------------------------------- | --------------------------------------- | ------------------------------------------------------ |
| 1    | `/ideate-lite <idea>`            | `feature.md` + multiple `task.md` files | `feature-template.md` & `task-template.md`             |
| 2    | `/plan-lite <task-id>`           | `research.md` + `plan.md`               | `research-template.md`, `plan-template.md` & `task.md` |
| 3    | `/build-lite <task-id> [--auto]` | staged code changes                     | `plan.md` & `task.md`                                  |

The agent never commits. It stages changes once they have been reviewed; committing and raising the PR is yours.

### Artifacts

```
artifacts
  /lite-workflow
    /{feature}
      feature.md
      /{task}
        task.md
        research.md
        plan.md
```

Task ids are globally unique identifiers (e.g. feature letters `aa`, then task number `00` together make `aa-00`), 
so `/plan-lite` and `/build-lite` take a bare task id and find its directory by globbing `artifacts/lite-workflow/*/{task}/`.

Commit the artifacts alongside the code. They are the workflow's only state, so they need to survive an interrupted
session and travel with the branch. It is preferred to delete the feature/task directories when they are done.

### 1. Ideate

Invoke `/ideate-lite` with a feature idea. The agent works through the idea with you, refining the requirements and
breaking the feature into PR-sized tasks. It writes a `feature.md` and a `task.md` per task.

The session is about sharing context: what the feature is for, what it must do, and where the boundaries between
tasks fall.

### 2. Plan

Invoke `/plan-lite` with a task id. The agent first spawns `research-lite` as a sub-agent to explore the codebase,
so that exploration does not crowd out the planning session's context.

It then works with you to refine implementation details and break the task into commit-sized sub-tasks. It writes a
`research.md` and a `plan.md`, and updates `task.md` if the session changes any major decision.

Re-run with the same task id to amend the plan. The agent reports how stale `research.md` is, asks whether to reuse
it or run a fresh research pass, then amends `plan.md`.

### 3. Build

Invoke `/build-lite` with a task id. The agent iterates over the sub-tasks in `plan.md` until the task is complete.
One iteration covers one sub-task: implement, verify (build, unit tests, fix diagnostics), a sub-agent review, then
your review. When a sub-task passes all three, the agent marks it `Done` and stages its changes.

Once every sub-task is `Done`, the agent runs a review sub-agent across the whole task, and its findings start
another iteration. It then asks for your review, and your findings likewise start another iteration. The task is
marked `Done` when you approve.

`--auto` swaps the per-sub-task human review for a sub-agent review, so iterations run unattended. The final human
review still stands: nothing is staged during an iteration, and the whole task's changes are staged together once
you approve.

## General

If the task or plan needs changing, stop the build session and move to the session that owns that change. The agent
marks the current sub-task `Blocked` and records the reason against it, so the next session does not start blind.

Features, tasks and sub-tasks all share the same four statuses (`Not started`, `In progress`, `Blocked`, `Done`),
so sessions can be interrupted and finished later.
