---
name: deepen
description: >
  Make a task prompt deeper, not bigger. Analyses what a top professional would do, which raw source
  material they would start from, which methods and tools they would use, and what independent evidence
  would verify the result, then rewrites the prompt to ask for exactly that.
  Use when the user says "deepen this prompt", "make this task deeper", "tiefer, nicht größer",
  or pastes a task and wants a sharper version before running it.
argument-hint: "[task prompt to deepen]"
user-invocable: true
effort: medium
---

# Deepen

Goal: a **deeper** version of the user's task, not a **bigger** one. Depth means closer to how an expert actually works and verifies. It does not mean more sections, more deliverables, or more length.

## Input

The task prompt is the skill argument or the text the user pasted. If none is given, ask for it. Reply in the user's language (German or English); keep the rewritten prompt in the language of the original.

## Process

Answer the four questions below in order, **before** rewriting. Ground every answer in the specific field and task at hand. Generic advice ("do thorough research", "use best practices") is a failure. If the field is unclear, ask one question rather than guessing.

1. **What a top professional would do that the user is not asking for.**
   Name the moves an expert in this field makes by default that the prompt omits: framing the problem, questioning the premise, checking assumptions, choosing what to leave out, working in a different order. Pick the few that change the result most.

2. **The rawest material they would start from.**
   Name the primary sources, raw data, original documents, code, logs, measurements, or direct observations the expert would begin with, as opposed to summaries, articles, or other pre-digested material the user would otherwise get. Be concrete: name the dataset, filing, spec, repository, paper, or instrument.

3. **The specific methods and tools they would use.**
   Name actual techniques, frameworks, calculations, and tools, not categories. For each, say in one line what it does for this task.

4. **What, other than you or me, would show the result is right.**
   Name an external check that does not depend on the model's or the user's judgment: a test suite, a reproducible calculation, a benchmark, a primary source that can be cited and checked, a standard or regulation, a domain expert's review, a real-world trial. If nothing external exists, say so plainly and name the closest substitute.

## Rewrite

Then rewrite the user's prompt so it asks for exactly what questions 1-4 surfaced:

- Keep the original intent and scope. Do not add deliverables, sections, or extra scope.
- Require the raw sources from question 2 and the methods from question 3 by name.
- State the external check from question 4 as an acceptance criterion, with what to report if it cannot be met.
- Include only the expert moves from question 1 that change the result.
- Stay about as long as the original, or shorter. Cut anything that only makes the prompt bigger.

## Output format

1. **Expert moves**: short list
2. **Raw material**: short list
3. **Methods and tools**: short list
4. **External verification**: short list
5. **Rewritten prompt**: in a single block the user can copy

Do not run the rewritten prompt unless the user asks. Offer to run it as the final line.
