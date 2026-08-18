---
name: build-lite
description: Implement a task's plan sub-task by sub-task, ticking them off as they complete.
argument-hint: [task id] [--auto]
arguments: task_id mode
disable-model-invocation: true
---

# Plan to code

## Resolve arguments first

The arguments are `$task_id` then `$mode`.

- If `$task_id` is empty, ask for one and stop.
- If `$mode` is exactly `--auto`, the mode is **auto**. Otherwise it is **review**.

The task directory is `artifacts/lite-workflow/$task_id/`. If it does not exist, list the task ids that do exist and stop. If it holds no `plan.md`, tell the user to run `/plan-lite` first and stop.

Read `plan.md` and `task.md` from disk now rather than trusting anything seen earlier in the session — another session may have moved them on.

A run may be continuing an earlier session: an `In progress` task was interrupted, so check what is already in the working tree before redoing it. Otherwise start at the first sub-task that is not `Done`.

State the mode, the sub-task you are starting or resuming at, and why, before making any change.

## Standing rules

- `task.md` is the contract and `plan.md` is the route.
- Update `plan.md` as you go. It is the only state — a session that dies mid-sub-task must be resumable from the file alone.

## The iteration

One iteration covers one sub-task. Work them in plan order.

1. **Mark it `In progress`** in `plan.md` before touching any code.
2. **Implement** what its **TODO** describes, in the files it lists.
3. **Verify.** Run the build, run the unit tests for the touched area, and clear any diagnostics or lint the change introduced. Fix and re-run until clean. Then check the sub-task's **Acceptance criteria** are actually met — a green build is not the same as the criteria being satisfied.
4. **Sub-agent review.** Spawn a sub-agent, point it at the sub-task and the requirements in `task.md`, and let it read the diff itself with `git diff` over the sub-task's files. Brief it to report: correctness bugs, anything that does not meet the acceptance criteria, anything outside the sub-task's scope, and departures from the codebase's existing patterns. It reports findings; it does not edit. On the whole-task iteration it checks the task against `task.md` instead — every requirement met, nothing out of scope, and no seams left between sub-tasks that were fine alone and wrong together.
5. **Act on the findings.** Fix what is real, say plainly what you are rejecting and why, then re-verify.
6. **Human review.** Present the sub-task, a summary of the diff, the verification result, and anything the sub-agent raised that you rejected. Wait. Skipped for a sub-task in auto mode, never on the whole-task iteration — see [Modes](#modes).
7. **Refine** — only if they had findings. Implement them, re-verify, run steps 4 and 5 again, then back to step 6. Their approval is the only thing that ends this loop.
8. **Close it out.** Mark the sub-task `Done` in `plan.md`. On the whole-task iteration, set `task.md`'s **Status** to `Done` instead and report: if a task under the same two-letter code is still not `Done`, name the next one — `/clear`, then `/plan-lite {next task id}`.

Once every sub-task is `Done`, run one last iteration over the whole task. The code is already written, so it starts at step 4 and reads the whole task's diff wherever a step says the sub-task's.

## Modes

**review** — the default. Step 6 runs on every sub-task, so the user sees each one as it lands.

**auto** — step 6 is skipped for sub-tasks, so they run unattended. It still runs on the whole-task iteration, which is the first the user sees of the run.
