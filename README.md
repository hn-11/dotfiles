# dotfiles

macOS と Linux (WSL の Ubuntu) 用の個人設定ファイル。CI (GitHub Actions) で両 OS のセットアップを毎回まっさらな環境から検証している。

## 管理しているもの

| ファイル | 内容 |
|---|---|
| `.zshrc` | zsh 設定 (eza / starship / sheldon / mise / fzf / zoxide / bat) |
| `.zprofile` | ログインシェル (Homebrew・Docker の PATH) |
| `.gitconfig` | git 設定 (delta をページャに使用) |
| `.vimrc` | vim |
| `.config/ghostty/config` | ターミナル (Ghostty) |
| `.config/starship.toml` | プロンプト |
| `.config/sheldon/plugins.toml` | zsh プラグイン (autosuggestions, syntax-highlighting) |
| `.config/mise/config.toml` | ランタイム (go, node, uv など) |
| `.config/herdr/config.toml` | herdr |
| `.config/gh/config.yml` | GitHub CLI 設定 |
| `.claude/settings.json` | Claude Code 設定 (プラグイン, hooks, effort など) |
| `Brewfile` | Homebrew パッケージ (macOS / Linux 共通の CLI) |
| `Brewfile.mac` | macOS 専用 (アプリ・App Store・VS Code 拡張・go/uv/npm ツール) |
| `bootstrap.sh` | セットアップ一式 |
| `install.sh` | シンボリックリンク作成 |
| `install-assets.sh` | 自作リポジトリの最新リリースを配置 (下記) |
| `check.sh` | セットアップ結果の検証 (CI でも使用) |

`gh/hosts.yml` は認証トークンを含むため追跡しない (gitignore 済み)。
`~/.claude/` は `settings.json` だけを追跡する。認証情報・セッション履歴・プラグインキャッシュなどは対象外。

## セットアップ

```sh
git clone https://github.com/hn-11/dotfiles.git ~/dev/dotfiles
~/dev/dotfiles/bootstrap.sh
~/dev/dotfiles/check.sh   # 確認

# Claude Code の herdr 連携 hook (~/.claude/hooks/herdr-agent-state.sh)
# herdr が自動更新するスクリプトなのでリポジトリでは持たず、herdr に生成させる
herdr integration install claude
```

`bootstrap.sh` は Homebrew (Linux では Linuxbrew) の導入 → `Brewfile` → リンク作成 → `mise install`
→ (macOS のみ) `Brewfile.mac` → `install-assets.sh` の順に流す。何度流してもよい。

### WSL (Ubuntu)

Windows 側で WSL と Ubuntu を入れ、Ubuntu の中で上の手順を流す。`apt` で zsh 等を入れるため sudo を聞かれる。
最後に `chsh -s "$(command -v zsh)"` でログインシェルを zsh にする。

`install-assets.sh` は WSL を検出すると Windows 側にも配置する:

- フォント: Windows のユーザーフォント (`%LOCALAPPDATA%\Microsoft\Windows\Fonts`) に登録 (管理者権限不要)
- Windows Terminal: fragment で配色 "One Dark Modern" を追加。プロファイルの配色・フォント
  (`Gengou Code JP Term NF`) の選択は Windows Terminal の設定画面で行う
- VS Code: Windows 側の VS Code に拡張を入れる (配色テーマは UI 側の拡張なので WSL 側に入れても効かない)

Windows 側の処理は CI (Ubuntu) では検証できないので、実機で初回に確認すること。

## 自作リポジトリのリリース (`install-assets.sh`)

| リポジトリ | 配置先 |
|---|---|
| [hn-11/gengou-code](https://github.com/hn-11/gengou-code) | フォント (macOS: `~/Library/Fonts`、Linux: `~/.local/share/fonts/gengou-code`) |
| [hn-11/one-dark-modern](https://github.com/hn-11/one-dark-modern) | VS Code 拡張・Ghostty テーマ・Vim colorscheme・(WSL) Windows Terminal 配色 |

導入した版を `~/.local/state/dotfiles-assets/` に記録し、新しいリリースが出ているものだけ入れ替える。
`--force` で強制的に入れ直す。

## メンテナンス

- 設定は `$HOME` 側を直接編集すればリンク経由でこのリポジトリに反映される。あとは commit するだけ
- パッケージを追加したら、両 OS で使うものは `Brewfile`、macOS 専用は `Brewfile.mac` に手で追記する
  (`brew bundle dump` は両者を1ファイルにまとめてしまうので使わない)。ずれの確認は `brew bundle check --file=Brewfile`
- フォント・テーマの更新: `./install-assets.sh`
- gh の補完キャッシュを更新したいとき: `rm -rf ~/.cache/zsh/completions`
