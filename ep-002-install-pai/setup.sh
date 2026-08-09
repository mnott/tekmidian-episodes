#!/usr/bin/env bash
#
# EP-002 — prerequisites for PAI.
#
# Checks and, where it can, installs what PAI needs: developer tools (for git),
# a working Docker, and bun. It deliberately stops short of installing PAI
# itself: `pai setup` is an interactive wizard and should be run by you, with
# your eyes on the questions it asks.
#
# NOT YET REHEARSED END TO END. Read it before running it.
#
# Safe to run twice.

set -euo pipefail

say  () { printf '\n\033[1m%s\033[0m\n' "$1"; }
ok   () { printf '  \033[32m✓\033[0m %s\n' "$1"; }
warn () { printf '  \033[33m!\033[0m %s\n' "$1"; }

[[ "$(uname -s)" == "Darwin" ]] || { echo "This script is for macOS." >&2; exit 1; }

MISSING=0

# ------------------------------------------------------------ developer tools
say "Developer tools"
if xcode-select -p >/dev/null 2>&1; then
  ok "present — $(xcode-select -p)"
else
  warn "not installed. Opening the installer; this takes ~12 minutes."
  # Asynchronous: the command returns immediately while a GUI installer runs.
  xcode-select --install || true
  echo "     Re-run this script once it has finished."
  MISSING=1
fi

# ---------------------------------------------------------------------- git
say "git"
if xcode-select -p >/dev/null 2>&1 && git --version >/dev/null 2>&1; then
  ok "$(git --version)"
else
  warn "not usable yet — it arrives with the developer tools above."
  MISSING=1
fi

# ------------------------------------------------------------------- docker
say "Docker"
if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
  ok "running — $(docker --version)"

  # Docker Desktop defaults to a 4GB VM. Once the vector index passes a
  # gigabyte it cannot stay cached, and every similarity search hits disk.
  MEM=$(docker info --format '{{.MemTotal}}' 2>/dev/null || echo 0)
  if [[ "$MEM" -gt 0 ]] && [[ "$MEM" -lt 6000000000 ]]; then
    warn "the Docker VM has only $((MEM/1024/1024/1024))GB."
    echo "     Raise it in Docker Desktop ▸ Settings ▸ Resources ▸ Memory."
    echo "     8GB is sensible; vector search suffers below that."
  fi
elif command -v docker >/dev/null 2>&1; then
  warn "docker is installed but not running."
  command -v colima >/dev/null 2>&1 && echo "     Try: colima start"
  MISSING=1
else
  warn "not installed."
  echo "     Docker Desktop:  https://www.docker.com/products/docker-desktop/"
  echo "     or, without the desktop app:"
  echo "         brew install colima docker docker-compose && colima start"
  MISSING=1
fi

# ---------------------------------------------------------------------- bun
say "bun"
if command -v bun >/dev/null 2>&1; then
  ok "$(bun --version)"
else
  warn "not installed. Installing…"
  curl -fsSL https://bun.sh/install | bash
  echo "     Open a new terminal afterwards so bun is on your PATH."
  MISSING=1
fi

# -------------------------------------------------------------------- report
if [[ $MISSING -ne 0 ]]; then
  say "Not ready yet"
  echo "  Deal with the items marked ! above, then run this script again."
  exit 1
fi

say "Prerequisites are in place"
cat <<'EOS'

  Now install PAI. The documented way is to ask Claude Code:

      Clone https://github.com/mnott/PAI and set it up for me

  Or do it by hand:

      git clone https://github.com/mnott/PAI
      cd PAI
      bun install
      bun run build
      pai setup

  In the wizard, choose PostgreSQL with pgvector. SQLite works but gives you
  keyword search only, which is most of the point gone.

EOS
