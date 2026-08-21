<#
.SYNOPSIS
    Copies the dev (repo) skills to the global Claude skills directory.

.DESCRIPTION
    Mirrors each skill folder under <repo>/.claude/skills into the destination
    (default: $HOME\.claude\skills). Files removed from the dev version are
    deleted from the destination copy. Skills in the destination that do not
    exist in the repo are never touched.

.EXAMPLE
    ./scripts/sync-skills.ps1 -DryRun
    ./scripts/sync-skills.ps1
    ./scripts/sync-skills.ps1 -Skill plan-lite
#>
[CmdletBinding()]
param(
    # Destination skills root.
    [string]$Destination = (Join-Path $HOME '.claude\skills'),

    # Limit the sync to specific skill folder names.
    [string[]]$Skill,

    # Show what would change without writing anything.
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$source   = Join-Path $repoRoot '.claude\skills'

if (-not (Test-Path -LiteralPath $source)) {
    throw "Source skills directory not found: $source"
}

$skillDirs = Get-ChildItem -LiteralPath $source -Directory
if ($Skill) {
    $skillDirs = $skillDirs | Where-Object { $Skill -contains $_.Name }
    $missing = $Skill | Where-Object { $skillDirs.Name -notcontains $_ }
    if ($missing) { throw "Skill(s) not found in $source : $($missing -join ', ')" }
}
if (-not $skillDirs) { throw "No skills found in $source" }

if (-not (Test-Path -LiteralPath $Destination)) {
    if ($DryRun) {
        Write-Host "CREATE DIR $Destination" -ForegroundColor Yellow
    } else {
        New-Item -ItemType Directory -Path $Destination -Force | Out-Null
    }
}

$copied = 0; $updated = 0; $deleted = 0

foreach ($dir in $skillDirs) {
    $destDir = Join-Path $Destination $dir.Name
    Write-Host "== $($dir.Name)" -ForegroundColor Cyan

    if (-not (Test-Path -LiteralPath $destDir)) {
        if ($DryRun) {
            Write-Host "  CREATE DIR $destDir" -ForegroundColor Yellow
        } else {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
    }

    # Copy / update files from dev -> destination.
    foreach ($file in Get-ChildItem -LiteralPath $dir.FullName -File -Recurse) {
        $relative = $file.FullName.Substring($dir.FullName.Length).TrimStart('\')
        $target   = Join-Path $destDir $relative

        $action = $null
        if (-not (Test-Path -LiteralPath $target)) {
            $action = 'ADD'
        } else {
            $srcHash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
            $dstHash = (Get-FileHash -LiteralPath $target      -Algorithm SHA256).Hash
            if ($srcHash -ne $dstHash) { $action = 'UPDATE' }
        }

        if (-not $action) { continue }

        if ($DryRun) {
            Write-Host "  $action $relative" -ForegroundColor Yellow
        } else {
            $targetParent = Split-Path -Parent $target
            if (-not (Test-Path -LiteralPath $targetParent)) {
                New-Item -ItemType Directory -Path $targetParent -Force | Out-Null
            }
            Copy-Item -LiteralPath $file.FullName -Destination $target -Force
            Write-Host "  $action $relative" -ForegroundColor Green
        }

        if ($action -eq 'ADD') { $copied++ } else { $updated++ }
    }

    # Remove destination files that no longer exist in the dev version.
    if (Test-Path -LiteralPath $destDir) {
        foreach ($file in Get-ChildItem -LiteralPath $destDir -File -Recurse) {
            $relative = $file.FullName.Substring($destDir.Length).TrimStart('\')
            $origin   = Join-Path $dir.FullName $relative
            if (Test-Path -LiteralPath $origin) { continue }

            if ($DryRun) {
                Write-Host "  DELETE $relative" -ForegroundColor Yellow
            } else {
                Remove-Item -LiteralPath $file.FullName -Force
                Write-Host "  DELETE $relative" -ForegroundColor Red
            }
            $deleted++
        }
    }
}

$prefix = if ($DryRun) { 'Dry run: ' } else { '' }
Write-Host "$prefix$copied added, $updated updated, $deleted deleted -> $Destination"
