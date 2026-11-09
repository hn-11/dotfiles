# ====================
# Homebrew & Completion
# ====================
# brew --prefix はサブプロセス起動で遅いので環境変数で済ませる
FPATH="${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh/site-functions:${FPATH}"
fpath=("$HOME/.docker/completions" $fpath)

# gh の補完はキャッシュ生成して fpath 経由で読む (起動高速化)
# 更新したいときは: rm -rf ~/.cache/zsh/completions
ZSH_COMP_CACHE="$HOME/.cache/zsh/completions"
mkdir -p "$ZSH_COMP_CACHE"
[[ -f "$ZSH_COMP_CACHE/_gh" ]] || gh completion -s zsh > "$ZSH_COMP_CACHE/_gh"
fpath=("$ZSH_COMP_CACHE" $fpath)

autoload -Uz compinit
compinit

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'  # 大文字小文字を区別しない
zstyle ':completion:*' menu select                    # 候補を矢印キーで選択

# ====================
# History
# ====================
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt share_history          # 複数ターミナル間で履歴を共有
setopt hist_ignore_all_dups   # 重複は古い方を消す
setopt hist_ignore_space      # 先頭スペースのコマンドは記録しない
setopt hist_reduce_blanks     # 余分な空白を詰める

# ====================
# Aliases
# ====================
alias ls="eza --icons=auto"
alias tree="ls --tree"
alias claude="claude --dangerously-skip-permissions"
alias agy="agy --dangerously-skip-permissions"

# ====================
# Shell enhancements
# ====================
eval "$(starship init zsh)"
eval "$(sheldon source)"

# ====================
# fzf (Ctrl+R 履歴検索 / Ctrl+T ファイル / Alt+C cd + 補完)
# ====================
source <(fzf --zsh)

# ====================
# PATH additions
# ====================
. "$HOME/.local/bin/env"

# ====================
# mise (version manager)
# ====================
eval "$(mise activate zsh)"
