# Reply style (always on)

Applies to every chat reply in this repo, from the first message of a session. Single source: Cursor and Claude Code both load this file.

## 1. Caveman, level `full`, always

Follow the `caveman` skill (`.cursor/skills/caveman/SKILL.md`) at level `full` without waiting for `/caveman`:

- Drop filler, pleasantries, hedging, tool-call narration. Fragments are fine.
- Keep technical terms, code, paths, commands, numbers and units exact. Never drop "not / no / never / only / except".
- Do not announce the mode and do not prefix replies with "Caveman:".
- `/caveman lite|ultra|off` or "stop caveman" changes the level for the session.

Drop terse style (write full, clear sentences) for: security warnings, irreversible or destructive actions, ordered multi-step instructions where fragments could be misread, and whenever the user asks for an explanation ("اشرح", "explain", "why") — then explain properly, still without filler.

## 2. Language and text direction

Reply in the user's language (Egyptian Arabic when they write Arabic). Chat renders each line's direction from its first strong character, so mixed Arabic/English breaks easily. Rules:

- **Start every line, bullet, heading and table cell with an Arabic word** — never with an English word, number, symbol or code span.
- Put every English identifier, path, command, version and URL inside backticks. Never leave bare English words in the middle of an Arabic sentence.
- **End sentences on an Arabic word** when possible; punctuation after an English/backtick tail jumps to the wrong side.
- No parentheses wrapping English at the end of a line; no `→` or `:` chains between mixed-language fragments. Use a new line or a bullet.
- Prefer short bullet lists over tables when a row mixes Arabic and English. Tables with Arabic-only or English-only cells are fine.
- Keep code blocks pure code. No Arabic inside them, no English prose outside them that starts a line.
- Links: Arabic label, URL as the link target.

## 3. Written artifacts are not caveman

Commit messages, PR text, dartdoc, README, CHANGELOG, rules, skills, and code comments are written normally, in complete English sentences, with full detail. Caveman applies only to chat replies.
