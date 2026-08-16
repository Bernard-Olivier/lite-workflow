---
name: research
description: Investigate the codebase for a planned feature and report findings. Runs in an isolated subagent.
argument-hint: [task id]
arguments: task id
---

# Feature research

Read `artifacts/lite-workflow/{feature}/{task}/task.md` first. Everything below is scoped to the task.

Investigate and report:

1. **Touch points** Files, modules, and functions the task will need to change. Give paths.
2. **Existing patterns** How this codebase already does the thing being asked for — naming, error handling, data access, test structure. Cite a concrete example file for each pattern.
3. **Dependencies** Libraries already available that fit. Flag anything that would need adding.
4. **Test surface** Where tests for this area live, how they run, what the existing convention looks like.
5. **Unknowns** Anything that makes a task harder than it reads: shared state, migrations, callers you'd break, missing seams.

## Output

Return a structured summary as your result. Do not write files — report back to the caller, which writes them.

Be specific over complete, do not be verbose. A path and a line number beats a paragraph of description. If a task turns out to be unimplementable as written, say so plainly and explain what's blocking it.
