#!/bin/bash
# セットアップ後の状態を検証する。CI と手元の両方で使う。
set -u

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
failed=0
ok() { echo "ok   $1"; }
ng() { echo "FAIL $1"; failed=1; }
check() {
    local desc="$1"; shift
    if "$@"; then ok "$desc"; else ng "$desc"; fi
}

for f in .zshrc .zprofile .gitconfig .vimrc .config/starship.toml .config/sheldon/plugins.toml .config/mise/config.toml; do
    check "link $f" [ "$(readlink "$HOME/$f")" = "$DOTFILES_DIR/$f" ]
done

# zsh の対話シェルを起動して、各ツールが解決できるかを zsh 自身に答えさせる (alias や関数も含めて見るため)
out="$(zsh -l -i -c 'for c in bat eza fd fzf rg z delta gh jq mise sheldon starship; do whence -w $c >/dev/null && echo "has $c" || echo "missing $c"; done' 2>"${TMPDIR:-/tmp}/zsh-stderr" </dev/null)"
echo "$out" | sed -n 's/^has /ok   command /p; s/^missing /FAIL command /p'
echo "$out" | grep -q '^missing' && failed=1

# tty 無しで起動したときの zle 警告と、mise の未導入警告 (ランタイムは別途 mise install で入る) は無視する
errors="$(grep -vE "can't change option: zle|mise WARN" "${TMPDIR:-/tmp}/zsh-stderr" || true)"
check "zsh startup without errors" [ -z "$errors" ]
[ -z "$errors" ] || echo "$errors"

check "git pager = delta" [ "$(git config --global core.pager)" = delta ]

state="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-assets"
check "fonts installed" [ -s "$state/gengou-code" ]
check "theme installed" [ -s "$state/one-dark-modern" ]
check "ghostty theme" [ -f "$HOME/.config/ghostty/themes/one-dark-modern" ]
check "vim colors" [ -f "$HOME/.vim/colors/one-dark-modern.vim" ]

exit "$failed"
