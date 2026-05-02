---
name: mcp
description: The Model Context Protocol (MCP) is an open source standard for AI-tool integrations. MCP servers give Claude Code access to external tools, databases, and APIs.
---

# Claude Code MCP – Official Reference

Source: <https://code.claude.com/docs/en/mcp>

---

## What Is MCP?

The Model Context Protocol (MCP) is an open source standard for AI-tool integrations. MCP servers give Claude Code access to external tools, databases, and APIs.

**Use when:** You find yourself copying data into chat from another tool (issue tracker, monitoring dashboard, database). Once connected, Claude reads and acts on that system directly.

---

## Installing MCP Servers

All options (`--transport`, `--env`, `--scope`, `--header`) must come **before** the server name. `--` separates the server name from the server's command and arguments.

### HTTP (recommended for remote servers)

```bash
claude mcp add --transport http <name> <url>

# With Bearer token
claude mcp add --transport http secure-api https://api.example.com/mcp \
  --header "Authorization: Bearer your-token"
```

### SSE (deprecated — use HTTP instead)

```bash
claude mcp add --transport sse <name> <url>
```

### Stdio (local processes, direct system access)

```bash
claude mcp add [options] <name> -- <command> [args...]

# With env var
claude mcp add --transport stdio --env AIRTABLE_API_KEY=YOUR_KEY airtable \
  -- npx -y airtable-mcp-server
```

### From JSON

```bash
claude mcp add-json <name> '<json>'

# HTTP example
claude mcp add-json weather-api '{"type":"http","url":"https://api.weather.com/mcp","headers":{"Authorization":"Bearer token"}}'

# Stdio example
claude mcp add-json local-tool '{"type":"stdio","command":"/path/to/cli","args":["--flag"],"env":{"KEY":"val"}}'
```

### Import from Claude Desktop

```bash
claude mcp add-from-claude-desktop   # macOS and WSL only
```

---

## Managing Servers

```bash
claude mcp list           # List all configured servers
claude mcp get <name>     # Details for a specific server
claude mcp remove <name>  # Remove a server
/mcp                      # Within Claude Code: status, auth, manage
```

---

## Scopes

| Scope | Loads in | Shared with team | Stored in |
| :--- | :--- | :--- | :--- |
| `local` (default) | Current project only | No | `~/.claude.json` |
| `project` | Current project only | Yes, via `.mcp.json` in VCS | `.mcp.json` at project root |
| `user` | All your projects | No | `~/.claude.json` |

```bash
claude mcp add --transport http stripe --scope local  https://mcp.stripe.com
claude mcp add --transport http paypal --scope project https://mcp.paypal.com/mcp
claude mcp add --transport http hubspot --scope user  https://mcp.hubspot.com/anthropic
```

**Scope hierarchy** (first match wins):

1. Local scope
2. Project scope
3. User scope
4. Plugin-provided servers
5. Claude.ai connectors

Project-scoped `.mcp.json` requires approval before first use. Reset approvals with `claude mcp reset-project-choices`.

---

## `.mcp.json` Format

```json
{
  "mcpServers": {
    "api-server": {
      "type": "http",
      "url": "${API_BASE_URL:-https://api.example.com}/mcp",
      "headers": {
        "Authorization": "Bearer ${API_KEY}"
      }
    },
    "local-tool": {
      "command": "/path/to/server",
      "args": [],
      "env": {}
    }
  }
}
```

**Environment variable expansion** (supported in `command`, `args`, `env`, `url`, `headers`):

- `${VAR}` — expands to the value of `VAR`
- `${VAR:-default}` — expands to `VAR` if set, otherwise `default`

---

## Authentication

### OAuth 2.0 (interactive)

```bash
claude mcp add --transport http sentry https://mcp.sentry.dev/mcp
/mcp   # then follow browser login flow
```

Tokens stored securely and refreshed automatically.

### Fixed OAuth callback port

```bash
claude mcp add --transport http --callback-port 8080 my-server https://mcp.example.com/mcp
```

### Pre-configured OAuth credentials

```bash
claude mcp add --transport http \
  --client-id your-client-id --client-secret --callback-port 8080 \
  my-server https://mcp.example.com/mcp

# Via env var (CI)
MCP_CLIENT_SECRET=your-secret claude mcp add --transport http \
  --client-id your-client-id --client-secret --callback-port 8080 \
  my-server https://mcp.example.com/mcp
```

### Dynamic headers (non-OAuth auth)

```json
{
  "mcpServers": {
    "internal-api": {
      "type": "http",
      "url": "https://mcp.internal.example.com",
      "headersHelper": "/opt/bin/get-mcp-auth-headers.sh"
    }
  }
}
```

The command must write a JSON object of string key-value pairs to stdout. Runs fresh on each connection (no caching). Environment variables available: `CLAUDE_CODE_MCP_SERVER_NAME`, `CLAUDE_CODE_MCP_SERVER_URL`.

### Restrict OAuth scopes

```json
{
  "mcpServers": {
    "slack": {
      "type": "http",
      "url": "https://mcp.slack.com/mcp",
      "oauth": {
        "scopes": "channels:read chat:write search:read"
      }
    }
  }
}
```

---

## Output Limits

| Setting | Value |
| :--- | :--- |
| Warning threshold | 10,000 tokens |
| Default maximum | 25,000 tokens |
| Hard ceiling (per-tool annotation) | 500,000 characters |

```bash
export MAX_MCP_OUTPUT_TOKENS=50000
```

Per-tool limit (MCP server authors, in `tools/list` response):

```json
{
  "name": "get_schema",
  "description": "Returns the full database schema",
  "_meta": { "anthropic/maxResultSizeChars": 200000 }
}
```

---

## Tool Search (Context Efficiency)

By default, MCP tools are **deferred** — only tool names load at session start. Claude uses a search tool to discover relevant tools when needed, keeping context usage low.

Control with `ENABLE_TOOL_SEARCH`:

| Value | Behavior |
| :--- | :--- |
| (unset) | All tools deferred; falls back to upfront on Vertex AI / non-first-party `ANTHROPIC_BASE_URL` |
| `true` | All tools deferred, including Vertex AI |
| `auto` | Threshold: load upfront if fits within 10% of context window, defer otherwise |
| `auto:<N>` | Custom threshold (e.g., `auto:5` = 5%) |
| `false` | All tools loaded upfront |

```bash
ENABLE_TOOL_SEARCH=auto:5 claude
ENABLE_TOOL_SEARCH=false claude
```

Requires Sonnet 4+ or Opus 4+ (Haiku does not support tool search).

**Always load a specific server** (exempt from deferral):

```json
{
  "mcpServers": {
    "core-tools": { "type": "http", "url": "https://mcp.example.com/mcp", "alwaysLoad": true }
  }
}
```

Also supported per-tool via `"anthropic/alwaysLoad": true` in the tool's `_meta` object.

**Disable ToolSearch via permissions:**

```json
{ "permissions": { "deny": ["ToolSearch"] } }
```

---

## MCP Resources

Reference resources with `@` mentions (same as files):

```
@github:issue://123
@docs:file://api/authentication
@postgres:schema://users
```

Resources are auto-fetched and included as attachments.

---

## MCP Prompts as Commands

MCP servers can expose prompts as commands: `/mcp__<server>__<prompt>`

```
/mcp__github__list_prs
/mcp__github__pr_review 456
/mcp__jira__create_issue "Bug in login flow" high
```

---

## Plugin-Provided MCP Servers

Define in `.mcp.json` at plugin root or inline in `plugin.json`:

```json
{
  "mcpServers": {
    "database-tools": {
      "command": "${CLAUDE_PLUGIN_ROOT}/servers/db-server",
      "args": ["--config", "${CLAUDE_PLUGIN_ROOT}/config.json"],
      "env": { "DB_URL": "${DB_URL}" }
    }
  }
}
```

- `${CLAUDE_PLUGIN_ROOT}` — plugin installation directory
- `${CLAUDE_PLUGIN_DATA}` — plugin persistent data (survives updates)
- Servers connect automatically when plugin is enabled; run `/reload-plugins` to reconnect after enable/disable

---

## Claude Code as MCP Server

```bash
claude mcp serve
```

`claude_desktop_config.json` entry:

```json
{
  "mcpServers": {
    "claude-code": {
      "type": "stdio",
      "command": "/full/path/to/claude",
      "args": ["mcp", "serve"],
      "env": {}
    }
  }
}
```

Use `which claude` to find the full path.

---

## Managed MCP Configuration (Organizations)

### Option 1: Exclusive control (`managed-mcp.json`)

Deploys a fixed set; users cannot add/modify/use any other servers.

System-wide paths (require admin privileges):

- macOS: `/Library/Application Support/ClaudeCode/managed-mcp.json`
- Linux/WSL: `/etc/claude-code/managed-mcp.json`
- Windows: `C:\Program Files\ClaudeCode\managed-mcp.json`

Same format as `.mcp.json`.

### Option 2: Policy-based (allowlists/denylists in managed settings)

```json
{
  "allowedMcpServers": [
    { "serverName": "github" },
    { "serverCommand": ["npx", "-y", "@modelcontextprotocol/server-filesystem"] },
    { "serverUrl": "https://mcp.company.com/*" },
    { "serverUrl": "https://*.internal.corp/*" }
  ],
  "deniedMcpServers": [
    { "serverName": "dangerous-server" },
    { "serverUrl": "https://*.untrusted.com/*" }
  ]
}
```

Each entry must have exactly one of: `serverName`, `serverCommand`, or `serverUrl`.

**Allowlist behavior:**

- `undefined` — no restrictions
- `[]` — complete lockdown
- list — only matching servers allowed

**Precedence rules:**

- Denylist always takes precedence over allowlist
- Stdio servers must match a `serverCommand` entry when any command entries exist
- Remote servers must match a `serverUrl` entry when any URL entries exist
- `serverCommand` matching is exact (order and all args must match)
- `serverUrl` supports `*` wildcards

**Also set in managed settings to prevent user config of MCP:**

```json
{ "allowManagedMcpServersOnly": true }
```

---

## Connection Behavior

- **Auto-reconnect:** HTTP/SSE servers reconnect with exponential backoff (up to 5 attempts, starting at 1s, doubling each time). Stdio servers are not reconnected.
- **Initial connection retries (v2.1.121+):** Up to 3 retries on transient errors (5xx, connection refused, timeout). Auth and 404 errors are not retried.
- **Dynamic tool updates:** Supports `list_changed` notifications — tools/prompts/resources refresh without reconnecting.
- **Startup timeout:** Set with `MCP_TIMEOUT` env var (e.g., `MCP_TIMEOUT=10000 claude` for 10s).

---

## Claude.ai MCP Connectors

MCP servers added in Claude.ai are automatically available in Claude Code when logged in with a Claude.ai account. Disable with:

```bash
ENABLE_CLAUDEAI_MCP_SERVERS=false claude
```

---

## Related Resources

- [MCP specification](https://modelcontextprotocol.io/introduction) — open source protocol
