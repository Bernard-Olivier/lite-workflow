---
name: ideate-lite
description: Turn a rough feature idea into trackable tasks with requirements. Interactive.
argument-hint: [idea]
arguments: idea
---

# Idea to tasks

The idea: `$idea`. If it is empty, ask for one before doing anything else.

Artifacts live under `artifacts/lite-workflow/{feature}/`, with a directory per task inside it:

```
// each feature is assigned a title e.g. add-authorisation
artifacts/lite-workflow/{feature-title}/feature.md
// each feature is assigned a 2 letter code. e.g. aa
artifacts/lite-workflow/{feature-title}/aa-00/task.md
```

## New or amend

Glob `artifacts/lite-workflow/*/feature.md` and read the titles.

- **The idea is not one of them** — this is a new feature. Follow the steps below.
- **The idea matches one** — this is an amendment. Read that `feature.md` and every `task.md` under it, then jump to [Amending an existing feature](#amending-an-existing-feature).

If it is unclear which, ask. Do not guess.

## Standing rules

- This is a conversation, not a generation task. Write no files until the user approves the breakdown.
- Ask questions in batches of 2-4, not one at a time.
- Requirements describe behaviour, not implementation. File paths, libraries and design decisions belong to `/plan-lite`.
- Out of scope is part of the output, not a footnote. If the user rules something out, record it.
- Keep the artifacts short. They are read at the start of every later session, so every line has to earn its place.

## Steps

1. **Understand the idea.** Ask what the feature is for, who uses it, what it must do, and what is explicitly out of scope. Read enough of the codebase to ask sharper questions — do not survey it, that is `/plan-lite`'s job.
2. **Stop asking** once the answers stop changing your understanding. Two rounds is usually enough.
3. **Draft the breakdown in the chat.** The feature's goals and non-goals first, then the tasks: for each, a title, a one-line description, its requirements, and any task it depends on. Do not write files yet.
4. **Get approval.** The user approves, cuts, splits, merges or reorders. Revise in the chat and re-present. Repeat until they approve.
5. **Allocate ids.** See [Ids](#ids).
6. **Write the artifacts.** `feature.md` from [feature-template.md](feature-template.md), and one `{task}/task.md` per task from [task-template.md](task-template.md). Strip the `//` comment lines from the templates; they are instructions to you, not content. Every status starts as `Not started`.
7. **Report** the feature id and the tasks in build order, then name the next step: `/clear`, then `/plan-lite {task id}`. Say the clear explicitly — planning starts from the artifacts, so nothing in this session is worth carrying over.

## Ids

Feature ids are two lowercase letters, task ids are the feature id plus a two-digit number: `aa`, then `aa-00`, `aa-01`.

Glob `artifacts/lite-workflow/*/` for the ids already in use and create a new unused one from the feature name, e.g. `add-auth` becomes `aa`. Number tasks from `00` in increments of 5 (helps with latter additions, between tasks), in build order.

Ids are referenced in conversation and by `/plan-lite` and `/build-lite`. Never reuse a retired id for a different task, and never renumber a task that already exists. A gap in the sequence is fine.

## Task sizing

One task is one PR's worth of work. A task is the wrong size when it:

- Delivers nothing observable on its own — merge it into the task it serves.
- Covers two unrelated behaviours, or reads as more than roughly five commits — propose a split, and say why.
- Is needed by two other tasks — promote it to a setup task at the top of the order rather than duplicating it.

Tasks should be a vertical slices rather than horizontal. They should each be a small, complete piece of functionality and be testable.

Order tasks so each one builds on what is already merged. Record real ordering constraints in **Dependencies**; leave it empty when there are none rather than inventing them.

Propose the split, name the reason, and let the user decide. Do not resize a task unilaterally.

## Amending an existing feature

`feature.md` and the `task.md` files carry status, and later sessions have written decisions into their **Notes**. Merge into them; do not regenerate them.

1. Summarise the feature and its tasks back to the user in a few lines, with each task's status, and ask what is changing.
2. Work out which tasks the change touches and say so explicitly before drafting anything.
3. **Flag every affected task that is `In progress` or `Done`.** That is work already spent. Name each one and what the change costs it, then let the user decide. Do not edit tasks marked as `Done`, create a new task instead. Do not edit anything until they answer. 
4. Draft the revised tasks in the chat and get approval, same as for a new feature.
5. On approval, write the changes: edit the tasks that changed, add new ones with the next free ids, and append the decision to the relevant **Notes**. Leave untouched tasks exactly as they are, statuses included.
6. Delete a task's directory only when the user asks for it. Otherwise mark it out of scope in `feature.md` and say why.
7. Report which tasks changed, and that any of them already planned need `/clear`, then `/plan-lite {task id}` re-running.

If the request is really a new task rather than an edit to an existing one, say so and append it instead. Additions are cheap; changes to work already done are not.
