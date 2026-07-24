# ================================
# CONFIGURATION
# ================================
$basePath = "The DIR"
$clients = @("CUST_1", "CUST_2", "CUST_3", "CUST_4", "CUST_5")

# ================================
# TEMPLATE CONTENT
# ================================

$readme_general = @"
# Folder Purpose

This folder contains structured documentation related to operations, incidents, and systems.

## Guidelines
- Follow naming conventions
- Keep documents updated
- Avoid duplicates

Last updated: $(Get-Date)
"@

$incident_template = @"
# Incident Report

## Incident ID:
## Date:
## System (SID / Host):
## Environment (PROD/QA/DEV):

## Description:
[Describe the issue]

## Impact:
[Business / technical impact]

## Root Cause:
[If known]

## Resolution:
[Steps taken]

## Owner:
## Status:
"@

$rca_template = @"
# Root Cause Analysis (RCA)

## Incident Reference:
## Date:

## Summary:
[Short description]

## Timeline:
- Time:
- Event:

## Root Cause:
[Detailed cause]

## Corrective Actions:
- [Action 1]
- [Action 2]

## Preventive Measures:
[Future prevention]

## Owner:
"@

$change_template = @"
# Change Request

## Change ID:
## Description:
## System:

## Risk Level:
Low / Medium / High

## Implementation Plan:
[Steps]

## Rollback Plan:
[Steps]

## Approval:
[Names]

## Scheduled Date:
"@

$sop_template = @"
# Standard Operating Procedure (SOP)

## Title:
## System:

## Purpose:
[What this SOP is for]

## Steps:
1.
2.
3.

## Validation:
[How to verify success]

## Owner:
"@

# ================================
# FOLDER DEFINITIONS
# ================================

$folders = @(
    "00_Governance\SLA",
    "00_Governance\Contracts",
    "00_Governance\RACI",

    "01_Architecture\SAP\Landscape_Diagrams",
    "01_Architecture\SAP\SID_Overview",
    "01_Architecture\Infrastructure\Network",
    "01_Architecture\Infrastructure\NTT_DC",
    "01_Architecture\Infrastructure\Cloud_RISE",
    "01_Architecture\OS\Linux",
    "01_Architecture\OS\Windows",

    "02_Environments\PROD\SAP",
    "02_Environments\PROD\Linux",
    "02_Environments\PROD\Windows",
    "02_Environments\QA\SAP",
    "02_Environments\QA\Linux",
    "02_Environments\QA\Windows",
    "02_Environments\DEV\SAP",
    "02_Environments\DEV\Linux",
    "02_Environments\DEV\Windows",

    "03_Operations\Runbooks",
    "03_Operations\SOPs",
    "03_Operations\Monitoring",
    "03_Operations\Health_Checks",

    "04_Incidents_Problems\2026\INC\SAP",
    "04_Incidents_Problems\2026\INC\Linux",
    "04_Incidents_Problems\2026\INC\Windows",
    "04_Incidents_Problems\2026\PRB",

    "05_Changes_Releases\CAB",
    "05_Changes_Releases\Transports\PROD",
    "05_Changes_Releases\Transports\QA",
    "05_Changes_Releases\Releases\2026",

    "06_Projects\Active",
    "06_Projects\Completed",

    "07_Vendors_NTT_RISE\NTT\Tickets",
    "07_Vendors_NTT_RISE\SAP_RISE\Tickets",

    "08_Backups_Dumps\SAP",
    "08_Backups_Dumps\DB",
    "08_Backups_Dumps\OS",

    "09_Templates"
)

# ================================
# EXECUTION
# ================================

foreach ($client in $clients) {

    $clientPath = Join-Path $basePath $client

    foreach ($folder in $folders) {
        $fullPath = Join-Path $clientPath $folder
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null

        # Add README to key folders only
        if ($folder -match "00_Governance|01_Architecture|03_Operations|04_Incidents_Problems|05_Changes_Releases") {
            $readmePath = Join-Path $fullPath "README.md"
            if (!(Test-Path $readmePath)) {
                Set-Content -Path $readmePath -Value $readme_general
            }
        }
    }

    # ================================
    # CREATE TEMPLATES
    # ================================
    $templatePath = Join-Path $clientPath "09_Templates"

    Set-Content -Path (Join-Path $templatePath "Incident_Template.md") -Value $incident_template
    Set-Content -Path (Join-Path $templatePath "RCA_Template.md") -Value $rca_template
    Set-Content -Path (Join-Path $templatePath "Change_Request_Template.md") -Value $change_template
    Set-Content -Path (Join-Path $templatePath "SOP_Template.md") -Value $sop_template
}

Write-Output "✅ Folder structure + README + Templates created successfully!"
