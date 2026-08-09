# TEKMidian Episodes

Scripts and notes that accompany the videos on
[TEKMidian](https://www.youtube.com/@tekmidian).

One directory per episode. Clone once, then `git pull` before each new video.

```bash
git clone https://github.com/mnott/tekmidian-episodes
cd tekmidian-episodes
```

## Episodes

| # | Episode | Directory |
|---|---|---|
| 001 | Install Claude Code on a fresh Mac | [`ep-001-install-claude`](ep-001-install-claude) |
| 002 | Give Claude Code a memory (PAI) | [`ep-002-install-pai`](ep-002-install-pai) |

## Read before you run

Every script here is short and meant to be read. Before running anything:

```bash
cat setup.sh
```

That is not a formality. You should not run other people's shell scripts without
looking at them, and these are deliberately kept small enough that looking is
quick.

None of these scripts require `sudo`. If one ever asks for your password,
something is wrong — stop and open an issue.
