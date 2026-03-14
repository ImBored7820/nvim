# ============================================================
#  install.ps1 — Neovim config installer
#  Usage: iwr -useb https://raw.githubusercontent.com/ImBored7820/nvim/main/install.ps1 | iex
# ============================================================

$ErrorActionPreference = "Stop"

# ── Helpers ──────────────────────────────────────────────────

function Write-Header {
    Write-Host ""
    Write-Host "  ███╗   ██╗██╗   ██╗██╗███╗   ███╗" -ForegroundColor Cyan
    Write-Host "  ████╗  ██║██║   ██║██║████╗ ████║" -ForegroundColor Cyan
    Write-Host "  ██╔██╗ ██║██║   ██║██║██╔████╔██║" -ForegroundColor Cyan
    Write-Host "  ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║" -ForegroundColor Cyan
    Write-Host "  ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║" -ForegroundColor Cyan
    Write-Host "  ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Config Installer by ImBored7820" -ForegroundColor DarkCyan
    Write-Host "  ──────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""
}

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

function Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "  ► $Message" -ForegroundColor Green
}

function Warn {
    param([string]$Message)
    Write-Host "  ⚠  $Message" -ForegroundColor DarkYellow
}

function Fail {
    param([string]$Message)
    Write-Host ""
    Write-Host "  ✖ $Message" -ForegroundColor Red
    Write-Host ""
    exit 1
}

function OK {
    param([string]$Message)
    Write-Host "  ✔ $Message" -ForegroundColor Cyan
}

# ── Entry point ───────────────────────────────────────────────

Write-Header

# ── 1. Check for winget ───────────────────────────────────────

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

Write-Host ""
if (Ask-YesNo "Install Neovim?") {
    Step "Installing Neovim via winget..."
    winget install --id Neovim.Neovim -e --source winget --accept-source-agreements --accept-package-agreements
    OK "Neovim installed."
} else {
    Warn "Skipping Neovim installation."
}

# ── 3. Optional: Install Neovide ──────────────────────────────

$installNeovide = Read-Host "Install Neovide? (y/n)"
if ($installNeovide.Trim().ToUpper() -eq "Y") {
    $scoopCmd = Get-Command scoop -ErrorAction SilentlyContinue
    if (-not $scoopCmd) {
        $installScoop = Read-Host "Scoop is not installed. Install Scoop permanently? (y/n)"
        if ($installScoop.Trim().ToUpper() -ne "Y") {
            Warn "Skipping Neovide installation."
        } else {
            Step "Installing Scoop..."
            Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
            $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "User") + ";" +
                        [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
            Step "Adding Scoop extras bucket..."
            scoop bucket add extras
            Step "Installing Neovide via Scoop..."
            scoop install neovide
            OK "Neovide installed."
        }
    } else {
        Step "Adding Scoop extras bucket..."
        scoop bucket add extras
        Step "Installing Neovide via Scoop..."
        scoop install neovide
        OK "Neovide installed."
    }
} else {
    Warn "Skipping Neovide installation."
}

# ── 4. Clone config ───────────────────────────────────────────

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
# doesn't misinterpret it as a fatal PowerShell error
$gitOutput = & git clone https://github.com/ImBored7820/nvim.git $configDir 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host $gitOutput
    Fail "Clone failed. Please check your internet connection and try again."
}

OK "Config cloned successfully."

# ── 5. Done ───────────────────────────────────────────────────

Write-Host ""
Write-Host "  ══════════════════════════════════════" -ForegroundColor DarkGray
Write-Host "  ✔  All done! Happy editing." -ForegroundColor Cyan
Write-Host ""
Write-Host "  Run 'nvim' or 'neovide' to get started." -ForegroundColor DarkCyan
Write-Host "  Lazy.nvim will auto-install plugins on first launch." -ForegroundColor DarkGray
Write-Host "  ══════════════════════════════════════" -ForegroundColor DarkGray
Write-Host ""
