# Create the Log directory if it doesn't exist
$LogDirectory = "C:\PerfLogs"
if (-not (Test-Path -Path $LogDirectory -PathType Container)) {
    New-Item -Path $LogDirectory -ItemType Directory
}

# Define the output JSON file path with the current date and time
$CurrentDate = Get-Date -Format "ddMMyyyy"
$OutputFilePath = Join-Path -Path $LogDirectory -ChildPath "$CurrentDate.json"

# Initialize an array to store the JSON objects
$DiskSpaceInfo = @()

# Gather disk space information and add it to the array
Get-WmiObject -Class Win32_LogicalDisk | ForEach-Object {
    $deviceID = $_.DeviceID
    $freeSpaceGB = [math]::Round($_.FreeSpace / 1GB, 2)  # Free space in GB, rounded to two decimal places
    $totalSpaceGB = [math]::Round($_.Size / 1GB, 2)       # Total space in GB, rounded to two decimal places

    # Create an ordered hashtable to ensure consistent ordering
    $OrderedDiskInfo = [ordered]@{
        "LogTime" = (Get-Date -Format "dd/MM/yyyy HH:mm")
        "DeviceID" = $deviceID
        "FreeSpace" = $freeSpaceGB 
        "TotalSpace" = $totalSpaceGB
    }

    $JsonContent = $OrderedDiskInfo | ConvertTo-Json -Compress
    # Log the JSON log entry to the output file on a single line
    $JsonContent | Out-File -FilePath $OutputFilePath -Encoding UTF8 -Append
}
