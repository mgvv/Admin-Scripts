<#
.SYNOPSIS
Renames files and folders by replacing spaces with underscores.

.DESCRIPTION
This script recursively renames files and directories by replacing
blank spaces (" ") with underscores ("_").

Features:
- Works on files AND folders
- Recursive
- Timestamped CSV log file
- Dry-run mode (preview only)
- Undo (redo) capability using the latest log file

.PARAMETER Path
The root directory to process.
Default is the current directory.

.PARAMETER DryRun
Preview all rename operations without making any changes.

.PARAMETER Undo
Reverts the most recent rename operation using the latest log file.
Can be combined with -DryRun.

.EXAMPLE
Preview changes only:
.\Rename-SpacesToUnderscore.ps1 -Path "C:\Data" -DryRun

.EXAMPLE
Perform renaming:
.\Rename-SpacesToUnderscore.ps1 -Path "C:\Data"

.EXAMPLE
Preview undo:
.\Rename-SpacesToUnderscore.ps1 -Path "C:\Data" -Undo -DryRun

.EXAMPLE
Undo last rename:
.\Rename-SpacesToUnderscore.ps1 -Path "C:\Data" -Undo

.NOTES
Author: Your Name
Log files are stored in the target Path.
Undo relies entirely on the latest rename_log_*.csv file.
Always run DryRun before executing changes in production.
#>

param (
    [string]$Path = ".",
    [switch]$Undo,
    [switch]$DryRun
)

# Timestamp for log file
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$LogFile   = Join-Path $Path "rename_log_$Timestamp.csv"

# =========================
# UNDO MODE
# =========================
if ($Undo) {
    $LatestLog = Get-ChildItem -Path $Path -Filter "rename_log_*.csv" |
                 Sort-Object LastWriteTime -Descending |
                 Select-Object -First 1

    if (-not $LatestLog) {
        Write-Error "No log file found to undo."
        exit 1
    }

    Import-Csv $LatestLog.FullName |
    Sort-Object Depth |
    ForEach-Object {
        if (Test-Path $_.NewPath) {
            if ($DryRun) {
                Write-Host "[DRY-RUN] Rename $($_.NewPath) -> $($_.OldPath)"
            } else {
                Rename-Item -Path $_.NewPath -NewName (Split-Path $_.OldPath -Leaf)
            }
        }
    }

    Write-Host "Undo completed using log: $($LatestLog.Name)"
    exit
}

# =========================
# RENAME MODE
# =========================
$log = @()

# Rename directories (deepest first)
Get-ChildItem -Path $Path -Recurse -Directory |
Sort-Object FullName -Descending |
ForEach-Object {
    if ($_.Name -match ' ') {
        $newName = $_.Name -replace ' ', '_'
        $newPath = Join-Path $_.Parent.FullName $newName

        if ($DryRun) {
            Write-Host "[DRY-RUN] Rename DIR  : $($_.FullName) -> $newPath"
        } else {
            Rename-Item $_.FullName $newName
        }

        $log += [pscustomobject]@{
            OldPath = $_.FullName
            NewPath = $newPath
            Depth   = $_.FullName.Split('\').Count
            Type    = "Directory"
        }
    }
}

# Rename files
Get-ChildItem -Path $Path -Recurse -File |
ForEach-Object {
    if ($_.Name -match ' ') {
        $newName = $_.Name -replace ' ', '_'
        $newPath = Join-Path $_.DirectoryName $newName

        if ($DryRun) {
            Write-Host "[DRY-RUN] Rename FILE : $($_.FullName) -> $newPath"
        } else {
            Rename-Item $_.FullName $newName
        }

        $log += [pscustomobject]@{
            OldPath = $_.FullName
            NewPath = $newPath
            Depth   = $_.FullName.Split('\').Count
            Type    = "File"
        }
    }
}

# Save log
$log | Export-Csv $LogFile -NoTypeInformation

Write-Host "Operation completed."
Write-Host "Log saved as: $LogFile"

if ($DryRun) {
    Write-Host "No files or folders were actually renamed (DRY-RUN)."
}
