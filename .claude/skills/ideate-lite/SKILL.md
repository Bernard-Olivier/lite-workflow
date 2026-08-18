---
name: ideate-lite
description: Turn a rough idea into trackable tasks with requirements. Interactive.
argument-hint: [idea]
disable-model-invocation: true
---

# Idea to tasks

The idea: `$ARGUMENTS`. If it is empty, ask for one before doing anything else.

Artifacts live under `artifacts/lite-workflow/`, one directory per task:

```
artifacts/lite-workflow/{task id}/task.md
```

Glob `artifacts/lite-workflow/*/task.md` and read the titles and descriptions. If the idea changes tasks that already exist this is an amendment — read those `task.md` files in full. The steps are the same; each says what changes. If it is unclear which this is, ask.

## Standing rules

- This is a conversation, not a generation task. Write no files until the user approves the breakdown.
- Ask questions in batches of 2-4.
- Requirements describe behaviour, not implementation. File paths, libraries and design decisions belong to `/plan-lite`.

## Steps

1. **Understand the idea.** Ask what it is for, who uses it, what it must do, and what is explicitly out of scope. Read enough of the codebase to ask sharper questions — surveying it is `/plan-lite`'s job. Stop once the answers stop changing your understanding; two rounds is usually enough. For an amendment, summarise the tasks it touches first and what the changes will be.
2. **Draft the breakdown in the chat.** For each task: a title, a one-line description, its requirements, and any task it depends on.
   For an amendment, draft only the tasks that change and name the ones you are leaving alone. If the request is really a new task rather than an edit to an existing one, say so and add it instead — additions are cheap, changes to work already done are not.
3. **Get approval.** Revise in the chat and re-present until they approve.
4. **Allocate ids.** See [Ids](#ids).
5. **Write the artifacts.** One `{task id}/task.md` per task from [task-template.md](task-template.md). Strip the `//` comment lines.
   For an amendment, size the rewrite to the change: a small one appends to the notes section and leaves the rest of the file alone; a large one rewrites the task.
6. **Report** the tasks in build order, then the next step: `/clear`, then `/plan-lite {task id}`. Say the clear explicitly — planning starts from the artifacts on disk.
   For an amendment, say which tasks changed; any of them already planned need `/plan-lite` re-running.

## Task Ids

A task id is two lowercase letters plus a two-digit number: `aa-00`, `aa-05`.

The two letters are the **session code** — one code for everything this session produces, derived from the idea, e.g. `add-auth` becomes `aa`. Glob `artifacts/lite-workflow/*/` for the codes already in use and pick an unused one. An amendment keeps the code it is amending, and its new tasks take the next free numbers under it.

Number tasks from `00` in increments of 5, in build order — the gaps leave room to insert a task between two others later.

`/plan-lite`, `/build-lite` and the user all refer to tasks by id, so an id once issued is permanent: retired ids stay retired, existing tasks keep their number, and a gap is fine.

## Task sizing

One task is one PR's worth of work. A task is the wrong size when it:

- Delivers nothing observable on its own — merge it into the task it serves.
- Covers two unrelated behaviours, or reads as more than roughly five commits — propose a split, and say why.
- Is needed by two other tasks — promote it to a setup task at the top of the order rather than duplicating it.

Tasks are vertical slices, not horizontal layers: each a complete, testable piece of functionality.

Order tasks so each one builds on what is already merged. Record real ordering constraints in **Dependencies**; leave it empty when there are none rather than inventing them.

Sizing changes are proposals; the user decides.
