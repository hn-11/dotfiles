#!/bin/bash
set -eu

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Create dotfile links."

# ホーム直下のドットファイル (.zshrc など)
for dotfile in "$DOTFILES_DIR"/.??*; do
    name="$(basename "$dotfile")"
    case "$name" in
        .git | .gitignore | .config | .DS_Store) continue ;;
    esac
    ln -snfv "$dotfile" "$HOME/$name"
done

# .config 配下はファイル単位でリンク (既存の他ツール設定を壊さないため)
if [ -d "$DOTFILES_DIR/.config" ]; then
    (cd "$DOTFILES_DIR/.config" && find . -type f) | while read -r rel; do
        rel="${rel#./}"
        mkdir -p "$HOME/.config/$(dirname "$rel")"
        ln -snfv "$DOTFILES_DIR/.config/$rel" "$HOME/.config/$rel"
    done
fi

echo "Success"
