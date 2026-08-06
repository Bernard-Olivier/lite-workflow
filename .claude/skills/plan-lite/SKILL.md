---
name: plan-lite
description: Research the codebase and turn approved stories into an implementation plan.
argument-hint: [slug]
arguments: slug
disable-model-invocation: true
allowed-tools: Read Grep Glob Write Skill(research *)
---

# Story to implementation plan

Feature slug: `$slug`. Requires `artifacts/features/$slug/story.md` to exist; if it doesn't, tell the user to run `/idea-lite` first and stop.

## New or replan

Check whether `artifacts/features/$slug/plan.md` exists.

- **It doesn't** — follow the steps below.
- **It does** — this is a replan. Jump to [Replanning](#replanning).

## Steps

1. Invoke `/research $slug` and wait for it to return. This runs unattended — do not ask the user anything during it.
2. Write its findings to `artifacts/features/$slug/research.md`. Preserve the file paths and examples verbatim; they're the useful part.
3. Generate a task list and present it in the chat. Do not write `plan.md` yet.
4. Ask the user to approve, reorder, or cut tasks. Revise and re-present.
5. On approval, write `artifacts/features/$slug/plan.md` using [plan-template.md](plan-template.md).

## Replanning

The existing `plan.md` holds progress state. Losing a tick means work gets redone or silently skipped, so treat the file as data to merge into, not a draft to overwrite.

1. Read `plan.md` and note which tasks are ticked.
2. Re-run research only if `story.md` changed since `research.md` was written, or the user asks for it. Otherwise reuse the existing `research.md` — research is the slow part and stale-but-relevant beats a needless rerun.
3. Work out the delta against the current stories: which tasks are unaffected, which need changing, which are new, which are now obsolete.
4. Present the delta in the chat as three lists — **keep**, **change or add**, **drop** — with the ticked state shown against each. Do not write anything yet.
5. **Flag every ticked task that lands in "change" or "drop".** That's completed work being invalidated. Name it and let the user decide; never quietly drop a ticked task.
6. On approval, rewrite `plan.md`: carry ticked tasks across with their ticks intact and their IDs unchanged, insert new tasks with the next free IDs, and remove dropped ones.

Task IDs are referenced in commits and conversation. Reusing a retired ID for a different task is worse than leaving a gap.

## Task sizing rules

Each task must be:

- One commit's worth of work
- Scoped to a named set of files, listed in the task
- Verifiable by a specific command, named in the task

Group tasks under the story they serve. If a task serves two stories, it belongs to neither — split it or promote it to a setup task at the top.

If research flagged a story as blocked, surface that before presenting tasks. Do not plan around it silently.
