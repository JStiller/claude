# MCP Server Scaffold

## What you're creating
An MCP (Model Context Protocol) server configuration — connects Claude to external tools, APIs, or data sources.

## File to modify/create

| Context | File |
|---|---|
| Project | `.mcp.json` |
| Plugin | `plugins/<plugin-name>/.mcp.json` |
| User global | `~/.claude/.mcp.json` |

## stdio server (most common)

```json
{
  "mcpServers": {
    "<server-name>": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "<npm-package>@latest"],
      "env": {
        "API_KEY": "${API_KEY}"
      }
    }
  }
}
```

## HTTP server

```json
{
  "mcpServers": {
    "<server-name>": {
      "type": "http",
      "url": "https://<your-server>/mcp",
      "headers": {
        "Authorization": "Bearer ${TOKEN}"
      }
    }
  }
}
```

## Tips
- Use `${ENV_VAR}` for secrets — never hardcode API keys in `.mcp.json`.
- stdio servers are spawned per-session. HTTP servers must already be running.
- After adding, run `/mcp` to verify the connection and list available tools.
- Tool names in Claude follow: `mcp__<server-name>__<tool-name>`.
- Commit `.mcp.json` to share with the team; add secrets to `.env` (gitignored).

## Full MCP reference
`${CLAUDE_SKILL_DIR}/references/claude-code-mcp.md`
