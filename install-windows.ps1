#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Symlinks dotfiles from this repo to their expected locations on Windows.
.DESCRIPTION
    Run this script from an elevated PowerShell 7+ prompt:
        pwsh -ExecutionPolicy Bypass -File install-windows.ps1

    It creates symbolic links from where each tool expects its config
    back into this dotfiles repo. Existing files are backed up to *.backup
    before linking.
#>

param(
    [switch]$DryRun   # Show what would happen without doing it
)

$ErrorActionPreference = "Stop"
$DotfilesDir = $PSScriptRoot
$Home = $env:USERPROFILE

function Link-Item {
    param(
        [string]$Source,   # File/dir inside this repo
        [string]$Target    # Where the tool expects it
    )

    if (-not (Test-Path $Source)) {
        Write-Warning "Source missing, skipping: $Source"
        return
    }

    $targetParent = Split-Path $Target -Parent
    if (-not (Test-Path $targetParent)) {
        if ($DryRun) { Write-Host "[DRY RUN] mkdir $targetParent" -ForegroundColor Cyan; return }
        New-Item -ItemType Directory -Path $targetParent -Force | Out-Null
    }

    if (Test-Path $Target) {
        $item = Get-Item $Target -Force
        if ($item.LinkType -eq "SymbolicLink") {
            $existingTarget = $item.Target
            if ($existingTarget -eq (Resolve-Path $Source).Path) {
                Write-Host "Already linked: $Target" -ForegroundColor Green
                return
            }
            # Remove stale symlink
            Remove-Item $Target -Force
        } else {
            # Backup existing file/dir
            $backup = "$Target.backup"
            if ($DryRun) { Write-Host "[DRY RUN] backup $Target -> $backup" -ForegroundColor Cyan; return }
            Write-Host "Backing up: $Target -> $backup" -ForegroundColor Yellow
            if (Test-Path $backup) { Remove-Item $backup -Recurse -Force }
            Move-Item $Target $backup
        }
    }

    if ($DryRun) {
        Write-Host "[DRY RUN] link $Target -> $Source" -ForegroundColor Cyan
        return
    }

    $isDir = (Get-Item $Source) -is [System.IO.DirectoryInfo]
    New-Item -ItemType SymbolicLink -Path $Target -Target (Resolve-Path $Source).Path | Out-Null
    Write-Host "Linked: $Target -> $Source" -ForegroundColor Green
}

Write-Host "`n=== Dotfiles Installer (Windows) ===" -ForegroundColor Magenta
Write-Host "Repo: $DotfilesDir`n"

# --- Git ---
Link-Item "$DotfilesDir\git\.gitconfig"          "$Home\.gitconfig"
Link-Item "$DotfilesDir\git\.gitconfig-personal"  "$Home\.gitconfig-personal"
Link-Item "$DotfilesDir\git\.gitconfig-work"      "$Home\.gitconfig-work"
Link-Item "$DotfilesDir\git\ignore"               "$Home\.config\git\ignore"

# --- Bash ---
Link-Item "$DotfilesDir\bash\.bash_profile"       "$Home\.bash_profile"

# --- Neovim ---
Link-Item "$DotfilesDir\nvim"                     "$env:LOCALAPPDATA\nvim"

# --- WezTerm ---
Link-Item "$DotfilesDir\wezterm\.wezterm.lua"     "$Home\.wezterm.lua"

# --- SSH config (NOT keys) ---
Link-Item "$DotfilesDir\ssh\config"               "$Home\.ssh\config"

# --- PowerShell profile ---
Link-Item "$DotfilesDir\powershell\Microsoft.PowerShell_profile.ps1" "$Home\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"

# --- Windows Terminal ---
$wtPath = Get-ChildItem "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_*" -Directory -ErrorAction SilentlyContinue | Select-Object -First 1
if ($wtPath) {
    Link-Item "$DotfilesDir\windows-terminal\settings.json" "$($wtPath.FullName)\LocalState\settings.json"
} else {
    Write-Warning "Windows Terminal package folder not found, skipping."
}

# --- GlazeWM ---
Link-Item "$DotfilesDir\glazewm\config.yaml"      "$Home\.glzr\glazewm\config.yaml"

# --- YASB ---
Link-Item "$DotfilesDir\yasb\config.yaml"          "$Home\.config\yasb\config.yaml"
Link-Item "$DotfilesDir\yasb\styles.css"           "$Home\.config\yasb\styles.css"

# --- VS Code ---
Link-Item "$DotfilesDir\vscode\settings.json"      "$env:APPDATA\Code\User\settings.json"
Link-Item "$DotfilesDir\vscode\keybindings.json"   "$env:APPDATA\Code\User\keybindings.json"

# --- Cursor ---
Link-Item "$DotfilesDir\cursor\settings.json"      "$env:APPDATA\Cursor\User\settings.json"
Link-Item "$DotfilesDir\cursor\keybindings.json"   "$env:APPDATA\Cursor\User\keybindings.json"

# --- Mintty (Git Bash) ---
Link-Item "$DotfilesDir\mintty\.minttyrc"          "$Home\.minttyrc"

# --- GitHub CLI ---
Link-Item "$DotfilesDir\github-cli\config.yml"    "$env:APPDATA\GitHub CLI\config.yml"

# --- Fonts ---
$fontDest = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
if (-not (Test-Path $fontDest)) { New-Item -ItemType Directory -Path $fontDest -Force | Out-Null }
foreach ($font in Get-ChildItem "$DotfilesDir\fonts\*.ttf") {
    $target = Join-Path $fontDest $font.Name
    if (-not (Test-Path $target)) {
        if ($DryRun) { Write-Host "[DRY RUN] copy font $($font.Name)" -ForegroundColor Cyan; continue }
        Copy-Item $font.FullName $target
        Write-Host "Copied font: $($font.Name)" -ForegroundColor Green
    } else {
        Write-Host "Font exists: $($font.Name)" -ForegroundColor Green
    }
}

Write-Host "`n=== Done! ===" -ForegroundColor Magenta
Write-Host "Run with -DryRun to preview changes without applying them.`n"
