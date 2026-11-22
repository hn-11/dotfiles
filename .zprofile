# macOS (Apple Silicon) と Linux/WSL (Linuxbrew) のどちらの Homebrew でも PATH を通す
for brew_bin in /opt/homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
    [ -x "$brew_bin" ] && eval "$("$brew_bin" shellenv)" && break
done
unset brew_bin

# Docker Desktop の CLI
[ -d "$HOME/.docker/bin" ] && export PATH="$PATH:$HOME/.docker/bin"
