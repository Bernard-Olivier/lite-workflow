---
name: research-lite
description: Research the codebase for one lite-workflow task and report findings. Invoked by plan-lite.
argument-hint: [task id]
arguments: task_id
context: fork
agent: Explore
background: false
user-invocable: false
---

# Feature research

The task id: `$task_id`. This agent runs isolated and cannot ask the caller anything, so if the id is empty or its directory does not exist, report that as your whole result and stop.

Find the task directory by globbing `artifacts/lite-workflow/*/$task_id/` and read its `task.md` first. Everything below is scoped to the task.

Investigate and report:

1. **Touch points** Files, modules, and functions the task will need to change. Give paths.
2. **Existing patterns** How this codebase already does the thing being asked for — naming, error handling, data access, test structure. Cite a concrete example file for each pattern.
3. **Dependencies** Libraries already available that fit. Flag anything that would need adding.
4. **Build and test** The exact command that builds this project, and the exact command that runs the tests for this area — `/build-lite` runs both verbatim from your report. Also where those tests live and what the existing convention looks like.
5. **Unknowns** Anything that makes a task harder than it reads: shared state, migrations, callers you'd break, missing seams.

## Output

Return a structured summary as your result, section by section in the order above. The caller writes the files; your report is the whole deliverable.

Be specific over complete. A path and a line number beats a paragraph of description. If a task turns out to be unimplementable as written, say so plainly and explain what's blocking it.
