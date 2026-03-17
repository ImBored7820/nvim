#!/usr/bin/env bash
#  install.sh — Neovim config installer (macOS & Linux)
#  Usage: bash <(curl -fsSL https://raw.githubusercontent.com/ImBored7820/nvim/main/install.sh)
# ============================================================

# ── Helpers ──────────────────────────────────────────────────

# Detect whether the terminal supports Unicode. Falls back to ASCII-safe symbols
# if LANG/LC_ALL suggests limited encoding or TERM is dumb.
supports_unicode() {
    case "${LANG:-}" in
        *[Uu][Tt][Ff]-8*|*[Uu][Tt][Ff]8*) return 0 ;;
    esac
    case "${LC_ALL:-}" in
        *[Uu][Tt][Ff]-8*|*[Uu][Tt][Ff]8*) return 0 ;;
    esac
    case "${TERM:-}" in
        dumb) return 1 ;;
    esac
    # Default to Unicode if we couldn't determine; most modern terminals support it
    [[ -t 1 ]] && return 0
    return 1
}

# Colors — use tput when available, else ANSI codes, else empty
if command -v tput &>/dev/null && [[ -t 1 ]]; then
    C_CYAN="$(tput setaf 6)"
    C_GREEN="$(tput setaf 2)"
    C_YELLOW="$(tput setaf 3)"
    C_RED="$(tput setaf 1)"
    C_DIM="$(tput setaf 8 2>/dev/null || printf '\033[2m')"
    C_RESET="$(tput sgr0)"
else
    C_CYAN='\033[36m'
    C_GREEN='\033[32m'
    C_YELLOW='\033[33m'
    C_RED='\033[31m'
    C_DIM='\033[90m'
    C_RESET='\033[0m'
fi

if supports_unicode; then
    SYM_STEP='►'
    SYM_OK='✔'
    SYM_WARN='[!]'
    SYM_FAIL='✖'
else
    SYM_STEP='>>'
    SYM_OK='[ok]'
    SYM_WARN='[!]'
    SYM_FAIL='[x]'
fi

write_header() {
    printf '\n'
    printf '  %b+----------------------------------+%b\n' "$C_CYAN" "$C_RESET"
    printf '  %b|                                  |%b\n' "$C_CYAN" "$C_RESET"
    printf '  %b|   NVIM  Config Installer         |%b\n' "$C_CYAN" "$C_RESET"
    printf '  %b|   by ImBored7820                 |%b\n' "$C_CYAN" "$C_RESET"
    printf '  %b|                                  |%b\n' "$C_CYAN" "$C_RESET"
    printf '  %b+----------------------------------+%b\n' "$C_CYAN" "$C_RESET"
    printf '\n'
}

ask_yesno() {
    local question="$1"
    local answer
    while true; do
        printf '  %b%s%b ' "$C_YELLOW" "$question" "$C_RESET"
        printf '%b[Y/N]: %b' "$C_DIM" "$C_RESET"
        read -r answer
        answer="$(printf '%s' "${answer}" | tr '[:lower:]' '[:upper:]' | tr -d ' \t')"
        case "$answer" in
            Y) return 0 ;;
            N) return 1 ;;
            *) printf '  %bPlease enter Y or N.%b\n' "$C_RED" "$C_RESET" ;;
        esac
    done
}

step() {
    printf '\n'
    printf '  %b%s %s%b\n' "$C_GREEN" "$SYM_STEP" "$1" "$C_RESET"
}

warn() {
    printf '  %b%s %s%b\n' "$C_YELLOW" "$SYM_WARN" "$1" "$C_RESET"
}

fail() {
    printf '\n'
    printf '  %b%s %s%b\n' "$C_RED" "$SYM_FAIL" "$1" "$C_RESET"
    printf '\n'
    exit 1
}

ok() {
    printf '  %b%s %s%b\n' "$C_CYAN" "$SYM_OK" "$1" "$C_RESET"
}

# ── OS detection ──────────────────────────────────────────────

detect_os() {
    case "$(uname -s)" in
        Darwin) echo "macos" ;;
        Linux)  echo "linux" ;;
        *)      echo "unknown" ;;
    esac
}

# ── macOS functions ───────────────────────────────────────────

macos_check_homebrew() {
    if ! command -v brew &>/dev/null; then
        warn "Homebrew is not installed."
        if ask_yesno "Install Homebrew? (required for optional package installs)"; then
            step "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || fail "Homebrew installation failed."
            # Add Homebrew to PATH for Apple Silicon and Intel
            for brew_path in /opt/homebrew/bin/brew /usr/local/bin/brew; do
                if [[ -x "$brew_path" ]]; then
                    eval "$("$brew_path" shellenv)"
                    break
                fi
            done
            step "Configuring PATH for GUI applications..."
            sudo launchctl config user path "$(brew --prefix)/bin:${PATH}" || warn "Failed to configure PATH for GUI apps."
            ok "Homebrew installed."
        else
            fail "Homebrew is required to install git, Neovim, or Neovide. Please install it from https://brew.sh and re-run."
        fi
    else
        ok "Homebrew is available."
    fi
}

macos_check_git() {
    if ! command -v git &>/dev/null; then
        warn "git was not found in PATH."
        if command -v brew &>/dev/null; then
            if ask_yesno "Install git via Homebrew?"; then
                step "Installing git via Homebrew..."
                brew install git || fail "git install failed."
                ok "git installed successfully."
            else
                fail "git is required to clone the config repo. Please install git and re-run."
            fi
        else
            fail "git is required. Please install Homebrew first, or install git manually."
        fi
    else
        ok "git is available."
    fi
}

macos_install_neovim() {
    if ask_yesno "Install Neovim?"; then
        step "Installing Neovim via Homebrew..."
        brew install neovim || fail "Neovim install failed."
        ok "Neovim installed."
        return 0
    fi
    return 1
}

macos_install_neovide() {
    if ask_yesno "Install Neovide?"; then
        step "Installing Neovide via Homebrew..."
        brew install --cask neovide || fail "Neovide install failed."
        ok "Neovide installed."
        return 0
    fi
    warn "Skipping Neovide installation."
    return 1
}

# ── Linux functions ───────────────────────────────────────────


detect_pkg_manager() {
    if command -v apt-get &>/dev/null; then
        echo "apt"
    elif command -v pacman &>/dev/null; then
        echo "pacman"
    elif command -v dnf &>/dev/null; then
        echo "dnf"
    elif command -v zypper &>/dev/null; then
        echo "zypper"
    else
        echo "unknown"
    fi
}

linux_check_git() {
    if ! command -v git &>/dev/null; then
        warn "git was not found in PATH."
        local pm
        pm="$(detect_pkg_manager)"
        case "$pm" in
            apt)    step "Installing git..."
                    sudo apt-get update -qq || fail "apt-get update failed."
                    sudo apt-get install -y git || fail "git install failed."
                    ok "git installed." ;;
            pacman) step "Installing git..."
                    sudo pacman -S --noconfirm git || fail "git install failed."
                    ok "git installed." ;;
            dnf)    step "Installing git..."
                    sudo dnf install -y git || fail "git install failed."
                    ok "git installed." ;;
            zypper) step "Installing git..."
                    sudo zypper install -y git || fail "git install failed."
                    ok "git installed." ;;
            *)      fail "Could not detect a supported package manager. Please install git manually and re-run." ;;
        esac
    else
        ok "git is available."
    fi
}

linux_install_neovim() {
    if ! ask_yesno "Install Neovim?"; then
        return 1
    fi

    local pm
    pm="$(detect_pkg_manager)"

    case "$pm" in
        apt)
            if command -v add-apt-repository &>/dev/null; then
                step "Adding Neovim PPA and installing Neovim..."
                sudo add-apt-repository -y ppa:neovim-ppa/stable || fail "Failed to add Neovim PPA."
            else
                warn "add-apt-repository not available (non-Ubuntu distro). Installing Neovim from default repos — version may be older."
                step "Installing Neovim..."
            fi
            sudo apt-get update -qq || fail "apt-get update failed."
            sudo apt-get install -y neovim || fail "Neovim install failed."
            ok "Neovim installed."
            ;;
        pacman)
            step "Installing Neovim via pacman..."
            sudo pacman -S --noconfirm neovim || fail "Neovim install failed."
            ok "Neovim installed."
            ;;
        dnf)
            step "Installing Neovim via dnf..."
            sudo dnf install -y neovim || fail "Neovim install failed."
            ok "Neovim installed."
            ;;
        zypper)
            step "Installing Neovim via zypper..."
            sudo zypper install -y neovim || fail "Neovim install failed."
            ok "Neovim installed."
            ;;
        *)
            warn "No supported package manager found (apt, pacman, dnf, zypper). Skipping Neovim install."
            warn "You can install Neovim manually from https://neovim.io"
            return 1
            ;;
    esac
    return 0
}

linux_install_neovide() {
    if ! ask_yesno "Install Neovide?"; then
        warn "Skipping Neovide installation."
        return 1
    fi

    local pm
    pm="$(detect_pkg_manager)"

    case "$pm" in
        pacman)
            step "Installing Neovide via pacman..."
            sudo pacman -S --noconfirm neovide || fail "Neovide install failed."
            if ask_yesno "Install libxkbcommon-x11 for X11 support?"; then
                sudo pacman -S --noconfirm libxkbcommon-x11 || warn "libxkbcommon-x11 install failed."
            fi
            ok "Neovide installed."
            return 0
            ;;
        *)
            if command -v nix &>/dev/null; then
                warn "Nix detected. For Nix, run: nix-shell -p neovide"
                warn "For NixOS, add neovide to environment.systemPackages in configuration.nix"
                if ask_yesno "Try nix-shell -p neovide to install temporarily?"; then
                    step "Running nix-shell -p neovide..."
                    nix-shell -p neovide --run "echo 'Neovide available in this shell'" || warn "nix-shell failed."
                    ok "Neovide available via nix-shell."
                    return 0
                else
                    return 1
                fi
            else
                if ask_yesno "Build Neovide from source?"; then
                    linux_build_neovide "$pm"
                    return $?
                else
                    warn "Skipping Neovide installation."
                    return 1
                fi
            fi
            ;;
    esac
}

linux_build_neovide() {
    local pm="$1"

    # Check rust
    if ! command -v cargo &>/dev/null; then
        step "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf "https://sh.rustup.rs" | sh -s -- -y || fail "Rust install failed."
        export PATH="$HOME/.cargo/bin:$PATH"
        ok "Rust installed."
    fi

    # Install deps
    case "$pm" in
        apt)
            step "Installing dependencies for Ubuntu/Debian..."
            sudo apt-get update -qq || fail "apt update failed."
            sudo apt-get install -y curl gnupg ca-certificates git gcc-multilib g++-multilib cmake libssl-dev pkg-config libfreetype6-dev libasound2-dev libexpat1-dev libxcb-composite0-dev libbz2-dev libsndio-dev freeglut3-dev libxmu-dev libxi-dev libfontconfig1-dev libxcursor-dev || fail "Dependencies install failed."
            ;;
        dnf)
            step "Installing dependencies for Fedora..."
            sudo dnf install -y fontconfig-devel freetype-devel @development-tools libstdc++-static libstdc++-devel || fail "Dependencies install failed."
            ;;
        zypper)
            step "Installing dependencies for openSUSE..."
            sudo zypper install -y fontconfig-devel freetype-devel gcc-c++ cmake libopenssl-devel pkgconfig || fail "Dependencies install failed."
            ;;
        *)
            warn "Unknown package manager. Please install dependencies manually: gcc, cmake, freetype, fontconfig, etc."
            if ! ask_yesno "Continue anyway?"; then
                return 1
            fi
            ;;
    esac

    step "Building Neovide from source..."
    cargo install --git https://github.com/neovide/neovide || fail "Neovide build failed."
    ok "Neovide built and installed."
    return 0
}

# ── Clone config (shared) ─────────────────────────────────────

clone_config() {
    local config_dir="$1"
    local backup_dir

    printf '\n'
    step "Cloning Neovim config to: $config_dir"

    if [[ -d "$config_dir" ]]; then
        warn "A Neovim config directory already exists at: $config_dir"
        if ask_yesno "Back up existing config and replace it?"; then
            backup_dir="$(dirname "$config_dir")/nvim.backup_$(date +%Y%m%d_%H%M%S)"
            mv "$config_dir" "$backup_dir" || fail "Failed to back up existing config."
            ok "Existing config backed up to: $backup_dir"
        else
            warn "Leaving existing config untouched. Skipping clone."
            printf '\n'
            printf '  %bInstallation complete (config not replaced).%b\n' "$C_DIM" "$C_RESET"
            printf '\n'
            exit 0
        fi
    fi

    if git clone https://github.com/ImBored7820/nvim.git "$config_dir"; then
        ok "Config cloned successfully."
    else
        fail "Clone failed. Please check your internet connection and try again."
    fi
}

bootstrap_lazy() {
    local data_dir
    if [[ "$OS" == "macos" ]]; then
        data_dir="$HOME/Library/Application Support/nvim"
    else
        data_dir="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"
    fi
    local lazypath="$data_dir/lazy/lazy.nvim"

    if [[ -d "$lazypath" ]]; then
        ok "lazy.nvim already exists at: $lazypath"
        return 0
    fi

    step "Bootstrapping lazy.nvim..."
    mkdir -p "$(dirname "$lazypath")" || fail "Failed to create data directory: $(dirname "$lazypath")"

    if git clone --filter=blob:none --branch=stable https://github.com/folke/lazy.nvim.git "$lazypath"; then
        ok "lazy.nvim cloned successfully."
    else
        fail "Failed to clone lazy.nvim. Check your internet connection."
    fi
}

# ── Entry point ───────────────────────────────────────────────

neovide_installed=0
OS="$(detect_os)"

write_header

if [[ "$OS" != "macos" && "$OS" != "linux" ]]; then
    fail "Unsupported OS: $(uname -s). This script supports macOS and Linux only."
fi

# ── 1. Prerequisites ──────────────────────────────────────────

step "Checking prerequisites..."

if [[ "$OS" == "macos" ]]; then
    macos_check_homebrew
    macos_check_git
else
    linux_check_git
fi

# ── 2. Optional: Neovim ───────────────────────────────────────

printf '\n'
if [[ "$OS" == "macos" ]]; then
    macos_install_neovim
else
    linux_install_neovim
fi

# ── 3. Optional: Neovide ──────────────────────────────────────

printf '\n'

if [[ "$OS" == "macos" ]]; then
    if macos_install_neovide; then
        neovide_installed=1
    fi
else
    if linux_install_neovide; then
        neovide_installed=1
    fi
fi

# ── 4. Clone config ───────────────────────────────────────────

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
clone_config "$CONFIG_DIR"

# ── 5. Bootstrap lazy.nvim ────────────────────────────────────

bootstrap_lazy

# ── 6. Done ───────────────────────────────────────────────────

printf '\n'
printf '  %b======================================%b\n' "$C_DIM" "$C_RESET"
printf '  %b%s  All done! Happy editing.%b\n' "$C_CYAN" "$SYM_OK" "$C_RESET"
printf '\n'

if [[ "$neovide_installed" -eq 1 ]]; then
    printf '  %bRun neovide to launch Neovide (recommended GUI),%b\n' "$C_DIM" "$C_RESET"
    printf '  %bor nvim to launch Neovim in the terminal.%b\n' "$C_DIM" "$C_RESET"
else
    printf '  %bRun nvim to launch Neovim in the terminal.%b\n' "$C_DIM" "$C_RESET"
fi

printf '\n'
printf '  %bLazy.nvim is pre-installed. Plugins will auto-install on first launch.%b\n' "$C_DIM" "$C_RESET"
printf '  %b======================================%b\n' "$C_DIM" "$C_RESET"
printf '\n'
