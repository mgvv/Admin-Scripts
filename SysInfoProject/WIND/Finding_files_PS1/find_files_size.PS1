# Prompt user for inputs
$directory = Read-Host "Enter the target directory path"
$minSizeMB = Read-Host "Enter minimum file size in MB (e.g., 500)"
$topCount = Read-Host "Enter how many top items to display (e.g., 10)"

# Convert minimum size to bytes
$minSizeBytes = [math]::Round($minSizeMB * 1MB)

Write-Host "`n--- Largest Files ---`n"

# Get largest files meeting criteria
$largestFiles = Get-ChildItem -Path $directory -Recurse -File |
    Where-Object { $_.Length -ge $minSizeBytes } |
    Sort-Object Length -Descending |
    Select-Object FullName, @{Name="Size(MB)";Expression={[math]::Round($_.Length / 1MB, 2)}} -First $topCount

$largestFiles | Format-Table -AutoSize

Write-Host "`n--- Largest Folders ---`n"

# Calculate folder sizes
$largestFolders = Get-ChildItem -Path $directory -Directory |
    ForEach-Object {
        $folderSize = (Get-ChildItem -Path $_.FullName -Recurse -File | Measure-Object -Property Length -Sum).Sum
        [PSCustomObject]@{
            Folder = $_.FullName
            SizeMB = [math]::Round($folderSize / 1MB, 2)
        }
    } |
    Sort-Object SizeMB -Descending |
    Select-Object -First $topCount

