---
name: commit-with-coauthor
description: Ends every git commit message with the repo owner's Co-Authored-By trailer. Use whenever writing, creating, or amending a git commit, running git commit, or drafting a commit message for this repository.
---

# Commit with co-author trailer

Every commit message ends with this line, exactly as written:

```
Co-Authored-By: Mohammed El Shora <riyadm2001@gmail.com>
```

## Rules

- It is the **last** line of the message, separated from the body by one blank line.
- Applies to `git commit`, `git commit --amend`, and any commit message drafted for the user to paste elsewhere.
- Already present? Leave it. Never write it twice.
- Another co-author trailer in the message stays where it is; this one goes after it.
- Title and bullets: Conventional Commits as in `CLAUDE.md`. This skill only adds the trailer.

## Committing

```bash
git commit -m "$(cat <<'EOF'
feat(scope): short imperative summary

- what changed and why

Co-Authored-By: Mohammed El Shora <riyadm2001@gmail.com>
EOF
)"
```

## Hook (safety net)

```bash
cp .cursor/skills/commit-with-coauthor/commit-msg .git/hooks/
chmod +x .git/hooks/commit-msg
```

Still write the trailer yourself — hooks are skipped by `--no-verify`.
