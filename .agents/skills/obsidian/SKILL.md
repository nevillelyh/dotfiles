---
name: obsidian
description: Work with the user's Obsidian notes or vault, including locating, reading, creating, editing, organizing, or versioning notes. Use for requests mentioning "my Obsidian", "my notes", or "my vault".
---

# Obsidian

Use the Obsidian CLI for vault-aware operations such as search, note lookup, properties, links, and opening notes. Use `obsidian help <command>` when needed.

For note content edits:

1. Resolve the vault root with `obsidian eval code="app.vault.adapter.basePath"` when it is not already known.
2. Check the vault Git status. If clean, pull with rebase before editing; preserve and account for existing user changes if dirty.
3. Edit Markdown files directly with `apply_patch`; do not use `obsidian eval` for prose replacement.
4. Review the diff and run relevant validation.
5. Commit and push directly with Git. Use `git-agent` for commits or rebases when needed to avoid editor and signing prompts. Do not use the Obsidian Git plugin for agent-driven edits.

For note metadata:

- Store attributes as Obsidian Properties in YAML frontmatter.
- Use only these properties when applicable:
  - `created`: creation date in `YYYY-MM-DD` format
  - `tags`: purpose and subjects, such as `idea`, `todo`, `fixme`, `investigation`, or `troubleshooting`
  - `repos`: canonical HTTPS repository URLs
  - `issues`: canonical HTTPS issue URLs
  - `prs`: canonical HTTPS pull-request URLs
- Store `tags`, `repos`, `issues`, and `prs` as lists, even for one value. Omit properties that do not apply.
- Use `https://gitea.home.lyh.me` as the HTTP(S) host for Gitea URLs; `git.home.lyh.me` is SSH-only.

If a CLI operation is needed and no Obsidian instance is running, start the app, wait, and retry:

- macOS: `open -a Obsidian`
- Linux (Flatpak): `flatpak run md.obsidian.Obsidian`
