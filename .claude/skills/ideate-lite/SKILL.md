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

Glob `artifacts/lite-workflow/*/task.md` and read the titles and descriptions. If the idea changes tasks that already exist this is an **amendment** — read those `task.md` files in full. The steps are the same; each says what changes. If it is unclear which this is, ask.

## Standing rules

- This is a conversation: the breakdown gets agreed in the chat, then written to disk in step 5.
- Ask questions in batches of 2-4.
- Requirements describe observable behaviour. File paths, libraries and design decisions belong to `/plan-lite`.

## Steps

1. **Understand the idea.** Ask what it is for, who uses it, what it must do, and what is out of scope. Read enough of the codebase to ask sharper questions — surveying it is `/plan-lite`'s job. Keep asking until you can state each task's observable outcome and its scope boundary without guessing; two rounds is usually enough.
   Amendment: summarise the tasks it touches and what the changes will be first.
2. **Draft the breakdown in the chat.** Per task: a title, a one-line description, its requirements, and any task it depends on. See [Task sizing](#task-sizing).
   Amendment: draft only the tasks that change and name the ones you are leaving alone. If the request is really a new task rather than an edit to an existing one, say so and add it instead — additions are cheap, changes to work already done are not.
3. **Get approval.** Revise and re-present until they approve. Their approval is the only thing that ends this step.
4. **Allocate ids.** See [Task ids](#task-ids).
5. **Write the artifacts.** One `{task id}/task.md` per task from [task-template.md](task-template.md). Strip the `//` comment lines. Every task starts at **Status** `Not started`;
   Amendment: size the rewrite to the change — a small one appends to the notes section and leaves the rest alone, a large one rewrites the task.
6. **Report** the tasks in build order, then the next step: `/clear`, then `/plan-lite {task id}`. Say the clear explicitly — planning starts from the artifacts on disk.
   Amendment: say which tasks changed; any of them already planned need `/plan-lite` re-running.

## Task ids

A task id is two lowercase letters plus a two-digit number: `aa-00`, `aa-05`.

The two letters are the **session code** — one code for everything this session produces, derived from the idea, e.g. `add-auth` becomes `aa`. Glob `artifacts/lite-workflow/*/` for the codes in use and pick an unused one. An amendment keeps the code it is amending, and its new tasks take the next free numbers under it.

Number tasks from `00` in increments of 5, in build order — the gaps leave room to insert a task between two others later.

`/plan-lite`, `/build-lite` and the user all refer to tasks by id, so an id once issued is permanent: retired ids stay retired, existing tasks keep their number, and a gap is fine.

## Task sizing

One task is one PR's worth of work, a vertical slice: a complete, testable piece of functionality. A task is the wrong size when it:

- Delivers nothing observable on its own — merge it into the task it serves.
- Covers two unrelated behaviours, or reads as more than roughly five commits — propose a split, and say why.
- Is needed by two other tasks — promote it to a setup task at the top of the order rather than duplicating it.

Order tasks so each one builds on what is already merged. Record real ordering constraints in **Dependencies**; leave it empty when there are none rather than inventing them.

Sizing changes are proposals; the user decides.
