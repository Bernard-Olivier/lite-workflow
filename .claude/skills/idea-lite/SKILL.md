---
name: idea-lite
description: Turn a rough feature idea into user stories with acceptance criteria. Interactive.
argument-hint: [slug]
arguments: slug
disable-model-invocation: true
allowed-tools: Read Grep Glob Write
---

# Idea to stories

Feature slug: `$slug`. If empty, ask for one before doing anything else.

## New or amend

Check whether `artifacts/features/$slug/story.md` exists.

- **It doesn't** — this is a new feature. Follow the steps below.
- **It does** — this is an amendment. Read it, then jump to [Amending an existing story](#amending-an-existing-story).

## Standing rules

- This is a conversation, not a generation task. Do not write any file until the user approves the stories.
- No story ships without acceptance criteria that can be checked by running something.
- Non-goals are part of the output, not a footnote.

## Steps

1. Ask clarifying questions in batches of 2-4, not one at a time. Cover: who uses this, what problem it solves, what is explicitly out of scope, what already exists that this touches.
2. Stop asking once the answers stop changing your understanding. Two rounds is usually enough.
3. Draft stories in the chat. Each one: a title, a user-facing description, and 2-5 acceptance criteria.
4. Ask the user to approve, cut, or split. Revise in the chat and re-present.
5. Only after explicit approval, write `artifacts/features/$slug/story.md` using the structure in [story-template.md](story-template.md).

## Amending an existing story

Read `story.md`, and read `plan.md` if it exists. Then:

1. Summarise the current stories back to the user in two or three lines, and ask what's changing.
2. Work out which existing stories the change touches. Say so explicitly before drafting.
3. **If `plan.md` has ticked tasks under an affected story, stop and report it.** List the completed tasks the change puts at risk and ask how to proceed. Do not edit `story.md` until the user answers.
4. Draft the revised stories in the chat and get approval, same as for a new feature.
5. On approval, rewrite `story.md`. Preserve untouched stories exactly as written, including their IDs. Never renumber a story that already exists — new stories get the next free ID.
6. Tell the user which stories changed and that `/plan-lite $slug` needs re-running for those.

Additions are cheap and changes are not. If the user's request is really a new story rather than an edit to an existing one, say so and append it instead.

## Splitting heuristic

If a story needs more than roughly five tasks to implement, or its criteria cover two unrelated behaviours, propose splitting it. Say why. Let the user decide.
