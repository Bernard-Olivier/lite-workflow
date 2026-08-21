---
name: status-lite
description: Report the workflow status of each tracked repo.
argument-hint: [repo name]
disable-model-invocation: true
---

# Repos to status

`$ARGUMENTS` filters to the repos whose **Name** matches. Empty means all of them.

[tracked-repos.md](tracked-repos.md) is the repo list — read it first. If it holds no repo rows, tell the user to add one and stop.

This is read-only. Report in the chat and write nothing to disk — not the skill's own files, not the repos.

Resolve each repo's status from the status table in [report-template.md](report-template.md), first match top to bottom. Where the status carries a **Task Id** and more than one task matches, report the first found.

## Steps

1. **Collect the tasks.** Per tracked repo, glob `{path}/artifacts/lite-workflow/*/task.md` and read each one's **Status**. Count the `task.md` files for the **Tasks** column and the `plan.md` files beside them for **Plans**. Read the repos in one batch rather than one round-trip each.
2. **Drill down.** For every task at `In progress`, read its `plan.md` and check whether any sub-task is `Review required`. A task at `In progress` with no `plan.md` stays `In progress`.
3. **Report** the table from [report-template.md](report-template.md), `//` comment lines stripped. Say nothing else — the table carries the rest. Ignore the `Done` tasks from the Tasks and Plans counts.