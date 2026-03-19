# uninstall.ps1 — Neovim config uninstaller
# Removes Neovim, Neovide, and related configuration/data directories.

$ErrorActionPreference = "Stop"
Write-Host ""
Write-Host "  Neovim Uninstaller" -ForegroundColor Cyan
Write-Host "  ==================" -ForegroundColor Cyan
Write-Host ""

# 1. Ask for confirmation
Write-Host "  Are you sure you want to completely remove Neovim, Neovide, and all" -ForegroundColor Yellow
Write-Host "  configuration and data files?" -ForegroundColor Yellow
$confirm = Read-Host "  [Y/N]"

if ($confirm.Trim().ToUpper() -ne 'Y') {
    Write-Host ""
    Write-Host "  Uninstallation aborted." -ForegroundColor DarkYellow
    exit 0
}

Write-Host ""
# Change working directory so we don't lock the folder we're about to delete
Set-Location $env:USERPROFILE

# 2. Uninstall Neovide (scoop)
if (Get-Command scoop -ErrorAction SilentlyContinue) {
    # Check if installed
    $neovideInstalled = $false
    try { if (scoop list neovide 2>$null) { $neovideInstalled = $true } } catch {}
    if ($neovideInstalled) {
        Write-Host "  >> Uninstalling Neovide via scoop..." -ForegroundColor Green
        try { scoop uninstall neovide 2>&1 | Out-Null } catch {}
    }
}

# 3. Uninstall Neovim (scoop and winget)
if (Get-Command scoop -ErrorAction SilentlyContinue) {
    $neovimScoopInstalled = $false
    try { if (scoop list neovim 2>$null) { $neovimScoopInstalled = $true } } catch {}
    if ($neovimScoopInstalled) {
        Write-Host "  >> Uninstalling Neovim via scoop..." -ForegroundColor Green
        try { scoop uninstall neovim 2>&1 | Out-Null } catch {}
    }
}

if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Host "  >> Attempting to uninstall Neovim via winget (if installed)..." -ForegroundColor Green
    # Winget exits successfully if the package was removed, or quietly fails if not.
    try { winget uninstall --id Neovim.Neovim --silent --accept-source-agreements 2>&1 | Out-Null } catch {}
}

# 4. Remove directories
$dirs = @(
    "$env:LOCALAPPDATA\nvim",
    "$env:LOCALAPPDATA\nvim-data",
    "$env:LOCALAPPDATA\state\nvim"
)

foreach ($d in $dirs) {
    if (Test-Path $d) {
        Write-Host "  >> Removing directory: $d..." -ForegroundColor Gray
        try {
            Remove-Item -Recurse -Force $d -ErrorAction SilentlyContinue
        } catch {
            Write-Host "  [!] Could not completely remove $d. A file might be in use." -ForegroundColor Yellow
        }
    }
}

Write-Host ""
Write-Host "  Uninstallation complete!" -ForegroundColor Cyan
Write-Host ""
