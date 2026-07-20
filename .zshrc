# ====================
# Homebrew & Completion
# ====================
if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi
fpath=("$HOME/.docker/completions" $fpath)

# gh / kubectl の補完はキャッシュ生成して fpath 経由で読む (起動高速化)
# 更新したいときは: rm -rf ~/.cache/zsh/completions
ZSH_COMP_CACHE="$HOME/.cache/zsh/completions"
mkdir -p "$ZSH_COMP_CACHE"
[[ -f "$ZSH_COMP_CACHE/_gh" ]] || gh completion -s zsh > "$ZSH_COMP_CACHE/_gh"
[[ -f "$ZSH_COMP_CACHE/_kubectl" ]] || kubectl completion zsh > "$ZSH_COMP_CACHE/_kubectl"
fpath=("$ZSH_COMP_CACHE" $fpath)

autoload -Uz compinit
compinit

# ====================
# Aliases
# ====================
alias ls="eza --icons=auto"
alias tree="ls --tree"

# ====================
# Shell enhancements
# ====================
eval "$(starship init zsh)"
eval "$(sheldon source)"

# ====================
# mise (version manager)
# ====================
eval "$(mise activate zsh)"

# ====================
# fzf (キーバインド + 補完)
# ====================
source <(fzf --zsh)

# ====================
# fzf history search
# ====================
function fzf-select-history() {
    BUFFER=$(history -n -r 1 | fzf --query "$LBUFFER")
    CURSOR=$#BUFFER
    zle reset-prompt
}
zle -N fzf-select-history
bindkey '^r' fzf-select-history

# ====================
# PATH additions
# ====================
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

. "$HOME/.local/bin/env"
