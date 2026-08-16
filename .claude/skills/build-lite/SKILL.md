---
name: build-lite
description: Implement tasks from a feature plan, ticking them off as they complete.
argument-hint: [task id] [--auto]
arguments: task_id mode
disable-model-invocation: true
---

# Plan to code

## Resolve arguments first

The arguments are `$task_id` then `$mode`.

- If `$task_id` is empty, ask for one and stop.
- If `$mode` is exactly `--auto`, the mode is **auto**. Otherwise it is **review**.

Find the task directory by globbing `artifacts/lite-workflow/*/$task_id/`. If the glob finds nothing, list the task ids that do exist and stop. If it finds no `plan.md`, tell the user to run `/plan-lite` first and stop.

Read `plan.md` and `task.md`, and `research.md` for the build and test commands. Read them from disk now rather than trusting anything seen earlier in the session — another session may have moved them on.

State the mode, the sub-task you are resuming at, and why, before making any change.

## Where to resume

- `Done` sub-tasks are finished. Skip them.
- A `Blocked` sub-task is why the last session stopped. Report its recorded reason and ask whether it is resolved. Wait.
- An `In progress` sub-task was interrupted. Check what is already in the working tree before redoing it.
- Otherwise start at the first sub-task that is not `Done`.

## Standing rules

- **Never commit.** Staging is as far as this session goes — the commit and the PR are the user's.
- Never discard work — no `git reset`, `checkout --`, `clean` or `stash` over the user's tree.
- Build only what the current sub-task describes. Not the next one, not a refactor you noticed on the way.
- `task.md` is the contract and `plan.md` is the route. If the code wants to go somewhere neither describes, that is a stop condition, not a judgement call.
- Update `plan.md` as you go. It is the only state — a session that dies mid-sub-task must be resumable from the file alone.
- Match the surrounding code — `research.md` lists the patterns to follow.

## The iteration

One iteration covers one sub-task. Work them in plan order.

1. **Mark it `In progress`** in `plan.md` before touching any code.
2. **Implement** what its **TODO** describes, in the files it lists.
3. **Verify.** Run the build, run the unit tests for the touched area, and clear any diagnostics or lint the change introduced. Fix and re-run until clean. Then check the sub-task's **Acceptance criteria** are actually met — a green build is not the same as the criteria being satisfied. Keep the decisive lines of any failure rather than the whole log.
4. **Sub-agent review.** Spawn a sub-agent, point it at the sub-task and the requirements in `task.md`, and let it read the diff itself with `git diff` over the sub-task's files. Brief it to report: correctness bugs, anything that does not meet the acceptance criteria, anything outside the sub-task's scope, and departures from the codebase's existing patterns. It reports findings; it does not edit.
5. **Act on the findings.** Fix what is real, say plainly what you are rejecting and why. Re-verify after any fix. Repeat from step 3 until the review is clean.
6. **Human review** — in review mode only. Present the sub-task, a summary of the diff, and the verification result. Wait. Their findings restart the iteration at step 2. In auto mode this step is a second sub-agent review instead; see [Modes](#modes).
7. **Close it out.** Mark the sub-task `Done` in `plan.md`, and in review mode stage its files with `git add` on named paths — never `git add -A`. In auto mode, stage nothing yet.

A sub-task is `Done` only once it has passed all three of verify, sub-agent review and the review in step 6.

## When every sub-task is Done

1. **Whole-task review.** Spawn a review sub-agent to read the task's full diff itself and check it against `task.md` — every requirement met, nothing out of scope, no seams left between sub-tasks that were fine alone and wrong together.
2. **Its findings start another iteration.** If the changes are large enough then append them to `plan.md` as new sub-tasks with the next free numbers, then work them exactly as above. **`Done` is append-only** — a correction is a new sub-task, so the built history stays readable.
3. **Human review.** Present the whole task: what was built, the verification results, and anything the reviews raised that you rejected. Wait.
4. **Their findings likewise start another iteration** — same appending, same loop, back to step 1 when they are done.
5. **On approval**, stage the task's changes together — in auto mode this is the first staging of the run — including the updated artifacts, since they travel with the branch. Set `task.md`'s **Status** to `Done`, and update the feature's **Status** in `feature.md` if this was its last task.
6. **Report** what is staged, what is not, and that committing is theirs. If the feature has a task left, name it: `/clear`, then `/plan-lite {next task id}`.

## Modes

**review** — the default. Step 6 of each iteration is the user's. Their approval is what stages that sub-task's changes.

**auto** — step 6 is a second sub-agent review instead, briefed differently from the first: given `task.md` and the sub-task, does this change actually deliver what was asked, and would it survive review by someone who did not write it? Iterations run unattended.

Auto changes who reviews each sub-task, not what stops the run. Nothing is staged during an iteration, and the final human review still stands.

## Context hygiene

Sub-agents are the lever: what they read stays in their context, and only their conclusion comes back.

- Reviewers fetch their own diff and return findings, never the diff itself.
- Delegate exploration when a sub-task's files are unfamiliar or scattered — a sub-agent reports where the change goes, you make it. Implementation stays in this session; it is what the reviews and the user are judging.
- Read the files a sub-task lists, not the modules around them. `research.md` already has the surrounding context.
- Read `plan.md` and `task.md` once at the top, and again only after another session may have written to them.

If the session still gets long, `plan.md` holds the state. Say so, and let the user clear and re-run `/build-lite $task_id` — it resumes at the first sub-task that is not `Done`.

## Stopping

**Stop, mark the current sub-task `Blocked` with the reason recorded against it in `plan.md`, and end the turn if:**

- Verification fails in a way you cannot fix without changing what the sub-task set out to do.
- The sub-task is ambiguous enough that you would be guessing at intent.
- The work needs a file the sub-task does not list, and it is not a mechanical consequence such as updating a caller's import. Record the file and why.
- The requirements in `task.md` or the route in `plan.md` turn out to be wrong.

Say which condition tripped, what is done up to that point, what is in the working tree, and what would unblock it. The reason recorded in `plan.md` is what the next session reads, so write it for someone who was not here.

For a wrong plan, send the user to `/clear`, then `/plan-lite $task_id`; for wrong requirements, to `/clear`, then `/ideate-lite`. Fixing either from a build session puts the artifacts and the code out of step.

Do not push past a stop condition in either mode.
