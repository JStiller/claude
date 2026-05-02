# Agent Scaffold

## What you're creating
A custom subagent — an isolated Claude instance with its own system prompt, tools, and model.

## File to create
`<location>/agents/<name>.md`

`<location>`:
- `.claude/agents/` — project-scoped
- `~/.claude/agents/` — user-scoped (all projects)
- `plugins/<plugin-name>/agents/` — inside a plugin (note: `hooks`, `mcpServers`, `permissionMode` ignored in plugins)

## Agent file template

```
---
name: <name>
description: <Primary delegation trigger. "Use when [specific context]." Drives auto-delegation.>
tools: Read Grep Glob Bash
model: inherit
---

<System prompt body — this IS the agent's identity and instructions.
Write it as if briefing a specialist who has zero project context.
Include: domain, what to do when invoked, what to return.>
```

## Key frontmatter fields

| Field | Notes |
|---|---|
| `tools` | Space-separated allowlist. Omit to inherit all tools. |
| `model` | `haiku` for fast/cheap agents, `opus` for complex reasoning. |
| `permissionMode` | `default` \| `acceptEdits` \| `auto` \| `bypassPermissions` \| `plan`. Ignored inside plugins. |
| `memory` | `user` \| `project` \| `local` — enables persistent memory across sessions. |
| `background` | `true` to always run as a background task. |

## Tips
- Agents cannot spawn other agents.
- After adding a file, restart the session or use `/agents` to load immediately.
- Use `@"agent-name (agent)"` to guarantee invocation regardless of description match.
- Plugin agents: `@agent-plugin-name:agent-name`

## Full frontmatter reference
`${CLAUDE_SKILL_DIR}/references/claude-code-subagents.md`
