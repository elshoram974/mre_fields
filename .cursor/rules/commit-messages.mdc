---
description: Commit messages — staged changes first, otherwise all pending; full detail, Conventional Commits, co-author trailer
globs: "*"
alwaysApply: true
---
# Commit messages (ALWAYS)

The full rules live in the repository root: @.cursorrules

Summary (the root file wins on any detail):

- Run `git diff --cached --name-only` first. Output present → describe ONLY `git diff --cached`; never run `git diff` without `--cached` or `git status`, never use chat history or open files to find changes. Output empty → describe all pending changes, including untracked files.
- `type(scope): imperative summary` ≤ 72 chars, blank line, explanatory body, footer.
- Body explains what changed and why, per logical change, naming real symbols from the diff; flags removed public API and `BREAKING CHANGE:`.
- Last line, exactly once: `Co-Authored-By: Mohammed El Shora <riyadm2001@gmail.com>`.
- Output only the message. Never describe code that is not in the diff.
