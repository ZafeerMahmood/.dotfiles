<#
.SYNOPSIS
    Bundles private files (env files, notes, Claude Code config, agent configs, optional DB dumps) into one zip
    on the Desktop for the Mac. Read-only on this PC except for the zip and a temp staging folder.

.DESCRIPTION
    The zip holds manifest.txt and home/, laid out like the Mac home dir. On the Mac run:
        bash ~/.dotfiles/macos/import-from-windows.sh <zip>
    The zip holds secrets. Keep it out of git, move it by AirDrop/USB, delete it after import.

.PARAMETER IncludePgDump
    Also pg_dump the local databases and roles (asks for the postgres password once).

.PARAMETER IncludeTranscripts
    Copy full ~/.claude/projects (session transcripts, ~1.8 GB) instead of only memory/ folders.

.EXAMPLE
    pwsh ~/.dotfiles/export-for-mac.ps1 -IncludePgDump
#>
param(
    [switch]$IncludePgDump,
    [switch]$IncludeTranscripts,
    [string[]]$Databases = @('taxgpt', 'djangoTest', 'ai'),
    [string]$OutputDirectory = [Environment]::GetFolderPath('Desktop')
)

$ErrorActionPreference = 'Stop'

$workDirectory = Join-Path $HOME 'Desktop\Work'
$timestamp = Get-Date -Format 'yyyyMMdd-HHmm'
$stagingDirectory = Join-Path $env:TEMP "mac-export-$timestamp"
$bundleHome = Join-Path $stagingDirectory 'home'
$zipPath = Join-Path $OutputDirectory "mac-export-$timestamp.zip"
$manifestLines = [System.Collections.Generic.List[string]]::new()

$excludedDirectories = @(
    'node_modules', '.venv', 'venv', 'env', '__pycache__', '.pytest_cache', '.mypy_cache', '.ruff_cache',
    '.next', '.turbo', '.cache', 'cache', 'worktrees', '.trash', 'synced'
)
$excludedFiles = @('id_rsa*', 'id_ed25519*', 'id_ecdsa*', '*.pem', '*.ppk', '.credentials.json', 'auth.json')

function Copy-Entry {
    param([string]$SourcePath, [string]$BundleRelativePath)

    if (-not (Test-Path -LiteralPath $SourcePath)) {
        $manifestLines.Add("MISSING  $SourcePath")
        return
    }

    $targetPath = Join-Path $bundleHome $BundleRelativePath
    $sourceItem = Get-Item -LiteralPath $SourcePath -Force

    if ($sourceItem.PSIsContainer) {
        # NOTE: robocopy follows junctions (the two skill links) and copies their contents
        robocopy $SourcePath $targetPath /E /R:0 /W:0 /NFL /NDL /NJH /NJS /NP /XD @excludedDirectories /XF @excludedFiles | Out-Null
        if ($LASTEXITCODE -ge 8) {
            $manifestLines.Add("FAILED   $SourcePath (robocopy exit $LASTEXITCODE)")
            return
        }
    }
    else {
        New-Item -ItemType Directory -Force -Path (Split-Path $targetPath) | Out-Null
        Copy-Item -LiteralPath $SourcePath -Destination $targetPath -Force
    }

    $manifestLines.Add("OK       $SourcePath -> home/$($BundleRelativePath -replace '\\', '/')")
}

New-Item -ItemType Directory -Force -Path $bundleHome | Out-Null
$manifestLines.Add("mac-export $timestamp from $env:COMPUTERNAME")
$manifestLines.Add('')

Write-Host '==> Project env files'
$envTarget = Join-Path $bundleHome 'Desktop\Work'
robocopy $workDirectory $envTarget '.env' '.env.*' /S /R:0 /W:0 /NJH /NJS /NP /NDL `
    /XD @excludedDirectories .git .cursor test-worktree | Out-Null
Get-ChildItem -LiteralPath $envTarget -Recurse -Force -File -ErrorAction SilentlyContinue | ForEach-Object {
    $manifestLines.Add("OK       env: Desktop/Work/$($_.FullName.Substring($envTarget.Length + 1) -replace '\\', '/')")
}

Write-Host '==> Project private folders'
$privateFolderNames = @('.docs', '.superpowers', 'notes', '.fallow', 'tmp', '.gemini')
foreach ($repository in Get-ChildItem -LiteralPath $workDirectory -Directory -Force) {
    foreach ($folderName in $privateFolderNames) {
        $folderPath = Join-Path $repository.FullName $folderName
        if (Test-Path -LiteralPath $folderPath) {
            Copy-Entry $folderPath "Desktop\Work\$($repository.Name)\$folderName"
        }
    }
}

$workExtras = @(
    'TaxGPT_App\.claude\CLAUDE.md',
    'TaxGPT_App\.claude\settings.local.json',
    'TaxGPT_App\.claude\plans',
    'TaxGPT_App\.claude\projects',
    'TaxGPT_App\backend\script.py',
    'TaxGPT_App\backend\taxbiz_script.py',
    'TaxGPT_App\frontend\src\app\(app)\test',
    'TaxGPT_App\frontend\lib\rollbar\RollbarClientProvider.tsx',
    'TaxGPT_ai_services\.claude',
    'TaxGPT_ai_services\runbook-v1.md',
    'TaxGPT_ai_services\app\api\document_selection',
    'TaxGPT_ai_services\app\api\imports',
    'TaxGPT_ai_services\app\exp',
    'TaxGPT_ai_services\app\core\config\loader_aa_review.py',
    'TaxGPT_ai_services\app\core\config\loader_research.py',
    'TaxGPT_cowork\.claude\CLAUDE.md',
    'TaxGPT_cowork\.claude\settings.local.json',
    'TaxGPT_cowork\.claude\skills',
    'TaxGPT_cowork-formatting\.claude',
    'TaxGPT_ui_library\.claude\CLAUDE.md',
    'TaxGPT_ui_library\.claude\settings.local.json',
    'review-assignments\taxgpt-assignment-review.md',
    'claude-code-leaked'
)
foreach ($relativePath in $workExtras) {
    Copy-Entry (Join-Path $workDirectory $relativePath) "Desktop\Work\$relativePath"
}

Write-Host '==> Git stashes as patches'
$stashDirectory = Join-Path $bundleHome 'mac-export\stashes'
foreach ($repository in Get-ChildItem -LiteralPath $workDirectory -Directory -Force) {
    # NOTE: worktrees have a .git file and share the main repo stashes, skip them to avoid duplicates
    if (-not (Test-Path -LiteralPath (Join-Path $repository.FullName '.git') -PathType Container)) { continue }

    $stashCount = @(git -C $repository.FullName stash list).Count
    for ($stashIndex = 0; $stashIndex -lt $stashCount; $stashIndex++) {
        New-Item -ItemType Directory -Force -Path $stashDirectory | Out-Null
        $patchPath = Join-Path $stashDirectory "$($repository.Name)-stash-$stashIndex.patch"
        git -C $repository.FullName stash show -p --include-untracked "stash@{$stashIndex}" "--output=$patchPath"
        $manifestLines.Add("OK       stash: $($repository.Name) stash@{$stashIndex} -> home/mac-export/stashes")
    }
}

Write-Host '==> Claude Code'
$claudeDirectory = Join-Path $HOME '.claude'
foreach ($name in 'CLAUDE.md', 'settings.json', 'settings.local.json', 'keybindings.json', 'output-styles', 'skills') {
    Copy-Entry (Join-Path $claudeDirectory $name) ".claude\$name"
}

$projectsDirectory = Join-Path $claudeDirectory 'projects'
foreach ($project in Get-ChildItem -LiteralPath $projectsDirectory -Directory -Force -ErrorAction SilentlyContinue) {
    if ($IncludeTranscripts) {
        Copy-Entry $project.FullName ".claude\projects\$($project.Name)"
        continue
    }

    $memoryPath = Join-Path $project.FullName 'memory'
    if (Test-Path -LiteralPath $memoryPath) {
        Copy-Entry $memoryPath ".claude\projects\$($project.Name)\memory"
    }
}

foreach ($name in '.agents', '.agent', 'skills-lock.json') {
    Copy-Entry (Join-Path $HOME $name) $name
}

Write-Host '==> Codex + Gemini'
foreach ($name in 'AGENTS.md', 'memories', 'rules', 'skills', 'config.toml') {
    Copy-Entry (Join-Path $HOME ".codex\$name") ".codex\$name"
}
foreach ($name in 'commands', 'extensions', 'settings.json', 'skills') {
    Copy-Entry (Join-Path $HOME ".gemini\$name") ".gemini\$name"
}

Write-Host '==> Neovim extras'
$nvimDirectory = Join-Path $env:LOCALAPPDATA 'nvim'
foreach ($name in '.claude\CLAUDE.md', '.claude\settings.local.json', '.docs', 'todo.md', 'spell\en.utf-8.add') {
    Copy-Entry (Join-Path $nvimDirectory $name) ".config\nvim\$name"
}
foreach ($name in 'CLAUDE.md', 'todo.md') {
    Copy-Entry (Join-Path $env:LOCALAPPDATA "unknown-decay.nvim\$name") "code\unknown-decay.nvim\$name"
}

Write-Host '==> Loose notes'
Copy-Entry (Join-Path $HOME '.doc') '.doc'

if ($IncludePgDump) {
    Write-Host '==> Postgres dumps'
    $pgDump = Get-Command pg_dump -ErrorAction SilentlyContinue
    $pgBinDirectory = 'C:\Program Files\PostgreSQL\16\bin'
    if ($pgDump) { $pgBinDirectory = Split-Path $pgDump.Source }

    $dumpDirectory = Join-Path $bundleHome 'mac-export\pg'
    New-Item -ItemType Directory -Force -Path $dumpDirectory | Out-Null

    $securePassword = Read-Host 'postgres password' -AsSecureString
    $env:PGPASSWORD = [System.Net.NetworkCredential]::new('', $securePassword).Password
    try {
        foreach ($databaseName in $Databases) {
            & "$pgBinDirectory\pg_dump.exe" -U postgres -h localhost -Fc -f "$dumpDirectory\$databaseName.dump" $databaseName
            $status = 'OK      '
            if ($LASTEXITCODE -ne 0) { $status = 'FAILED  ' }
            $manifestLines.Add("$status pg_dump $databaseName -> home/mac-export/pg/$databaseName.dump")
        }
        & "$pgBinDirectory\pg_dumpall.exe" -U postgres -h localhost --roles-only -f "$dumpDirectory\roles.sql"
        $manifestLines.Add("OK       pg_dumpall roles -> home/mac-export/pg/roles.sql")
    }
    finally {
        Remove-Item Env:PGPASSWORD -ErrorAction SilentlyContinue
    }
}

$manifestLines | Set-Content -LiteralPath (Join-Path $stagingDirectory 'manifest.txt') -Encoding utf8NoBOM

Write-Host '==> Zipping'
Add-Type -AssemblyName System.IO.Compression.FileSystem
if (Test-Path -LiteralPath $zipPath) { Remove-Item -LiteralPath $zipPath -Force }
[System.IO.Compression.ZipFile]::CreateFromDirectory($stagingDirectory, $zipPath)
Remove-Item -LiteralPath $stagingDirectory -Recurse -Force

$manifestLines | Where-Object { $_ -match '^(MISSING|FAILED)' } | ForEach-Object { Write-Warning $_ }
Write-Host "Done: $zipPath ($([math]::Round((Get-Item $zipPath).Length / 1MB, 1)) MB)"
Write-Host 'Holds secrets. Move it by AirDrop/USB, never commit it, delete after import on the Mac.'
