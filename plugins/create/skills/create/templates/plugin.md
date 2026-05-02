# Plugin Scaffold

## What you're creating
A Claude Code plugin — a distributable package containing skills, agents, hooks, MCP servers, and/or settings.

## Directory structure

```
<plugin-name>/
├── .claude-plugin/
│   └── plugin.json          # Required manifest — ONLY this file goes here
├── skills/
│   └── <skill-name>/
│       └── SKILL.md         # At minimum, create one skill
├── agents/                  # Optional — custom subagents
├── hooks/
│   └── hooks.json           # Optional — lifecycle hooks
├── .mcp.json                # Optional — MCP server configs
└── settings.json            # Optional — only "agent" and "subagentStatusLine" keys supported
```

## plugin.json

```json
{
  "$schema": "https://json.schemastore.org/claude-code-plugin-manifest.json",
  "name": "<plugin-name>",
  "description": "<shown in plugin manager when browsing/installing>",
  "version": "0.1.0",
  "author": {
    "name": "<name>",
    "email": "<email>",
    "url": "<url>"
  },
  "license": "MIT"
}
```

## Naming rules
- `name` must be lowercase letters, numbers, hyphens only.
- Skill names are namespaced: `/plugin-name:skill-name`
- Agent @-mention: `@agent-plugin-name:agent-name`

## Local development

```bash
# Load without installing
claude --plugin-dir ./<plugin-name>

# Reload after edits (no restart needed)
/reload-plugins
```

## Tips
- Create only the subdirectories you need — skip empty dirs.
- Plugin subagents cannot use `hooks`, `mcpServers`, or `permissionMode` frontmatter (ignored for security).
- Bump `version` to push updates to installed users.
- Submit to marketplace: `https://claude.ai/settings/plugins/submit`

## Full plugin reference
`${CLAUDE_SKILL_DIR}/references/claude-code-plugins.md`
