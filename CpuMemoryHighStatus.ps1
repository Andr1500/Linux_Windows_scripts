# Create the Log directory if it doesn't exist
$LogDirectory = "C:\ProcessesCpuMemoryStatus"
if (-not (Test-Path -Path $LogDirectory -PathType Container)) {
    New-Item -Path $LogDirectory -ItemType Directory
}

$LogPath = "$LogDirectory\ProcessesCpuMemoryStatus.json"
$cpu     = Get-WmiObject -class Win32_processor -Property NumberOfCores, NumberOfLogicalProcessors
$mem     = (Get-CimInstance -class cim_physicalmemory | Measure-Object Capacity -Sum).Sum
$LogTime = Get-Date -Format "dd/MM/yyyy HH:mm"

# Create an array to store individual log entries
$logEntries = @()

Get-Process -IncludeUserName | ForEach-Object {
    if ($_.StartTime -gt 0) {
        $ts        = (New-TimeSpan -Start $_.StartTime -ErrorAction SilentlyContinue).TotalSeconds
        $cpuusage  = [Math]::Round($_.CPU * 100 / $ts / $cpu.NumberOfLogicalProcessors, 2)
        $starttime = $_.StartTime.ToString("dd/MM/yyyy HH:mm")
    } else {
        $cpuusage  = 0
        $starttime = 0
    }

    $memoryUsageMB     = [Math]::Round($_.WorkingSet / 1MB, 2)
    $memoryUsagePercent = [Math]::Round(($_.WorkingSet / $mem) * 100, 2)

    $logEntry = [PSCustomObject]@{
        "LogTime"     = $LogTime
        "CPU(%)"      = $cpuusage
        "CPU(s)"      = $_.CPU
        "Memory(%)"   = $memoryUsagePercent
        "Memory(MB)"  = $memoryUsageMB
        "ProcessName" = $_.ProcessName
        "ProcessID"   = $_.Id
        "UserName"    = $_.UserName
        "StartTime"   = $starttime
    }

    $logEntries += $logEntry
}

# Combine all individual log entries into a single JSON object
$logEntriesObject = $logEntries | ConvertTo-Json -Compress

# Write the JSON object to the log file (overwriting existing data)
$logEntriesObject | Out-File -FilePath $LogPath -Encoding UTF8 -Force
