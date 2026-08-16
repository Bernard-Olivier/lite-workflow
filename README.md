# Feature workflow skills

A lite, 3 step AI workflow that take a feature from a rough idea to committed code, with the artifacts on disk as the only state. 
Consists of 4 Claude Code skills; ideate-lite, plan-lite, research-lite & build-lite.

## Workflow

| step | skill                         | Output                                      |
| ---- | ----------------------------- | ------------------------------------------- |
| 1    | `/ideate-lite <idea>`         | multiple `task.md` files grouped by feature |
| 2.   | `/plan-lite <task>`           | `research.md` + `plan.md`                   |
| 3.   | `/build-lite <task> <--auto>` | code                                        |

### Artifacts

```
artifacts
  /features
    /{feature}
      feature.md
      /{taskid}
        task.md
        research.md
        plan.md
```

### 1. Ideate

We start the workflow by invoking `/build-plan` with a feature idea as an argument. Ideate turns a rough idea into
multiple trackable tasks. The session is about sharing context with the AI agent, refining requirements and
breaking the feature into tasks. A `feature.md` and multiple `task.md` files will be created.

### 2. Plan

Invoke `/build-plan` with the task id as an argument. Plan will research the codebase and create an 
implementation plan for the task. The implementation task consists of multiple sub-tasks. The session is about helping the AI 
agent understand the existing codebase, refining implementation details and breaking the task up into smaller pieces of work.
A `research.md` and `plan.md` will be created. 

If any major decisions or changes are made during the session, then the `story.md` file will be updated.
You can amend the plan by re-running the session with the same task id.

### 3. Build

Invoke `/build-lite` with the task id as an argument. Build will iterate over the sub-tasks within `plan.md` until the task is
complete. An iteration consists of an implementation, verification (build, run unit tests, fix diagnostics), review and human 
review of the sub-task. Once the sub-task is verified (passes verification, and both reviews) as completed then it will be 
marked as completed. 

Once all tasks are complete, the ai agent will spawn a review sub-agent and those finding will start another iteration. 
Lastly a human review will be requested, any finding will start another iteration, the task will be marked completed when
the human review has approved. The skill supports an Auto mode that swaps the human review with a sub-agent review during
an iteration. If changes to the story or plan are needed then we stop the build session and transition to the necessary session.
Sub-tasks have a status and so sessions can be interrupted and finished later.