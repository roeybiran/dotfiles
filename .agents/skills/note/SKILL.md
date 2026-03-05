---
name: note
description: Update AGENTS.md instructions from user notes. Use when a user asks to add, revise, remove, or reorganize project operating instructions in AGENTS.md. Default to the current project's AGENTS.md, and only target global AGENTS.md when the user explicitly asks for global scope.
---

# Note

Apply user-provided notes to AGENTS.md with minimal, precise edits and clear scope handling.

## Scope Resolution

1. Resolve target scope before editing:
- `project` (default): modify the current project's AGENTS.md.
- `global` (only when explicitly requested): modify global AGENTS.md.
2. Never edit both files unless the user explicitly asks for both.
3. If scope is not explicit, assume `project`.

## Target File Rules

1. For `project` scope:
- Prefer `./AGENTS.md` in the current workspace.
- If missing, search upward from the current directory for the nearest `AGENTS.md`.
- If none exists, create `./AGENTS.md`.
2. For `global` scope:
- Prefer `$CODEX_HOME/AGENTS.md` when `CODEX_HOME` is set.
- Otherwise use `$HOME/.codex/AGENTS.md`.
- If missing, create it.

## Editing Workflow

1. Read the existing target file fully.
2. Convert user input into concrete edits:
- Add new rules as concise bullets.
- Revise existing rules instead of duplicating them.
- Remove rules only when asked.
3. Preserve unrelated instructions and existing structure where possible.
4. Keep wording directive and actionable; avoid narrative text.
5. Write changes directly to the resolved AGENTS.md path.

## Output Expectations

1. Report which AGENTS.md path was modified.
2. Summarize what was added, changed, or removed.
3. Call out assumptions only when necessary (for example, inferred project scope).
