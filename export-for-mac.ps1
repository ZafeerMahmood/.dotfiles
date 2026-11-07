<#
.SYNOPSIS
    Bundles private files (env files, per-repo .claude/.docs/notes/tmp, Claude Code config + memories,
    optional DB dumps) into one zip
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
$privateFolderNames = @('.claude', '.docs', '.notes', 'notes', '.tmp', 'tmp', '.superpowers', '.fallow')
foreach ($repository in Get-ChildItem -LiteralPath $workDirectory -Directory -Force) {
    foreach ($folderName in $privateFolderNames) {
        $folderPath = Join-Path $repository.FullName $folderName
        if (Test-Path -LiteralPath $folderPath) {
            Copy-Entry $folderPath "Desktop\Work\$($repository.Name)\$folderName"
        }
    }
}

# NOTE: not a git repo, so the whole folder has to travel
Copy-Entry (Join-Path $workDirectory 'claude-code-leaked') 'Desktop\Work\claude-code-leaked'

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

Write-Host '==> Neovim extras'
$nvimDirectory = Join-Path $env:LOCALAPPDATA 'nvim'
foreach ($name in '.claude\CLAUDE.md', '.claude\settings.local.json', '.docs', 'todo.md', 'spell\en.utf-8.add') {
    Copy-Entry (Join-Path $nvimDirectory $name) ".config\nvim\$name"
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
        $databaseNames = & "$pgBinDirectory\psql.exe" -U postgres -h localhost -Atc `
            "select datname from pg_database where not datistemplate and datname <> 'postgres' order by 1"
        if ($LASTEXITCODE -ne 0) { throw 'psql could not list databases, wrong password?' }
        $manifestLines.Add("databases: $($databaseNames -join ', ')")

        foreach ($databaseName in $databaseNames) {
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
