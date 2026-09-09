---
name: conventional-commit
description: >
  Enforce Conventional Commits v1.0.0 format whenever a git commit is created.
  Use when making a git commit, writing a commit message, staging and committing
  changes, or when a Bash(git commit) call is about to run.
  Trigger on: "commit", "git commit", "commit the changes", "commit this",
  "make a commit", "stage and commit", "write a commit message", "commit message".
when_to_use: >
  Activate any time a git commit is about to be created — whether the user asks
  to "commit", "save to git", "push a commit", "finalize the change", or whenever
  a Bash(git commit *) call is imminent. Also trigger when writing or formatting
  a commit message from scratch.
allowed-tools: Bash(git *)
effort: low
user-invocable: true
---

# Conventional Commits — Enforcement Guide

Every git commit in this session MUST follow the Conventional Commits v1.0.0
specification. Commit messages MUST always be written in English.

---

## Commit Message Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Rules

1. **type** — required. Lowercase. One of the allowed types listed below.
2. **scope** — optional. Lowercase noun in parentheses describing the affected module: `feat(auth):`, `fix(db):`.
3. **description** — required. Imperative, lowercase, no period at end. Summarises the change in one line.
4. **body** — optional. Free-form prose explaining the *why*, not the *what*. Separated from the description by one blank line.
5. **footers** — optional. Each footer on its own line after a blank line. Token: value format (e.g. `Reviewed-by: Alice`). `BREAKING CHANGE:` is a special footer token.

---

## Allowed Types & SemVer Mapping

| Type | SemVer impact | When to use |
|------|--------------|-------------|
| `feat` | **MINOR** | A new feature visible to the user or caller |
| `fix` | **PATCH** | A bug fix |
| `perf` | **PATCH** | A change that improves performance without altering API |
| `refactor` | none | Code restructuring with no behaviour change and no new feature |
| `test` | none | Adding or correcting tests |
| `docs` | none | Documentation only |
| `build` | none | Build system, dependencies, tooling |
| `ci` | none | CI/CD configuration and scripts |
| `chore` | none | Maintenance that doesn't fit any other type |
| `style` | none | Formatting, whitespace — no logic change |
| `revert` | depends | Reverts a previous commit |

---

## Breaking Changes → MAJOR bump

A breaking change is signalled in **one of two ways** (both are valid):

```
feat!: drop support for Node 18
```

```
feat(api): change response shape

BREAKING CHANGE: the `data` field is now nested under `result`
```

Use `!` for a short inline signal. Use the `BREAKING CHANGE:` footer when
additional explanation is needed.

---

## Examples

**Minimal — patch fix:**
```
fix(parser): handle empty input without crashing
```

**Feature with scope:**
```
feat(auth): add OAuth2 login flow
```

**Breaking change via footer:**
```
feat(api): rename /users endpoint to /accounts

BREAKING CHANGE: all clients must update the base URL from /users to /accounts
```

**Refactor with body:**
```
refactor(db): extract query builder into separate module

The query logic was duplicated across three repositories.
This centralises it without changing any observable behaviour.
```

---

## Commit Checklist

Before running `git commit`:

- [ ] Type is one of the allowed types above
- [ ] Description is in English, imperative mood, lowercase, no trailing period
- [ ] Scope (if used) is a single lowercase noun
- [ ] Breaking change is marked with `!` or `BREAKING CHANGE:` footer
- [ ] Message is passed via HEREDOC to avoid shell escaping issues:

```bash
git commit -m "$(cat <<'EOF'
feat(scope): description

Optional body here.
EOF
)"
```
