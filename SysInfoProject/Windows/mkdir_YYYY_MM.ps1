param (
    [int]$Year
)

# Create the year directory
New-Item -ItemType Directory -Name $Year -Force | Out-Null

# Create month subdirectories (01–12)
1..12 | ForEach-Object {
    $month = "{0:D2}" -f $_
    New-Item -ItemType Directory -Path "$Year\$month" -Force | Out-Null
}

Write-Host "Directory structure created for year $Year"
