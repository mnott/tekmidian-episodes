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
  # Do not skip a missing file. A clean macOS install has no ~/.zshrc at all,
  # so "the file isn't there" is the normal case here, not an edge case.
  [[ -e "$rc" ]] || touch "$rc"
  local disp="~${rc#$HOME}"
  if grep -q '\.local/bin' "$rc" 2>/dev/null; then
    say "PATH already configured in $disp"
  else
    printf '\n# Claude Code\n%s\n' "$PATH_LINE" >> "$rc"
    say "Added ~/.local/bin to PATH in $disp"
  fi
}

# $SHELL is the login shell, which is the one whose config we want to change —
# even if this script itself was started with `bash setup.sh`.
case "${SHELL:-}" in
  */zsh)  add_path_line "$HOME/.zshrc" ;;
  */bash) add_path_line "$HOME/.bash_profile" ;;
  */fish) say "fish detected. Add this to ~/.config/fish/config.fish:"
          echo "  fish_add_path \$HOME/.local/bin" ;;
  *)      # zsh has been the macOS default since Catalina, so it is the sane
          # fallback when $SHELL is unset or unfamiliar.
          say "Unrecognised shell (${SHELL:-unset}) — assuming zsh"
          add_path_line "$HOME/.zshrc" ;;
esac

# Only so the verification below can run. This CANNOT affect the shell you
# started the script from — a child process cannot change its parent's
# environment — which is why the closing message tells you to open a new
# terminal.
export PATH="$BIN_DIR:$PATH"

# ------------------------------------------------------------------ verify
say "Verifying"
if command -v claude >/dev/null 2>&1; then
  claude --version
  printf '\n\033[1m⚠  One more thing: open a NEW terminal window.\033[0m\n'
  cat <<'EOS'

   This script cannot change the PATH of the shell you launched it from —
   no script can. The line has been written to your shell config, so a new
   terminal will pick it up. In this one, `claude` will still say
   "command not found".

   Open a new terminal (Cmd-N), or run:

       source ~/.zshrc

   Then:

       claude doctor   # diagnostics, if anything looks wrong
       claude          # start it, and sign in via the browser

   Claude Code needs a Pro, Max, Team, Enterprise or Console account.
   The free Claude.ai plan does not include it.

EOS
else
  echo "claude is still not on PATH." >&2
  echo "Open a new terminal and try again, or run:" >&2
  echo "  $PATH_LINE" >&2
  exit 1
fi
