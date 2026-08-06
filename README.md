# Feature workflow skills

Four Claude Code skills that take a feature from a rough idea to committed code, with the artifacts on disk as the only state.

```
/idea <slug>            →  story.md
/plan <slug>            →  research.md + plan.md
/build [--auto] <slug>  →  code, ticking plan.md as it goes
```

## Install

Copy the four directories into `.claude/skills/` at your repo root:

```
.claude/skills/
  idea/
  research/
  plan/
  build/
```

Claude Code watches skill directories, so they register within the current session — no restart needed. Commit them to share with the team.

## Artifacts

One directory per feature:

```
artifacts/features/<slug>/
  story.md      # stories + acceptance criteria
  research.md   # codebase findings
  plan.md       # tasks as checkboxes — the progress tracker
```

The checkboxes in `plan.md` are the only progress state. That's deliberate: any session, on any machine, can resume cold by reading the file. Nothing lives in conversation history.

## The four skills

### `/idea <slug>` — interactive

Asks clarifying questions in batches, drafts stories in the chat, and writes nothing until you approve. Every story needs acceptance criteria that can be checked by running something.

Run it on an existing slug and it switches to amend mode: it reads the current stories, asks what's changing, and preserves the IDs of stories you didn't touch.

### `/research <slug>` — automatic

Runs in a forked `Explore` subagent, so it greps and reads without filling your main context with file dumps. Reports touch points, existing patterns, dependencies, test surface, and risks.

You normally don't invoke this directly — `/plan` calls it.

### `/plan <slug>` — auto research, interactive sign-off

Runs research unattended, writes `research.md`, then generates a task list and presents it in the chat. `plan.md` is written only after you approve. Each task is one commit's worth of work, scoped to named files, with a named verify command.

On an existing slug it replans: presents a **keep / change / drop** delta with ticked state shown, then merges rather than overwrites.

### `/build [--auto] <slug>` — two modes

Works unticked tasks in order. For each: make the change, run its verify command, tick the box. Never ticks a box whose verification failed.

- **review** (default) — stops after every task with the diff and verify result
- **`--auto`** — runs to the end of the story, then reports

Both modes stop immediately on a failed verification, an ambiguous task, or a change that would touch files outside the task's declared scope. `--auto` changes *when you get a report*, not *what stops the loop*.

## Design decisions

**Research is a separate skill because the Explore agent is read-only.** It can't write `research.md` itself, so it returns findings and `/plan` writes them out. The isolation is worth the extra file — planning context stays clean.

**Replan merges, it doesn't regenerate.** A clean rewrite of `plan.md` would look correct and silently lose the record of what's already built. Ticked tasks carry across with IDs intact; any ticked task the revision invalidates gets named to you before anything is written.

**Task IDs are never reused.** They show up in commits and conversation. A gap in the numbering is cheaper than an ID that means two different things.

**`--auto` is a flag, not a positional argument.** `/build payments` and `/build --auto payments` are unambiguous; a bare `auto` in first position could be mistaken for a slug. The argument that decides whether Claude pauses for review is the last place you want the skill guessing.

**The mutating skills set `disable-model-invocation: true`.** Claude won't decide on its own to start building because your code looks ready. It also keeps them out of the skill listing, which saves context budget.

## Tuning

- **Always re-research on replan.** `/plan` reuses `research.md` unless `story.md` changed. If your codebase moves fast, edit step 2 of the Replanning section to re-run every time.
- **Pre-approve more tools.** `build/SKILL.md` grants `Read Edit Write Grep Glob Bash(git *)`. Add your test runner to skip approval prompts mid-loop.
- **Change the artifact root.** It appears in all four `SKILL.md` files; grep for `artifacts/features`.

## Notes

Skill content stays in context for the rest of the session once loaded, so the bodies are written terse on purpose — every line is a recurring token cost. Claude Code doesn't re-read a skill file on later turns, which is why `/build`'s rules are phrased as standing instructions rather than a one-time checklist. Keep both properties in mind when editing.
