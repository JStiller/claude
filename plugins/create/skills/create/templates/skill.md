# Skill Scaffold

## What you're creating
A Claude Code skill — a `SKILL.md` file Claude reads when invoked via `/skill-name`.

## File to create
`<location>/skills/<name>/SKILL.md`

`<location>`:
- `.claude/` — project-scoped
- `~/.claude/` — user-scoped (all projects)
- `plugins/<plugin-name>/skills/` — inside a plugin
- `plugins/<plugin-name>/skills/references` — non-auto-loaded reference skills for internal use (e.g., reference implementations, templates)
- `plugins/<plugin-name>/skills/scripts` — executable scripts used by hooks or as tool implementations
- `plugins/<plugin-name>/skills/examples` — example skills for demonstration or testing purposes
- `plugins/<plugin-name>/skills/assets` — files used in output — not loaded into context
- `plugins/<plugin-name>/skills/templates` — template files for generating skill content

## SKILL.md template

```
---
name: <name>
description: <Primary use case. Front-load the trigger. Claude reads this to decide auto-invoke.>
when_to_use: <Additional trigger phrases and example requests. Combined 1,536-char budget with description.>
argument-hint: <hint shown in autocomplete, e.g. [filename] or [issue-number]>
allowed-tools: Read Write Bash(git *)
effort: <low | medium | high | xhigh | max>
# user-invocable: false        # hide from / list (when auto-triggers are sufficient)
# disable-model-invocation: true  # pure shell workflow; Claude never processes content
# context: fork                # isolated subagent (no conversation history)
# agent: Explore               # subagent type (requires context: fork)
# paths: ["src/**/*.ts"]       # auto-load only for matching files
---

<skill instructions here — write in imperative form: "Check X", "Run Y">
```

## Frontmatter: invocability

| Field | Value | When to use |
|---|---|---|
| `when_to_use` | trigger phrases | Extra auto-invoke patterns beyond `description`; combined 1,536-char budget |
| `user-invocable` | `false` | Hide from `/` list; set when auto-triggers cover all use cases |
| `disable-model-invocation` | `true` | Pure shell side-effect (deploy, commit, send); Claude never processes content |

## Frontmatter: isolation

| Field | Value | When to use |
|---|---|---|
| `context` | `fork` | Run in isolated subagent; no conversation history access |
| `agent` | `Explore` / `Plan` / `general-purpose` / custom | Subagent type to use (requires `context: fork`) |

## Frontmatter: hooks

Embed hooks scoped to this skill's lifecycle:

```yaml
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/check.sh"
  PostToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "./scripts/lint.sh"
```

Full hook event reference: `${CLAUDE_SKILL_DIR}/reference/claude-code-hooks.md`

## Frontmatter: allowed-tools

| Use case | Suggested tools |
|---|---|
| Read/search files | `Read Glob Grep` |
| Edit/write files | `Read Write Edit` |
| Git operations | `Bash(git *)` |
| Web lookups | `WebFetch WebSearch` |
| Run tests / build | `Bash(npm *) Bash(yarn *)` |
| Full shell access | `Bash` |

## Frontmatter: paths (auto-load filter)

```yaml
paths: ["src/**/*.ts", "*.md"]
```

Skill auto-loads only when working with files matching these globs.

## Tips
- Keep under 500 lines. Move detailed reference material to separate files.
- Use `${CLAUDE_SKILL_DIR}` to reference files bundled alongside the skill.
- Shell injection: `` !`command` `` runs before skill content reaches Claude. Output replaces the placeholder.
- Multi-line shell injection uses a fenced ` ```! ` block.

## Full frontmatter reference
`${CLAUDE_SKILL_DIR}/references/claude-code-skills.md`
