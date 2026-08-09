# EP-002 — Give Claude Code a memory

Companion to the video. Installs [PAI](https://github.com/mnott/PAI), which adds
persistent memory across sessions.

**Assumes** you finished [EP-001](../ep-001-install-claude) and have Claude Code
working.

Unlike EP-001, this one has real prerequisites: developer tools, git, and Docker
for the Postgres database. Budget half an hour, most of it downloads.

> **Status: not yet rehearsed end to end.** Written from the PAI documentation
> and a partial run. Expect the details to shift once it has been done start to
> finish on a clean machine.

---

## 1. Developer tools

```bash
xcode-select -p 2>/dev/null || xcode-select --install
```

A dialog appears. Confirm it and accept the licence. **About 12 minutes**,
roughly a gigabyte. If they are already installed the command prints the path
and stops.

You need this for **git**, which a clean Mac does not really have. `/usr/bin/git`
exists on every Mac, so checking for it looks like success — but it is a stub
whose only job is to offer to install the real tools. `xcode-select -p` is the
honest test: it reports the active developer directory, which either the
Command Line Tools or full Xcode provides.

If nothing is installed it fails with:

```
xcode-select: error: Unable to get active developer directory.
Use `sudo xcode-select --switch path/to/Xcode.app` to set one
```

**Ignore that suggestion.** It is meant for machines that have Xcode pointed
somewhere odd. On a fresh Mac it leads nowhere.

## 2. Check git

```bash
git --version
```

## 3. Get this repository

```bash
git clone https://github.com/mnott/tekmidian-episodes
cd tekmidian-episodes/ep-002-install-pai
```

## 4. Docker

PAI stores its memory in Postgres with the pgvector extension, run in a
container.

```bash
docker --version
```

If you already have Docker, use it. If not, either
[Docker Desktop](https://www.docker.com/products/docker-desktop/) or Colima will
do — Colima runs containers without the Desktop app, which suits a
terminal-centric setup and has no licence conditions:

```bash
brew install colima docker docker-compose
colima start
```

Verify before continuing:

```bash
docker run --rm hello-world
```

**Docker Desktop's default VM is 4 GB**, which is too small once your memory
index grows: the vector index alone can pass a gigabyte, and it will never stay
cached. Raise it in Settings ▸ Resources ▸ Memory — 8 GB is a reasonable figure
on a 16 GB machine or larger.

## 5. Install PAI

The documented way is to ask Claude Code:

```
Clone https://github.com/mnott/PAI and set it up for me
```

It works on a bare machine — it detects what is missing and installs it. Or do
it yourself:

```bash
git clone https://github.com/mnott/PAI
cd PAI
bun install
bun run build
pai setup
```

## 6. The setup wizard

`pai setup` asks about storage. **Choose PostgreSQL with pgvector** — SQLite
works but gives you keyword search only, no semantic search, which is most of
the point.

If Docker is not running when you reach this step, the wizard falls through to
asking for a connection string, which is a dead end. Sort out step 4 first.

## 7. Start the daemon

```bash
pai daemon start
pai daemon status      # should say running
pai memory search test # should return results once indexing has run
```

---

## Where your data lives

The Postgres data is bind-mounted to `~/.pai/pgdata` on your machine, not held
in a Docker-managed volume.

That distinction matters on macOS. A named Docker volume lives *inside* Docker's
Linux VM, where you cannot browse it, copy it, or pick it up with your normal
backups. A bind mount is an ordinary directory you can see.

The database is not small — a working install can reach tens of gigabytes, most
of it embeddings — so it is worth knowing where it is before you need to find
it.

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| Wizard asks for a connection string | Docker not running | Step 4, then re-run `pai setup` |
| `git --version` opens a dialog | `/usr/bin/git` is the stub | Step 1 |
| Daemon runs but finds nothing | Container is not up | `docker ps`; with Colima also `colima start` |
| Searches feel slow | Vector index not cached | Raise the Docker VM memory, step 4 |

## A note on Colima and restarts

Docker Desktop starts at login. **Colima does not.** PAI's daemon *does* start at
login, so after a reboot you can end up with a daemon talking to a database that
is not running. Until that is smoothed over, run `colima start` after rebooting.

## Reference

- [PAI](https://github.com/mnott/PAI)
