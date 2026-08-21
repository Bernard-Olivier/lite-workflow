---
name: build-lite
description: Implement a task's plan sub-task by sub-task, ticking them off as they complete.
argument-hint: [task id] [--auto]
arguments: task_id mode
disable-model-invocation: true
---

# Plan to code

## Resolve arguments first

Arguments are `$task_id` then `$mode`.

- `$task_id` empty: ask for one and stop.
- `$mode` exactly `--auto`: **auto** — step 6 is skipped for sub-tasks, so they run unattended. It still runs on the whole-task iteration, the first the user sees of the run.
- Anything else: **review** — step 6 runs on every sub-task, so the user sees each one as it lands.

The task directory is `artifacts/lite-workflow/$task_id/`. If it does not exist, list the task ids that do exist and stop. If it holds no `plan.md`, send the user to `/plan-lite` and stop.

Read `plan.md` and `task.md` from disk rather than trusting anything seen earlier in the session — another session may have moved them on.

A run may be continuing an earlier session: an `In progress` sub-task was interrupted, so check the working tree before redoing that work. A sub-task left at `Review required` is already implemented and verified — resume it at step 6. Otherwise start at the first sub-task that is not `Done`.

State the mode, the sub-task you are starting or resuming at, and why, before making any change.

## Standing rules

- `task.md` is the contract and `plan.md` is the route.
- Update `plan.md` as you go. It is the only state — a session that dies mid-sub-task must be resumable from the file alone.

## The iteration

One iteration covers one sub-task, in plan order.

1. **Mark it `In progress`** in `plan.md` before touching any code.
2. **Implement** what its **TODO** describes, in the files it lists.
3. **Verify.** Run the build, run the tests for the touched area, and clear any diagnostics or lint the change introduced. Fix and re-run until clean. Then check the sub-task's **Acceptance criteria** are met — a green build is not the same as the criteria being satisfied.
4. **Sub-agent review.** Spawn a sub-agent, point it at the sub-task and the requirements in `task.md`, and have it read the diff itself with `git diff` over the sub-task's files. Brief it to report correctness bugs, acceptance criteria missed, scope creep, and departures from the codebase's existing patterns. It reports findings for you to act on in step 5.
5. **Act on the findings.** Fix what is real, say plainly what you reject and why, then re-verify.
6. **Human review.** Set the sub-task's **Status** to `Review required` in `plan.md`, then present the sub-task, a summary of the diff, the verification result, and anything the sub-agent raised that you rejected. Wait.
7. **Refine** — only if they had findings. Implement them, re-verify, run steps 4 and 5 again, then back to step 6. Their approval is the only thing that ends this loop.
8. **Close it out.** Once approved, change the sub-task's **Status** from `Review required` to `Done` in `plan.md`. In auto mode, where step 6 is skipped, go straight to `Done`.

## The whole-task iteration

Once every sub-task is `Done`, run one last iteration over the whole task. The code is already written, so start at step 4, and read the whole task's diff wherever a step says the sub-task's.

- Step 4 checks the task against `task.md` instead: every requirement met, nothing out of scope, and no seams left between sub-tasks that were fine alone and wrong together.
- Step 6 always runs, in both modes.
- Step 6 sets `task.md`'s **Status** to `Review required`; step 8 changes it to `Done` after approval, and reports: if a task under the same two-letter code is still not `Done`, name the next one — `/clear`, then `/plan-lite {next task id}`.
