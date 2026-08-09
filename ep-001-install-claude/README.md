# EP-001 — Install Claude Code on a fresh Mac

Companion to the video. Two commands, about two minutes.

**You need** a Claude **Pro, Max, Team, Enterprise or Console** account. The free
Claude.ai plan does not include Claude Code.

You do **not** need Node, Homebrew, Xcode or git. Nothing but a Mac and `curl`,
which macOS already has.

---

## 1. Install

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

## 2. Open a new terminal

**Required.** The installer puts `claude` in `~/.local/bin`, which is not on the
default macOS PATH, and it does not edit your shell config for you. It prints a
note telling you to do it:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
```

Then open a new terminal window, or `source ~/.zshrc`.

## 3. Verify and sign in

```bash
claude --version
claude doctor
claude
```

`claude` opens a browser to sign in. That is the whole installation.

---

## Why this installer, and not npm or Homebrew?

- **No Node needed.** The npm route means installing Node first — another
  download, another concept, and the global-install permission trap.
- **No Homebrew needed.** Installing a package manager to get one tool is a
  bigger detour than the tool.
- **No `sudo`.** It installs under your home directory. Nothing touches system
  paths, and you are never asked for a password.
- **It updates itself.** Native installs update in the background. Homebrew and
  npm installs have to be updated by hand.

It lands in:

- `~/.local/bin/claude` — the launcher
- `~/.local/share/claude/versions/` — the versions themselves

## "command not found" right after installing

The commonest stumble, and it does not mean the install failed.

`~/.local/bin` is not on the default macOS PATH, and **a script cannot change
the PATH of the shell you launched it from** — no script can modify its parent's
environment. So this is expected:

```bash
source ~/.zshrc      # or just open a new terminal window
```

## `claude doctor`

Read-only diagnostics: install health, settings problems, warnings with
suggested fixes. It is what to run when something looks wrong, and almost nobody
discovers it exists.

---

## Optional — the script

If you already have git, everything above is also in `setup.sh`, which adds one
thing: it writes the PATH line for you, creating `~/.zshrc` if you do not have
one (a clean Mac does not).

```bash
cat setup.sh
./setup.sh
```

Read it first. That is worth doing with any script you find on the internet, and
these are kept short enough that reading them is quick.

## Optional — fewer permission prompts

Claude Code asks before it acts. If you are new to it, leave that alone for a
while: watching what it wants to do is how you learn what it does.

If you use it constantly, the prompts wear thin. `setup.sh` ships a starter
config, [`settings.starter.json`](settings.starter.json), which skips prompts by
default while keeping a deny list for destructive commands.

**It is only installed on a brand-new install.** If Claude Code was already on
your machine when you ran the script, nothing is changed — you already have a
way of working and it is not ours to override. Even on a fresh install, an
existing `~/.claude/settings.json` is never overwritten.

To go back to being asked about everything, delete `~/.claude/settings.json`.

### What a deny list is, and is not

Worth being precise, because a long deny list creates a feeling of safety it
cannot deliver.

Deny rules are **string matches**. A rule blocking one spelling of a destructive
command does not block its variants — different flag order, different quoting,
or the same thing reached from another directory. They catch a mistyped command,
not a determined one, and they are not a sandbox.

The starter list is deliberately short and grouped by category: whole-disk
erasure, home-directory deletion, raw disk writes, irreversible git operations,
keychain dumps. A dozen rules you have read beat fifty you have not.

Your real safety net is committed git history, backups, and — while
experimenting — a virtual machine with a snapshot.

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `claude: command not found` after installing | `~/.local/bin` not on PATH | New terminal, or `source ~/.zshrc` |
| Sign-in fails or loops | Free Claude.ai plan | Needs Pro, Max, Team, Enterprise or Console |
| `claude doctor` reports a launcher it did not create | A custom `~/.local/bin/claude` | Remove it and run `claude update` |

## Next

[EP-002](../ep-002-install-pai) gives Claude Code a memory that survives
restarts — and that one does need developer tools, git and Docker.

## Reference

- [Claude Code setup docs](https://docs.claude.com/en/docs/claude-code/setup)
