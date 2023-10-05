$Customer = "Customer"

$Environment = "env1"

$Node = "1"

# Import the AWS Tools for PowerShell module (if not imported)
Import-Module AWSPowerShell

# Get information about the EC2 instance
$InstanceInfo = Get-EC2Instance -InstanceId (Invoke-RestMethod -Uri http://169.254.169.254/latest/meta-data/instance-id -Headers @{ "X-aws-ec2-metadata-token" = $env:AWS_SESSION_TOKEN })

# Extract the instance name from the tags
$InstanceName = $InstanceInfo.Instances[0].Tags | Where-Object { $_.Key -eq "Name" } | Select-Object -ExpandProperty Value

# Determine the root drive
$SystemDrive = (Get-WmiObject -Class Win32_OperatingSystem).SystemDrive

# Create the Log directory if it doesn't exist
$LogDirectory = "C:\monitoring\logs\DiskSpace"
if (-not (Test-Path -Path $LogDirectory -PathType Container)) {
    New-Item -Path $LogDirectory -ItemType Directory
}

# Define the output JSON file path with the current date and time
$CurrentDate = Get-Date -Format "yyyy-MM-dd"
$OutputFilePath = Join-Path -Path $LogDirectory -ChildPath "$CurrentDate.json"

# Initialize a hashtable to store the disk space information
$DiskSpaceInfo = @{}

# Initialize a counter for data drives
$dataDriveCounter = 1

# Gather disk space information and add it to the hashtable
Get-WmiObject -Class Win32_LogicalDisk | ForEach-Object {
    $deviceID = $_.DeviceID
    $totalSpaceBytes = $_.Size
    $freeSpaceBytes = $_.FreeSpace
    $usedSpaceBytes = $totalSpaceBytes - $freeSpaceBytes

    # Determine the disk name based on the root drive
    if ($deviceID -eq $SystemDrive) {
        $diskName = "root"
    } else {
        $diskName = "data$dataDriveCounter"
        $dataDriveCounter++
    }

    # Create an ordered hashtable for the disk space information in bytes
    $DiskInfo = [ordered]@{
        "path" = $deviceID
        "total" = $totalSpaceBytes
        "used" = $usedSpaceBytes
        "free" = $freeSpaceBytes
    }

    # Add the disk space information to the hashtable
    $DiskSpaceInfo[$diskName] = $DiskInfo
}

# Create an ordered hashtable for the final JSON entity
$JsonEntity = [ordered]@{
    "LogTime" = (Get-Date -Format "yyyy-MM-dd HH:mm")
    "customer" = $Customer
    "environment" = $Environment
    "node" = $Node
    "InstanceName" = $InstanceName
    "diskspace" = $DiskSpaceInfo
}

# Convert the ordered hashtable to JSON and write it to the output file on a single line
$JsonContent = $JsonEntity | ConvertTo-Json -Compress
$JsonContent | Out-File -FilePath $OutputFilePath -Encoding UTF8 -Append
