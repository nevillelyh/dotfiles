# Agent Notes

## Git

The user's normal Git setup signs commits and uses `nvim` as the editor. For
agent-driven Git operations, avoid interactive editor and GPG prompts.

Use the repo-provided wrapper for mutating Git commands:

```sh
git-agent status
git-agent rebase main
git-agent commit -m "message"
```

If the wrapper is not available on `PATH`, run it directly:

```sh
~/.dotfiles/bin/git-agent rebase main
```

For one-off commands without the wrapper, use equivalent overrides:

```sh
GIT_EDITOR=true GIT_SEQUENCE_EDITOR=true \
  git -c core.editor=true \
      -c sequence.editor=true \
      -c commit.gpgSign=false \
      -c tag.gpgSign=false \
      "$@"
```

Do not change the user's global signing or editor defaults just to complete an
agent task.
