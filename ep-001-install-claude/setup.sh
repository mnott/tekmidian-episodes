#!/usr/bin/env bash
#
# EP-001 — install Claude Code on macOS.
#
# Installs Claude Code using Anthropic's official native installer and makes
# sure it is on your PATH. Nothing here needs sudo, and nothing touches system
# directories: everything lands under your home folder.
#
# Safe to run twice.

set -euo pipefail

BIN_DIR="$HOME/.local/bin"
PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'

say () { printf '\n\033[1m%s\033[0m\n' "$1"; }

# ------------------------------------------------------------------ sanity
[[ "$(uname -s)" == "Darwin" ]] || {
  echo "This script is for macOS. For Linux or Windows see:" >&2
  echo "  https://docs.claude.com/en/docs/claude-code/setup" >&2
  exit 1
}

# ----------------------------------------------------------------- install
if command -v claude >/dev/null 2>&1; then
  say "Claude Code is already installed — $(claude --version)"
else
  say "Installing Claude Code"
  # The native installer: a self-contained binary, no Node and no Homebrew
  # required, and it updates itself in the background afterwards.
  curl -fsSL https://claude.ai/install.sh | bash
fi

# -------------------------------------------------------------------- PATH
# The installer puts the launcher in ~/.local/bin, which is not on the default
# macOS PATH. Without this you get "command not found" straight after a
# successful install, which looks like a failure and is not.
#
# Appending is guarded: the installer may already have written this line, and a
# duplicate would be untidy rather than harmful.
add_path_line () {
  local rc="$1"
  [[ -f "$rc" ]] || return 0
  if grep -q '\.local/bin' "$rc" 2>/dev/null; then
    say "PATH already configured in ${rc/#$HOME/\~}"
  else
    printf '\n# Claude Code\n%s\n' "$PATH_LINE" >> "$rc"
    say "Added ~/.local/bin to PATH in ${rc/#$HOME/\~}"
  fi
}

case "${SHELL:-}" in
  */zsh)  add_path_line "$HOME/.zshrc" ;;
  */bash) add_path_line "$HOME/.bash_profile" ;;
  *)      say "Unrecognised shell (${SHELL:-unset}) — add this to your shell config:"
          echo "  $PATH_LINE" ;;
esac

# Make it work in this shell too, so verification below succeeds without
# opening a new terminal.
export PATH="$BIN_DIR:$PATH"

# ------------------------------------------------------------------ verify
say "Verifying"
if command -v claude >/dev/null 2>&1; then
  claude --version
  echo
  echo "Done. Next:"
  echo "  claude doctor   # diagnostics, if anything looks wrong"
  echo "  claude          # start it, and sign in via the browser"
  echo
  echo "Claude Code needs a Pro, Max, Team, Enterprise or Console account."
  echo "The free Claude.ai plan does not include it."
else
  echo "claude is still not on PATH." >&2
  echo "Open a new terminal and try again, or run:" >&2
  echo "  $PATH_LINE" >&2
  exit 1
fi
