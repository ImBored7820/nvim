# My notes app with neovim, made for neovide

## Installation

### Windows

1. **First time setup** (optional — may not be needed):
   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

2. **Run the installer**:
   ```powershell
   iwr -useb https://raw.githubusercontent.com/ImBored7820/nvim/main/install.ps1 | iex
   ```

### macOS / Linux

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ImBored7820/nvim/main/install.sh)
```

The installer will:
- Check for prerequisites (Homebrew on macOS; git on both)
- Optionally install Neovim (Homebrew on macOS; apt/pacman/dnf/zypper or PPA on Linux)
- Optionally install Neovide (Homebrew on macOS; Flatpak on Linux)
- Clone this config to `~/.config/nvim` (or `%LOCALAPPDATA%\nvim` on Windows)
- Create a timestamped backup if a config already exists

Lazy.nvim will auto-install plugins on first launch.
