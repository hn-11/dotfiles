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
# gh が無い環境で空ファイルをキャッシュしてしまわないよう存在確認する
[[ -f "$ZSH_COMP_CACHE/_gh" ]] || ! (( $+commands[gh] )) || gh completion -s zsh > "$ZSH_COMP_CACHE/_gh"
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
# -pp = 装飾なし・ページャなし。cat の置き換えとしてパイプ/コピペで邪魔にならないように
alias cat="bat -pp"

# man をシンタックスハイライト付きで読む
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"

# ====================
# Shell enhancements
# ====================
eval "$(starship init zsh)"
eval "$(sheldon source)"

# ====================
# fzf (Ctrl+R 履歴検索 / Ctrl+T ファイル / Alt+C cd + 補完)
# ====================
# 候補列挙を fd にして .gitignore を尊重しつつ隠しファイルも拾う
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:300 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always --icons=auto {}'"
source <(fzf --zsh)

# ====================
# PATH additions
# ====================
# uv / Claude Code のインストーラが使う置き場。インストーラ生成の env ファイルは新環境に無いので直接書く
[[ ":$PATH:" == *":$HOME/.local/bin:"* ]] || export PATH="$HOME/.local/bin:$PATH"

# ====================
# mise (version manager)
# ====================
eval "$(mise activate zsh)"

# ====================
# zoxide (z <キーワード> で頻用ディレクトリへ / zi で fzf 選択)
# ====================
# compinit より後・ファイル末尾で初期化するのが公式推奨
eval "$(zoxide init zsh)"
