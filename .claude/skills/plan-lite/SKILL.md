---
name: plan-lite
description: Research the codebase and create an implementation plan for the task.
argument-hint: [task id]
arguments: task_id
disable-model-invocation: true
---

# Task to plan

The task id: `$task_id`. If it is empty, ask for one before doing anything else.

The task directory is `artifacts/lite-workflow/$task_id/`. Everything below reads and writes inside it:

```
artifacts/lite-workflow/$task_id/task.md   <- the contract
artifacts/lite-workflow/$task_id/plan.md   <- you write it, step 4
```

If the directory does not exist, list the task ids that do exist and stop. If it holds no `task.md`, send the user to `/ideate-lite` and stop.

Read `task.md` before anything else, along with the `task.md` of any id under its **Dependencies**. **`task.md` is the contract**: the plan implements its requirements and nothing outside them.

If `plan.md` already exists this is an amendment. The steps are the same — each says what changes.

## Standing rules

- This is a conversation, not a generation task. The user approves the sub-tasks in the chat; `plan.md` gets written in step 4, after that.
- Plan against what the codebase actually does, not what it ought to do. Every sub-task points at files research found.
- If a requirement in the contract cannot be built as written, say so and get an answer before planning around it.

## Steps

1. **Research the codebase**, scoped to the task and nothing wider. Delegate the reading to a sub-agent where it is more than a few files. Be specific over complete: a path and a line number beats a paragraph of description. Ask the user nothing while it runs. Establish:
   - **Relevant code paths** — the files, modules, tests and functions the task will change. Give paths.
   - **Current behaviors** — the context that matters for the current task. 
   - **Tests** — tests related to current behaviour that will need to be re-run for regression or updated, and the exact commands that build the project and run them. `/build-lite` runs both verbatim.
Report the findings in a few lines, highlight the **open questions** brought to light by the findings.
2. **Refine with the user.** This is where implementation details get settled — approach, trade-offs, ordering, what to leave out. Ask in batches of 2-4 questions. Revise and re-present until they approve.
3. **Summaries the plan** and ask for confirmation before continuing. If feedback is provided then go back to step 2.
4. **Write `plan.md`** from [plan-template.md](plan-template.md), stripping the `//` comment lines.
   For an amendment, size the rewrite to the change: a small one appends sub-tasks at the next free numbers and leaves the rest of the file alone; a large one rewrites the plan.
5. **Update `task.md`** only if the session changed a major decision — a requirement, a boundary, something ruled out. Append it to **Notes** and leave the requirements as they stand: the contract records what the task must do, not how the plan does it. If the change alters what the task delivers, say so and send the user to `/ideate-lite`.
6. **Next steps** `/clear`, then `/build-lite $task_id`.

## Sub-task sizing

One sub-task is one commit's worth of work. Each must be:

- A single coherent change, not a grab-bag.
- Scoped to a named set of files, listed against it.
- Verifiable — the acceptance criteria say what to run or observe, not "it works".
- Ordered so the build is green after each one. A sub-task that leaves the tree broken belongs merged into the next.

Number sub-tasks sequentially from 1 in build order. `/build-lite` and the user both refer to them by number, so a number, once issued, is permanent: new sub-tasks take the next free number, and a gap is fine.

Split anything that needs two unrelated changes to satisfy its own criteria.
