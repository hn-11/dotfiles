#!/bin/bash
# 自作リポジトリの最新リリースを取得して配置する。
#   - Gengou Code (hn-11/gengou-code): フォント
#   - One Dark Modern (hn-11/one-dark-modern): VS Code / Ghostty / Vim / Windows Terminal のテーマ
# 再実行すると、新しいリリースが出ているものだけ入れ替える (--force で強制)。
set -eu

FORCE=0
[ "${1:-}" = "--force" ] && FORCE=1

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-assets"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

is_wsl() { grep -qi microsoft /proc/version 2>/dev/null; }

# CI では未認証 API の 60 回/時制限に当たりうるのでトークンがあれば使う
github_api() {
    if [ -n "${GITHUB_TOKEN:-}" ]; then
        curl -fsSL -H "Authorization: Bearer $GITHUB_TOKEN" "https://api.github.com/$1"
    else
        curl -fsSL "https://api.github.com/$1"
    fi
}

latest_tag() {
    github_api "repos/$1/releases/latest" | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p'
}

download() {
    curl -fsSL -o "$TMP/$3" "https://github.com/$1/releases/download/$2/$3"
}

# 導入済みなら 1 を返す。呼び出し側は更新が要るときだけ処理する
needs_update() {
    local name="$1" tag="$2"
    [ "$FORCE" = 1 ] && return 0
    [ "$(cat "$STATE_DIR/$name" 2>/dev/null || true)" != "$tag" ]
}

mark_installed() {
    mkdir -p "$STATE_DIR"
    echo "$2" > "$STATE_DIR/$1"
    echo "$1 $2 を導入しました"
}

# WSL から Windows 側の環境変数・パスを扱う。cmd.exe は UNC の cwd で警告を出すので C: に移ってから呼ぶ
win_env() { (cd /mnt/c && cmd.exe /c "echo %$1%" 2>/dev/null | tr -d '\r'); }
win_path() { wslpath "$(win_env "$1")"; }

install_fonts() {
    local repo="hn-11/gengou-code" tag font_dir asset
    tag="$(latest_tag "$repo")"
    [ -n "$tag" ] || { echo "$repo の最新リリースを取得できませんでした" >&2; return 1; }
    needs_update gengou-code "$tag" || { echo "gengou-code $tag は導入済み"; return 0; }

    case "$(uname -s)" in
        Darwin) font_dir="$HOME/Library/Fonts" ;;
        *)      font_dir="${XDG_DATA_HOME:-$HOME/.local/share}/fonts/gengou-code" ;;
    esac
    mkdir -p "$font_dir" "$TMP/fonts"
    for asset in GengouCodeJP GengouCodeJP-NerdFont GengouCodeJPTerm GengouCodeJPTerm-NerdFont; do
        download "$repo" "$tag" "$asset.zip"
        unzip -qo "$TMP/$asset.zip" '*.otf' -d "$TMP/fonts"
    done
    cp "$TMP"/fonts/*.otf "$font_dir/"
    if command -v fc-cache >/dev/null; then fc-cache -f "$font_dir" >/dev/null; fi

    # Windows Terminal が描画に使うのは Windows 側のフォントなので、ユーザー単位 (管理者権限不要) で登録する
    if is_wsl; then
        local win_fonts win_fonts_w f
        win_fonts="$(win_path LOCALAPPDATA)/Microsoft/Windows/Fonts"
        mkdir -p "$win_fonts"
        win_fonts_w="$(win_env LOCALAPPDATA)\\Microsoft\\Windows\\Fonts"
        for f in "$TMP"/fonts/*.otf; do
            cp "$f" "$win_fonts/"
            (cd /mnt/c && reg.exe add 'HKCU\Software\Microsoft\Windows NT\CurrentVersion\Fonts' \
                /v "$(basename "$f" .otf) (OpenType)" /t REG_SZ /d "$win_fonts_w\\$(basename "$f")" /f >/dev/null)
        done
    fi
    mark_installed gengou-code "$tag"
}

install_theme() {
    local repo="hn-11/one-dark-modern" tag version vsix
    tag="$(latest_tag "$repo")"
    [ -n "$tag" ] || { echo "$repo の最新リリースを取得できませんでした" >&2; return 1; }
    needs_update one-dark-modern "$tag" || { echo "one-dark-modern $tag は導入済み"; return 0; }

    download "$repo" "$tag" one-dark-modern
    mkdir -p "$HOME/.config/ghostty/themes"
    # 以前 dotfiles からリンクしていた名残があるとリンク先を上書きしてしまうので外してから置く
    rm -f "$HOME/.config/ghostty/themes/one-dark-modern"
    cp "$TMP/one-dark-modern" "$HOME/.config/ghostty/themes/one-dark-modern"

    download "$repo" "$tag" one-dark-modern.vim
    mkdir -p "$HOME/.vim/colors"
    cp "$TMP/one-dark-modern.vim" "$HOME/.vim/colors/one-dark-modern.vim"

    version="${tag#v}"
    vsix="one-dark-modern-$version.vsix"
    download "$repo" "$tag" "$vsix"
    if is_wsl; then
        # 配色テーマは UI 側 (Windows の VS Code) の拡張。WSL の code に入れるとリモート側に入って効かない
        local win_tmp
        win_tmp="$(win_path TEMP)"
        cp "$TMP/$vsix" "$win_tmp/$vsix"
        (cd /mnt/c && cmd.exe /c code --install-extension "$(win_env TEMP)\\$vsix" --force) || echo "Windows の VS Code に拡張を入れられませんでした (未インストール?)" >&2

        # Windows Terminal の fragment で配色を追加する (settings.json を直接書き換えない)
        local fragment_dir
        fragment_dir="$(win_path LOCALAPPDATA)/Microsoft/Windows Terminal/Fragments/dotfiles"
        mkdir -p "$fragment_dir"
        download "$repo" "$tag" one-dark-modern.json
        jq '{schemes: [.]}' "$TMP/one-dark-modern.json" > "$fragment_dir/one-dark-modern.json"
    elif command -v code >/dev/null; then
        code --install-extension "$TMP/$vsix" --force
    else
        echo "code コマンドが無いので VS Code 拡張はスキップ"
    fi
    mark_installed one-dark-modern "$tag"
}

install_fonts
install_theme
