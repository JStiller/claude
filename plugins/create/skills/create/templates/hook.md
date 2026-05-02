# Hook Scaffold

## What you're creating
A lifecycle hook — a shell command, HTTP endpoint, prompt, or agent that fires at specific Claude Code events.

## File to modify/create

| Context | File |
|---|---|
| Plugin | `plugins/<plugin-name>/hooks/hooks.json` |
| Project standalone | `.claude/settings.json` (under `"hooks"` key) |
| User global | `~/.claude/settings.json` (under `"hooks"` key) |

## Hook JSON structure

```json
{
  "hooks": {
    "<EventName>": [
      {
        "matcher": "<tool-name, pipe-list, regex, or *>",
        "hooks": [
          {
            "type": "command",
            "command": "<shell command — receives hook JSON on stdin>"
          }
        ]
      }
    ]
  }
}
```

## Common events

| Event | When | Can do |
|---|---|---|
| `PreToolUse` | Before tool runs | allow / deny / modify input |
| `PostToolUse` | After tool runs | add context |
| `UserPromptSubmit` | Before Claude processes prompt | block / add context |
| `SessionStart` | Session begins | inject context, set env vars |
| `Stop` | Claude finishes responding | prevent stop, continue |
| `FileChanged` | Watched file changes on disk | async notification |

## Exit codes (command hooks)

| Code | Behavior |
|---|---|
| `0` | Success. JSON stdout processed; non-JSON logged. |
| `2` | Blocking error. stderr fed back to Claude. |
| other | Non-blocking. stderr shown in transcript. |

## PreToolUse allow/deny example

```bash
#!/usr/bin/env bash
COMMAND=$(jq -r '.tool_input.command' 2>/dev/null)
if echo "$COMMAND" | grep -q 'rm -rf'; then
  jq -n '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:"Destructive rm -rf blocked"}}'
else
  exit 0
fi
```

## Tips
- Matchers: `"Bash"` exact, `"Edit|Write"` pipe-list, `"^mcp__.*"` JS regex, `"*"` all.
- `"if": "Bash(git *)"` adds a permission-rule-style filter on top of the matcher.
- `"async": true` — fire and forget (logging). `"asyncRewake": true` — background but wakes Claude on exit code 2.
- `"once": true` — run only once per session.

## Full event and output reference
`${CLAUDE_SKILL_DIR}/references/claude-code-hooks.md`
