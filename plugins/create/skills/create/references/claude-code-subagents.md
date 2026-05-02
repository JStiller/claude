---
name: sub-agents
description: Subagents are specialized AI assistants that handle specific tasks in their own context window. Use one when a side task would flood your main conversation with search results, logs, or file contents you won't reference again — the subagent does that work in isolation and returns only the summary.
---

# Claude Code Subagents – Official Reference

Source: <https://code.claude.com/docs/en/sub-agents>

---

## What Are Subagents?

Subagents are specialized AI assistants that handle specific tasks in their own context window. Use one when a side task would flood your main conversation with search results, logs, or file contents you won't reference again — the subagent does that work in isolation and returns only the summary.

**Subagents vs. Agent Teams:** Subagents work within a single session. [Agent teams](https://code.claude.com/docs/en/agent-teams) coordinate across separate sessions with sustained parallelism.

**Subagents vs. Skills:** Skills run in the main conversation context. Subagents run in isolated contexts with their own tools and permissions.

**Subagents vs. `/btw`:** For a quick question already in context with no tool access needed, use `/btw` instead.

Benefits:

- **Preserve context** — keep exploration/implementation out of your main conversation
- **Enforce constraints** — limit which tools a subagent can use
- **Reuse configurations** — user-level subagents available across all projects
- **Specialize behavior** — focused system prompts for specific domains
- **Control costs** — route tasks to faster/cheaper models like Haiku

**Important:** Subagents cannot spawn other subagents.

---

## Built-in Subagents

| Agent | Model | Tools | Purpose |
| :--- | :--- | :--- | :--- |
| **Explore** | Haiku (fast) | Read-only | File discovery, code search, codebase exploration |
| **Plan** | Inherits | Read-only | Codebase research during plan mode |
| **general-purpose** | Inherits | All tools | Complex research, multi-step operations, code modifications |
| statusline-setup | Sonnet | — | Auto-invoked by `/statusline` |
| Claude Code Guide | Haiku | — | Auto-invoked for Claude Code feature questions |

Explore accepts a thoroughness level: **quick**, **medium**, or **very thorough**.

---

## Subagent Locations & Priority

| Location | Scope | Priority |
| :--- | :--- | :---: |
| Managed settings | Organization-wide | 1 (highest) |
| `--agents` CLI flag | Current session only | 2 |
| `.claude/agents/` | Current project | 3 |
| `~/.claude/agents/` | All your projects | 4 |
| Plugin `agents/` directory | Where plugin is enabled | 5 (lowest) |

When multiple subagents share the same name, the higher-priority location wins.

**Project subagents** (`.claude/agents/`) — commit to version control for team sharing. Discovered by walking up from the current working directory.

**User subagents** (`~/.claude/agents/`) — available in all projects.

**CLI-defined subagents** — passed as JSON, exist only for that session:

```bash
claude --agents '{
  "code-reviewer": {
    "description": "Expert code reviewer. Use proactively after code changes.",
    "prompt": "You are a senior code reviewer...",
    "tools": ["Read", "Grep", "Glob", "Bash"],
    "model": "sonnet"
  }
}'
```

---

## Subagent File Format

```markdown
---
name: code-reviewer
description: Reviews code for quality and best practices
tools: Read, Glob, Grep
model: sonnet
---

You are a code reviewer. When invoked, analyze the code and provide
specific, actionable feedback on quality, security, and best practices.
```

The body becomes the system prompt. Subagents receive **only** this system prompt plus basic environment details — not the full Claude Code system prompt.

**Note:** Subagents are loaded at session start. After manually adding a file, restart the session or use `/agents` to load it immediately.

---

## Frontmatter Fields

Only `name` and `description` are required.

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | Yes | Unique identifier: lowercase letters and hyphens only |
| `description` | Yes | When Claude should delegate to this subagent |
| `tools` | No | Allowlist of tools. Inherits all if omitted |
| `disallowedTools` | No | Denylist of tools, removed from inherited/specified list |
| `model` | No | `sonnet`, `opus`, `haiku`, full model ID, or `inherit` (default) |
| `permissionMode` | No | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, `plan` |
| `maxTurns` | No | Maximum agentic turns before stopping |
| `skills` | No | Skills to inject at startup (full content, not just available for invocation) |
| `mcpServers` | No | MCP servers for this subagent (inline or reference by name) |
| `hooks` | No | Lifecycle hooks scoped to this subagent |
| `memory` | No | Persistent memory scope: `user`, `project`, or `local` |
| `background` | No | `true` = always run as background task. Default: `false` |
| `effort` | No | `low`, `medium`, `high`, `xhigh`, `max` — overrides session effort |
| `isolation` | No | `worktree` = run in temporary isolated git worktree |
| `color` | No | `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan` |
| `initialPrompt` | No | Auto-submitted as first user turn when agent runs as main session (via `--agent`) |

**Plugin subagents** cannot use `hooks`, `mcpServers`, or `permissionMode` (ignored).

---

## Model Resolution Order

When Claude invokes a subagent, the model is resolved in this order:

1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable
2. Per-invocation `model` parameter
3. Subagent definition's `model` frontmatter
4. Main conversation's model

---

## Tool Control

**Allowlist** (`tools`) — only listed tools available:

```yaml
tools: Read, Grep, Glob, Bash
```

**Denylist** (`disallowedTools`) — inherit all except listed:

```yaml
disallowedTools: Write, Edit
```

If both are set: `disallowedTools` applied first, then `tools` resolved against remaining pool.

**Restrict which subagents can be spawned** (for agents running as main thread with `--agent`):

```yaml
tools: Agent(worker, researcher), Read, Bash  # allowlist of spawnable agents
tools: Agent, Read, Bash                       # allow spawning any subagent
# Omitting Agent entirely: cannot spawn any subagents
```

---

## Permission Modes

| Mode | Behavior |
| :--- | :--- |
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits for paths in working dir / additionalDirectories |
| `auto` | Background classifier reviews commands and protected-directory writes |
| `dontAsk` | Auto-deny permission prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip all permission prompts ⚠️ |
| `plan` | Read-only exploration |

**Warning:** `bypassPermissions` allows writes to `.git`, `.claude`, `.vscode`, `.idea`, `.husky` without approval. Root/home `rm -rf` still prompts as circuit breaker.

**Inheritance rules:**

- If parent uses `bypassPermissions` or `acceptEdits` → takes precedence, cannot be overridden
- If parent uses `auto` → subagent inherits auto mode, `permissionMode` in frontmatter is ignored

---

## Preloading Skills

```yaml
---
name: api-developer
skills:
  - api-conventions
  - error-handling-patterns
---
```

Full skill content is injected at startup — not just made available for invocation. Subagents don't inherit parent's skills; must list explicitly. Cannot preload skills with `disable-model-invocation: true`.

---

## Persistent Memory

```yaml
memory: user   # or: project | local
```

| Scope | Location | Use when |
| :--- | :--- | :--- |
| `user` | `~/.claude/agent-memory/<name>/` | Learnings apply across all projects |
| `project` | `.claude/agent-memory/<name>/` | Project-specific, shareable via version control |
| `local` | `.claude/agent-memory-local/<name>/` | Project-specific, not in version control |

When enabled: system prompt includes memory instructions + first 200 lines/25KB of `MEMORY.md`. Read, Write, Edit tools are auto-enabled.

**Tips:**

- `project` is the recommended default
- Prompt the subagent to "check your memory before starting"
- Prompt the subagent to "update your memory after completing"
- Include memory update instructions directly in the subagent markdown body

---

## Hooks in Subagents

### In subagent frontmatter (scoped to the subagent)

```yaml
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate-command.sh"
  PostToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "./scripts/run-linter.sh"
```

`Stop` hooks in frontmatter are auto-converted to `SubagentStop` at runtime.

### In settings.json (project-level, react to subagent lifecycle)

```json
{
  "hooks": {
    "SubagentStart": [
      { "matcher": "db-agent", "hooks": [{ "type": "command", "command": "./scripts/setup.sh" }] }
    ],
    "SubagentStop": [
      { "hooks": [{ "type": "command", "command": "./scripts/cleanup.sh" }] }
    ]
  }
}
```

| Event | Matcher input | When it fires |
| :--- | :--- | :--- |
| `PreToolUse` | Tool name | Before subagent uses a tool |
| `PostToolUse` | Tool name | After subagent uses a tool |
| `Stop` | (none) | When subagent finishes |
| `SubagentStart` | Agent type name | When any subagent begins (settings.json) |
| `SubagentStop` | Agent type name | When any subagent completes (settings.json) |

---

## Invoking Subagents

### Automatic delegation

Claude uses the `description` field to decide when to delegate. Add "use proactively" to encourage automatic usage.

### Natural language

```text
Use the test-runner subagent to fix failing tests
```

### @-mention (guaranteed invocation)

```text
@"code-reviewer (agent)" look at the auth changes
```

Plugin subagents: `@agent-<plugin-name>:<agent-name>`

### Session-wide (replaces default system prompt)

```bash
claude --agent code-reviewer
```

Or set as default in `.claude/settings.json`:

```json
{ "agent": "code-reviewer" }
```

### Disable specific subagents

```json
{ "permissions": { "deny": ["Agent(Explore)", "Agent(my-custom-agent)"] } }
```

---

## Foreground vs. Background

**Foreground** — blocks main conversation; permission prompts and questions pass through.

**Background** — runs concurrently; permissions pre-approved before launch; auto-denies unapproved requests afterward. Press **Ctrl+B** to background a running task.

To disable all background tasks: `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`.

---

## Forked Subagents (Experimental)

Requires Claude Code v2.1.117+. Enable with `CLAUDE_CODE_FORK_SUBAGENT=1`.

A fork **inherits the entire conversation** (system prompt, tools, model, message history) instead of starting fresh. Tool calls stay out of your main context; only the final result returns.

```text
/fork draft unit tests for the parser changes so far
```

| | Fork | Named subagent |
| :--- | :--- | :--- |
| Context | Full conversation history | Fresh context |
| System prompt & tools | Same as main session | From definition file |
| Model | Same as main session | From `model` field |
| Permissions | Prompts surface in terminal | Pre-approved before launch |
| Prompt cache | Shared with main session | Separate cache |

When fork mode is enabled:

- General-purpose subagent is replaced by forks
- Every subagent spawn runs in background
- `/fork` spawns a fork (no longer an alias for `/branch`)

Fork panel keys:

| Key | Action |
| :--- | :--- |
| `↑` / `↓` | Move between rows |
| `Enter` | Open transcript / send follow-up |
| `x` | Dismiss finished fork or stop running one |
| `Esc` | Return focus to prompt input |

---

## Common Patterns

### Isolate high-volume operations

```text
Use a subagent to run the test suite and report only failing tests with error messages
```

### Parallel research

```text
Research the authentication, database, and API modules in parallel using separate subagents
```

### Chain subagents

```text
Use the code-reviewer subagent to find performance issues, then use the optimizer subagent to fix them
```

---

## When to Use What

| Scenario | Use |
| :--- | :--- |
| Frequent back-and-forth, iterative refinement | Main conversation |
| Phases sharing significant context | Main conversation |
| Quick, targeted change | Main conversation |
| Latency-sensitive task | Main conversation |
| Verbose output you don't need in main context | Subagent |
| Enforcing specific tool restrictions | Subagent |
| Self-contained work returning a summary | Subagent |
| Reusable prompt/workflow in main context | Skill |
| Quick side question already in context | `/btw` |
| Sustained parallelism beyond context window | Agent teams |

---

## MCP Servers Scoped to a Subagent

```yaml
mcpServers:
  - playwright:                          # inline: scoped to this subagent only
      type: stdio
      command: npx
      args: ["-y", "@playwright/mcp@latest"]
  - github                               # reference: reuses already-configured server
```

Inline servers connect when subagent starts, disconnect when it finishes. To keep an MCP server out of the main conversation entirely, define it inline here.

---

## Resume Subagents

Each invocation creates a new instance by default. To continue an existing subagent:

```text
Continue that code review and now analyze the authorization logic
```

Transcripts stored at: `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`

Cleanup period controlled by `cleanupPeriodDays` setting (default: 30 days).
