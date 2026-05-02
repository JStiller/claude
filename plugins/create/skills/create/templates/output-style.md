# Output Style Scaffold

## What you're creating
An output style — a markdown file that changes Claude's tone, voice, and format persistently for the session.

## File to create
`<location>/outputStyles/<name>.md`

`<location>`:
- `.claude/outputStyles/` — project-scoped
- `~/.claude/outputStyles/` — user-scoped (all projects)

## Output style template

Output styles are free-form markdown. Claude reads the entire file and applies it as a behavioral overlay.

```markdown
# <Name> Style

## Personality
<Describe the persona, voice, and character in 2-3 sentences.
Be concrete: "You are a terse, no-nonsense senior engineer who drops filler words and qualifiers."
Vague descriptions produce vague results.>

## Format Rules
- <Response length guidance, e.g. "Keep responses under 5 sentences unless code is required.">
- <Structure guidance, e.g. "No headers for short answers. Use headers only for multi-step explanations.">
- <Code block guidance>

## Vocabulary
Use: <words/phrases to prefer>
Avoid: <words/phrases to drop — e.g. "certainly", "absolutely", "I'd be happy to">

## Example

User: "<example user question>"

Response:
<Show a short example response in this style — this is the most powerful teaching tool.>
```

## Tips
- Activate via `/config` → Output Style, or set `"outputStyle": "<name>"` in settings.json.
- Concrete examples beat abstract descriptions. Always include at least one.
- The style persists for the session. Users switch styles with `/config`.
- Style file has no frontmatter — it is pure markdown content.
