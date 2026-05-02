---
name: create
description: >
  Create Claude Code artifacts — skill, agent, hook, output-style, plugin, mcp.
  Intelligently recommends the best artifact type for the desired behavior.
  Use when creating any new Claude Code extension or automation.
  Triggers on: "create a skill", "make an agent", "add a hook", "new output style",
  "create a plugin", "set up MCP server", "I want something that...".
argument-hint: "[type] [description]"
user-invocable: true
allowed-tools: Read Write Bash(jq *) Bash(ls *)
effort: medium
---

## Reference status
!`jq -r '"CC v" + .version + " - refs checked " + .timestamp' "${CLAUDE_SKILL_DIR}/scripts/.reference-cache.json" 2>/dev/null || echo "No ref cache — run: bash ${CLAUDE_SKILL_DIR}/scripts/check-references.sh --update"`

---

## Your task

Create a Claude Code artifact from `$ARGUMENTS`. Follow these steps in order.

---

## Step 1 — Parse arguments

Input: `$ARGUMENTS`

- **stated type**: first word of `$ARGUMENTS` if it matches a known type or alias (case-insensitive)
- **description**: everything after the stated type; or all of `$ARGUMENTS` if no valid type found

**Known types and aliases:**

| Canonical | Aliases |
|---|---|
| `skill` | `slash`, `command` |
| `agent` | `subagent` |
| `output-style` | `style`, `persona`, `tone` |
| `hook` | `hooks` |
| `plugin` | — |
| `mcp` | `mcp-server`, `server` |

---

## Step 2 — Determine recommended type

Check **combination signals first**. If none match, fall through to single-type signals.

### Combination signals (check first)

| Description contains… | Recommended | Notes |
|---|---|---|
| invokable task + automatically validate / check / enforce *during that task's tool calls* | `skill` with embedded `hooks` | Hooks scoped to this skill via `hooks:` frontmatter |
| dedicated AI + validates or prevents its own tool use | `agent` with embedded `hooks` | Same `hooks:` frontmatter; `Stop` auto-converts to `SubagentStop` |
| multiple distinct artifact types (e.g., skill + hook, agent + MCP) | `plugin` | Plugin is the container for mixed artifact sets |

**Combination rule:** "automatically" alone ≠ standalone hook. If the automatic action needs AI reasoning, or is scoped to one skill/agent's tool calls → embed hooks in the skill/agent instead.

Reference: `${CLAUDE_SKILL_DIR}/reference/claude-code-hooks.md` — "Hooks in skills and agents" section.

### Single-type signals (fallback)

| Description contains… | Recommended type | Reason |
|---|---|---|
| style / tone / personality / voice / respond like / act like / format responses | `output-style` | Persistent behavioral overlay — not a skill invocation |
| every time / on save / after edit / auto-run / pre-commit / automatically when X — *and no AI reasoning needed* | `hook` | Pure event-driven automation |
| distribute / share / team / publish / marketplace / use across projects | `plugin` | Needs packaging and namespacing |
| external API / connect to / integrate / MCP / tool server | `mcp` | Tool server protocol |
| specialized AI / expert in / isolated / dedicated agent | `agent` | Needs isolated context and system prompt |
| (none of the above) | `skill` | Default: invokable instruction set |

---

## Step 3 — Confirm type and name with user

**If stated type = recommended type (or type was clear and unambiguous):**

> "Creating a `<type>` named `<suggested-name>`. Does that look right? (Or suggest a different name)"

**If no type was given, or stated type ≠ recommended type:**

> "Based on your description, I'd recommend a `<recommended-type>` rather than a `<stated-type>` because `<one sentence reason>`. Shall I create a `<recommended-type>`, or did you want a `<stated-type>`?"

Derive `<suggested-name>` from the description: lowercase letters and hyphens only, max 32 characters.

**Wait for confirmation before continuing.**

---

## Step 4 — Gather context

Ask in one message:

1. "What's a concrete example of how you'd use this? (e.g., '/my-skill check the auth module' or 'whenever I push code, lint runs')"
2. *(skill type only)* "Should Claude be able to invoke this automatically when the situation matches, or only when you type /name explicitly?"

Use the answers to set frontmatter:

**Triggers described (user gave examples / automatic scenarios):**
- Populate `description` with the primary trigger (front-loaded, concise)
- Populate `when_to_use` with additional trigger phrases
- Do NOT set `disable-model-invocation` (AI must be able to invoke)
- *(skill only)* Ask: "Should users also invoke this manually with /name, or rely on auto-invocation only?" → If auto-only: set `user-invocable: false`

**No triggers (purely manual / on-demand):**
- `user-invocable: true` (default), omit `when_to_use`
- *(skill only)* May set `disable-model-invocation: true` if it's a pure side-effect workflow

**Always:** Recommend `allowed-tools` from the use case (file reads → `Read Glob`, git → `Bash(git *)`, web → `WebFetch WebSearch`, edits → `Read Write Edit`).

Skip questions for which the original description already has a clear answer.

**Wait for answer before continuing.**

---

## Step 5 — Scaffold

1. Read `${CLAUDE_SKILL_DIR}/templates/<confirmed-type>.md` (if it doesn't exist, scaffold from the reference doc alone)
2. If you need detail on the artifact format, read `${CLAUDE_SKILL_DIR}/reference/claude-code-<confirmed-type>.md`
3. Create all required files using Write, filling every placeholder from:
   - Confirmed name and location
   - User's description as the purpose/content guide
4. Show each file path as it's created

---

## Step 6 — Done

Tell the user:
1. Files created (paths)
2. How to activate/test it:
   - skill/agent/hook in plugin → `/reload-plugins`
   - skill/agent/hook standalone → restart session or `/agents`
   - output-style → `/config` → Output Style
   - mcp → `/mcp` to verify connection
3. Relevant reference doc if they want to customize: `${CLAUDE_SKILL_DIR}/reference/claude-code-<type>.md`
