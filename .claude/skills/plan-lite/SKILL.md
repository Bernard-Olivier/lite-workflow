---
name: plan-lite
description: Research the codebase and create an implementation plan for the task.
argument-hint: [task id]
arguments: task id
---

# Task to plan

The task id: `$task id`. If it is empty, ask for one before doing anything else.

Find the task directory by globbing `artifacts/lite-workflow/*/{task id}/`. Everything below reads and writes inside it:

```
artifacts/lite-workflow/{feature-title}/feature.md
artifacts/lite-workflow/{feature-title}/{task id}/task.md
artifacts/lite-workflow/{feature-title}/{task id}/research.md
artifacts/lite-workflow/{feature-title}/{task id}/plan.md
```

If the glob finds nothing, list the task ids that do exist and stop. If it finds no `task.md`, tell the user to run `/ideate-lite` first and stop.

Read `task.md` and the feature's `feature.md` before anything else. `task.md` is the contract — the plan implements its requirements and nothing outside them.

## New or amend

- **No `plan.md`** — follow the steps below.
- **`plan.md` exists** — this is an amendment. Read it, then jump to [Amending an existing plan](#amending-an-existing-plan).

## Standing rules

- This is a conversation, not a generation task. Write no files until the user approves the sub-tasks.
- Plan against what the codebase actually does, not what it ought to do. Every sub-task points at files research found.
- Do not implement anything. No edits to source, no scaffolding, no "while I was in there". That is `/build-lite`'s job.
- If a requirement in `task.md` cannot be built as written, say so before planning around it. Do not quietly reinterpret it.
- Keep the artifacts short. `plan.md` is re-read at the top of every build iteration.

## Steps

1. **Research.** Spawn a sub-agent to run `research-lite` for this task id and wait for it to return. The point is isolation — the exploration spends the sub-agent's context, not this session's, so do not read the codebase yourself first. This runs unattended; ask the user nothing during it.
2. **Write `research.md`** from [research-template.md](research-template.md) as soon as the sub-agent returns. Preserve its file paths, line numbers and example references verbatim; they are the useful part. Strip the `//` comment lines from the template.
3. **Report the findings** in a few lines, and surface anything research flagged as blocked or unimplementable before proposing sub-tasks.
4. **Draft the sub-tasks in the chat.** For each: a title, what changes, the files it touches, and how to know it is done. Do not write `plan.md` yet.
5. **Refine with the user.** This is where implementation details get settled — approach, trade-offs, ordering, what to leave out. Ask in batches of 2-4 questions. Revise and re-present until they approve.
6. **Write `plan.md`** from [plan-template.md](plan-template.md). Every sub-task status starts as `Not started`.
7. **Update `task.md`** only if the session changed a major decision — a requirement, a boundary, something ruled out. Append it to **Notes**; do not rewrite the requirements to match the plan. If the change is big enough to alter what the task delivers, say so and send the user to `/ideate-lite`.
8. **Report** the sub-tasks in build order, then name the next step: `/clear`, then `/build-lite {task id}`. Say the clear explicitly — the build reads `plan.md`, `task.md` and `research.md` from disk, so nothing in this session is worth carrying over.

## Sub-task sizing

One sub-task is one commit's worth of work. Each must be:

- A single coherent change, not a grab-bag.
- Scoped to a named set of files, listed against it.
- Verifiable — the acceptance criteria say what to run or observe, not "it works".
- Ordered so the build is green after each one. A sub-task that leaves the tree broken belongs merged into the next.

Number sub-tasks sequentially from 1 in build order. Ids are referenced by `/build-lite` and in conversation, so never renumber an existing sub-task; new ones take the next free number and a gap is fine.

Split anything that needs two unrelated changes to satisfy its own criteria.

## Amending an existing plan

`plan.md` holds build progress. Losing a `Done` means work gets redone or silently skipped, so merge into the file; do not regenerate it.

1. **Report how stale `research.md` is.** See [Research staleness](#research-staleness). Ask whether to reuse it or run a fresh research pass, and wait for the answer — research is the slow part, and stale-but-relevant beats a needless rerun.
2. Read `plan.md` and note the status of every sub-task, plus any recorded `Blocked` reason. A blocked sub-task is usually why this session was started; address it first.
3. Work out the delta and present it in the chat as three lists — **keep**, **change or add**, **drop** — with each sub-task's status shown against it. Write nothing yet.
4. **Flag every `In progress` or `Done` sub-task that lands in "change" or "drop".** That is work already spent. Never edit a `Done` sub-task — add a new one for the correction instead, so the built history stays readable. Name what the change costs and let the user decide.
5. On approval, rewrite `plan.md`: carry existing sub-tasks across with their statuses and numbers intact, insert new ones with the next free numbers, and remove only what the user agreed to drop.
6. Append any major decision to `task.md`'s **Notes**, as in step 7 above.
7. Report what changed and which sub-tasks are now next, then the same next step: `/clear`, then `/build-lite {task id}`.

## Research staleness

Establish, and state plainly:

- When `research.md` was written — `git log -1 --format=%cr -- {path}`, or its modified time if it is uncommitted.
- How much has landed since — `git rev-list --count {sha}..HEAD` on the repo, and whether any of it touched the files listed under **Touch points**.
- Whether `task.md` has changed since `research.md` was written.

Recommend a fresh pass when `task.md` changed after `research.md`, or when commits since have touched its touch points. Otherwise recommend reuse. The user decides either way.
