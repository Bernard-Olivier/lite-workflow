// The report. One row repo.
| Repo   | Tasks        | Plans        | Status        | Task Id                 |
| ------ | ------------ | ------------ | ------------- | ----------------------- |
| {name} | {# of tasks} | {# of plans} | {repo status} | {Further status detail} |

// Statuses, not part of template. First match wins, top to bottom.
| Status               | Task Id   | Explanation                                                                                            |
| -------------------- | --------- | ------------------------------------------------------------------------------------------------------ |
| Not found            |           | The repo path does not exist. Tasks and Plans are blank                                                |
| No stories           |           | No `artifacts/` dir, no `lite-workflow/` dir, or the Tasks column is 0                                  |
| Task requires review | {task_id} | A task is `Review required`, or a task is `In progress` and one of its sub-tasks is `Review required`  |
| Task in progress     | {task_id} | A task is `In progress`                                                                                |
| Ready for next task  | {task_id} | A task is `Not started`                                                                                |
| All done             |           | Every task is `Done`                                                                                   |
