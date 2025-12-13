
# Define the process names to check
$processNames = @("R3load", "R3ldctl", "SAPuptool", "R3szchk")

# Get all processes matching the names
$runningProcesses = Get-Process | Where-Object { $processNames -contains $_.ProcessName }

# Display results
if ($runningProcesses) {
    Write-Host "The following processes are running:" -ForegroundColor Green
    $runningProcesses | Select-Object ProcessName, Id
} else {
    Write-Host "None of the specified processes are running." -ForegroundColor Yellow
}
