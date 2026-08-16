# Amending a plan

The amendment branch of [`SKILL.md`](SKILL.md), reached when `plan.md` already exists. `plan.md` holds build progress: a lost `Done` means work gets redone or silently skipped, so merge into the file rather than regenerating it.

Two terms govern this branch:

- **`Done` is append-only.** A finished sub-task records work that already exists in the tree. It keeps its number, its status and its wording; a correction to it is a *new* sub-task at the next free number, so the built history stays readable. `/build-lite` holds to the same rule.
- **Sunk work** is any `In progress` or `Done` sub-task that the amendment would change or drop. It has already cost time, so the user decides its fate.

## Steps

1. **Report how stale `research.md` is.** See [Staleness](#staleness). Ask whether to reuse it or run a fresh research pass, and wait for the answer — research is the slow part, and stale-but-relevant beats a needless rerun.
2. **Read `plan.md`** and note every sub-task's status, plus any recorded `Blocked` reason. A blocked sub-task is usually why this session was started; address it first.
3. **Present the delta in the chat** as three lists — **keep**, **change or add**, **drop** — with each sub-task's status against it. Chat only at this stage.
4. **Flag the sunk work.** Name every sub-task in "change" or "drop" that is `In progress` or `Done`, say what the amendment costs it, and let the user choose. For a `Done` one the choice is between leaving it alone and adding a new sub-task that corrects it.
5. **On approval, merge into `plan.md`**: carry existing sub-tasks across with their statuses and numbers intact, insert new ones at the next free numbers, and remove only what the user agreed to drop.
6. **Append any major decision** to `task.md`'s **Notes**, as the **Update `task.md`** step in `SKILL.md` describes.
7. **Report** what changed and which sub-tasks are next, then the next step: `/clear`, then `/build-lite {task id}`.

## Staleness

Establish, and state plainly:

- When `research.md` was written — `git log -1 --format=%cr -- {path}`, or its modified time if it is uncommitted.
- How much has landed since — `git rev-list --count {sha}..HEAD` on the repo, and whether any of it touched the files listed under **Touch points**.
- Whether `task.md` has changed since `research.md` was written.

Recommend a fresh pass when `task.md` changed after `research.md`, or when commits since have touched its touch points. Otherwise recommend reuse. The user decides either way.
