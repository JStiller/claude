---
name: skills
description: 
---

# Claude Code Skills – Official Reference

Source: <https://code.claude.com/docs/en/skills>

## Directory Structure

```text
my-skill/
├── SKILL.md                # Main instructions (required)
├── template.md             # Template for Claude to fill in
├── reference/
│   └── <reference-name>.md # Example output showing expected format
├── examples/
│   └── <example-name>.md   # Example output showing expected format
└── scripts/
    └── validate.sh         # Script Claude can execute
```

Keep `SKILL.md` under 500 lines. Move detailed reference material to separate files and reference them from `SKILL.md`.

## SKILL.md Frontmatter Reference

All fields are optional. Only `description` is strongly recommended.

```yaml
---
name: my-skill
description: What this skill does and when to use it
when_to_use: Additional trigger context or example phrases
argument-hint: [issue-number]
arguments: issue branch
disable-model-invocation: true
user-invocable: false
allowed-tools: Read Grep Bash(git *)
model: claude-opus-4-7
effort: high
context: fork
agent: Explore
hooks: ...
paths: ["src/**/*.ts", "*.md"]
shell: bash
---
```

| Field                      | Description                                                                                                   |
| :------------------------- | :------------------------------------------------------------------------------------------------------------ |
| `name`                     | Display name. Lowercase letters, numbers, hyphens only. Max 64 chars. Defaults to directory name.            |
| `description`              | When to use the skill. Claude uses this to decide when to auto-invoke. Front-load the key use case. Combined with `when_to_use`, truncated at 1,536 chars. |
| `when_to_use`              | Additional context: trigger phrases, example requests. Appended to `description` in skill listing.           |
| `argument-hint`            | Hint shown in autocomplete. Example: `[issue-number]` or `[filename] [format]`.                              |
| `arguments`                | Named positional args for `$name` substitution. Space-separated string or YAML list.                         |
| `disable-model-invocation` | `true` = Claude cannot auto-invoke. Description also hidden from Claude's context. Default: `false`.          |
| `user-invocable`           | `false` = hidden from `/` menu. Claude can still auto-invoke. Default: `true`.                                |
| `allowed-tools`            | Tools Claude can use without approval when skill is active. Space-separated string or YAML list.             |
| `model`                    | Model override for this skill's turn. Reverts after turn ends. Accepts same values as `/model`.              |
| `effort`                   | Effort level override: `low`, `medium`, `high`, `xhigh`, `max`. Reverts after turn.                          |
| `context`                  | Set to `fork` to run in isolated subagent context.                                                            |
| `agent`                    | Subagent type when `context: fork`. Options: `Explore`, `Plan`, `general-purpose`, or custom agents.         |
| `hooks`                    | Hooks scoped to this skill's lifecycle.                                                                       |
| `paths`                    | Glob patterns. When set, Claude only auto-loads skill when working with matching files.                       |
| `shell`                    | Shell for `!` commands: `bash` (default) or `powershell`.                                                     |

---

## String Substitutions

| Variable               | Description                                                                  |
| :--------------------- | :--------------------------------------------------------------------------- |
| `$ARGUMENTS`           | Full argument string as typed. Auto-appended if not present in content.      |
| `$ARGUMENTS[N]`        | Specific argument by 0-based index.                                          |
| `$N`                   | Shorthand for `$ARGUMENTS[N]`. `$0` = first, `$1` = second.                 |
| `$name`                | Named argument from `arguments` frontmatter. Maps by position.              |
| `${CLAUDE_SESSION_ID}` | Current session ID.                                                          |
| `${CLAUDE_EFFORT}`     | Current effort level: `low`, `medium`, `high`, `xhigh`, `max`.              |
| `${CLAUDE_SKILL_DIR}`  | Directory containing the skill's `SKILL.md`. Use to reference bundled files.|

Multi-word arguments must be quoted: `/my-skill "hello world" second` → `$0` = `hello world`, `$1` = `second`.

---

## Invocation Control

| Frontmatter                      | You can invoke | Claude can invoke | Context loading                                     |
| :------------------------------- | :------------- | :---------------- | :-------------------------------------------------- |
| (default)                        | Yes            | Yes               | Description always in context; full skill on invoke |
| `disable-model-invocation: true` | Yes            | No                | Description NOT in context; full skill on invoke    |
| `user-invocable: false`          | No             | Yes               | Description always in context; full skill on invoke |

**Rule of thumb:**

- Side-effect workflows (deploy, commit, send-message): use `disable-model-invocation: true`
- Background knowledge not actionable as a command: use `user-invocable: false`

---

## Skill Content Lifecycle

When a skill is invoked, the rendered `SKILL.md` content enters the conversation as a single message and stays for the rest of the session. Claude Code does not re-read the file on later turns.

**After auto-compaction:** Claude Code re-attaches the most recent invocation of each skill (first 5,000 tokens each). All re-attached skills share a 25,000-token budget, filled from most-recently-invoked. Older skills can be dropped.

---

## Dynamic Context Injection (Shell Injection)

Syntax: `` !`<command>` `` — runs before skill content reaches Claude. Output replaces the placeholder.

```yaml
---
name: pr-summary
context: fork
agent: Explore
allowed-tools: Bash(gh *)
---

## Pull request context
- PR diff: !`gh pr diff`
- PR comments: !`gh pr view --comments`
- Changed files: !`gh pr diff --name-only`

## Your task
Summarize this pull request...
```

For multi-line commands, use a fenced block opened with ` ```! `:

````markdown
## Environment
```!
node --version
npm --version
git status --short
```
````

To disable shell injection: set `"disableSkillShellExecution": true` in settings.

---

## Subagent Execution (`context: fork`)

With `context: fork`, the skill content becomes the prompt for an isolated subagent. It won't have access to your conversation history.

**Warning:** Only makes sense for skills with explicit instructions/tasks, not pure reference/guideline content.

| Approach                     | System prompt                   | Task                 | Also loads                   |
| :--------------------------- | :------------------------------ | :------------------- | :--------------------------- |
| Skill with `context: fork`   | From agent type                 | SKILL.md content     | CLAUDE.md                    |
| Subagent with `skills` field | Subagent's markdown body        | Claude's delegation  | Preloaded skills + CLAUDE.md |

Built-in agent types: `Explore`, `Plan`, `general-purpose`. Custom agents from `.claude/agents/` also work.

---

## Skill Types by Content

**Reference content** — adds knowledge Claude applies inline. Conventions, patterns, style guides.

```yaml
---
name: api-conventions
description: API design patterns for this codebase
---
```

**Task content** — step-by-step instructions for a specific action. Usually `disable-model-invocation: true`.

```yaml
---
name: deploy
description: Deploy the application to production
context: fork
disable-model-invocation: true
---
```

---

## Controlling Skill Access (Permissions)

**Disable all skills:**

```markdown
# In deny rules:
Skill
```

**Allow/deny specific skills:**

```markdown
# Allow only:
Skill(commit)
Skill(review-pr *)

# Deny specific:
Skill(deploy *)
```

Permission syntax: `Skill(name)` for exact match, `Skill(name *)` for prefix match.

Note: `user-invocable` only controls menu visibility, NOT Skill tool access. Use `disable-model-invocation: true` to block programmatic invocation.

---

## Troubleshooting

| Problem | Fix |
| :--- | :--- |
| Skill not triggering | Add keywords users would naturally say to description; try direct `/skill-name` invocation |
| Skill triggers too often | Make description more specific; add `disable-model-invocation: true` |
| Description cut short | Trim description; front-load key use case; set `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var |
| Skill stops influencing after first response | Strengthen description and instructions; re-invoke after compaction |

---

## Related Resources

- [Agent Skills specification](https://agentskills.io/specification) — full frontmatter spec
