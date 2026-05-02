---
name: hooks
description: Hooks are user-defined shell commands, HTTP endpoints, LLM prompts, or MCP tools that execute at specific points in Claude Code's lifecycle.
---

# Claude Code Hooks – Official Reference

Source: <https://code.claude.com/docs/en/hooks>

---

## What Are Hooks?

Hooks are user-defined shell commands, HTTP endpoints, LLM prompts, or MCP tools that execute at specific points in Claude Code's lifecycle. They enable automation of workflows, validation, logging, and permission management.

---

## Hook Locations

| Location | Scope | Shareable |
| :--- | :--- | :--- |
| `~/.claude/settings.json` | All projects | No |
| `.claude/settings.json` | Current project | Yes (via VCS) |
| `.claude/settings.local.json` | Current project | No |
| Plugin `hooks/hooks.json` | When plugin is enabled | Yes |
| Skill/agent frontmatter | While skill/agent is active | Yes |

---

## Configuration Structure

Three nesting levels:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "./.claude/hooks/validate.sh"
          }
        ]
      }
    ]
  }
}
```

1. **Hook event** — lifecycle point (e.g., `PreToolUse`)
2. **Matcher group** — filter for when it fires (e.g., `"Bash"`)
3. **Hook handlers** — the action that runs

---

## Hook Events

### Event Cadence

| Cadence | Events |
| :--- | :--- |
| Once per session | `SessionStart`, `SessionEnd` |
| Once per turn | `UserPromptSubmit`, `Stop`, `StopFailure` |
| Every tool call | `PreToolUse`, `PostToolUse`, `PermissionRequest`, `PermissionDenied` |
| Async / event-driven | `FileChanged`, `CwdChanged`, `Notification`, `ConfigChange`, `InstructionsLoaded`, `WorktreeCreate`, `WorktreeRemove` |
| Slash command | `UserPromptExpansion` |
| MCP input | `Elicitation`, `ElicitationResult` |

### Event Details

| Event | Matcher input | Control | Notes |
| :--- | :--- | :--- | :--- |
| `SessionStart` | `startup`, `resume`, `clear`, `compact` | Inject context via `additionalContext` | Can persist env vars via `CLAUDE_ENV_FILE` |
| `SessionEnd` | — | — | Cleanup tasks |
| `UserPromptSubmit` | — (no matcher) | Block prompt, add context, set session title | Fires before Claude processes the prompt |
| `UserPromptExpansion` | Command names | Block expansion, inject context | Fires when slash command expands |
| `PreToolUse` | Tool names | `allow`, `deny`, `ask`, `defer`; can modify `updatedInput` | Only event that can modify tool input before execution |
| `PermissionRequest` | Tool names | Allow/deny on behalf of user | Fires only when permission dialog would be shown |
| `PostToolUse` | Tool names | Block (with `decision: "block"`) | Tool already ran; can add context |
| `Stop` | — (no matcher) | Prevent stopping, continue conversation | Fires when Claude finishes responding |
| `StopFailure` | — | — | Fires when Claude stops due to an error |
| `FileChanged` | Literal filenames (e.g., `".envrc\|.env"`) | None | Async; fires when watched file changes on disk |
| `CwdChanged` | — | — | Async; fires when working directory changes |
| `ConfigChange` | `user_settings`, `project_settings`, etc. | Block config change (except managed settings) | — |
| `Elicitation` | MCP server name | Accept/decline/cancel | MCP server requests user input |
| `ElicitationResult` | MCP server name | — | User responded to MCP elicitation |

---

## Hook Types

### 1. Command

```json
{
  "type": "command",
  "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/script.sh",
  "async": false,
  "asyncRewake": false,
  "shell": "bash"
}
```

Receives JSON on stdin. Most common type.

### 2. HTTP

```json
{
  "type": "http",
  "url": "http://localhost:8080/hooks",
  "headers": {
    "Authorization": "Bearer $MY_TOKEN"
  },
  "allowedEnvVars": ["MY_TOKEN"]
}
```

POSTs JSON body to URL.

### 3. MCP Tool

```json
{
  "type": "mcp_tool",
  "server": "my_server",
  "tool": "security_scan",
  "input": { "file_path": "${tool_input.file_path}" }
}
```

Calls a tool on a connected MCP server.

### 4. Prompt

```json
{
  "type": "prompt"
}
```

Single-turn LLM evaluation for decisions.

### 5. Agent

```json
{
  "type": "agent"
}
```

Spawns a subagent for complex validation.

### Common Fields (All Types)

| Field | Description |
| :--- | :--- |
| `if` | Permission rule syntax filter (e.g., `"Bash(git *)"`) — additional condition beyond the matcher |
| `timeout` | Seconds before canceling. Default varies by event |
| `statusMessage` | Custom spinner message shown while hook runs |
| `once` | `true` = run only once per session |
| `async` | `true` = run in background, don't wait for result (command only) |
| `asyncRewake` | `true` = background, but exit code 2 wakes Claude (command only) |

---

## Matcher Patterns

| Pattern | Behavior | Example |
| :--- | :--- | :--- |
| `"*"`, `""`, or omitted | Match all | Always fires |
| Letters, digits, `_`, `\|` | Exact string or pipe-delimited list | `"Bash"`, `"Edit\|Write"` |
| Any other characters | JavaScript regex | `"^Notebook"`, `"mcp__.*"` |

**MCP tool names** follow the pattern `mcp__<server>__<tool>`:

```
mcp__memory__create_entities
mcp__.*__write.*    (any write tool on any server)
```

---

## Exit Codes (Command Hooks)

| Exit code | Behavior |
| :--- | :--- |
| `0` | Success. JSON stdout is processed; non-JSON is logged or shown to Claude |
| `2` | Blocking error. stderr is fed back to Claude. JSON output is ignored |
| Other | Non-blocking error. stderr shown in transcript |

---

## JSON Output Format

```json
{
  "continue": true,
  "stopReason": "Build failed",
  "suppressOutput": false,
  "systemMessage": "Warning: ...",
  "decision": "block",
  "reason": "Why blocked",
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Database writes not allowed",
    "additionalContext": "Extra info for Claude"
  }
}
```

| Field | Description |
| :--- | :--- |
| `continue` | `false` stops Claude entirely |
| `stopReason` | Message shown when `continue` is `false` |
| `suppressOutput` | Omit from debug log |
| `systemMessage` | Warning shown to user |
| `decision` | Event-specific control (`allow`, `deny`, `block`, `ask`, `defer`) |
| `reason` | Human-readable reason for the decision |
| `hookSpecificOutput` | Per-event output (see below) |

---

## PreToolUse — Decision Control

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Only SELECT queries are allowed"
  }
}
```

| Decision | Behavior |
| :--- | :--- |
| `allow` | Proceed without prompting user |
| `deny` | Block tool call; reason fed back to Claude |
| `ask` | Show permission dialog to user |
| `defer` | Fall through to normal permission handling |

**Modify tool input before execution** (`updatedInput`):

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "updatedInput": { "command": "echo 'sanitized'" }
  }
}
```

---

## Context Injection (`additionalContext`)

Use in `PostToolUse`, `SessionStart`, `UserPromptSubmit` to add information Claude should know:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "Current branch: main\nDeployment target: staging"
  }
}
```

Context is shown as system reminders (not chat messages). Best for:

- Environment state (git branch, deployment target, feature flags)
- Conditional project rules
- External data (open issues, CI results)

---

## Environment Variables Available in Hooks

| Variable | Description |
| :--- | :--- |
| `CLAUDE_PROJECT_DIR` | Project root directory |
| `CLAUDE_ENV_FILE` | Path for persisting env vars (available in `SessionStart`, `Setup`, `CwdChanged`, `FileChanged`) |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin installation directory (plugin hooks only) |
| `${CLAUDE_PLUGIN_DATA}` | Plugin persistent data directory (plugin hooks only) |

**Persisting environment variables across turns** (from `SessionStart`):

```bash
echo 'export NODE_ENV=production' >> "$CLAUDE_ENV_FILE"
```

---

## Hooks in Skills & Agent Frontmatter

Define hooks scoped to the lifetime of a skill or agent:

```yaml
---
name: secure-operations
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/security-check.sh"
  PostToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "./scripts/run-linter.sh"
---
```

`Stop` hooks in frontmatter are auto-converted to `SubagentStop` when running as a subagent.

---

## Subagent Lifecycle Hooks (in `settings.json`)

```json
{
  "hooks": {
    "SubagentStart": [
      {
        "matcher": "db-agent",
        "hooks": [{ "type": "command", "command": "./scripts/setup-db.sh" }]
      }
    ],
    "SubagentStop": [
      {
        "hooks": [{ "type": "command", "command": "./scripts/cleanup.sh" }]
      }
    ]
  }
}
```

| Event | Matcher | Fires |
| :--- | :--- | :--- |
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop` | Agent type name | When a subagent completes |

---

## Async Hooks

```json
{ "type": "command", "command": "log-event.sh", "async": true }
```

```json
{ "type": "command", "command": "check.sh", "asyncRewake": true }
```

- `async: true` — runs in background, Claude doesn't wait
- `asyncRewake: true` — runs in background; if it exits with code 2, Claude is woken up

---

## Disabling Hooks

Delete from settings JSON, or temporarily disable all hooks:

```json
{
  "disableAllHooks": true
}
```

Cannot disable hooks from managed settings at user/project level.

---

## Practical Example: Block Destructive Commands

`settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "if": "Bash(rm *)",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/block-rm.sh"
          }
        ]
      }
    ]
  }
}
```

`.claude/hooks/block-rm.sh`:

```bash
#!/bin/bash
COMMAND=$(jq -r '.tool_input.command')

if echo "$COMMAND" | grep -q 'rm -rf'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Destructive rm -rf blocked"
    }
  }'
else
  exit 0
fi
```

---

## Viewing Hooks (`/hooks`)

Type `/hooks` to browse all configured hooks:

- Read-only browser showing all hooks by event
- Shows hook count per event
- Displays source: `User`, `Project`, `Local`, `Plugin`, `Session`, `Built-in`
- Labels handler type: `[command]`, `[prompt]`, `[agent]`, `[http]`, `[mcp_tool]`
