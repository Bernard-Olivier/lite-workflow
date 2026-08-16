# Feature workflow skills

A lite, 3 step AI workflow that takes a feature from a rough idea to reviewed, staged code, with the artifacts on disk as the only state.
Consists of 4 Claude Code skills; ideate-lite, plan-lite, research-lite & build-lite. The first three are the workflow
steps below; research-lite is not invoked directly, plan-lite spawns it as an isolated sub-agent.

## Workflow

| Step | Skill                            | Output                                  | Uses                                                   |
| ---- | -------------------------------- | --------------------------------------- | ------------------------------------------------------ |
| 1    | `/ideate-lite <idea>`            | `feature.md` + multiple `task.md` files | `feature-template.md` & `task-template.md`             |
| 2    | `/plan-lite <task-id>`           | `research.md` + `plan.md`               | `research-template.md`, `plan-template.md` & `task.md` |
| 3    | `/build-lite <task-id> [--auto]` | staged code changes                     | `plan.md` & `task.md`                                  |

The AI agent never commits. It stages changes once a human has reviewed them; committing and raising the pr is yours.

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

Task ids are globally unique slugs (e.g. `auth-refresh-token`), so `/plan-lite` and `/build-lite` take a bare task id
and find its directory by globbing `artifacts/lite-workflow/*/{task}/`.

Artifacts are committed alongside the code. They are the workflow's only state, so they need to survive an interrupted
session and travel with the branch.

### 1. Ideate

We start the workflow by invoking `/ideate-lite` with a feature idea as an argument. Ideate turns a rough idea into
multiple trackable tasks. The session is about sharing context with the AI agent, refining requirements and
breaking the feature into tasks (tasks are pr size). A `feature.md` and multiple `task.md` files will be created.

### 2. Plan

Invoke `/plan-lite` with the task id as an argument. Plan will research the codebase and create an
implementation plan for the task. The implementation plan consists of multiple sub-tasks (commit size). The session is about helping the AI
agent understand the existing codebase, refining implementation details and breaking the task up into smaller pieces of work.
The AI agent will spawn a sub-agent using the `/research-lite` skill to understand the codebase, so that exploring it
does not crowd out the planning session's context.
A `research.md` and `plan.md` will be created.

If any major decisions or changes are made during the session, then the `task.md` file will be updated.
You can amend the plan by re-running the session with the same task id. On a re-run the skill reports how stale
`research.md` is and asks whether to reuse it or run a fresh research pass, then amends `plan.md`.

### 3. Build

Invoke `/build-lite` with the task id as an argument. Build will iterate over the sub-tasks within `plan.md` until the task is
complete. An iteration consists of an implementation, verification (build, run unit tests, fix diagnostics), a sub-agent
review and a human review of the sub-task. Once the sub-task is verified (passes verification, and both reviews) then it
will be marked `Done` and its changes staged.

Once all sub-tasks are `Done`, the ai agent will spawn a review sub-agent and those finding will start another iteration.
Lastly a human review will be requested, any finding will start another iteration, the task will be marked `Done` when
the human review has approved. The skill supports an Auto mode (`--auto`) that swaps the per-sub-task human review with a
sub-agent review, so iterations run unattended. The final human review still stands: under `--auto` nothing is staged
during an iteration, and the whole task's changes are staged together once that final review has approved.

If changes to the task or plan are needed then we stop the build session and transition to the necessary session; the
current sub-task is marked `Blocked` with the reason recorded against it, so the next session does not start blind.
Sub-tasks have a status (`Not started`, `In progress`, `Blocked`, `Done`) and so sessions can be interrupted and
finished later. Features, tasks and sub-tasks all use these same four values.
