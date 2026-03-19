#!/usr/bin/env bash
# uninstall.sh — Neovim config uninstaller (macOS & Linux)

printf '\n'
printf '\033[36m  Neovim Uninstaller\033[0m\n'
printf '\033[36m  ==================\033[0m\n\n'

printf '\033[33m  Are you sure you want to completely remove Neovim, Neovide, and all\033[0m\n'
printf '\033[33m  configuration and data files? [Y/N]: \033[0m'
read answer

answer="$(printf '%s' "$answer" | tr '[:lower:]' '[:upper:]' | tr -d ' \t')"
if [[ "$answer" != "Y" ]]; then
    printf '\n  \033[33mUninstallation aborted.\033[0m\n'
    exit 0
fi

printf '\n'
cd "$HOME" || exit

OS="$(uname -s)"
if [[ "$OS" == "Darwin" ]]; then
    if command -v brew &>/dev/null; then
        printf '  \033[32m>>\033[0m Uninstalling Neovide via Homebrew...\n'
        brew uninstall --cask neovide 2>/dev/null || true
        printf '  \033[32m>>\033[0m Uninstalling Neovim via Homebrew...\n'
        brew uninstall neovim 2>/dev/null || true
    fi
else
    # Linux package managers
    if command -v pacman &>/dev/null; then
        printf '  \033[32m>>\033[0m Uninstalling via pacman...\n'
        sudo pacman -Rns --noconfirm neovide 2>/dev/null || true
        sudo pacman -Rns --noconfirm neovim 2>/dev/null || true
    elif command -v apt-get &>/dev/null; then
        printf '  \033[32m>>\033[0m Uninstalling via apt...\n'
        sudo apt-get remove -y neovim 2>/dev/null || true
    elif command -v dnf &>/dev/null; then
        printf '  \033[32m>>\033[0m Uninstalling via dnf...\n'
        sudo dnf remove -y neovim 2>/dev/null || true
    elif command -v zypper &>/dev/null; then
        printf '  \033[32m>>\033[0m Uninstalling via zypper...\n'
        sudo zypper remove -y neovim 2>/dev/null || true
    fi

    # Cargo neovide uninstall
    if command -v cargo &>/dev/null; then
        printf '  \033[32m>>\033[0m Uninstalling Neovide via cargo...\n'
        cargo uninstall neovide 2>/dev/null || true
    fi
fi

# Remove directories
dirs=(
    "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
    "${XDG_DATA_HOME:-$HOME/.local/share}/nvim"
    "${XDG_STATE_HOME:-$HOME/.local/state}/nvim"
    "${XDG_CACHE_HOME:-$HOME/.cache}/nvim"
)

for d in "${dirs[@]}"; do
    if [[ -d "$d" ]]; then
        printf '  \033[90m>> Removing directory: %s...\033[0m\n' "$d"
        rm -rf "$d" 2>/dev/null || true
    fi
done

printf '\n  \033[36mUninstallation complete!\033[0m\n\n'
