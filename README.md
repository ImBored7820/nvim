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


### Uninstallation

To completely remove Neovim, Neovide, and all configuration files:

#### Windows
```powershell
.\uninstall.ps1
```

#### macOS / Linux
```bash
bash ./uninstall.sh
```

The uninstaller will:
- Optionally uninstall Neovim and Neovide via the appropriate package manager.
- Remove all configuration, data, state, and cache directories.
- **Note:** It will NOT uninstall Scoop, Homebrew, or other system package managers.

## Script Details

The installer will:
- Check for prerequisites (Homebrew on macOS; git on both).
- Optionally install Neovim (Scoop/Winget on Windows; Homebrew on macOS; apt/pacman/dnf/zypper on Linux).
- Optionally install Neovide (Scoop on Windows; Homebrew on macOS; cargo/pacman on Linux).
- Clone this config to `%LOCALAPPDATA%\nvim` (Windows) or `~/.config/nvim` (macOS/Linux).
- Create a timestamped backup if a config already exists.

Lazy.nvim will auto-install plugins on first launch.

