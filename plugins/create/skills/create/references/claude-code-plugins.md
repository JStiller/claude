---
name: plugins
description: 
---

# Claude Code Plugins – Official Reference

Source: <https://code.claude.com/docs/en/plugins>

---

## Plugins vs. Standalone Configuration

| Approach | Skill names | Best for |
| :--- | :--- | :--- |
| **Standalone** (`.claude/` directory) | `/hello` | Personal workflows, project-specific config, quick experiments |
| **Plugins** (`.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing with teams, distributing to community, versioned releases, reuse across projects |

**Use standalone when:** single project, personal, experimenting, want short names like `/deploy`.

**Use plugins when:** sharing with team/community, same skills across multiple projects, versioned distribution, marketplace listing. Plugin skills are namespaced (e.g., `/my-plugin:hello`) to prevent conflicts.

**Recommended workflow:** Start with standalone `.claude/` for quick iteration, then convert to a plugin when ready to share.

---

## Plugin Directory Structure

```text
my-plugin/
├── .claude-plugin/        # ONLY plugin.json goes here
│   └── plugin.json        # Plugin manifest (required)
├── skills/                # Skills as <name>/SKILL.md directories
├── commands/              # Skills as flat Markdown files (legacy; prefer skills/)
├── agents/                # Custom agent definitions
├── hooks/
│   └── hooks.json         # Event handlers
├── .mcp.json              # MCP server configurations
├── .lsp.json              # LSP server configurations
├── monitors/
│   └── monitors.json      # Background monitor configurations
├── bin/                   # Executables added to Bash tool's PATH
└── settings.json          # Default settings applied when plugin is enabled
```

**Common mistake:** Do NOT put `skills/`, `agents/`, `hooks/`, or `commands/` inside `.claude-plugin/`. Only `plugin.json` goes there.

---

## Plugin Manifest (`plugin.json`)

```json
{
  "name": "my-first-plugin",
  "description": "A greeting plugin to learn the basics",
  "version": "1.0.0",
  "author": {
    "name": "Your Name"
  }
}
```

| Field | Required | Purpose |
| :--- | :--- | :--- |
| `name` | Yes | Unique identifier and skill namespace prefix (e.g., `/my-first-plugin:hello`) |
| `description` | Yes | Shown in plugin manager when browsing/installing |
| `version` | No | Bump to trigger updates. If omitted and distributed via git, commit SHA is used |
| `author` | No | Attribution |
| `homepage` | No | URL for plugin homepage |
| `repository` | No | Source repository URL |
| `license` | No | License identifier |

---

## Skills in Plugins

```text
my-plugin/
└── skills/
    └── code-review/
        └── SKILL.md
```

The folder name becomes the skill name, prefixed with the plugin's `name` field:
`skills/hello/` in plugin `my-first-plugin` → `/my-first-plugin:hello`

```yaml
---
description: Reviews code for best practices and potential issues. Use when reviewing PRs or analyzing code quality.
disable-model-invocation: true
---

When reviewing code, check for:
1. Code organization and structure
2. Error handling and security concerns
3. Test coverage
```

After installing or editing, run `/reload-plugins` to pick up changes.

---

## Agents in Plugins

Place agent Markdown files in `agents/` at the plugin root. Plugin subagents use the `plugin-name:agent-name` namespace and appear in `/agents` alongside custom subagents.

**Restriction:** Plugin subagents cannot use `hooks`, `mcpServers`, or `permissionMode` frontmatter fields (ignored for security). To use these, copy the agent file to `.claude/agents/` or `~/.claude/agents/`.

---

## Hooks in Plugins

Create `hooks/hooks.json` with the same format as the `hooks` object in `settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path' | xargs npm run lint:fix"
          }
        ]
      }
    ]
  }
}
```

The command receives hook input as JSON on stdin.

---

## MCP Servers in Plugins

Add `.mcp.json` at the plugin root — same format as project-level `.mcp.json`:

```json
{
  "mcpServers": {
    "my-server": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "my-mcp-server"]
    }
  }
}
```

---

## LSP Servers in Plugins

Add `.lsp.json` at the plugin root. Use for languages not covered by official LSP plugins:

```json
{
  "go": {
    "command": "gopls",
    "args": ["serve"],
    "extensionToLanguage": {
      ".go": "go"
    }
  }
}
```

Users must have the language server binary installed. For common languages (TypeScript, Python, Rust), install pre-built LSP plugins from the official marketplace instead.

---

## Background Monitors

Add `monitors/monitors.json` — each stdout line from the command is delivered to Claude as a notification:

```json
[
  {
    "name": "error-log",
    "command": "tail -F ./logs/error.log",
    "description": "Application error log"
  }
]
```

Monitors start automatically when the plugin is active.

---

## Default Settings

Add `settings.json` at the plugin root. Currently only `agent` and `subagentStatusLine` keys are supported:

```json
{
  "agent": "security-reviewer"
}
```

Setting `agent` activates one of the plugin's custom agents as the main thread, replacing the default system prompt. Settings in `settings.json` take priority over `settings` declared in `plugin.json`. Unknown keys are silently ignored.

---

## Local Development & Testing

Load a plugin without installing it:

```bash
claude --plugin-dir ./my-plugin
```

Multiple plugins at once:

```bash
claude --plugin-dir ./plugin-one --plugin-dir ./plugin-two
```

When a `--plugin-dir` plugin has the same name as an installed marketplace plugin, the local copy takes precedence (except marketplace plugins force-enabled by managed settings).

**During development:**

- Edit files → run `/reload-plugins` to pick up changes without restarting
- Try skills: `/plugin-name:skill-name`
- Check agents: `/agents`
- Verify hooks trigger correctly

---

## Migrating Standalone Config to a Plugin

| Standalone (`.claude/`) | Plugin |
| :--- | :--- |
| Only available in one project | Can be shared via marketplaces |
| Files in `.claude/commands/` | Files in `plugin-name/commands/` |
| Hooks in `settings.json` | Hooks in `hooks/hooks.json` |
| Must manually copy to share | Install with `/plugin install` |

Migration steps:

```bash
# 1. Create plugin structure
mkdir -p my-plugin/.claude-plugin

# 2. Create plugin.json
# { "name": "my-plugin", "description": "...", "version": "1.0.0" }

# 3. Copy existing files
cp -r .claude/commands my-plugin/
cp -r .claude/agents my-plugin/
cp -r .claude/skills my-plugin/

# 4. Test
claude --plugin-dir ./my-plugin
```

After migrating: remove original files from `.claude/` to avoid duplicates.

---

## Distribution

### Version Management

- **With `version` field:** users only receive updates when you bump the field
- **Without `version` field** (git-distributed): every commit counts as a new version (commit SHA used)

### Sharing Options

| Method | Use for |
| :--- | :--- |
| `--plugin-dir` flag | Development and local testing |
| Git repository (team marketplace) | Internal team distribution |
| Official Anthropic marketplace | Public community distribution |
| Private repository marketplace | Internal org distribution |

### Submit to Official Marketplace

- Claude.ai: `https://claude.ai/settings/plugins/submit`
- Console: `https://platform.claude.com/platform.claude.com/plugins/submit`

Once listed, you can prompt Claude Code users to install your plugin from your CLI using plugin hints.

---

## Plugin Permissions & Security

- Plugin subagents: `hooks`, `mcpServers`, `permissionMode` fields are ignored
- MCP servers and hooks from plugins run with the same permissions as user-defined hooks
- Managed settings can force-enable plugins that cannot be overridden by `--plugin-dir`

---

## Related Resources

- [Plugins reference](https://code.claude.com/docs/en/plugins-reference) — complete technical specifications
- [Discover and install plugins](https://code.claude.com/docs/en/discover-plugins) — browsing and installing
- [Plugin marketplaces](https://code.claude.com/docs/en/plugin-marketplaces) — creating and distributing
