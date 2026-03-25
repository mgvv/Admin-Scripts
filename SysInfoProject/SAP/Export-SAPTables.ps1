# ---------------------------------------------------------------
# Script: Export-SAPTables.ps1
# Purpose: Export SAP tables using R3trans (Windows)
# Author: Manuel Gabriel Veliz (SAP Basis)
# ---------------------------------------------------------------

# ---- CONFIG ----------------------------------------------------

# SAP SID
$SID = "PRD"

# Path to R3trans binary
$R3transPath = "C:\usr\sap\$SID\SYS\exe\uc\NTAMD64\R3trans.exe"

# Working directory for export
$WorkDir = "C:\usr\sap\trans\export"
New-Item -ItemType Directory -Force -Path $WorkDir | Out-Null

# Control and log files
$CtlFile = "$WorkDir\export_tables.ctl"
$LogFile = "$WorkDir\export_tables.log"

# ---- EXECUTION ------------------------------------------------

Write-Host "------------------------------------------------------------"
Write-Host " SAP Table Export via R3trans (PowerShell)"
Write-Host " Control File: $CtlFile"
Write-Host " Log File:      $LogFile"
Write-Host " Working Dir:   $WorkDir"
Write-Host "------------------------------------------------------------"

# Check if R3trans exists
if (-Not (Test-Path $R3transPath)) {
    Write-Host "ERROR: R3trans not found at $R3transPath" -ForegroundColor Red
    exit 1
}

# Copy control file to working directory if needed
if (-Not (Test-Path $CtlFile)) {
    Write-Host "ERROR: Control file not found at $CtlFile" -ForegroundColor Red
    exit 1
}

# Run R3trans
& "$R3transPath" $CtlFile | Out-File -FilePath $LogFile -Encoding utf8

# ---- RESULT CHECK ---------------------------------------------

$ExitCode = $LASTEXITCODE

if ($ExitCode -eq 0) {
    Write-Host "✔ Export completed successfully." -ForegroundColor Green
    Write-Host "   Output file: $WorkDir\table_export.dat"
} else {
    Write-Host "❌ Export failed with Return Code: $ExitCode" -ForegroundColor Red
    Write-Host "   Check log: $LogFile"
}

exit $ExitCode
