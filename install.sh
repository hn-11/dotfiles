#!/bin/bash
set -eu

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Create dotfile links."

# ホーム直下のドットファイル (.zshrc など)
for dotfile in "$DOTFILES_DIR"/.??*; do
    name="$(basename "$dotfile")"
    case "$name" in
        .git | .gitignore | .config | .claude | .DS_Store) continue ;;
    esac
    ln -snfv "$dotfile" "$HOME/$name"
done

# .config / .claude 配下はファイル単位でリンク
# (ディレクトリごとリンクすると、他ツールの設定や Claude Code のセッション履歴などがリポジトリに混ざるため)
for dir in .config .claude; do
    [ -d "$DOTFILES_DIR/$dir" ] || continue
    (cd "$DOTFILES_DIR/$dir" && find . -type f ! -name .DS_Store) | while read -r rel; do
        rel="${rel#./}"
        mkdir -p "$HOME/$dir/$(dirname "$rel")"
        ln -snfv "$DOTFILES_DIR/$dir/$rel" "$HOME/$dir/$rel"
    done
done

echo "Success"
