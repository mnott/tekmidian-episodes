# EP-001 — From a fresh Mac to a working Claude Code

Companion to the video. Six commands, in order.

**You need** a Claude **Pro, Max, Team, Enterprise or Console** account. The free
Claude.ai plan does not include Claude Code.

---

## 1. Install the developer tools

```bash
xcode-select --install
```

A dialog appears. Confirm it and accept the licence. It takes about **12 minutes**
and downloads roughly a gigabyte.

If you already have them you will see `command line tools are already installed`.
That is fine — carry on.

## 2. Check git works

```bash
git --version
```

## 3. Get this repository

```bash
git clone https://github.com/mnott/tekmidian-episodes
cd tekmidian-episodes/ep-001-install-claude
```

## 4. Read the script, then run it

```bash
cat setup.sh
./setup.sh
```

## 5. Open a new terminal

**Required.** `setup.sh` writes the PATH line to your shell config, but it
cannot change the shell you ran it from — no script can change its parent's
environment. Until you open a new terminal, `claude` will still say
*command not found*.

Open a new window (⌘N), or:

```bash
source ~/.zshrc
```

## 6. Verify and sign in

```bash
claude --version
claude doctor
claude
```

---

## Why the developer tools first?

You need git, and on a clean Mac git does not really exist yet.

`/usr/bin/git` is on every Mac, so checking for it *looks* like success — but it
is a stub. It is the `xcrun` shim whose only job is to offer to install the real
tools. Run it and you get a dialog, not a version.

To check without triggering anything:

```bash
xcode-select -p
```

That reports the active developer directory, which either the Command Line Tools
or full Xcode provides. On a machine with neither it fails with:

```
xcode-select: error: Unable to get active developer directory.
Use `sudo xcode-select --switch path/to/Xcode.app` to set one
```

**Ignore that suggestion.** It is meant for machines that have Xcode installed
but pointed somewhere odd. On a fresh Mac it leads nowhere. Run
`xcode-select --install` instead.

## Why this installer, and not npm or Homebrew?

`setup.sh` uses Anthropic's official native installer:

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

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

`~/.local/bin` is not on the default macOS PATH.

`setup.sh` writes the line to your shell config, but **it cannot change the shell
you ran it from** — a child process cannot modify its parent's environment. So
this is expected, not a fault:

```bash
source ~/.zshrc      # or just open a new terminal window
```

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

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `claude: command not found` after installing | `~/.local/bin` not on PATH | New terminal, or `export PATH="$HOME/.local/bin:$PATH"` |
| `unable to get active developer directory` | Developer tools missing | Step 1 |
| `git --version` opens a dialog | `/usr/bin/git` is the stub | Step 1 |
| `command line tools are already installed` | They are | Nothing — continue |
| Sign-in fails or loops | Free Claude.ai plan | Needs Pro, Max, Team, Enterprise or Console |

## Reference

- [Claude Code setup docs](https://docs.claude.com/en/docs/claude-code/setup)
