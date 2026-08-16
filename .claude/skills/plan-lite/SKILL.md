---
name: plan-lite
description: Research the codebase and create an implementation plan for the task.
argument-hint: [task id]
arguments: task_id
disable-model-invocation: true
---

# Task to plan

The task id: `$task_id`. If it is empty, ask for one before doing anything else.

Find the task directory by globbing `artifacts/lite-workflow/*/$task_id/`. Everything below reads and writes inside it:

```
artifacts/lite-workflow/{feature}/feature.md
artifacts/lite-workflow/{feature}/$task_id/task.md      <- the contract
artifacts/lite-workflow/{feature}/$task_id/research.md  <- you write it, step 2
artifacts/lite-workflow/{feature}/$task_id/plan.md      <- you write it, step 6
```

If the glob finds nothing, list the task ids that do exist and stop. If it finds no `task.md`, send the user to `/ideate-lite` and stop.

Read `task.md` and the feature's `feature.md` before anything else. **`task.md` is the contract**: the plan implements its requirements and nothing outside them.

## Standing rules

- This is a conversation, not a generation task. The user approves the sub-tasks in the chat; files get written in step 6, after that.
- Plan against what the codebase actually does, not what it ought to do. Every sub-task points at files research found.
- Planning reads source and writes artifacts. Source files stay untouched — implementing, scaffolding and the refactor you noticed on the way all belong to `/build-lite`.
- If a requirement in the contract cannot be built as written, say so and get an answer before planning around it.
- Keep the artifacts short — one line per field in the templates. `plan.md` is re-read at the top of every build iteration.

## New or amend

- **No `plan.md`** — a new plan. Follow the steps below.
- **`plan.md` exists** — an amendment. Read [`amending.md`](amending.md) and follow its steps in place of **Steps** below. **Standing rules** and **Sub-task sizing** still apply.

## Steps

1. **Research.** Invoke the `research-lite` skill with `$task_id`. It forks into an isolated agent and returns its report to this turn — the exploration spends its context rather than this session's, so let it do the reading. Ask the user nothing while it runs.
2. **Write `research.md`** from [research-template.md](research-template.md) as soon as research returns. Carry its paths, line numbers, commands and example references across verbatim — they are the useful part, and `/build-lite` runs the build and test commands exactly as written there. Strip the `//` comment lines; they are instructions to you, not content.
3. **Report the findings** in a few lines, and surface anything research flagged as blocked or unimplementable before proposing sub-tasks.
4. **Draft the sub-tasks in the chat.** For each: a title, what changes, the files it touches, and how to know it is done. Chat only at this stage.
5. **Refine with the user.** This is where implementation details get settled — approach, trade-offs, ordering, what to leave out. Ask in batches of 2-4 questions. Revise and re-present until they approve.
6. **Write `plan.md`** from [plan-template.md](plan-template.md), stripping the `//` comment lines. Every sub-task status starts as `Not started`.
7. **Update `task.md`** only if the session changed a major decision — a requirement, a boundary, something ruled out. Append it to **Notes** and leave the requirements as they stand: the contract records what the task must do, not how the plan does it. If the change alters what the task delivers, say so and send the user to `/ideate-lite`.
8. **Report** the sub-tasks in build order, then the next step: `/clear`, then `/build-lite $task_id`. Say the clear explicitly — the build reads `plan.md`, `task.md` and `research.md` from disk, so this session's context is spent.

## Sub-task sizing

One sub-task is one commit's worth of work. Each must be:

- A single coherent change, not a grab-bag.
- Scoped to a named set of files, listed against it.
- Verifiable — the acceptance criteria say what to run or observe, not "it works".
- Ordered so the build is green after each one. A sub-task that leaves the tree broken belongs merged into the next.

Number sub-tasks sequentially from 1 in build order. `/build-lite` and the user both refer to them by number, so a number, once issued, is permanent: new sub-tasks take the next free number, and a gap is fine.

Split anything that needs two unrelated changes to satisfy its own criteria.
