#!/usr/bin/env bash
#  install.sh — Neovim config installer (macOS & Linux)
#  Usage: bash <(curl -fsSL https://raw.githubusercontent.com/ImBored7820/nvim/main/install.sh)
# ============================================================

set -e

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
    C_DIM="$(tput dim 2>/dev/null || tput setaf 8 2>/dev/null || printf '\033[2m')"
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
        answer="$(echo "${answer}" | tr '[:lower:]' '[:upper:]' | tr -d ' \t')"
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
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            # Add Homebrew to PATH for Apple Silicon and Intel
            if [[ -f /opt/homebrew/bin/brew ]]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            elif [[ -f /usr/local/bin/brew ]]; then
                eval "$(/usr/local/bin/brew shellenv)"
            fi
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
                brew install git
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
        brew install neovim
        ok "Neovim installed."
        return 0
    fi
    return 1
}

macos_install_neovide() {
    if ask_yesno "Install Neovide?"; then
        step "Installing Neovide via Homebrew..."
        brew install neovide
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
                    sudo apt-get update -qq && sudo apt-get install -y git
                    ok "git installed." ;;
            pacman) step "Installing git..."
                    sudo pacman -S --noconfirm git
                    ok "git installed." ;;
            dnf)    step "Installing git..."
                    sudo dnf install -y git
                    ok "git installed." ;;
            zypper) step "Installing git..."
                    sudo zypper install -y git
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
            step "Adding Neovim PPA and installing Neovim..."
            sudo add-apt-repository -y ppa:neovim-ppa/stable
            sudo apt-get update -qq
            sudo apt-get install -y neovim
            ok "Neovim installed."
            ;;
        pacman)
            step "Installing Neovim via pacman..."
            sudo pacman -S --noconfirm neovim
            ok "Neovim installed."
            ;;
        dnf)
            step "Installing Neovim via dnf..."
            sudo dnf install -y neovim
            ok "Neovim installed."
            ;;
        zypper)
            step "Installing Neovim via zypper..."
            sudo zypper install -y neovim
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

    if ! command -v flatpak &>/dev/null; then
        warn "Flatpak is not installed. Neovide is best installed via Flatpak on Linux."
        local pm
        pm="$(detect_pkg_manager)"
        case "$pm" in
            apt)
                if ask_yesno "Install Flatpak and Neovide?"; then
                    sudo apt-get update -qq
                    sudo apt-get install -y flatpak
                    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
                    step "Installing Neovide via Flatpak..."
                    flatpak install -y flathub com.neovide.neovide && ok "Neovide installed." && return 0
                    warn "Flatpak install failed." && return 1
                else
                    warn "Skipping Neovide installation."
                    return 1
                fi
                ;;
            pacman)
                if ask_yesno "Install Flatpak and Neovide?"; then
                    sudo pacman -S --noconfirm flatpak
                    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
                    step "Installing Neovide via Flatpak..."
                    flatpak install -y flathub com.neovide.neovide && ok "Neovide installed." && return 0
                    warn "Flatpak install failed." && return 1
                else
                    warn "Skipping Neovide installation."
                    return 1
                fi
                ;;
            dnf)
                if ask_yesno "Install Flatpak and Neovide?"; then
                    sudo dnf install -y flatpak
                    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
                    step "Installing Neovide via Flatpak..."
                    flatpak install -y flathub com.neovide.neovide && ok "Neovide installed." && return 0
                    warn "Flatpak install failed." && return 1
                else
                    warn "Skipping Neovide installation."
                    return 1
                fi
                ;;
            zypper)
                if ask_yesno "Install Flatpak and Neovide?"; then
                    sudo zypper install -y flatpak
                    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
                    step "Installing Neovide via Flatpak..."
                    flatpak install -y flathub com.neovide.neovide && ok "Neovide installed." && return 0
                    warn "Flatpak install failed." && return 1
                else
                    warn "Skipping Neovide installation."
                    return 1
                fi
                ;;
            *)
                warn "Neovide requires Flatpak. Install Flatpak for your distro, then run: flatpak install flathub com.neovide.neovide"
                return 1
                ;;
        esac
    else
        step "Installing Neovide via Flatpak..."
        if flatpak install -y flathub com.neovide.neovide; then
            ok "Neovide installed."
            return 0
        else
            warn "Flatpak install failed. You can try manually: flatpak install flathub com.neovide.neovide"
            return 1
        fi
    fi
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
            mv "$config_dir" "$backup_dir"
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
    macos_install_neovim || true
else
    linux_install_neovim || true
fi

# ── 3. Optional: Neovide ──────────────────────────────────────

printf '\n'
if [[ "$OS" == "linux" ]]; then
    printf '  %bNOTE: Neovide on Linux is installed via Flatpak (universal).%b\n' "$C_DIM" "$C_RESET"
    printf '  %b      Flatpak will be installed if needed.%b\n' "$C_DIM" "$C_RESET"
    printf '\n'
fi

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

# ── 5. Done ───────────────────────────────────────────────────

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
printf '  %bLazy.nvim will auto-install plugins on first launch.%b\n' "$C_DIM" "$C_RESET"
printf '  %b======================================%b\n' "$C_DIM" "$C_RESET"
printf '\n'
