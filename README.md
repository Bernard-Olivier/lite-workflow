# Feature workflow skills

A lite, 3-step AI workflow that takes a feature from a rough idea to reviewed, staged code, with the artifacts on
disk as the only state — so any session can be interrupted and picked up later.

## Workflow

| Step | Command                          | Output                                                |
| ---- | -------------------------------- | ----------------------------------------------------- |
| 1    | `/ideate-lite <idea>`            | `feature.md` + a `task.md` per PR-sized task          |
| 2    | `/plan-lite <task id>`           | `research.md` + a `plan.md` of commit-sized sub-tasks |
| 3    | `/build-lite <task id> [--auto]` | staged code changes                                   |

`/clear` between steps. Each one starts from the artifacts on disk, and the skills say so when they hand off.

Steps 1 and 2 are conversations — you approve the breakdown before anything is written, and re-running either with
the same id amends what it produced. Step 3 iterates sub-task by sub-task until you approve the task; `--auto`
swaps the per-sub-task review for a sub-agent so it runs unattended, and the final review is still yours.

The agent never commits. It stages changes once they have been reviewed; committing and raising the PR is yours.

`research-lite` is a fourth skill, invoked only by `plan-lite` to explore the codebase in an isolated agent.

## Artifacts

```
artifacts/lite-workflow/{feature}/
  feature.md
  {task id}/
    task.md
    research.md
    plan.md
```

Task ids are globally unique — `aa` for the feature, `aa-00` for its first task — so steps 2 and 3 take a bare id.

Commit the artifacts alongside the code. They are the workflow's only state, so they need to survive an interrupted
session and travel with the branch. Delete a feature's directory once it is done.
