#!/bin/bash
# 新しい macOS / Linux (WSL) を一通りセットアップする。何度流しても同じ状態に収束する。
# DOTFILES_CI=1 のときは CI で入れられないもの (Mac のアプリ・App Store) を飛ばす。
set -eu

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
OS="$(uname -s)"

if [ "$OS" = Linux ]; then
    # Homebrew の前提パッケージと zsh 本体 (Linux の Homebrew は zsh をログインシェルにする用途に向かない)
    sudo apt-get update -qq
    sudo apt-get install -y -qq build-essential procps curl file git unzip zsh
fi

if ! command -v brew >/dev/null; then
    for brew_bin in /opt/homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
        [ -x "$brew_bin" ] && break
    done
    if [ ! -x "$brew_bin" ]; then
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    for brew_bin in /opt/homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
        [ -x "$brew_bin" ] && eval "$("$brew_bin" shellenv)" && break
    done
fi

brew bundle --file "$DOTFILES_DIR/Brewfile"
"$DOTFILES_DIR/install.sh"

eval "$(mise activate bash --shims)"
mise install

if [ "$OS" = Darwin ] && [ "${DOTFILES_CI:-}" != 1 ]; then
    brew bundle --file "$DOTFILES_DIR/Brewfile.mac"
fi

"$DOTFILES_DIR/install-assets.sh"

if [ "$(basename "${SHELL:-}")" != zsh ]; then
    echo "ログインシェルを zsh にするには: chsh -s \"$(command -v zsh)\""
fi
