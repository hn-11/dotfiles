# ====================
# Homebrew & Completion
# ====================
if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi
fpath=(/Users/hn/.docker/completions $fpath)
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
# Tool completions (native zsh)
# ====================
# fzf
source <(fzf --zsh)

# GitHub CLI
source <(gh completion -s zsh)

# Kubernetes (kubectl)
source <(kubectl completion zsh)

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
export PATH="/Users/hn/.antigravity/antigravity/bin:$PATH"

. "$HOME/.local/bin/env"
