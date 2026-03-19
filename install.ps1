#  install.ps1 — Neovim config installer
#  Usage: iwr -useb https://raw.githubusercontent.com/ImBored7820/nvim/main/install.ps1 | iex
# ============================================================

$ErrorActionPreference = "Stop"

# ── Helpers ──────────────────────────────────────────────────

# Detect whether the current terminal supports Unicode output.
# Falls back to ASCII-safe symbols if encoding is limited (e.g. older Windows
# terminals, SSH sessions, or ConsoleHost without UTF-8 configured).
function Get-SupportsUnicode {
    $enc = [Console]::OutputEncoding
    return ($enc.CodePage -eq 65001) -or ($enc.EncodingName -match "Unicode|UTF")
}

$unicode = Get-SupportsUnicode

# Symbol set — chosen at startup based on terminal capability
if ($unicode) {
    $SYM_STEP = [char]0x25BA   # ►
    $SYM_OK   = [char]0x2714   # ✔
    $SYM_WARN = "[!]"          # no clean ASCII-width Unicode glyph; [!] is clear either way
    $SYM_FAIL = [char]0x2716   # ✖
} else {
    $SYM_STEP = ">>"
    $SYM_OK   = "[ok]"
    $SYM_WARN = "[!]"
    $SYM_FAIL = "[x]"
}

# Print the banner. Uses only plain ASCII characters so it renders correctly
# on every terminal regardless of font or encoding.
function Write-Header {
    Write-Host ""
    Write-Host "  +----------------------------------+" -ForegroundColor Cyan
    Write-Host "  |                                  |" -ForegroundColor Cyan
    Write-Host "  |   NVIM  Config Installer         |" -ForegroundColor Cyan
    Write-Host "  |   by ImBored7820                 |" -ForegroundColor Cyan
    Write-Host "  |                                  |" -ForegroundColor Cyan
    Write-Host "  +----------------------------------+" -ForegroundColor Cyan
    Write-Host ""
}

# Prompt a yes/no question and return $true for Y, $false for N.
function Ask-YesNo {
    param([string]$Question)
    while ($true) {
        Write-Host "  $Question " -NoNewline -ForegroundColor Yellow
        Write-Host "[Y/N]: " -NoNewline -ForegroundColor DarkGray
        $answer = (Read-Host).Trim().ToUpper()
        if ($answer -eq "Y") { return $true }
        if ($answer -eq "N") { return $false }
        Write-Host "  Please enter Y or N." -ForegroundColor Red
    }
}

# Print a major action step (green).
function Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "  $SYM_STEP $Message" -ForegroundColor Green
}

# Print a non-fatal warning (yellow).
function Warn {
    param([string]$Message)
    Write-Host "  $SYM_WARN $Message" -ForegroundColor DarkYellow
}

# Print a fatal error, then exit.
function Fail {
    param([string]$Message)
    Write-Host ""
    Write-Host "  $SYM_FAIL $Message" -ForegroundColor Red
    Write-Host ""
    exit 1
}

# Print a success confirmation (cyan).
function OK {
    param([string]$Message)
    Write-Host "  $SYM_OK $Message" -ForegroundColor Cyan
}

# ── Entry point ───────────────────────────────────────────────

$neovideInstalled = $false
Write-Header

# ── 1. Check prerequisites (winget and git) ───────────────────
# Winget is required for optional Neovim install and for git auto-install.
# Git is required to clone the config repo.

Step "Checking prerequisites..."

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Fail "winget not found. Please install the App Installer from the Microsoft Store and try again."
}
OK "winget is available."

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Warn "git was not found in PATH. Attempting to install via winget..."
    winget install --id Git.Git -e --source winget --silent --accept-source-agreements --accept-package-agreements
    # Refresh PATH — retry a few times to handle winget registry write delay
    $gitFound = $false
    for ($i = 0; $i -lt 5; $i++) {
        Start-Sleep -Seconds 2
        $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" +
                    [System.Environment]::GetEnvironmentVariable("PATH", "User")
        if (Get-Command git -ErrorAction SilentlyContinue) { $gitFound = $true; break }
    }
    if (-not $gitFound) {
        Fail "git install failed or PATH was not updated. Please restart your terminal and re-run."
    }
    OK "git installed successfully."
} else {
    OK "git is available."
}

# ── 2. Optional: Install Neovim ───────────────────────────────
# The user may choose between Scoop (recommended) or winget.
# If Scoop is chosen but not installed, we offer to install it first.

Write-Host ""
if (Ask-YesNo "Install Neovim?") {

    if (Ask-YesNo "Would you like to install Neovim through Scoop? (recommended)") {

        # --- Scoop path ---
        $scoopReady = $true
        if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
            if (Ask-YesNo "Scoop is not installed. Install Scoop permanently?") {
                Step "Installing Scoop..."
                Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -ErrorAction SilentlyContinue
                Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
                $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "User") + ";" +
                            [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
            } else {
                Warn "Scoop installation declined. Skipping Neovim installation."
                $scoopReady = $false
            }
        }

        if ($scoopReady) {
            Step "Installing Neovim via Scoop..."
            try { scoop install neovim 2>&1 | Out-Null } catch {}
            OK "Neovim installed via Scoop."
        }

    } else {

        # --- winget path ---
        Step "Installing Neovim via winget..."
        try { winget install --id Neovim.Neovim -e --source winget --accept-source-agreements --accept-package-agreements 2>&1 | Out-Null } catch {}
        OK "Neovim installed via winget."

    }
}

# ── 3. Optional: Install Neovide ──────────────────────────────
# Neovide is only available through Scoop (extras bucket).
# The extras bucket must be added before Neovide can be found by Scoop.

Write-Host ""
Write-Host "  NOTE: Neovide can only be installed through Scoop (via the extras bucket)." -ForegroundColor DarkGray
Write-Host "        The extras bucket extends Scoop with community-maintained apps like Neovide." -ForegroundColor DarkGray
Write-Host ""

if (Ask-YesNo "Install Neovide? (Scoop only)") {

    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        if (Ask-YesNo "Scoop is not installed. Install Scoop permanently?") {
            Step "Installing Scoop..."
            Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
            $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "User") + ";" +
                        [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
        } else {
            Warn "Scoop installation declined. Skipping Neovide installation."
        }
    }

    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Step "Adding Scoop extras bucket (required for Neovide)..."
        try { scoop bucket add extras 2>&1 | Out-Null } catch {}
        Step "Installing Neovide via Scoop..."
        try { scoop install neovide 2>&1 | Out-Null } catch {}
        OK "Neovide installed."
        $neovideInstalled = $true
    }

} else {
    Warn "Skipping Neovide installation."
}

# ── 4. Clone the Neovim config ────────────────────────────────
# Clones the config repo into %LOCALAPPDATA%\nvim.
# If a config already exists there, the user is offered a timestamped backup.

$configDir = Join-Path $env:LOCALAPPDATA "nvim"

Write-Host ""
Step "Cloning Neovim config to: $configDir"

if (Test-Path $configDir) {
    Warn "A Neovim config directory already exists at: $configDir"
    if (Ask-YesNo "Back up existing config and replace it?") {
        $backupLeaf = "nvim.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        $backup = Join-Path (Split-Path $configDir -Parent) $backupLeaf
        Rename-Item -Path $configDir -NewName $backupLeaf
        OK "Existing config backed up to: $backup"
    } else {
        Warn "Leaving existing config untouched. Skipping clone."
        Write-Host ""
        Write-Host "  Installation complete (config not replaced)." -ForegroundColor DarkCyan
        Write-Host ""
        exit 0
    }
}

# git writes clone progress to stderr; redirect it so $ErrorActionPreference = Stop
# doesn't misinterpret it as a fatal PowerShell error.
$gitOutput = & git clone https://github.com/ImBored7820/nvim.git $configDir 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host $gitOutput
    Fail "Clone failed. Please check your internet connection and try again."
}

OK "Config cloned successfully."

# ── 5. Done ───────────────────────────────────────────────────
# Print a summary that reflects what was actually installed.

Write-Host ""
Write-Host "  ======================================" -ForegroundColor DarkGray
Write-Host "  $SYM_OK  All done! Happy editing." -ForegroundColor Cyan
Write-Host ""

if ($neovideInstalled) {
    Write-Host "  Run 'neovide' to launch Neovide (recommended GUI)," -ForegroundColor DarkCyan
    Write-Host "  or 'nvim' to launch Neovim in the terminal." -ForegroundColor DarkCyan
} else {
    Write-Host "  Run 'nvim' to launch Neovim in the terminal." -ForegroundColor DarkCyan
}

Write-Host ""
Write-Host "  Lazy.nvim will auto-install plugins on first launch." -ForegroundColor DarkGray
Write-Host "  ======================================" -ForegroundColor DarkGray
Write-Host ""
