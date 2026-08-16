---
name: ideate-lite
description: Turn a rough feature idea into trackable tasks with requirements. Interactive.
argument-hint: [idea]
disable-model-invocation: true
---

# Idea to tasks

The idea: `$ARGUMENTS`. If it is empty, ask for one before doing anything else.

Artifacts live under `artifacts/lite-workflow/{feature}/`, with a directory per task inside it:

```
artifacts/lite-workflow/{feature}/feature.md
artifacts/lite-workflow/{feature}/{task id}/task.md
```

## New or amend

Glob `artifacts/lite-workflow/*/feature.md` and read the titles.

- **The idea is not one of them** — a new feature. Follow the steps below.
- **The idea matches one** — an amendment. Read that `feature.md` and every `task.md` under it, then jump to [Amending an existing feature](#amending-an-existing-feature).

If it is unclear which, ask.

## Standing rules

- This is a conversation, not a generation task. Write no files until the user approves the breakdown.
- Ask questions in batches of 2-4.
- Requirements describe behaviour, not implementation. File paths, libraries and design decisions belong to `/plan-lite`.
- Out of scope is part of the output, not a footnote. If the user rules something out, record it.
- Keep the artifacts short — one line per bullet. They are read at the start of every later session.

## Steps

1. **Understand the idea.** Ask what the feature is for, who uses it, what it must do, and what is explicitly out of scope. Read enough of the codebase to ask sharper questions — surveying it is `/plan-lite`'s job. Stop once the answers stop changing your understanding; two rounds is usually enough.
2. **Draft the breakdown in the chat.** The feature's goals and non-goals first, then the tasks: for each, a title, a one-line description, its requirements, and any task it depends on.
3. **Get approval.** Revise in the chat and re-present until they approve.
4. **Allocate ids.** See [Ids](#ids).
5. **Write the artifacts.** `feature.md` from [feature-template.md](feature-template.md), and one `{task id}/task.md` per task from [task-template.md](task-template.md). Strip the `//` comment lines. Every status starts as `Not started`.
6. **Report** the feature id and the tasks in build order, then the next step: `/clear`, then `/plan-lite {task id}`. Say the clear explicitly — planning starts from the artifacts on disk.

## Ids

Feature ids are two lowercase letters, task ids are the feature id plus a two-digit number: `aa`, then `aa-00`, `aa-05`.

Glob `artifacts/lite-workflow/*/` for the ids already in use and create a new unused one from the feature name, e.g. `add-auth` becomes `aa`. Number tasks from `00` in increments of 5, in build order — the gaps leave room to insert a task between two others later.

`/plan-lite`, `/build-lite` and the user all refer to tasks by id, so an id once issued is permanent: retired ids stay retired, existing tasks keep their number, and a gap is fine.

## Task sizing

One task is one PR's worth of work. A task is the wrong size when it:

- Delivers nothing observable on its own — merge it into the task it serves.
- Covers two unrelated behaviours, or reads as more than roughly five commits — propose a split, and say why.
- Is needed by two other tasks — promote it to a setup task at the top of the order rather than duplicating it.

Tasks are vertical slices, not horizontal layers: each a complete, testable piece of functionality.

Order tasks so each one builds on what is already merged. Record real ordering constraints in **Dependencies**; leave it empty when there are none rather than inventing them.

Sizing changes are proposals; the user decides.

## Amending an existing feature

`feature.md` and the `task.md` files carry status and decisions written by later sessions — merge into them rather than regenerating them.

1. Summarise the feature and its tasks back to the user in a few lines, with each task's status, and ask what is changing.
2. Work out which tasks the change touches and say so explicitly before drafting anything.
3. **Flag the sunk work** — every affected task that is `In progress` or `Done`. Name what the change costs each one and let the user decide before editing anything. A `Done` task is never edited; its correction is a new task.
4. Draft the revised tasks in the chat and get approval, same as for a new feature.
5. On approval, write the changes: edit the tasks that changed, add new ones with the next free ids, and append the decision to the relevant **Notes**. Leave untouched tasks exactly as they are, statuses included.
6. Delete a task's directory only when the user asks for it. Otherwise mark it out of scope in `feature.md` and say why.
7. Report which tasks changed, and that any of them already planned need `/clear`, then `/plan-lite {task id}` re-running.

If the request is really a new task rather than an edit to an existing one, say so and append it instead. Additions are cheap; changes to work already done are not.
