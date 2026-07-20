# dotfiles

macOS 用の個人設定ファイル。

## 管理しているもの

| ファイル | 内容 |
|---|---|
| `.zshrc` | zsh 設定 (eza / starship / sheldon / mise / fzf) |
| `.config/starship.toml` | プロンプト |
| `.config/sheldon/plugins.toml` | zsh プラグイン (autosuggestions, syntax-highlighting) |
| `.config/mise/config.toml` | ランタイム (go, node, uv など) |
| `.config/gh/config.yml` | GitHub CLI 設定 |
| `Brewfile` | Homebrew パッケージ一覧 |

`gh/hosts.yml` は認証トークンを含むため追跡しない (gitignore 済み)。

## セットアップ

```sh
git clone https://github.com/HayatoNakano/dotfiles.git ~/dev/dotfiles
cd ~/dev/dotfiles

# Homebrew パッケージ
brew bundle

# シンボリックリンク作成 ($HOME 直下 + .config 配下)
./install.sh

# ランタイム
mise install
```

## メンテナンス

- 設定は `$HOME` 側を直接編集すればリンク経由でこのリポジトリに反映される。あとは commit するだけ
- パッケージを追加したら `brew bundle dump --file=Brewfile --force` で Brewfile を更新
- gh / kubectl の補完キャッシュを更新したいとき: `rm -rf ~/.cache/zsh/completions`
